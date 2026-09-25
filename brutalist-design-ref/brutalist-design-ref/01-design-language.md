# 01 · Design Language

## Philosophy

After/Dark is **club flyer in your pocket**. The aesthetic borrows from:
- 1990s Swiss & post-modern poster design
- Underground techno flyer print
- Fanzine / xerox texture
- Editorial magazine grids (i-D, Dazed, 032c)

It rejects:
- Soft, friendly, "consumer" UI tropes
- Glassmorphism, neumorphism, soft shadows
- Round corners, pill buttons, pastel gradients
- Apologetic, polite copy

## Do

✅ Sharp 90° corners. Radius **0** is the default; **2px** is the maximum.
✅ Pure black backgrounds (`#050505`) with paper-white text (`#F4F1EA`).
✅ Oversized display type — hero text should feel *too big*.
✅ Mono uppercase chrome labels with `0.12em` tracking.
✅ Color blocks as full surfaces — acid yellow CTAs, magenta hero panels.
✅ 1px hairlines (paper @ 8% opacity) to separate content.
✅ 2px solid borders in `neon` for emphasis.
✅ Asymmetric layouts. Negative space as a design element.
✅ Italic serif (Fraunces) for editorial accents — quotes, "by", "feat.".

## Don't

❌ No rounded cards (avoid `border-radius` > 2px).
❌ No gradients on UI surfaces (gradients only on placeholder images).
❌ No drop shadows on cards or buttons.
❌ No gray-on-gray hierarchies — use scale, weight, and color blocks instead.
❌ No emoji as UI affordance. Use mono ASCII glyphs (`◉ ◇ ★ ▸ ⌘`) sparingly.
❌ No "friendly" microcopy — no exclamation marks, no "Oops!", no "Yay".
❌ No system blue, no Material Design palette.
❌ No icons larger than the text they label.

## Voice

| Trait | Example |
|---|---|
| Direct | "TONIGHT · 14 OPEN" not "There are 14 venues open tonight!" |
| Concrete | "DOORS 22:00" not "Doors open in the evening" |
| Editorial | "feat. Honey Dijon" not "Featuring Honey Dijon" |
| Cool, never trying | "Sold out" not "🔥 Almost gone!!" |
| Mono labels are loud, body copy is quiet | `LIVE NOW` (uppercase mono) → "124 inside Womb" (sentence case) |

## Visual checklist

Before shipping a screen, ask:
1. Is anything rounded that shouldn't be?
2. Is the largest text big enough to feel *aggressive*?
3. Are mono labels uppercase and tracked?
4. Is there at least one full-color block on the screen?
5. Have I removed all unnecessary borders, shadows, and decorations?
6. Does the hierarchy work in pure black-and-white before color is added?
