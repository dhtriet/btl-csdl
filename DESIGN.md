---
name: Open Campus
description: A welcoming resource workspace on apple green and warm cream.
colors:
  paper: "#f5f1e4"
  paper-deep: "#e9eadb"
  ink: "#2c2e2a"
  muted: "#62665a"
  line: "#d8dacb"
  teal: "#365c2a"
  coral: "#b6432d"
  gold: "#795619"
  danger: "#b03928"
  white: "#fffdf7"
  campus-green: "#8ed462"
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
  navigation: "10px"
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
    backgroundColor: "{colors.ink}"
    textColor: "{colors.paper}"
    rounded: "{rounded.action}"
    height: "44px"
  search-field:
    backgroundColor: "{colors.paper}"
    textColor: "{colors.ink}"
    rounded: "{rounded.field}"
    padding: "6px 6px 6px 16px"
  navigation-active:
    backgroundColor: "{colors.ink}"
    textColor: "{colors.paper}"
    rounded: "{rounded.navigation}"
    padding: "10px 24px 10px 12px"
  panel:
    backgroundColor: "{colors.white}"
    rounded: "{rounded.panel}"
    padding: "24px"
  discovery:
    backgroundColor: "{colors.campus-green}"
    textColor: "{colors.ink}"
    rounded: "{rounded.discovery}"
    padding: "25px 27px 21px"
---

# Design System: Open Campus

## Overview

**Creative North Star: "Open Campus"**

Apple green discovery surfaces sit on warm cream, with ink navigation and quiet ruled lists. Manrope headings and Be Vietnam Pro body copy give the workspace a welcoming, readable character. Color draws attention to finding resources while personal activity remains compact.

**Key Characteristics:**
- Apple green and warm cream.
- Dark navigation with a circular green destination marker.
- Rounded controls and quiet ruled activity lists.
- Self-hosted Vietnamese-capable typography.

This records the built system in `public/assets/campus.css`, loaded after the incumbent stylesheets. The approved surface contract lives in `.impeccable/surfaces/public-views-app-php.md`; surface composition is not a universal component rule.

## Colors

### Primary

Campus green identifies discovery and the active navigation marker. The historically named teal token is forest green: it colors links, input carets, and focus outlines.

### Secondary

Coral marks the assistant entry; gold supports warning language. Danger remains reserved for actionable problems.

### Neutral

Paper is the page ground; paper-deep groups filters and supporting content. White is a warm panel surface. Ink, muted, and line establish text hierarchy and separators.

**The Purposeful Green Rule.** Use campus green for discovery and destination cues; keep long reading areas on paper or white.

## Typography

Headings use Manrope with Be Vietnam Pro and sans-serif fallbacks; body and controls use Be Vietnam Pro with sans-serif fallback. Both families are self-hosted through `public/assets/fonts/campus-fonts.css`; retain the accompanying OFL licenses.

The student greeting uses the display role with an extra-bold emphasized span. Standard screen headings use headline; panel headings use title. Discovery headings use a heavier intermediate scale (25px, weight 800, line-height 1.35), reducing to 22px on mobile. At desktop widths of 1000px and above, `public/assets/campus-desktop.css` sets body text to 14px, meaningful metadata to 12–13px, request titles to 14px and status chips to 11px. Below that width, the existing compact typography remains unchanged. Do not shrink new reading content to match legacy small labels.

In the learning kit, section-heading identifies the result heading; title remains the smaller panel and resource-group role. Label identifies visible form labels and compact metadata. Form labels use weight 600, while source links use regular weight and a slightly looser line-height (1.7). Explanatory paragraphs use the body size with line-height 1.8–1.85. The result heading and form labels inherit the shell body line-height; the extension does not impose the panel heading line-height on them.

## Layout

The desktop shell has a labelled sidebar (220px), main inline padding (44px), and a header (88px). Main content is capped at 1720px. The student workspace uses a flexible main column and a personal activity column (296px), separated by a ruled gutter (32px).

At 761–1279px the sidebar becomes 200px, main padding 26px, and personal column 245px. At 1000px and below the workspace columns stack. At 760px and below the shell becomes a single column with 20px inline padding, an explicit menu toggle, and two-column navigation when expanded. Student discovery, personal status, and book lists reorder for narrow screens. The greeting steps down to 36px at intermediate widths and 34px on mobile.

## Elevation & Depth

Tonal surfaces and fine separators carry most hierarchy. Open student lists are transparent and unboxed; panels remain appropriate elsewhere. The modal uses the shared soft shadow (`0 12px 32px rgb(44 46 42 / 10%)`) over a dimmed backdrop. Do not apply modal elevation to every content group.

## Shapes

Controls use modest rounded corners; panels and discovery surfaces use larger radii from the frontmatter. Separators are thin and low contrast. Book cover silhouettes keep small asymmetric corners; destination markers remain circles.

## Components

The learning-kit extension uses a native disclosure above the assistant, with visible goal/time/level labels and a 24px result section heading. Recommendation and week content are ruled rows, with 12px labels and source links, 13px explanatory text and 14px resource titles. It inherits the existing palette and radii. Book reasons, verified PDF links, suggested practice and current availability have distinct labels. A separate cart action asks for a proposed return date and makes clear that adding books does not submit the borrowing request. Source: `public/assets/learning-kit.css`.

Desktop refinements are isolated in `public/assets/campus-desktop.css` at a minimum width of 1000px. Empty loan carts show a direct resource-selection action and hide notes/submission until an item is present. Room filters have persistent visible labels and a checked date/time recap; the filter uses six columns at 1280px and above, grouped into three columns at 1000–1279px. Approved request history uses the same green as dashboard approval, while completed requests use a neutral treatment. Mobile layout improvements were explicitly excluded from this pass.

Primary actions pair ink with paper text and darken to a green-tinted ink on hover. They are at least 44px tall; the discovery search action is 45px tall. Secondary text actions remain visually quiet.

The discovery search groups a transparent input and primary action within a paper field. Other inputs use the warm white surface and line border. Interactive elements receive a forest outline (3px, offset 4px) on keyboard focus; disabled buttons reduce opacity to 0.55.

Active navigation uses ink fill, paper text, and a trailing green circle (9px). Expanded mobile navigation keeps labels. The marker has a short scale animation (320ms); reduced-motion preferences remove animations and transitions.

Status chips combine green text and pale green backgrounds, with distinct warm warning and red danger variants. Resource cards use warm white, a fine line border, and a slightly greener border on hover. Student activity and book lists use ruled rows rather than elevated tiles.

## Do's and Don'ts

- **Do** pair Manrope headings with Be Vietnam Pro body copy.
- **Do** preserve visible keyboard focus and reduced-motion behavior.
- **Do** distinguish discovery surfaces from quiet reading areas.
- **Don't** turn every activity row into an elevated card.
- **Don't** replace the green destination marker with an unlabeled navigation state.
