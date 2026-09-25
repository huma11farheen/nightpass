# 04 · Typography

## Type families (4 total)

| Role | Family | Fallback | Where to use |
|---|---|---|---|
| **Display** | Bricolage Grotesque | Archivo, sans-serif | All hero & section titles |
| **Sans** | Inter Tight | Inter, system-ui | Body copy, UI labels |
| **Serif italic** | Fraunces (italic only) | Playfair, Georgia | Editorial accents — "by", "feat.", quotes |
| **Mono** | JetBrains Mono | IBM Plex Mono | Uppercase chrome labels, timestamps, prices |

### Loading (Google Fonts)

```html
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link
  href="https://fonts.googleapis.com/css2?family=Bricolage+Grotesque:opsz,wght@10..48,400;10..48,600;10..48,800&family=Fraunces:ital,opsz,wght@1,9..144,400;1,9..144,600&family=Inter+Tight:wght@400;500;600;700&family=JetBrains+Mono:wght@500;700&display=swap"
  rel="stylesheet">
```

## Scale

| Token | Size | Weight | Tracking | Leading | Family | Use |
|---|---|---|---|---|---|---|
| `hero` | 92px | 800 | -0.04em | 0.85 | display | Onboarding / landing hero |
| `display` | 72px | 800 | -0.04em | 0.85 | display | "Where to / tonight?" |
| `title` | 44px | 800 | -0.03em | 0.9 | display | Section/event titles |
| `section` | 26px | 700 | -0.02em | 1 | display | Sub-sections, "This week" |
| `body-lg` | 16px | 500 | 0 | 1.4 | sans | Default body, list items |
| `body` | 14px | 500 | 0 | 1.4 | sans | Secondary copy |
| `body-sm` | 13px | 500 | 0 | 1.4 | sans | Captions |
| `label` | 11px | 700 | 0.12em | 1 | mono | Chrome labels (uppercase) |
| `label-sm` | 10px | 700 | 0.12em | 1 | mono | Tight chrome labels |
| `serif-italic` | 13–18px | 400 | 0 | 1.3 | serif | Italic editorial accents |

## Weight rules

- **Display: only 800.** Never use 600 or lower for hero/title type — it dilutes the brutalist feel.
- **Sans: 500 default, 600 for emphasis, 700 only for very small UI text.** Avoid 400 for body — looks weak on dark.
- **Mono: 700 always.** Never use mono at regular weight.
- **Serif: 400 italic only.** Never use Fraunces upright in this system.

## Pairings

```
H1 (display)   "Where to tonight?"            ← Bricolage 72/800/-0.04em
Mono label    "TONIGHT · 14 OPEN"             ← JetBrains Mono 11/700/0.12em
Serif italic  "by Honey Dijon"                ← Fraunces 13/400/italic
Body          "Doors at 22:00 · ¥3000"        ← Inter Tight 14/500
```

## Examples

### Hero title
```css
font-family: var(--ad-font-display);
font-size: var(--ad-size-display);
font-weight: 800;
letter-spacing: var(--ad-tracking-tight);
line-height: var(--ad-leading-display);
color: var(--ad-paper);
```

### Mono label
```css
font-family: var(--ad-font-mono);
font-size: var(--ad-size-label);
font-weight: 700;
letter-spacing: var(--ad-tracking-label-lg);
text-transform: uppercase;
color: var(--ad-paper-mute);
```

### Editorial accent
```css
font-family: var(--ad-font-serif);
font-style: italic;
font-weight: 400;
font-size: 13px;
color: var(--ad-paper-dim);
```

## Capitalization

| Element | Case |
|---|---|
| Display titles | Sentence case ("Where to tonight?") |
| Mono labels | UPPERCASE ("TONIGHT · 14 OPEN") |
| Body | Sentence case |
| Buttons | Sentence case ("Get tickets") OR UPPERCASE mono ("BUY · ¥3000") — pick one per screen |
| Editorial accents | Lowercase ("feat. honey dijon") |

## Color × type

- Body on `--ad-ink-0`: always `--ad-paper`.
- Mono labels: always `--ad-paper-mute` (never paper).
- Title on color block (`--ad-acid`/`--ad-neon`): always `--ad-ink-0`.
- Italic serif on `--ad-paper-dim` for editorial humility.
