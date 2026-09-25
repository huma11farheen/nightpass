# 06 · Components

All components below assume tokens from `03-tokens.css` are loaded.
Specs are framework-agnostic — translate to your stack as needed.

---

## Button · Primary

**Anatomy:** Filled rectangle, no radius, mono uppercase label OR sentence-case sans bold.

```
Background:   --ad-neon (#FF1FA3)
Text:         --ad-ink-0
Padding:      14px 20px
Font:         Inter Tight 16/700  OR  JetBrains Mono 11/700/0.12em uppercase
Radius:       0
Border:       none
Hover:        background → --ad-neon-hot
Pressed:      background → --ad-neon-deep
Disabled:     background → --ad-ink-3, text → --ad-paper-mute
```

**Variant — Acid:** background `--ad-acid`, text `--ad-ink-0`. Use for "tonight only" / urgency.

**Variant — Ghost:** transparent background, `1px solid --ad-paper`, text `--ad-paper`. Secondary CTA.

---

## Button · Mono ticker (uppercase chip)

```
Background:   transparent
Border:       1px solid rgba(244,241,234,0.14)
Text:         --ad-paper / mono / 11/700/0.12em
Padding:      8px 14px
Radius:       0
Active:       background --ad-acid, text --ad-ink-0, border --ad-acid
```

---

## Card · Editorial

**Default = no card.** Use a 1px hairline divider above + below to group.
Only use a filled card when content needs to break the page rhythm.

```
Background:   --ad-ink-2
Border:       --ad-border-hairline
Radius:       0  (NEVER round)
Padding:      16px
```

**Featured/hero card:**
```
Background:   --ad-neon-deep (#C41284) OR placeholder gradient
Border:       --ad-border-emphasis  (2px solid --ad-neon)
Padding:      14px
Min height:   280px
Layout:       label top-left, title bottom-left, action bottom-right
```

---

## Hairline divider

```
border-top: 1px solid rgba(244, 241, 234, 0.08);
margin: 14px 0;
```

For section breaks, use a 2px paper border instead of 1px hairline.

---

## Input · Search bar

**Inverted (paper on ink):**
```
Background:   --ad-paper
Text input:   --ad-ink-0 / 14/500
Placeholder:  rgba(0,0,0,0.4)
Padding:      14px 16px
Radius:       0
Adornment:    JetBrains Mono "⌘K" chip — bg ink-0, text acid
```

**Dark input:**
```
Background:   --ad-ink-3
Border:       1px solid --ad-ink-4
Text:         --ad-paper
Padding:      14px 16px
Radius:       0
```

---

## Bottom Navigation

**Brutalist nav (recommended):**
```
Position:     fixed, 16px from edges, 16px from bottom
Height:       56px
Background:   --ad-ink-0
Border:       none
Radius:       0
Items:        flex 1 each
Item label:   JetBrains Mono 10/700/0.12em uppercase
Item color:   --ad-paper (active: --ad-neon)
Separator:    1px solid --ad-paper between items
```

No icons in the brutalist nav — labels only. If icons are needed, use stroked monoline 16×16, paper color.

---

## Mono Label (chrome)

The most-used component. Wraps section labels, statuses, timestamps.

```
Family:       JetBrains Mono
Size:         11px (10px if tight)
Weight:       700
Tracking:     0.12em
Case:         UPPERCASE
Color:        --ad-paper-mute (chrome) | --ad-neon (live) | --ad-acid (urgent)
```

Examples:
```
TONIGHT · 14 OPEN
DOORS · 22:00
LIVE · 124 INSIDE
SAT 25 · ¥2000
```

---

## Status dot

```
Diameter:     6px
Background:   --ad-neon (live) | --ad-acid (warning) | --ad-paper-mute (default)
Animation:    pulse keyframes — opacity 1 → 0.3 → 1, 1.6s ease-in-out infinite
```

---

## Ticker / Marquee

Horizontal scrolling text strip. Used for breaking news / urgency.

```
Height:        28px
Background:    --ad-neon OR --ad-acid
Text:          --ad-ink-0 / mono 11/700/0.12em uppercase
Animation:     translateX(0 → -50%) 40s linear infinite
Content:       duplicate inner string twice for seamless loop
Separator:     " · " between items
```

---

## Event row (list item)

```
Layout:        | DAY | TITLE + meta              | PRICE |
Padding:       14px 0
Top border:    1px solid rgba(255,255,255,0.08)  (first row: 2px paper)
Day cell:
  Width:       54px
  Right border: 2px solid <accent>
  DAY:         mono 10/700, color = accent
  NUMBER:      Bricolage 24/800
Title:         Inter Tight 16/600 paper
Meta:          mono 10/700/0.12em paper-mute
Price:         Bricolage 20/600 paper
```

---

## Chip (filter)

```
Padding:       8px 14px
Border:        1px solid rgba(255,255,255,0.14)
Background:    transparent
Text:          mono 11/700/0.12em uppercase, paper-dim
Radius:        0
Active:
  Background:  --ad-acid (or --ad-neon)
  Border:      same as background
  Text:        --ad-ink-0
```

---

## Bottom sheet

```
Background:    --ad-ink-1
Border-top:    --ad-border-emphasis  (2px solid --ad-neon)
Radius:        0  (no rounded top — break the convention)
Padding:       20px
Drag handle:   4px × 36px, --ad-paper-mute, top: 8px, centered
```

---

## Modal / Dialog

```
Backdrop:      rgba(5,5,5,0.85)
Surface:       --ad-ink-1
Border:        --ad-border-paper  (1px solid paper)
Radius:        0
Width:         min(360px, 90vw)
Padding:       24px
Title:         Bricolage 26/800/-0.02em
Body:          Inter Tight 14/500
Actions:       right-aligned, 8px gap
```

---

## Image placeholder

When real imagery isn't available:
```
Background:    diagonal stripes + linear-gradient between two cool tones
Foreground:    mono 10/700/0.12em label e.g. "VENUE · 01"
```

See `styles.css` `.ph` family for ready-made gradients.

---

## Toast / Inline notice

```
Height:        44px
Background:    --ad-ink-0
Border:        2px solid --ad-acid (or --ad-neon for error)
Padding:       0 16px
Text:          mono 11/700/0.12em uppercase, --ad-paper
Position:      top of viewport, slides in from above 240ms ease-out
Duration:      4s, dismiss with translateY(-100%)
```
