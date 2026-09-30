-- Migration: transfer idempotency race fix + PIN lockout
-- Fixes:
--   1. create_transfer idempotency was check-then-insert without a unique
--      constraint: two concurrent requests with the same key could both pass
--      the check and double-transfer. repayments/split_bills already enforce
--      this at the DB level; transfer_transactions was the only gap.
--   2. PIN verification had no attempt tracking or lockout. The client already
--      maps PIN_LOCKED / PIN_NOT_SET error tokens, so this is server-side only.
--      After MAX_PIN_ATTEMPTS consecutive failures the PIN locks for
--      PIN_LOCK_MINUTES; a successful verification resets the counter.

-- ------------------------------------------------------------------
-- 1. Transfer idempotency — enforce uniqueness at the DB level
-- ------------------------------------------------------------------
create unique index if not exists uq_transfers_sender_idempotency
    on public.transfer_transactions (sender_user_id, idempotency_key)
    where idempotency_key is not null;

-- ------------------------------------------------------------------
-- 2a. PIN attempt tracking columns
-- ------------------------------------------------------------------
alter table public.profiles
    add column if not exists pin_failed_attempts integer not null default 0,
    add column if not exists pin_locked_until timestamptz;

-- ------------------------------------------------------------------
-- 2b. verify_pin — lockout + PIN_NOT_SET distinction
--
-- Behavior change: a profile without a PIN now raises PIN_NOT_SET instead of
-- silently returning false (which surfaced to users as INVALID_PIN).
-- Callers (create_transfer, create_qr_repayment, repay_split_bill) propagate
-- the exception, so the client shows the mapped PIN_NOT_SET / PIN_LOCKED
-- messages with no client changes.
-- ------------------------------------------------------------------
create or replace function public.verify_pin(p_pin text)
 returns boolean
 language plpgsql
 set search_path to 'public', 'extensions', 'pg_temp'
as $function$
declare
    v_pin_hash text;
    v_attempts integer;
    v_locked_until timestamptz;
begin

    if p_pin !~ '^[0-9]{6}$' then
        return false;
    end if;

    select pin_hash, pin_failed_attempts, pin_locked_until
    into v_pin_hash, v_attempts, v_locked_until
    from public.profiles
    where id = auth.uid()
    for update;

    if v_pin_hash is null then
        raise exception 'PIN_NOT_SET';
    end if;

    if v_locked_until is not null and v_locked_until > now() then
        raise exception 'PIN_LOCKED';
    end if;

    if crypt(p_pin, v_pin_hash) = v_pin_hash then
        update public.profiles
        set
            pin_failed_attempts = 0,
            pin_locked_until = null,
            updated_at = now()
        where id = auth.uid();

        return true;
    end if;

    -- Wrong PIN: count the attempt, lock after MAX_PIN_ATTEMPTS (5).
    -- The lock is SET here and the NEXT call raises PIN_LOCKED — raising in
    -- the same transaction would roll back the lock update itself.
    if v_attempts + 1 >= 5 then
        update public.profiles
        set
            pin_failed_attempts = 0,
            pin_locked_until = now() + interval '15 minutes',
            updated_at = now()
        where id = auth.uid();

        return false;
    end if;

    update public.profiles
    set
        pin_failed_attempts = pin_failed_attempts + 1,
        updated_at = now()
    where id = auth.uid();

    return false;
end;
$function$;

-- ------------------------------------------------------------------
-- 2c. change_pin — wrong current PIN counts toward lockout,
--     successful change resets failed attempts
-- ------------------------------------------------------------------
create or replace function public.change_pin(p_current_pin text, p_new_pin text)
 returns boolean
 language plpgsql
 set search_path to 'public', 'extensions', 'pg_temp'
as $function$
DECLARE
    v_pin_hash text;
    v_attempts integer;
    v_locked_until timestamptz;
BEGIN

    -- Validate current PIN
    IF p_current_pin !~ '^[0-9]{6}$' THEN
        RAISE EXCEPTION 'Current PIN must contain exactly 6 digits';
    END IF;

    -- Validate new PIN
    IF p_new_pin !~ '^[0-9]{6}$' THEN
        RAISE EXCEPTION 'New PIN must contain exactly 6 digits';
    END IF;

    -- Get current PIN state
    SELECT pin_hash, pin_failed_attempts, pin_locked_until
    INTO v_pin_hash, v_attempts, v_locked_until
    FROM public.profiles
    WHERE id = auth.uid()
    FOR UPDATE;

    IF v_pin_hash IS NULL THEN
        RAISE EXCEPTION 'PIN has not been configured';
    END IF;

    IF v_locked_until IS NOT NULL AND v_locked_until > now() THEN
        RAISE EXCEPTION 'PIN_LOCKED';
    END IF;

    -- Verify current PIN. A wrong current PIN counts toward lockout; the
    -- lock is SET on the 5th failure and the NEXT call raises PIN_LOCKED.
    IF crypt(p_current_pin, v_pin_hash) <> v_pin_hash THEN
        IF v_attempts + 1 >= 5 THEN
            UPDATE public.profiles
            SET
                pin_failed_attempts = 0,
                pin_locked_until = now() + interval '15 minutes',
                updated_at = now()
            WHERE id = auth.uid();
        ELSE
            UPDATE public.profiles
            SET
                pin_failed_attempts = pin_failed_attempts + 1,
                updated_at = now()
            WHERE id = auth.uid();
        END IF;

        RAISE EXCEPTION 'Current PIN is incorrect';
    END IF;

    -- Prevent using the same PIN
    IF crypt(p_new_pin, v_pin_hash) = v_pin_hash THEN
        RAISE EXCEPTION 'New PIN must be different from current PIN';
    END IF;

    -- Update PIN and reset failed attempts
    UPDATE public.profiles
    SET
        pin_hash = crypt(p_new_pin, gen_salt('bf')),
        pin_failed_attempts = 0,
        pin_locked_until = null,
        updated_at = now()
    WHERE id = auth.uid();

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Profile not found';
    END IF;

    RETURN true;

END;
$function$;
