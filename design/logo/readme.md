# SplitPay — app icon "Converge" (option 1c)

Three solid nodes (the group) feeding one central hub; the hub carries a knocked-out
send-arrow, so repayment reads as flowing back in.

## Colors
- Primary gradient: #4D6BFF -> #263DD1, linear, top-left to bottom-right (userSpaceOnUse 0,0 -> 1024,1024)
- Neutral dark background: #16161D
- Mark on blue: #FFFFFF

## Geometry
- Canvas 1024 x 1024, square corners (OS applies the mask)
- Artwork sits inside the ~15% safe area (content bounds 191 - 833)
- Single path, fill-rule nonzero; the arrow is a real knockout, so the logomark works on any ground

## Files
svg/
  icon-blue-1024.svg    app icon, gradient background
  icon-dark-1024.svg    app icon, #16161D background
  logomark-gradient.svg transparent logomark, gradient fill
  logomark-white.svg    transparent logomark, white fill (for dark/photo grounds)
  logomark-dark.svg     transparent logomark, #16161D fill (for light grounds)
  lockup-light.svg      logomark + "SplitPay" for light grounds
  lockup-dark.svg       logomark + "SplitPay" for dark grounds
png/
  icon-blue-*.png       1024 / 512 / 180 / 120 / 80 / 48 / 24
  icon-dark-1024.png
  logomark-gradient-1024.png  transparent
  logomark-white-1024.png     transparent

## Notes
- Wordmark is set in Outfit SemiBold (600), -0.02em tracking. The lockup SVGs use live
  text, not outlines — either install Outfit or convert to outlines before handoff.
- Minimum clear space around the lockup: the height of the logomark's central hub.
- Do not recolor the mark outside the palette above; do not add shadows or strokes.
