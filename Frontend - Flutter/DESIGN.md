---
name: Pro-Service Modern
colors:
  surface: "#f8f9ff"
  surface-dim: "#cbdbf5"
  surface-bright: "#f8f9ff"
  surface-container-lowest: "#ffffff"
  surface-container-low: "#eff4ff"
  surface-container: "#e5eeff"
  surface-container-high: "#dce9ff"
  surface-container-highest: "#d3e4fe"
  on-surface: "#0b1c30"
  on-surface-variant: "#434655"
  inverse-surface: "#213145"
  inverse-on-surface: "#eaf1ff"
  outline: "#737686"
  outline-variant: "#c3c6d7"
  surface-tint: "#0053db"
  primary: "#004ac6"
  on-primary: "#ffffff"
  primary-container: "#2563eb"
  on-primary-container: "#eeefff"
  inverse-primary: "#b4c5ff"
  secondary: "#52625c"
  on-secondary: "#ffffff"
  secondary-container: "#d3e3dc"
  on-secondary-container: "#566660"
  tertiary: "#784b00"
  on-tertiary: "#ffffff"
  tertiary-container: "#996100"
  on-tertiary-container: "#ffeedd"
  error: "#ba1a1a"
  on-error: "#ffffff"
  error-container: "#ffdad6"
  on-error-container: "#93000a"
  primary-fixed: "#dbe1ff"
  primary-fixed-dim: "#b4c5ff"
  on-primary-fixed: "#00174b"
  on-primary-fixed-variant: "#003ea8"
  secondary-fixed: "#d5e6df"
  secondary-fixed-dim: "#bacac3"
  on-secondary-fixed: "#101e1a"
  on-secondary-fixed-variant: "#3b4a44"
  tertiary-fixed: "#ffddb8"
  tertiary-fixed-dim: "#ffb95f"
  on-tertiary-fixed: "#2a1700"
  on-tertiary-fixed-variant: "#653e00"
  background: "#f8f9ff"
  on-background: "#0b1c30"
  surface-variant: "#d3e4fe"
typography:
  headline-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 32px
    fontWeight: "700"
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-lg-mobile:
    fontFamily: Plus Jakarta Sans
    fontSize: 26px
    fontWeight: "700"
    lineHeight: 32px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 24px
    fontWeight: "600"
    lineHeight: 32px
  headline-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 20px
    fontWeight: "600"
    lineHeight: 28px
  body-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: "400"
    lineHeight: 28px
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: "400"
    lineHeight: 24px
  body-sm:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: "400"
    lineHeight: 20px
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: "600"
    lineHeight: 16px
    letterSpacing: 0.05em
  label-sm:
    fontFamily: Inter
    fontSize: 11px
    fontWeight: "500"
    lineHeight: 14px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 8px
  xs: 4px
  sm: 12px
  md: 16px
  lg: 24px
  xl: 32px
  container-margin-mobile: 16px
  container-margin-desktop: 48px
  gutter: 16px
---

## Brand & Style

The design system is anchored in the intersection of high-tech efficiency and domestic reliability. The target audience includes busy homeowners and urban professionals who value their time and require absolute certainty in service quality.

The visual direction follows a **Modern Corporate** style with a heavy leaning toward **Minimalism**. It utilizes expansive white space to reduce cognitive load during the service booking process, while incorporating subtle high-tech flourishes (like fine-line iconography and soft gradients) to signal the AI-powered nature of the platform. The goal is to evoke a feeling of "calm capability"—where the complexity of home maintenance is distilled into a friendly, professional interface.

## Colors

The palette is designed to balance authority with approachability.

- **Primary (Trust Blue):** Used for primary actions, navigation headers, and brand-critical touchpoints. It reinforces professional reliability.
- **Secondary (Soft Mint):** Primarily used for backgrounds of success states, active service cards, and subtle highlights. It provides a refreshing, clean contrast to the bold primary blue.
- **Accent (Warm Amber):** Reserved for attention-grabbing elements such as rating stars, urgent alerts, and promotional highlights.
- **Neutral (Slate Grays):** A refined range of cool grays handles typography and borders, ensuring the interface feels modern rather than stark black-and-white.

