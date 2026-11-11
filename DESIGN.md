---
name: Nexus Pink Glam
description: A glossy Pink Glam desktop skin for the existing Nexus resource workspace.
colors:
  paper: "#fff0f5"
  paper-deep: "#ffe4ed"
  ink: "#4a0e2e"
  muted: "#80506a"
  line: "#ecc4d8"
  teal: "#ad1457"
  teal-deep: "#880e4f"
  coral: "#ad1457"
  gold: "#795019"
  danger: "#ae263f"
  white: "#fffafd"
  campus-green: "#ff8bc6"
  glam-primary: "#d81b60"
  glam-primary-hover: "#b31552"
  glam-rose: "#ff69b4"
  glam-hot: "#ff1493"
  glam-glass: "rgb(255 250 253 / 76%)"
  glam-shine: "rgb(255 255 255 / 86%)"
typography:
  display:
    fontFamily: "Manrope, Be Vietnam Pro, sans-serif"
    fontSize: "42px"
    fontWeight: 600
    lineHeight: 1.25
    letterSpacing: "-0.035em"
  headline:
    fontFamily: "Manrope, Be Vietnam Pro, sans-serif"
    fontSize: "34px"
    fontWeight: 700
    lineHeight: 1.25
    letterSpacing: "-0.035em"
  title:
    fontFamily: "Manrope, Be Vietnam Pro, sans-serif"
    fontSize: "18px"
    fontWeight: 700
    lineHeight: 1.4
    letterSpacing: "-0.025em"
  body:
    fontFamily: "Be Vietnam Pro, sans-serif"
    fontSize: "13px"
    lineHeight: 1.65
  desktop-body:
    fontFamily: "Be Vietnam Pro, sans-serif"
    fontSize: "14px"
    lineHeight: 1.65
  label:
    fontFamily: "Be Vietnam Pro, sans-serif"
    fontSize: "12px"
    lineHeight: 1.65
  section-heading:
    fontFamily: "Manrope, Be Vietnam Pro, sans-serif"
    fontSize: "24px"
    fontWeight: 700
    lineHeight: 1.65
    letterSpacing: "-0.025em"
rounded:
  action: "7px"
  field: "8px"
  navigation: "24px"
  search: "28px"
  search-action: "22px"
  compact: "12px"
  panel: "14px"
  discovery: "16px"
spacing:
  small: "12px"
  medium: "16px"
  panel: "24px"
  column: "32px"
components:
  button-primary:
    backgroundColor: "{colors.glam-primary}"
    textColor: "#ffffff"
    rounded: "{rounded.action}"
    height: "44px"
  search-field:
    backgroundColor: "rgb(255 250 253 / 94%)"
    textColor: "{colors.ink}"
    rounded: "{rounded.search}"
    padding: "6px 6px 6px 16px"
  navigation-active:
    backgroundColor: "linear-gradient(110deg, #d81b60, #c2186b)"
    textColor: "#ffffff"
    rounded: "{rounded.navigation}"
    padding: "10px 12px"
  panel:
    backgroundColor: "{colors.glam-glass}"
    rounded: "{rounded.panel}"
    padding: "24px"
  discovery:
    backgroundColor: "linear-gradient(rgb(255 255 255 / 23%), rgb(255 255 255 / 23%)), linear-gradient(135deg, #ff69b4, #ff1493)"
    textColor: "{colors.ink}"
    rounded: "{rounded.discovery}"
    padding: "25px 27px 21px"
---

# Design System: Nexus Pink Glam

## Overview

**Creative North Star: "Pink Glam / Y2K Sparkle"**

Cream pink light, glossy rose-to-hot-pink discovery and plum type give Nexus the feel of a personal study space. Translucent materials, a glossy heart ornament, pearl-like dust and geometric four-point twinkles create the more extravagant sparkle requested by the user while compact resource and borrowing information remains easy to scan.

