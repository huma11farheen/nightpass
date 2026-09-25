# 05 · Color System

## The palette in one paragraph

Pure **black** stage. **Paper** text. One **electric magenta** primary. One **acid yellow** for shock contrast. One **cyan** for cool support. Everything else is grayscale ink. No gradients on UI.

## Surfaces (Ink)

| Token | Hex | Use |
|---|---|---|
| `--ad-ink-0` | `#050505` | App background. Default everything. |
| `--ad-ink-1` | `#0A0A0B` | Bottom-sheet, modal background. |
| `--ad-ink-2` | `#121214` | Card surface. Use sparingly — prefer no card at all. |
| `--ad-ink-3` | `#1A1A1D` | Elevated surface, input field background. |
| `--ad-ink-4` | `#242428` | Hover state on dark surfaces. |
| `--ad-ink-5` | `#3A3A40` | Dividers on dark, disabled state. |

## Text (Paper)

| Token | Hex | Use |
|---|---|---|
| `--ad-paper` | `#F4F1EA` | Primary text, headings. **Note:** warm off-white, not pure white. |
| `--ad-paper-dim` | `#B8B4AC` | Secondary text, captions. |
| `--ad-paper-mute` | `#7A7770` | Mono labels, timestamps, tertiary copy. |

## Accents

| Token | Hex | Role | Coverage |
|---|---|---|---|
| `--ad-neon` | `#FF1FA3` | Primary CTA, "live", emphasis | ≤ 15% of viewport |
| `--ad-neon-hot` | `#FF4DC0` | Hover state on neon | — |
| `--ad-neon-deep` | `#C41284` | Pressed/active on neon | — |
| `--ad-acid` | `#E6FF3A` | Secondary CTA, urgency, "tonight only" | ≤ 10% of viewport |
| `--ad-cyan` | `#6DF7FF` | Info, capacity, supporting accent | ≤ 5% of viewport |

## Usage rules

1. **One hero accent per screen.** Pick neon OR acid as the dominant color. Don't compete.
2. **Cyan is supporting.** Never use cyan as a primary CTA.
3. **Color = block.** Apply accents as solid full-width or full-block fills, not as 1px borders. Borders are paper or paper @ 8% opacity.
4. **No gradients on UI.** Gradients only allowed on placeholder/photo backgrounds.
5. **Color text on color block.** When text sits on `--ad-acid` or `--ad-neon`, use `--ad-ink-0`. Never paper on neon.
6. **Status colors are semantic, not decorative.** A red dot means "live". Don't add reds for vibe.

## Accessibility (contrast)

| Pair | Ratio | AA Body | AA Large |
|---|---|---|---|
| `paper` on `ink-0` | 14.8:1 | ✅ | ✅ |
| `paper-dim` on `ink-0` | 9.2:1 | ✅ | ✅ |
| `paper-mute` on `ink-0` | 4.9:1 | ✅ | ✅ |
| `ink-0` on `neon` | 5.7:1 | ✅ | ✅ |
| `ink-0` on `acid` | 14.1:1 | ✅ | ✅ |
| `paper-mute` on `ink-2` | 4.4:1 | ⚠️ Large only | ✅ |

**Rule:** never use `paper-mute` for body text smaller than 14px. It's for labels.

## Combos that work

```
ink-0 background + paper text + neon CTA
ink-0 background + paper text + acid block (full-bleed)
acid block + ink-0 text + ink-0 ticker beneath
neon block + ink-0 text + paper-dim caption
```

## Combos to avoid

```
❌ neon on acid (vibrating, illegible)
❌ cyan on paper (low contrast)
❌ paper on cyan (low contrast)
❌ neon-deep as a primary surface (too murky)
❌ multiple accents on the same screen
```
