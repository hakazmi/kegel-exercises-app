# Design tokens (for approval)

Extracted from `docs/design/*.png` and locked values from Prompt 1, then adjusted for WCAG AA contrast (`test/contrast_test.dart`).

**Exemptions:** disabled controls are not required to meet WCAG contrast; decorative tracks (session ring track) are not required to meet 3:1.

## Colours

| Token | Hex | Role |
| --- | --- | --- |
| `primary` | `#0B7A4B` | Brand green (progress, checks, selected radios) |
| `success` | `#0B7A4B` | Success / relax phase |
| `accent` | `#1AAE68` | Squeeze / hold phase ring accent (graphics on dark only) |
| `mint` | `#EAF7F0` | Mint tint (hero wash, breathing chip) |
| `background` | `#F5F7F6` | App scaffold background |
| `surface` | `#FFFFFF` | Cards, sheets |
| `surfaceMuted` | `#EEF1F0` | Muted rows / tracks |
| `border` | `#DCE3E0` | Default card / input border |
| `borderStrong` | `#0E1412` | Selected card border |
| `ink` | `#0E1412` | Primary CTA fill / near-black |
| `textPrimary` | `#0E1412` | Body / titles on light |
| `textSecondary` | `#66706B` | Secondary / captions (**was `#6F7974`**) |
| `textOnPrimary` | `#FFFFFF` | Text on ink / primary buttons |
| `textDisabled` | `#9AA39F` | Disabled icons (exempt) |
| `textDisabledLabel` | `#6F7974` | Disabled control labels (exempt) |
| `buttonDisabled` | `#CBD2D0` | Disabled primary button fill (exempt) |
| `sessionBackground` | `#0E1412` | Session screens |
| `sessionSurface` | `#1A221F` | Session raised surfaces |
| `sessionText` | `#FFFFFF` | Session primary text |
| `sessionTextSecondary` | `#9AA39F` | Session secondary text |
| `sessionRingTrack` | `#2A3430` | Ring track (decorative, exempt) |
| `phaseSqueezeHold` | `#1AAE68` | Ring: squeeze / hold |
| `phaseRelax` | `#0B7A4B` | Ring: relax |
| `phaseRest` | `#6F7974` | Ring: rest |
| `goalBladderBg` / `Fg` | `#E6EEFF` / `#3257D6` | Goal chip |
| `goalErectionBg` / `Fg` | `#EAF7F0` / `#0B7A4B` | Goal chip |
| `goalEjaculationBg` / `Fg` | `#FFF1E3` / `#B4520F` | Goal chip |
| `goalSurgeryBg` / `Fg` | `#F1EAFE` / `#6B3FC9` | Goal chip |
| `goalGeneralBg` / `Fg` | `#FFE9EE` / `#C2334F` | Goal chip |
| `streakBg` / `Fg` | `#FFF1E3` / `#B4520F` | Streak pill |
| `scrim` | `#660E1412` | Dialogs |

### Tokens changed for contrast

| Token | Before | After | Why |
| --- | --- | --- | --- |
| `textSecondary` | `#6F7974` | `#66706B` | 4.5:1 on `#F5F7F6` and `#EEF1F0` |

Disabled and decorative values stay at screenshot originals (exempt): `buttonDisabled` `#CBD2D0`, `textDisabledLabel` `#6F7974`, `textDisabled` `#9AA39F`, `sessionRingTrack` `#2A3430`.

`#1AAE68` (`accent` / `phaseSqueezeHold`) kept for graphics on dark session backgrounds only.

## Contrast table (WCAG AA)

Rules: **4.5:1** normal text; **3:1** large text (≥24px or ≥18.66px bold) and non-exempt graphics (ring phase fills, icons, chips). Disabled controls and decorative tracks are listed separately and are not pass/fail.

