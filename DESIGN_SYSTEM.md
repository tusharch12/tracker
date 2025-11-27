# Money Lending Tracker - Black & White Design System

## Design Philosophy

An authentic, minimalist black and white design that emphasizes clarity, professionalism, and trust. The design uses high contrast, clean typography, and subtle shadows to create depth without color.

---

## Color Palette

### Primary Colors
```
Pure Black:     #000000  // Primary text, headers, borders
Charcoal:       #1A1A1A  // Cards, elevated surfaces
Dark Gray:      #2D2D2D  // Secondary surfaces
```

### Neutral Grays
```
Medium Gray:    #666666  // Secondary text, icons
Light Gray:     #999999  // Tertiary text, disabled states
Pale Gray:      #E5E5E5  // Dividers, subtle borders
```

### Background Colors
```
Pure White:     #FFFFFF  // Main background
Off-White:      #F8F8F8  // Alternate background
Light Smoke:    #F2F2F2  // Input fields, inactive states
```

### Semantic Colors (Grayscale)
```
Success:        #000000  // Use with checkmark icon
Warning:        #4D4D4D  // Medium gray for warnings
Error:          #1A1A1A  // Dark with red icon (exception)
Overdue:        #CC0000  // Only red used in entire app (critical alerts)
```

---

## Typography

### Font Family
```
Primary: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif
Monospace: 'JetBrains Mono', 'Courier New', monospace (for numbers/amounts)
```

### Font Sizes
```
Display:        32px / 2rem      (Dashboard title)
H1:             24px / 1.5rem    (Page headers)
H2:             20px / 1.25rem   (Section headers)
H3:             18px / 1.125rem  (Card titles)
Body Large:     16px / 1rem      (Primary content)
Body:           14px / 0.875rem  (Secondary content)
Small:          12px / 0.75rem   (Captions, labels)
Tiny:           10px / 0.625rem  (Timestamps)
```

### Font Weights
```
Light:          300  (Subtle text)
Regular:        400  (Body text)
Medium:         500  (Emphasis)
Semibold:       600  (Subheadings)
Bold:           700  (Headers, important numbers)
Black:          900  (Display numbers, amounts)
```

---

## Spacing System

Based on 4px grid:
```
xs:   4px
sm:   8px
md:   16px
lg:   24px
xl:   32px
2xl:  48px
3xl:  64px
```

---

## Components

### Cards
```
Background: #FFFFFF
Border: 1px solid #E5E5E5
Border Radius: 8px
Shadow: 0 2px 8px rgba(0, 0, 0, 0.08)
Padding: 16px - 24px

Hover State:
  Shadow: 0 4px 16px rgba(0, 0, 0, 0.12)
  Border: 1px solid #CCCCCC
```

### Buttons

**Primary Button**
```
Background: #000000
Text: #FFFFFF
Border Radius: 6px
Padding: 12px 24px
Font Weight: 600

Hover: Background #1A1A1A
Active: Background #000000 + scale(0.98)
Disabled: Background #E5E5E5, Text #999999
```

**Secondary Button**
```
Background: #FFFFFF
Text: #000000
Border: 2px solid #000000
Border Radius: 6px
Padding: 12px 24px

Hover: Background #F8F8F8
Active: Background #F2F2F2
```

**Ghost Button**
```
Background: transparent
Text: #000000
Border: none
Padding: 8px 16px

Hover: Background #F8F8F8
Active: Background #E5E5E5
```

### Input Fields
```
Background: #F8F8F8
Border: 1px solid #E5E5E5
Border Radius: 6px
Padding: 12px 16px
Font Size: 14px

Focus:
  Border: 2px solid #000000
  Background: #FFFFFF
  
Error:
  Border: 2px solid #CC0000
```

### Badges/Tags
```
Background: #F2F2F2
Text: #1A1A1A
Border Radius: 4px
Padding: 4px 12px
Font Size: 12px
Font Weight: 600

Status Variants:
  Active: Background #000000, Text #FFFFFF
  Completed: Background #E5E5E5, Text #666666
  Overdue: Background #CC0000, Text #FFFFFF
  Cancelled: Background #F8F8F8, Text #999999, Strikethrough
```

