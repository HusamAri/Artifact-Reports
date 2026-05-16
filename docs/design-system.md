# Design System

Reference image: dark-themed mobile dashboard with rounded card blocks,
chip-style filter row, big KPI numbers.

## Color tokens

| Token | Hex | Usage |
|---|---|---|
| `bg.canvas` | `#0B0B0E` | App background |
| `bg.surface` | `#1A1A1F` | Card surface (neutral) |
| `accent.violet` | `#A855F7` | Hero card (e.g. "View presentation") |
| `accent.yellow` | `#F5D547` | Highlight card (e.g. "Case Studies") |
| `accent.white` | `#FFFFFF` | Neutral KPI card |
| `text.primary` | `#FFFFFF` | Headings on dark |
| `text.secondary` | `#A1A1AA` | Subtext |
| `text.onAccent` | `#0B0B0E` | Text on white/yellow cards |
| `chip.bg.muted` | `#2A2A30` | Inactive chip |
| `chip.bg.active` | `#FFFFFF` | Active chip |

## Typography

- Display: SF Pro Display, weight 700, size 32 (KPI section header)
- Headline: SF Pro Display, weight 600, size 22 (card title)
- Title: SF Pro Text, weight 600, size 17
- Body: SF Pro Text, weight 400, size 15
- Caption: SF Pro Text, weight 500, size 12 (subtle label like "made by ...")
- Number: SF Pro Display, weight 700, size 40 (big KPI numbers)

## Shape tokens

- `radius.card` = 28
- `radius.chip` = 999
- `radius.iconButton` = 20

## Card patterns (referans görsel)

1. **Hero card** — single column, accent color background, title + arrow icon.
2. **KPI duo** — two cards side-by-side, small label + huge number.
3. **CTA card** — full-width neutral dark card with title + arrow icon.
4. **Filter row** — horizontal scroll of pill chips, one active (light bg).

Flutter widgets land in `app/lib/core/widgets/` (M4):
- `KpiCard`
- `HeroCard`
- `CtaCard`
- `FilterChipRow`
- `StatGrid`