This is the user-pinned desktop skin, extracted from `public/assets/pink-glam.css` and `public/assets/pink-glam-effects.js`, with CSS layered after `campus.css` and `campus-desktop.css`. The values in the frontmatter apply from 1000px; smaller screens retain the existing Open Campus skin. The exact existing composition, components, text and live data are binding constraints. The specific surface contract is `.impeccable/surfaces/pink-glam.md`; the older application contract now points to the same direction. No approved image comp exists: implementation is code-led.

**Key Characteristics:**
- Cream pink ground and a glossy rose-to-hot-pink discovery banner.
- Frosted surfaces, plum type and magenta actions.
- Capsule navigation with a four-point destination twinkle.
- Self-hosted Vietnamese-capable typography and expressive sparkle effects with a persistent pause control.

## Colors

### Primary

Glam primary colors actions and keyboard focus; its darker hover variant supports interaction. Rose and hot pink form the discovery gradient, with a white overlay at 23% to support plum text. The historically named teal and coral tokens now resolve to deeper magenta for links and assistant cues. Campus-green is a compatibility alias for incumbent selectors, not a request to restore green desktop navigation.

### Secondary

Gold retains warning meaning; danger retains problem meaning. Approved status uses plum on pale pink, warning uses ochre on pale cream, danger uses red on pale rose, and completed requests remain neutral. Preserve visible status wording alongside color.

### Neutral

Paper is cream pink; paper-deep supports grouped content. White is a near-white pink field surface. Glass and shine supply translucent material and highlights; ink, muted and line establish readable plum text and fine rose separators.

**The Readable Gloss Rule.** Keep the discovery banner's white softening layer and dark plum labels together; do not remove the overlay while retaining the same text treatment.

## Typography

Headings use Manrope with Be Vietnam Pro and sans-serif fallbacks; body and controls use Be Vietnam Pro. Both remain self-hosted through `public/assets/fonts/campus-fonts.css`, with their OFL licenses. The skin introduces no font download or new type scale.

The student greeting uses display with an extra-bold emphasized span; standard screen headings use headline, and panel headings use title. Discovery headings remain 25px, weight 800, line-height 1.35. Desktop body text remains 14px, meaningful metadata 12–13px, request titles 14px and status chips 11px. Numeric statistics and table/ranking values use tabular numerals where styled.

Learning-kit section-heading remains the result heading; title is the smaller panel/resource-group role. Visible form labels are 12px at weight 600; source links use regular weight and line-height 1.7. Supporting paragraphs retain their incumbent line-height. Below desktop widths, the existing typography and greeting reductions remain unchanged.

## Layout

Preserve the existing shell and spacing. At wide desktop sizes the labelled sidebar is 220px, main inline padding 44px, header 88px and content cap 1720px. The student workspace has a flexible main column and a 296px personal activity column, separated by a ruled gutter of 32px. The reskin changes material and color without moving or replacing components.

At 761–1279px the incumbent sidebar is 200px, main padding 26px and personal column 245px. At 1000px and below the workspace columns stack; the Pink Glam skin starts at 1000px, so exactly 1000px retains that stacked composition with the new skin. At 760px and below the existing single-column shell, 20px inline padding, menu toggle and expanded two-column navigation remain. The greeting retains its 36px intermediate and 34px mobile sizes.

Desktop room filters retain six columns from 1280px, grouped into three at 1000–1279px. Existing cart entry, persistent room-filter labels, date/time recap and account-specific learning-kit disclosure retain their positions and behavior. The separate React example uses the real CSS with data and callbacks; it does not migrate the PHP application.

## Elevation & Depth

Frosted sidebar and ordinary panels use backdrop blur (10px). Main student reading groups and personal panels retain their open, square, borderless composition with a very faint translucent gradient and no backdrop blur. Fine rose rules continue to organize activity and book rows.

