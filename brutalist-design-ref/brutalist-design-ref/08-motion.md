# 08 · Motion

Brutalist motion is **mechanical, not bouncy**. No spring physics. No overshooting. Things snap into place.

## Durations

| Token | ms | When |
|---|---|---|
| `--ad-dur-instant` | 80 | Color flips, toggle states |
| `--ad-dur-fast` | 150 | Hover, press feedback |
| `--ad-dur-base` | 240 | Page/sheet transitions, reveals |
| `--ad-dur-slow` | 400 | Onboarding sequences only |
| `--ad-dur-ticker` | 40000 | Marquee scroll loop |

## Easings

| Token | Curve | When |
|---|---|---|
| `--ad-ease-out` | `cubic-bezier(0.2, 0.8, 0.2, 1)` | Default — entering elements |
| `--ad-ease-in` | `cubic-bezier(0.4, 0, 1, 1)` | Exiting elements |
| `--ad-ease-in-out` | `cubic-bezier(0.4, 0, 0.2, 1)` | Layout shifts |
| `linear` | linear | **Ticker only** |

## Patterns

### Page transition (push)
```
new-page:  translateX(100% → 0)   240ms ease-out
old-page:  translateX(0 → -20%)   240ms ease-out (parallax)
```

### Bottom sheet
```
sheet:     translateY(100% → 0)   240ms ease-out
backdrop:  opacity 0 → 1          240ms linear
```

### Hover (web prototypes)
```
button: background-color 150ms ease-out
```

### Press
```
scale(1 → 0.97)   80ms ease-in
release: scale(0.97 → 1)   150ms ease-out
```
*Use scale only on primary CTAs. Never on cards or list rows.*

### Live dot pulse
```
@keyframes pulse {
  0%, 100% { opacity: 1; }
  50%      { opacity: 0.3; }
}
animation: pulse 1.6s ease-in-out infinite;
```

### Ticker
```
@keyframes tick {
  from { transform: translateX(0); }
  to   { transform: translateX(-50%); }
}
animation: tick 40s linear infinite;
```

## Don'ts

❌ **No spring physics** (overshooting, bouncing, settling). Mechanical, not playful.
❌ **No fade-only transitions.** Always pair fade with slide or scale.
❌ **No stagger animations on list rows.** Rows appear instantly when their page resolves.
❌ **No parallax on photo backgrounds.** Distracting on a brutalist page.
❌ **No scroll-jacked animations.** Scrolling is the user's domain.

## Reduced motion

When `prefers-reduced-motion: reduce`:
- Ticker stops, content stays visible (don't hide it).
- All transitions drop to opacity-only at 80ms.
- Live-dot pulse stops; dot stays at full opacity.
