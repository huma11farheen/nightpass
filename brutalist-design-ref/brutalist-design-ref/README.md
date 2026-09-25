# Brutalist Design Reference — After/Dark

A complete design language for porting the brutalist nightlife direction into any codebase.
Framework-agnostic: tokens, type, components, motion, copy, voice.

## Files

| File | What it's for |
|---|---|
| `01-design-language.md` | Philosophy, do's & don'ts, voice |
| `02-tokens.json` | Design tokens (colors, type, spacing, motion) — JSON for tooling |
| `03-tokens.css` | Same tokens as CSS custom properties — drop into any CSS file |
| `04-typography.md` | Type scale, weights, pairings, examples |
| `05-color-system.md` | Palette logic, usage rules, accessibility |
| `06-components.md` | Component specs (buttons, cards, nav, ticker, etc.) |
| `07-layout-grid.md` | Grid, spacing, density rules |
| `08-motion.md` | Easings, durations, the "ticker" pattern |
| `09-iconography.md` | Icon style, sizes, mono labels |
| `10-copy-voice.md` | Tone, capitalization, copy patterns |
| `swatches.html` | Visual palette + type specimen, openable in any browser |

## Quick start

1. Drop `03-tokens.css` into your global stylesheet — all tokens are now CSS vars.
2. Use `02-tokens.json` if you have a token pipeline (Style Dictionary, Tailwind config, etc.).
3. Read `01-design-language.md` first to understand the *why*.
4. Open `swatches.html` in a browser to see the system.

## Design pillars

1. **High contrast, no gradients.** Pure black, paper white, electric magenta.
2. **Sharp corners.** Radius 0 or 2px max. No soft cards.
3. **Oversized display type.** Hero text 72–96px, tight tracking, tight leading.
4. **Mono labels.** Uppercase, letter-spaced, used as wayfinding chrome.
5. **Color as block, not decoration.** Acid yellow / magenta / cyan as full-bleed surfaces.
6. **Editorial rhythm.** Mix display sans + italic serif. Asymmetric grids.