The shared shadow is `0 16px 40px rgb(122 26 78 / 12%)`. Discovery combines a stronger diffuse rose shadow, two concentric cream/pink glazes and an inset white highlight. Its moving liquid-light sheen and glossy SVG heart with an orbital ellipse amplify the material. Active navigation and primary actions have smaller rose shadows. Button hover adds a soft pink glow. Do not apply discovery elevation to each list row. Full CSS values and motion live in `.impeccable/design.json`.

## Shapes

Existing panel and discovery radii stay intact. The desktop search becomes a rounded capsule (28px), its action uses 22px corners, and active navigation uses 24px corners without changing its padding or height. The destination marker is a four-point twinkle (10px), and a 29px animated twinkle sits beside the greeting. The 120px heart ornament is absolutely positioned above discovery; its orbit and sheen do not alter the banner dimensions. Book cover silhouettes retain their incumbent asymmetric corners.

## Components

Primary actions pair magenta with white, keep their incumbent dimensions (44px minimum for the shared primary button and 45px for discovery search), darken on hover and show one shimmer pass. Other task-specific button sizes remain inherited. Keyboard focus keeps the existing outline dimensions (3px, offset 4px) with magenta color; the grouped discovery search uses a white-and-magenta focus-within ring. Disabled buttons keep the inherited opacity (0.55).

The search keeps the same transparent input, label, tabs and action inside a near-white field. Ordinary fields use white and the rose line token, shifting border color on focus. Active navigation uses a magenta gradient capsule, white label and a trailing decorative four-point marker; expanded mobile navigation retains its existing labels and circular marker below desktop width.

Resource panels and the learning-kit disclosure inherit the glass material. Popular-book and activity rows remain ruled lists. Existing goal/time/level labels, recommendation reasons, verified PDF links, suggested practice, availability and proposed return date stay distinct; adding books to the cart remains separate from submitting a borrowing request.

The amplified atmosphere mounts 28 fixed decorative stars/pearls (seven are pearls) behind the workspace, plus a glossy heart-and-orbit SVG over discovery. Dust cycles vary from 4.5 to 8.5 seconds; discovery sparkle remains on a 4.8-second cycle, liquid sheen takes 9 seconds, the greeting twinkle 5 seconds and the heart float 6 seconds. Enabled primary actions keep the 700ms hover shimmer. All decoration is CSS, inline SVG or canvas; this skin introduces no shipping raster asset.

Fine-pointer movement can emit two short-lived canvas stars every 55ms; a pointer release on an enabled button or link emits a 14-particle burst, excluding the effects toggle. Trails last 600ms and bursts 850ms, with at most 90 particles and device-pixel ratio capped at 1.5. RequestAnimationFrame runs only while particles remain alive; overlays ignore pointer events and preserve component positions and interaction.

A fixed circular star control (44px, 20px from the lower-right corner) exposes its state through aria-pressed and a Vietnamese accessible label. Its pause choice persists under `nexus-glam-effects` in localStorage; storage failure does not prevent operation. Pausing hides dust and canvas, stops canvas frames, pauses decorative loops and suppresses hover shimmer while leaving static material in place. Hidden pages pause the same effects. IntersectionObserver pauses the banner and greeting loops when those elements leave the viewport.

Reduced-motion preferences keep static decoration and disable animation, transitions and canvas particles. Effects activate only from 1000px. `pink-glam-init.js` mounts the shared module in PHP; the React example imports the same module, mounts it in useEffect and calls its cleanup on unmount. Cleanup removes listeners, observers, animation frames and injected elements.

## Do's and Don'ts

- **Do** preserve the exact existing layout, components, Vietnamese text and live data.
- **Do** pair Manrope headings with Be Vietnam Pro body copy.
- **Do** preserve visible keyboard focus and reduced-motion behavior.
- **Do** keep the desktop skin scoped from 1000px and retain the smaller-screen Open Campus presentation.
- **Don't** turn every activity row into an elevated card.
- **Don't** replace the PHP frontend with the separate React example.
- **Don't** hardcode account identity, inventory or activity to match a demonstration.
