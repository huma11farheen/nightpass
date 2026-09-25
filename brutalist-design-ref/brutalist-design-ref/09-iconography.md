# 09 · Iconography

## Stance

Icons are **secondary** in this system. Whenever possible, use a mono label instead of an icon.

> A label says "TICKETS · 3". An icon says "🎟️". The label wins.

## When to use icons

- Where labels would be redundant (e.g. heart on a card, search field)
- Where international users would appreciate a glyph
- Bottom nav — but only as a *supplement* to the mono label, never replacing it

## Style

| Property | Value |
|---|---|
| Stroke | Monoline, 1.5px |
| Fill | None (outline only) |
| Corners | Sharp; 1px corner radius max |
| Family | Lucide, Phosphor (regular weight), or hand-drawn matching |
| Size | 16px (UI), 18px (nav), 20px (header) |

Avoid filled, rounded, or color icons. No glyph-style or "duotone" icons.

## Mono ASCII glyphs

These are preferred over icons in many cases — render in JetBrains Mono and they read as native chrome:

| Glyph | Use |
|---|---|
| `◉` | Live, current, focused |
| `◇` | Inactive, available |
| `★` | Featured, highlight |
| `▸` | Forward, more |
| `◂` | Back |
| `⌘` | Keyboard hint |
| `·` | Separator |
| `→` `←` `↑` `↓` | Direction |
| `─` | Horizontal rule (in mono context) |

Example:
```
◉ LIVE · 124 INSIDE
★ TONIGHT · 14 OPEN
TICKETS · 3 ▸
```

## Color rules for icons

- Default icon color: `--ad-paper-mute`
- Active/selected: `--ad-neon` or `--ad-paper`
- Never apply gradients or strokes-with-fills to icons.

## Sizing in lockup

When an icon sits next to text, the icon's optical height should be **80% of the cap height** of the adjacent text. Easier rule: 16px icon next to 14–16px text.
