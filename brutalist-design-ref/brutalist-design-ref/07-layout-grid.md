# 07 · Layout & Grid

## Phone canvas

- Reference width: **390px** (iPhone 15)
- Reference height: **844px**
- Safe area: 44px top status, 34px bottom indicator
- Working area: ~390 × 766

## Side margin

- Default screen padding: **16px** left & right
- Hero/full-bleed sections: 0px (intentional bleed)
- Avoid 12px or 20px — stick to 16 for rhythm

## Vertical rhythm

| Spacing | When |
|---|---|
| 8px | Inside a tight cluster (label → title) |
| 12px | Inside a card |
| 14px | Between list rows |
| 16px | Between cards |
| 24px | Between sections |
| 32px | Major section break |
| 48px | Above bottom-nav |

## Grid

The brutalist direction is **asymmetric, not column-based**. Don't impose a strict 4/8/12 column grid.

When you need structure:
- 2-up: 14fr / 10fr (golden-ish, unbalanced)
- 3-up: 1fr 1fr 1fr with 8px gap
- Hero + sidebar: 60% / 40% with 10px gap

## Density

Density is **medium-high**. The page should feel printed, packed, and intentional — not airy.

- Hero text occupies 50%+ of its container width
- Lists never have more than 14px row padding
- Cards never have more than 16px internal padding

## Bleed & overflow

- Tickers, marquees, and color blocks should bleed edge-to-edge (margin-left / margin-right negative the screen padding).
- Never indent a ticker — its edge bleed is the point.

## Hierarchy ladder

For any screen, the visual hierarchy should resolve in this order:

1. **One** oversized display title (the "shout").
2. **One** color block (the "anchor").
3. Mono labels (the "chrome").
4. Body content (the "substance").
5. Hairlines & dividers (the "frame").

If two elements compete for #1 or #2, kill one.

## Z-index

| Layer | z |
|---|---|
| Page content | 0 |
| Sticky header | 5 |
| Bottom nav | 10 |
| Bottom sheet | 20 |
| Modal | 30 |
| Toast | 40 |
| Tweaks panel (debug) | 50 |
