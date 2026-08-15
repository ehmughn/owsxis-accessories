---
name: Neo-Nostalgia Brutalism
colors:
  surface: '#fdf9f5'
  surface-dim: '#ddd9d6'
  surface-bright: '#fdf9f5'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f7f3ef'
  surface-container: '#f1ede9'
  surface-container-high: '#ebe7e4'
  surface-container-highest: '#e5e2de'
  on-surface: '#1c1c19'
  on-surface-variant: '#5b403c'
  inverse-surface: '#31302e'
  inverse-on-surface: '#f4f0ec'
  outline: '#8f706b'
  outline-variant: '#e3beb8'
  surface-tint: '#b62417'
  primary: '#660000'
  on-primary: '#ffffff'
  primary-container: '#900000'
  on-primary-container: '#ff9686'
  inverse-primary: '#ffb4a8'
  secondary: '#555997'
  on-secondary: '#ffffff'
  secondary-container: '#b5b9fe'
  on-secondary-container: '#434784'
  tertiary: '#745b00'
  on-tertiary: '#ffffff'
  tertiary-container: '#d0a602'
  on-tertiary-container: '#4f3d00'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#ffdad4'
  primary-fixed-dim: '#ffb4a8'
  on-primary-fixed: '#410000'
  on-primary-fixed-variant: '#930301'
  secondary-fixed: '#e0e0ff'
  secondary-fixed-dim: '#bfc2ff'
  on-secondary-fixed: '#0f1250'
  on-secondary-fixed-variant: '#3d417e'
  tertiary-fixed: '#ffe08b'
  tertiary-fixed-dim: '#eec12d'
  on-tertiary-fixed: '#241a00'
  on-tertiary-fixed-variant: '#584400'
  background: '#fdf9f5'
  on-background: '#1c1c19'
  surface-variant: '#e6e2de'
typography:
  display-lg:
    fontFamily: Bricolage Grotesque
    fontSize: 64px
    fontWeight: '800'
    lineHeight: 72px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Bricolage Grotesque
    fontSize: 40px
    fontWeight: '800'
    lineHeight: 48px
  headline-lg-mobile:
    fontFamily: Bricolage Grotesque
    fontSize: 32px
    fontWeight: '800'
    lineHeight: 38px
  headline-md:
    fontFamily: Bricolage Grotesque
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
  body-lg:
    fontFamily: Hanken Grotesk
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Hanken Grotesk
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-bold:
    fontFamily: Space Grotesk
    fontSize: 14px
    fontWeight: '700'
    lineHeight: 20px
  label-sm:
    fontFamily: Space Grotesk
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
rounded:
  sm: 0.125rem
  DEFAULT: 0.25rem
  md: 0.375rem
  lg: 0.5rem
  xl: 0.75rem
  full: 9999px
spacing:
  xs: 4px
  base: 8px
  sm: 12px
  md: 24px
  lg: 48px
  xl: 80px
  gutter: 24px
  margin-mobile: 16px
  margin-desktop: 64px
---

## Brand & Style
This design system, "Owsxi," is a high-energy fusion of **Neo-Brutalism** and **90s Retro-Pop**. It targets a Gen-Z and Millennial audience with an affinity for "indie-sleaze," street art, and physical collectibles. 

The aesthetic is intentionally loud and tactile, characterized by heavy outlines, high-contrast "hard" shadows, and a "sticker-slap" layout philosophy. The emotional response is one of playful rebellion—mixing professional UI patterns with chaotic, expressive decorative elements like wire grids, blobs, and hand-drawn SVG underlines. It rejects modern softness in favor of a "hard-edge" physical presence.

## Colors
The palette is rooted in a "Warm Cream" neutral base to evoke aged paper or vintage toy packaging. 
- **Primary (Deep Red):** Used for brand emphasis, pricing, and critical CTAs.
- **Secondary (Midnight Navy):** Acts as the structural anchor. It is used for all "sticker" borders, hard shadows, and high-contrast text.
- **Tertiary (Mustard Gold):** Used for highlighting special offers, secondary shadows, and decorative "stars."
- **Accents (Soft Lavender & Muted Teal):** Derived from the secondary fixed values, these are used for card backgrounds and container fills to prevent the high contrast from becoming visually exhausting.

## Typography
The system employs a three-font strategy to balance character with readability:
- **Display & Headlines:** *Bricolage Grotesque* provides a quirky, variable-width feel. Use it for big brand moments and section headers. High-weight (700-800) is mandatory.
- **Body:** *Hanken Grotesk* is used for descriptions and long-form text. It is sharp and contemporary, providing a necessary professional counterweight to the louder display fonts.
- **Labels & UI Mono:** *Space Grotesk* is used for buttons, navigation, and technical metadata. Its geometric, slightly futuristic nature supports the "tech-retro" vibe.

## Layout & Spacing
The layout follows a **12-column fixed grid** with a maximum width of 1200px. 
- **Bento Logic:** Components should span varying column widths (e.g., a "featured" item spanning 8 columns next to a 4-column item) to create visual asymmetry.
- **The "Sticker" Margin:** Elements often use negative margins or rotations (2-5 degrees) to break the grid, mimicking stickers placed on a surface.
- **Responsive Reflow:** On mobile, margins shrink to 16px and bento grids collapse into a single-column stack. Padding within sections remains generous (80px+) to maintain an "editorial" feel.

## Elevation & Depth
This system eschews traditional soft shadows for **Hard Shadows** (high opacity, 0 blur).
- **Depth Levels:**
  - **Level 0:** Flat on the surface (background).
  - **Level 1 (The Hard Shadow):** 4px offset in Navy (#0f1250), Gold (#d0a602), or Red (#900000).
  - **Level 2 (The Sticker Shadow):** A 3px solid border combined with a 4px white "halo" shadow to separate the element from the background pattern.
- **Interactive Depth:** When a button or card is hovered/pressed, the hard shadow should "collapse" (translate-x and translate-y by 4px), simulating the physical act of pushing a button into the page.

## Shapes
The shape language is "Soft-Brutalist." It uses **Soft (0.25rem - 0.75rem)** corners for most structural containers to maintain some approachability, while avoiding the "pill" shapes of modern mobile OSs (except for specific labels).
- **Primary Containers:** 0.75rem (rounded-xl) for product cards and main bento blocks.
- **Small Elements:** 0.25rem (rounded-default) for "Quick Add" buttons.
- **Pills:** Used exclusively for status tags (e.g., "Top Seller") and navigation links to indicate interactivity.

## Components
- **Buttons:** Must have a 3px solid Navy border and a hard Gold shadow. Text must be in *Space Grotesk* Bold.
- **Cards:** Product cards use a white background with a Navy border. Top sections of cards often feature a different background color (Lavender or Mint) to categorize the product type.
- **The "Sticker" Tag:** Small informational tags should be rotated slightly (-2 to 4 degrees) and have a hard shadow to look like they were slapped onto the UI.
- **Navigation:** A sticky top bar with a 4px bottom border and a Lavender hard shadow. Hover states for nav links should include a pill-shaped background fill.
- **Marquee:** A continuous scrolling text banner used to separate major sections, using *Space Grotesk* in all-caps.