The default mode is **Light**, emphasizing cleanliness and clarity, which are essential for a home services platform.

## Typography

This design system employs a dual-font strategy to balance personality and utility.

**Plus Jakarta Sans** is used for all headlines. Its slightly rounded terminals and open apertures provide a welcoming, friendly character that softens the professional tone of the app.

**Inter** is the workhorse for body text and labels. Its exceptional legibility at small sizes and neutral architecture make it ideal for service descriptions, technical details, and data-heavy forms.

For mobile screens, top-level headlines scale down to ensure they don't dominate the viewport, while body sizes remain generous to support accessibility for users who may be multitasking or in low-light environments.

## Layout & Spacing

The layout philosophy follows a **Fluid Grid** model with a base-8 spacing scale.

- **Mobile:** Uses a 4-column grid with 16px side margins and 16px gutters. This ensures content remains readable on narrow devices while allowing for dense service listings.
- **Tablet/Desktop:** Transitions to a 12-column grid. Service cards are arranged in responsive galleries, and the sidebar or top navigation expands to accommodate more complex management tools.

Spacing is used intentionally to group related service categories and separate distinct phases of the user journey (e.g., Discovery vs. Booking). Significant vertical padding (32px+) is encouraged between major sections to maintain a minimalist, uncluttered feel.

## Elevation & Depth

To maintain a "high-tech" yet "approachable" aesthetic, the design system utilizes **Ambient Shadows**.

Surfaces are categorized by their interactive depth:

1.  **Level 0 (Base):** The main background, usually pure white or a very faint gray (#F8FAFC).
2.  **Level 1 (Cards/Surface):** Service cards and list items use a very soft, diffused shadow (Blur: 15px, Opacity: 4%, Color: Primary Blue) to appear gently lifted.
3.  **Level 2 (Active/Floating):** Primary action buttons and navigation bars use a more defined shadow to signify interactivity and priority.
4.  **Backdrop Blurs:** In-app overlays and chat headers use a 12px backdrop blur (glassmorphism) to maintain context while focusing user attention. This adds a sophisticated, modern layer to the interface.

## Shapes

The shape language is consistently **Rounded**, reflecting the friendly and safe nature of home service assistance.

- **Primary Containers:** Standard cards and input fields use a 0.5rem (8px) radius.
- **Large Components:** Hero sections and modals use the `rounded-lg` (16px) or `rounded-xl` (24px) values to create a soft, modern enclosure.
- **Interactive Elements:** Small buttons and status badges may occasionally use pill-shaping (full rounding) to differentiate them from static content containers.

## Components

### Buttons

Primary buttons are high-contrast (Trust Blue with white text) with a subtle 2px shadow. Secondary buttons use the Soft Mint background with Primary Blue text to provide a clear but gentle hierarchy.

### Service Cards

Cards are the primary way users browse services. They feature a white background, Level 1 elevation, and a 1px soft gray border (#E2E8F0). The Soft Mint color is used as a "tag" background within these cards to indicate "Available" or "AI-Verified."

### Chat Bubbles

To emphasize the AI-powered aspect, the AI's chat bubbles should be Soft Mint with a slightly larger corner radius on the bottom-left, while user bubbles are Trust Blue. This asymmetry makes the conversation feel more organic.

### Status Badges

- **Success/Active:** Soft Mint background with dark green text.
- **Warning/Pending:** Warm Amber background with dark brown text.
- **Neutral:** Light gray background with Slate text.

### Input Fields

Fields feature a subtle gray border that transitions to a 2px Trust Blue border on focus. Labels sit clearly above the field in `label-md` Inter, ensuring clarity during the data-entry phase of booking.

### Navigation Bars

Mobile navigation uses a bottom-fixed bar with a heavy backdrop blur and 24px icons. The active state is indicated by a Primary Blue icon and a small dot indicator below, keeping the UI clean and functional.