### Dividers
```
Color: #E5E5E5
Height: 1px
Margin: 16px 0
```

---

## Layout Patterns

### Dashboard Grid
```
Container: max-width 1200px, centered
Padding: 24px
Gap: 24px

Summary Cards: 4 columns on desktop, 2 on tablet, 1 on mobile
List Items: Full width with internal grid
```

### List Items
```
Background: #FFFFFF
Border Bottom: 1px solid #F2F2F2
Padding: 16px
Min Height: 72px

Hover: Background #FAFAFA
Active: Background #F8F8F8
```

### Forms
```
Max Width: 600px
Label: 12px, #666666, uppercase, letter-spacing 0.5px
Input Spacing: 16px vertical
Button Group: 16px gap, right-aligned
```

---

## Icons

- **Style**: Outline/stroke icons (2px stroke weight)
- **Size**: 20px standard, 24px for primary actions, 16px for inline
- **Color**: Inherit from parent or #666666 for neutral

---

## Shadows

```
Subtle:     0 1px 3px rgba(0, 0, 0, 0.06)
Card:       0 2px 8px rgba(0, 0, 0, 0.08)
Elevated:   0 4px 16px rgba(0, 0, 0, 0.12)
Modal:      0 8px 32px rgba(0, 0, 0, 0.16)
```

---

## Animations

```
Duration: 200ms (micro), 300ms (standard), 500ms (complex)
Easing: cubic-bezier(0.4, 0.0, 0.2, 1) // Material ease-in-out

Transitions:
  - Button hover: 200ms
  - Card elevation: 300ms
  - Page transitions: 500ms
  - Modal open/close: 300ms
```

---

## Accessibility

- **Contrast Ratio**: Minimum 4.5:1 for normal text, 3:1 for large text
- **Touch Targets**: Minimum 44x44px
- **Focus States**: 2px solid black outline with 2px offset
- **Screen Reader**: Proper ARIA labels on all interactive elements

---

## Dashboard Metrics Display

### Large Number Display
```
Font Family: JetBrains Mono
Font Size: 32px
Font Weight: 900
Color: #000000
Letter Spacing: -0.5px
```

### Currency Format
```
Symbol: ₹ (or appropriate currency)
Decimal: 2 places
Thousands Separator: Comma
Example: ₹1,25,000.00
```

### Status Indicators
```
Overdue: Red dot (8px) + text
Due Soon: Gray dot (8px) + text
Paid: Checkmark icon (16px)
```

---

## Responsive Breakpoints

```
Mobile:     < 640px
Tablet:     640px - 1024px
Desktop:    > 1024px
Wide:       > 1440px
```

---

## Example Component: Borrower Card

```
┌─────────────────────────────────────────────┐
│ [Avatar] John Doe                    [···]  │
│          +91 98765 43210                    │
│                                             │
│ ┌──────────┬──────────┬──────────┐         │
│ │ Borrowed │   Paid   │Remaining │         │
│ │ ₹50,000  │ ₹30,000  │ ₹20,000  │         │
│ └──────────┴──────────┴──────────┘         │
│                                             │
│ Next Due: Jan 15, 2025 • ₹5,000            │
│ [●] 2 Active Loans                          │
└─────────────────────────────────────────────┘

Styling:
- Card: White background, 8px radius, subtle shadow
- Avatar: 48px circle, black background, white initials
- Numbers: JetBrains Mono, bold
- Labels: 12px, gray, uppercase
- Dividers: 1px light gray
```

---

## Dark Mode (Future Enhancement)

Invert the palette while maintaining contrast:
```
Background: #000000
Surface: #1A1A1A
Text: #FFFFFF
Borders: #2D2D2D
```

---

This design system ensures a professional, trustworthy appearance appropriate for financial tracking while maintaining excellent readability and usability through pure black and white aesthetics.