| Pair | Fg | Bg | Ratio | Min | Pass |
| --- | --- | --- | ---: | ---: | --- |
| textPrimary on background | #0E1412 | #F5F7F6 | 17.31 | 4.5 | yes |
| textPrimary on surface | #0E1412 | #FFFFFF | 18.63 | 4.5 | yes |
| textSecondary on background | #66706B | #F5F7F6 | 4.77 | 4.5 | yes |
| textSecondary on surface | #66706B | #FFFFFF | 5.13 | 4.5 | yes |
| textSecondary on surfaceMuted | #66706B | #EEF1F0 | 4.51 | 4.5 | yes |
| display (28/extraBold) on background | #0E1412 | #F5F7F6 | 17.31 | 3.0 | yes |
| title (20/bold) on surface | #0E1412 | #FFFFFF | 18.63 | 3.0 | yes |
| PrimaryButton text on ink | #FFFFFF | #0E1412 | 18.63 | 4.5 | yes |
| SecondaryButton text on surface | #0E1412 | #FFFFFF | 18.63 | 4.5 | yes |
| selected card title on surface | #0E1412 | #FFFFFF | 18.63 | 4.5 | yes |
| selected card subtitle on surface | #66706B | #FFFFFF | 5.13 | 4.5 | yes |
| selected radio fill on surface (graphic) | #0B7A4B | #FFFFFF | 5.39 | 3.0 | yes |
| goalBladder Fg on Bg (graphic) | #3257D6 | #E6EEFF | 5.20 | 3.0 | yes |
| goalErection Fg on Bg (graphic) | #0B7A4B | #EAF7F0 | 4.89 | 3.0 | yes |
| goalEjaculation Fg on Bg (graphic) | #B4520F | #FFF1E3 | 4.56 | 3.0 | yes |
| goalSurgery Fg on Bg (graphic) | #6B3FC9 | #F1EAFE | 5.64 | 3.0 | yes |
| goalGeneral Fg on Bg (graphic) | #C2334F | #FFE9EE | 4.68 | 3.0 | yes |
| streak Fg on Bg (graphic) | #B4520F | #FFF1E3 | 4.56 | 3.0 | yes |
| primary on surface (graphic/icon) | #0B7A4B | #FFFFFF | 5.39 | 3.0 | yes |
| primary on background (graphic/icon) | #0B7A4B | #F5F7F6 | 5.00 | 3.0 | yes |
| primary on mint (graphic/icon) | #0B7A4B | #EAF7F0 | 4.89 | 3.0 | yes |
| TextLink primary on background | #0B7A4B | #F5F7F6 | 5.00 | 4.5 | yes |
| TextLink primary on surface | #0B7A4B | #FFFFFF | 5.39 | 4.5 | yes |
| tab selected (ink) on surface | #0E1412 | #FFFFFF | 18.63 | 4.5 | yes |
| tab unselected (textSecondary) on surface | #66706B | #FFFFFF | 5.13 | 4.5 | yes |
| tab icon selected on surface (graphic) | #0E1412 | #FFFFFF | 18.63 | 3.0 | yes |
| sessionText on sessionBackground | #FFFFFF | #0E1412 | 18.63 | 4.5 | yes |
| sessionText on sessionSurface | #FFFFFF | #1A221F | 16.25 | 4.5 | yes |
| sessionTextSecondary on sessionBackground | #9AA39F | #0E1412 | 7.20 | 4.5 | yes |
| sessionTextSecondary on sessionSurface | #9AA39F | #1A221F | 6.28 | 4.5 | yes |
| phaseSqueezeHold on sessionBackground (ring) | #1AAE68 | #0E1412 | 6.47 | 3.0 | yes |
| phaseRelax on sessionBackground (ring) | #0B7A4B | #0E1412 | 3.46 | 3.0 | yes |
| phaseRest on sessionBackground (ring) | #6F7974 | #0E1412 | 4.14 | 3.0 | yes |
| accent on sessionBackground (graphic) | #1AAE68 | #0E1412 | 6.47 | 3.0 | yes |

### Exempt (disabled or decorative)

| Pair | Fg | Bg | Notes |
| --- | --- | --- | --- |
| PrimaryButton disabled label on buttonDisabled | #6F7974 | #CBD2D0 | Disabled control |
| SecondaryButton disabled label on surface | #6F7974 | #FFFFFF | Disabled control |
| textDisabled (icon) on surface | #9AA39F | #FFFFFF | Disabled icon |
| sessionRingTrack on sessionBackground | #2A3430 | #0E1412 | Decorative track |

## Spacing

| Token | Value |
| --- | --- |
| `xxs` | 4 |
| `xs` | 8 |
| `sm` | 12 |
| `md` | 16 |
| `lg` | 20 |
| `xl` | 24 |
| `xxl` | 32 |
| `minTouchTarget` | 48 |

## Radii

| Token | Value |
| --- | --- |
| `md` | 12 |
| `lg` | 16 |
| `xl` | 24 |
| `pill` | 999 |

## Typography (Manrope)

| Style | Size | Weight | Colour default |
| --- | --- | --- | --- |
| `display` | 28 | 800 | textPrimary |
| `title` | 20 | 700 | textPrimary |
| `body` | 16 | 400 | textPrimary |
| `caption` | 13 | 500 | textSecondary |
| `button` | 16 | 700 | textOnPrimary |

## Elevation

| Token | Shadow |
| --- | --- |
| `none` | none |
| `level1` | `0 2 8` at 8% ink |
| `level2` | `0 6 16` at 10% ink |

## Themes

- **Light** (`AppTheme.light`): onboarding, Today / Progress / Learn, Settings, paywall.
- **Session** (`AppTheme.session` / `SessionTheme`): S2 Countdown, S3 Player, S4 Done.
