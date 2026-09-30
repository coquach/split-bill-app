# SplitPay — split-bill-app

An iOS app for splitting bills: pick a past transfer, divide it among
participants, share a QR for everyone to repay, and track who has paid.

## Requirements

- Xcode 26+ (Swift 6.2 toolchain)
- iOS 17+ deployment target
- An iOS simulator (iPhone 17 Pro or newer) for the feature-package tests

## Project layout

The app is a plain Xcode project (app target: `SplitPay`) plus a set of local
SwiftPM packages — every feature and foundation layer builds and tests on its
own:

```
├── SplitPay.xcodeproj        # App target only; thin shell over the packages
├── SplitPay/                 # App entry point, DI wiring
├── Core/
│   └── CommonUi/             # Shared SwiftUI pieces (AppAlert, skeletons…)
├── Foundation/
│   ├── Domains/              # Models, DomainError, SplitCalculator, SessionStore,
│   │                         # repository protocols (I*Repository)
│   ├── DomainDatas/          # Supabase-backed repository implementations,
│   │                         # Postgres decoding, error mapping
│   ├── Network/              # APIEndpoint / HTTP plumbing
│   ├── Router/               # NavigationPath-based routing
│   ├── Utils/                # Formatting helpers (DateFormatting…)
│   ├── Loggers/              # Logging
│   └── SystemDesign/         # Design system (SwiftUI/UIKit components, QR card)
├── Features/
│   ├── Authentication/       # Login / register (validators + view models)
│   ├── Home/                 # Dashboard: profile, wallet, recent transfers
│   ├── Transfer/             # Transfer flow, history, transaction detail
│   ├── SplitBill/            # Split setup, QR flow, history, repay by scan
│   └── Profile/              # Profile, PIN setup/change, sign out
├── design/                   # Design references
├── SplitPayUITests/          # XCUITest suite (mock backend, one launch per test)
├── swiftgen.yml              # Generated asset constants (SystemDesign)
└── scripts/                  # run_tests.sh (unit), run_ui_tests.sh (UI)
```

### Architecture notes

- **MVVM + Coordinator.** View models are `@MainActor @Observable` classes;
  features own their coordinators for navigation.
- **Dependency injection via protocols.** Every feature depends only on the
  `I*Repository` protocols declared in `Domains` — the Supabase
  implementations live in `DomainDatas` and are wired up in the app target.
  This is what makes the view models testable with hand-written mocks.
- **Money is `Amount`, not `Int64`.** Split shares divide to fractional dong
  (40 / 3 = 13.333); `SplitCalculator` rounds to 2 decimals and lets the
  requester absorb the remainder so the parts always add back to the total.
- **Errors are `DomainError`.** Postgres/Supabase failures are mapped to
  typed, user-facing cases in `DomainDatas` (`RepositoryErrorMapper`); every
  case carries a displayable `message` through `LocalizedError`.

## Running the tests

The suite uses [Swift Testing](https://developer.apple.com/xctest/) (`@Test`,
`#expect`) throughout — there is no XCTest.

```bash
./scripts/run_tests.sh
```

This runs every package and prints a PASS/FAIL summary; it exits non-zero if
anything failed. One failing package never stops the others.

- `Foundation/{Utils,Network,Router,Domains}` test on the macOS host
  (`swift test` — fast, no simulator needed).
- `Core/CommonUi` and the five `Features/*` packages import `SystemDesign`,
  so they test in the iOS simulator (`xcodebuild test`). The script picks the
  booted simulator, falling back to the first available iPhone.

Useful variations:

```bash
./scripts/run_tests.sh Transfer                  # only packages matching a name
SIM_DESTINATION="platform=iOS Simulator,name=iPhone 17 Pro" ./scripts/run_tests.sh

# Single package while iterating:
cd Foundation/Domains && swift test
cd Features/Transfer && xcodebuild test -scheme Transfer \
    -destination "platform=iOS Simulator,name=iPhone 17 Pro"
```

## Test conventions

- **One file per subject**, named `XxxTests.swift`; test names are sentences
  (`theFormIsInvalidWhenTheAmountExceedsTheBalance`), not `testXxx`.
- **Hand-written mocks per package** in `Tests/<Pkg>Tests/Mocks/` — no shared
  mock library (SPM has no dev-dependencies). Mocks are `final class …
  @unchecked Sendable`, record call counts and last arguments, and can gate a
  call behind a continuation to test reentrancy guards.
- **Fixtures** live in a per-target `Fixtures.swift` with `makeXxx(…)`
  builders using default arguments.
- **Locale-safe assertions.** Formatted strings are asserted structurally
  (sign, `"VND"` suffix, `contains`) or compared against an identically
  configured formatter — never pinned to one locale's separators. Date
  grouping uses an injected `Calendar`.
- **Debounce is testable** because `TransferFlowViewModel.accountLookupDebounce`
  is a public constant tests sleep on.

Deliberately not tested: `qrImage` (UIImage rendering), idempotency-key
rotation (private, no seam — noted in the relevant test files), the
Supabase data layer over the network, and SwiftUI views.

## UI tests (XCUITest)

The unit tests above mock the view models; `SplitPayUITests` drives the real
app on the simulator — navigation, forms, multi-screen flows.

```bash
./scripts/run_ui_tests.sh                 # whole suite
./scripts/run_ui_tests.sh TransferTests   # one class
```

### How it runs

- **Mock backend.** Every test launches the app with `-UITest`, which swaps
  the DI container's Supabase assemblies for in-memory mock repositories
  (`SplitPay/UITestSupport/`, all `#if DEBUG`). No account, credentials or
  network involved, and each test gets a fresh store.
- **Deterministic data.** `UITestSeedData` serves two datasets (`empty`,
  `default`) plus "magic values" the mocks react to: `fail@test.com` fails
  auth, `000000` fails PIN verification, account `000000` fails wallet
  lookup. The tests and the seed data are one contract — change them
  together.
- **Failure injection.** `UITEST_SCENARIO` (`history-fails`, `otp-fails`,
  `qr-decode-fails`) makes individual repository calls throw.
- **Scanner seam.** The repay flow needs a camera; under `-UITest` the
  scanner is replaced with a canned QR payload injected through
  `SplitBillCoordinator.Dependencies` and fed through the real decode path.
- **Identifiers.** All queried elements expose accessibility identifiers
  from `SystemDesign`'s `UITestID` registry; AppModal overlays are queried
  by identifier (not `app.alerts`, which only sees system alerts).
- **One launch per test** via the `UITestCase` base class; waits use
  `waitForExistence`, never sleeps.

Two real bugs surfaced while writing the suite (both fixed):
`Split Bill` from a Transaction Detail in the History tab presented nothing
(its `fullScreenCover` modifier lived inside an un-presented cover), and the
error modal's buttons were unreachable to XCUITest once the modal container
carried an identifier (fixed with `accessibilityElement(children: .contain)`).
