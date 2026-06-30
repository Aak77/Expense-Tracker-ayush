---
name: FinTrack
colors:
  surface: '#051424'
  surface-dim: '#051424'
  surface-bright: '#2c3a4c'
  surface-container-lowest: '#010f1f'
  surface-container-low: '#0d1c2d'
  surface-container: '#122131'
  surface-container-high: '#1c2b3c'
  surface-container-highest: '#273647'
  on-surface: '#d4e4fa'
  on-surface-variant: '#c2c6d5'
  inverse-surface: '#d4e4fa'
  inverse-on-surface: '#233143'
  outline: '#8c909e'
  outline-variant: '#424753'
  surface-tint: '#acc7ff'
  primary: '#acc7ff'
  on-primary: '#002f68'
  primary-container: '#508ff8'
  on-primary-container: '#00285b'
  inverse-primary: '#005bbf'
  secondary: '#43defb'
  on-secondary: '#00363f'
  secondary-container: '#00c2de'
  on-secondary-container: '#004b57'
  tertiary: '#c3c6d7'
  on-tertiary: '#2c303d'
  tertiary-container: '#8d90a0'
  on-tertiary-container: '#252936'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#d7e2ff'
  primary-fixed-dim: '#acc7ff'
  on-primary-fixed: '#001a40'
  on-primary-fixed-variant: '#004492'
  secondary-fixed: '#a7eeff'
  secondary-fixed-dim: '#3ad8f5'
  on-secondary-fixed: '#001f25'
  on-secondary-fixed-variant: '#004e5b'
  tertiary-fixed: '#dfe2f3'
  tertiary-fixed-dim: '#c3c6d7'
  on-tertiary-fixed: '#171b28'
  on-tertiary-fixed-variant: '#434654'
  background: '#051424'
  on-background: '#d4e4fa'
  surface-variant: '#273647'
typography:
  display-currency:
    fontFamily: Inter
    fontSize: 40px
    fontWeight: '700'
    lineHeight: 48px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
  headline-md:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
    letterSpacing: 0.01em
  label-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.05em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 4px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  container-padding: 20px
---

## Brand & Style
The design system is engineered for a premium, high-performance personal finance experience. It targets financially conscious individuals who value precision, security, and a modern aesthetic. 

The style is a sophisticated blend of **Corporate Modern** and **Glassmorphism**. It utilizes a deep, immersive dark mode to reduce eye strain during data-heavy sessions, punctuated by vibrant electric accents that guide the user's eye to key actions and insights. The overall emotional response should be one of "controlled wealth"—calm, organized, and technologically advanced.

## Colors
The palette is rooted in the "Deep Navy" (#0A0E1A) foundation, providing a high-contrast base for "Electric Blue" (#4F8EF7) to act as the primary signal color. 

- **Primary:** Electric Blue is used for primary actions, active states, and critical progress indicators.
- **Secondary:** A complementary Cyan-tinted blue used for secondary data visualizations (e.g., secondary budget categories).
- **Surface & Glass:** Containers utilize a semi-transparent white wash over the navy background, creating a layered, glass-like effect.
- **Status:** Success is handled with an Emerald green, and alerts with a vivid Coral, though these are kept desaturated to maintain the premium feel.

## Typography
Inter is selected for its exceptional legibility in data-dense interfaces and its neutral, modern tone. 

The typography system prioritizes the "Display Currency" style for account balances, ensuring total wealth is the most prominent element on the screen. Indian Rupee (₹) symbols should always match the weight and color of the accompanying digits but may be scaled to 80% size for a more sophisticated, editorial look. Body text uses light grays to ensure the hierarchy remains clear against the pure white of headlines.

## Layout & Spacing
This design system utilizes a **Fixed Grid** approach for mobile, centered on a 4px baseline shift. 

- **Margins:** Screens should maintain a consistent 20px lateral margin.
- **Card Spacing:** Vertical stacks of glass cards should be separated by 16px (md) to maintain distinct grouping while preserving vertical rhythm.
- **Safe Areas:** Ensure bottom navigation and floating action buttons respect the device's home indicator safe zones.
- **Data Density:** In transaction lists, use 12px (sm+4) padding between items to balance information density with touch targets.

## Elevation & Depth
Depth is not communicated through traditional drop shadows but through **Backdrop Blurs** and **Tonal Layering**.

- **Level 0 (Base):** Deep Navy background.
- **Level 1 (Cards):** Glassmorphism surfaces. These use a `backdrop-filter: blur(12px)` and a subtle 1px border. The border is a linear gradient from top-left (white at 15% opacity) to bottom-right (blue at 5% opacity).
- **Level 2 (Modals/Overlays):** These use a higher opacity background (rgba(255, 255, 255, 0.08)) and a more pronounced 24px blur to separate them from the primary card layer.

## Shapes
The shape language is consistently rounded to evoke a friendly, approachable feeling within a high-tech environment.

The standard radius is **16px** for all primary cards, input fields, and large buttons. This generous rounding creates a "pocketable" feel, typical of modern premium mobile applications. Smaller elements like chips or tags should use a fully pill-shaped (rounded-full) geometry to differentiate them from interactive containers.

## Components
- **Glass Cards:** The signature component. Must include a 1px stroke that catches the "light" from the top-left. Content inside should have 20px internal padding.
- **Buttons:** 
  - *Primary:* Solid Electric Blue (#4F8EF7) with white text. 16px radius.
  - *Secondary:* Outlined with the same 1px glass-style border and white text.
- **Transaction Items:** Left-aligned 40px circular icons with category glyphs. The amount (₹) is right-aligned using `label-md` for secondary info and `headline-md` for the value.
- **Bottom Navigation:** A frosted glass bar (`backdrop-filter: blur(20px)`) with a subtle top border. Icons should be line-art style (2px stroke), with the active state glowing in Electric Blue.
- **Form Fields:** Darker than the background or semi-transparent glass. Borders should only brighten to Electric Blue on `:focus`.
- **Progress Bars:** Use a "track and fill" model. The track is `rgba(255, 255, 255, 0.05)` and the fill is a horizontal gradient from Primary Blue to Secondary Cyan.