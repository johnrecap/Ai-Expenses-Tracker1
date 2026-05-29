# Design System

## Source

Primary reference:

- `stitch_ai_expenses_tracker_pro/lumina_finance/DESIGN.md`

Secondary references:

- Repeated Tailwind config blocks inside `code.html` files.
- `screen.png` exports for visual spacing, glass effects, and composition.

## Design Principles

- Native Flutter only.
- Mobile-first financial clarity.
- Soft glass surfaces with restrained depth.
- Repeated components over one-off screen copies.
- No single-hue UI: use cyan/teal as primary, magenta/violet as secondary AI
  accents, and neutral surfaces as the dominant base.
- Text must fit at 360x800, 375x812, and 390x844.
- Letter spacing in Flutter should be `0`; Stitch negative and uppercase
  tracking values should be normalized for readability and consistency.

## Color Tokens

Create `AppColors` and a `ThemeExtension` for custom colors.

| Token | Hex |
| --- | --- |
| `surface` | `#F7F9FB` |
| `surfaceDim` | `#D8DADC` |
| `surfaceBright` | `#F7F9FB` |
| `surfaceContainerLowest` | `#FFFFFF` |
| `surfaceContainerLow` | `#F2F4F6` |
| `surfaceContainer` | `#ECEEF0` |
| `surfaceContainerHigh` | `#E6E8EA` |
| `surfaceContainerHighest` | `#E0E3E5` |
| `surfaceVariant` | `#E0E3E5` |
| `background` | `#F7F9FB` |
| `onSurface` | `#191C1E` |
| `onSurfaceVariant` | `#3B494C` |
| `outline` | `#6B7A7D` |
| `outlineVariant` | `#BAC9CC` |
| `primary` | `#006875` |
| `onPrimary` | `#FFFFFF` |
| `primaryContainer` | `#00E5FF` |
| `onPrimaryContainer` | `#00626E` |
| `primaryFixed` | `#9CF0FF` |
| `primaryFixedDim` | `#00DAF3` |
| `secondary` | `#B70052` |
| `onSecondary` | `#FFFFFF` |
| `secondaryContainer` | `#DD2269` |
| `tertiary` | `#6833EA` |
| `tertiaryContainer` | `#D6C9FF` |
| `error` | `#BA1A1A` |
| `errorContainer` | `#FFDAD6` |

## Gradients

Create `AppGradients`:

- `primaryAction`: `#00DAF3 -> #006875`
- `aiAction`: `#00E5FF -> #D6C9FF`
- `secondaryAi`: `#DD2269 -> #6833EA`
- `subtleCyanBlob`: primary at 8-12% opacity to transparent
- `subtleMagentaBlob`: secondary at 5-10% opacity to transparent

Use gradients sparingly on primary buttons, central add action, AI insight
borders, and large financial hero cards.

## Typography

Fonts:

- English: Inter.
- Arabic: IBM Plex Sans Arabic.
- Fallback: platform sans-serif.

Flutter text styles:

| Token | Size | Weight | Line height target |
| --- | --- | --- | --- |
| `displayLarge` | 40 | 700 | 48 |
| `displayMobile` | 32 | 700 | 40 |
| `headlineMedium` | 24 | 600 | 32 |
| `titleMedium` | 18 | 600 | 26 |
| `bodyLarge` | 16 | 400 | 24 |
| `bodySmall` | 14 | 400 | 20 |
| `labelCaps` | 12 | 600 | 16 |
| `arabicBody` | 16 | 400 | 28 |

Rules:

- Use tabular figures for currency where supported.
- Avoid viewport-scaled font sizes.
- Use `TextOverflow.ellipsis` only where content is secondary.
- Use `FittedBox` or tighter layout constraints for large currency values when
  needed at 360px width.

## Spacing

Base grid: 4 logical pixels.

| Token | Value |
| --- | --- |
| `xs` | 4 |
| `sm` | 8 |
| `md` | 16 |
| `lg` | 24 |
| `xl` | 32 |
| `containerPadding` | 20 |
| `cardGutter` | 12 |

## Radii

HTML exports are inconsistent (`0.75rem`, `24px`, and `32px` appear). Normalize
in Flutter:

| Token | Value |
| --- | --- |
| `sm` | 4 |
| `md` | 8 |
| `lg` | 12 |
| `xl` | 18 |
| `card` | 24 |
| `sheet` | 32 top corners |
| `pill` | 999 |

## Surface And Depth

Flutter cannot use CSS `backdrop-filter` directly in the same way. Recreate the
look with:

- `ClipRRect`
- `BackdropFilter`
- translucent `Container` fill
- subtle border
- soft `BoxShadow`

Surface recipes:

- Glass card: white 60-80% opacity, blur 16-20, border white 40%, shadow
  `0 8 32 rgba(0,0,0,0.05)`.
- Modal sheet: white 85-92% opacity, blur 32-40, top radius 32, upward shadow.
- Input: `#F1F5F9`, pill radius, white focus state with primary border.
- AI card: glass card plus gradient border and sparkle icon.

## Iconography

Use Flutter Material Symbols/Icons equivalents where possible:

- home, query_stats, add, account_balance_wallet, settings
- restaurant, local_taxi, shopping_bag, home, more_horiz
- search, tune, calendar_today, category, payments
- auto_awesome, mic, send, check_circle
- credit_card, account_balance, savings, subscriptions

If a Material Symbol is not available in the selected Flutter icon set, map to
the closest Material icon rather than embedding SVG icon text.

## RTL/LTR Readiness

Implementation must:

- Use `EdgeInsetsDirectional` and `AlignmentDirectional`.
- Use `TextAlign.start`/`end`.
- Mirror navigation and directional icons for RTL.
- Keep universal icons, logos, and sparkle symbols unmirrored.
- Use Arabic-ready text style when `Locale('ar')` is active.
- Exercise both `TextDirection.ltr` and `TextDirection.rtl` in widget tests.

## Responsive Rules

Required viewports:

- 360x800
- 375x812
- 390x844

Rules:

- All fixed-width content must be constrained by available width.
- Floating bottom nav must not cover primary content or submit buttons.
- Bottom sheets must have max height and scrollable content.
- Search/filter chip rows must scroll horizontally.
- Currency amounts must not overflow transaction rows.
- Forms must scroll when the keyboard would reduce available height.
