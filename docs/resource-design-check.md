# Resource extension design check

Reviewed 2026-11-04 against the incumbent Open Campus system in `DESIGN.md` and `.impeccable/design.json`, with product context from `PRODUCT.md` and the document workflow in `.agents/skills/impeccable/reference/document.md`.

This is an ordinary extension of the existing desktop interface. No new visual direction, component-system expansion, or design-system rewrite was requested. `DESIGN.md` and its sidecar remain unchanged.

## Result

The resource visibility controls, management thumbnails, photo editor, illustration labels, and room/equipment photography fit the incumbent green-and-cream interface. No new palette, font family, shadow vocabulary, or global spacing token is introduced by `public/assets/resource-gallery.css`. The implementation keeps the labelled navigation, green destination marker, warm reading surfaces, ruled equipment rows, and ink primary actions.

## Source comparison

| Area | Checked implementation | Finding |
| --- | --- | --- |
| Palette | `resource-gallery.css`, loaded after `campus.css`, `campus-desktop.css`, and `learning-kit.css` in `public/views/app.php` | Uses existing paper-deep, white, ink, muted, line, forest-green, and danger variables. Visibility has a written Hiện/Đã ẩn label and different marker shapes; delete uses the existing danger color. |
| Typography | `campus.css`, `campus-desktop.css`, `manage.js`, `app.js` | Manrope headings and Be Vietnam Pro body/control fonts remain inherited. New helper text and illustration captions use the existing 12px label scale; desktop shell body remains 14px. |
| Spacing and shape | `resource-gallery.css` | Existing 7px action-radius language is reused for photos/captions and the visibility filter. Toolbar gaps use 12px/16px. Photograph dimensions and 14px thumbnail gap are local content geometry, not new universal tokens. Panel padding/radius remain inherited at 24px/14px. |
| Depth and structure | Room/equipment galleries and management/editor markup | Photos add content to existing surfaces. Equipment stays a ruled list, management stays a table, and modal elevation stays inherited. |
| Focus and semantics | Shared focus rule, editor labels, photo renderer | New inputs/buttons inherit the forest outline. Image preview, remove action, visible illustration checkbox, and visibility select are labelled. Decorative table thumbnails have empty alternative text next to the resource name; gallery images name the resource and identify illustrations. |
| Desktop adaptation | Gallery stylesheet | Main/secondary columns use a 260px secondary panel on desktop and stack at 1000–1250px. Equipment photos become 112px by 88px from 1000px. These are local desktop layout accommodations. Mobile redesign was outside the review scope. |

## Rendered evidence

Evidence is stored under `.impeccable/review/resources/`. The capture set includes catalog, spaces, equipment, all four management tabs, equipment editor top/bottom, and room editor bottom at 1024px, 1440px, and 1920px. `results.json` records those three widths with an empty errors array. The capture script checks horizontal page overflow, student-gallery image loading, and JavaScript errors; this document does not claim to have rerun it.

Direct visual inspection for this documentation pass covered:

- `manage-rooms-1024.png`: thumbnails, operating status, visibility labels, and edit/hide/delete actions fit the table; warm shell and green destination marker remain intact.
- `editor-1024.png`: visible field labels, two-column form, inherited modal surface, and forest focus ring remain consistent. Lower fields are reached by scrolling within the existing modal.
- `catalog-1440.png`: cover images retain their full silhouettes within the incumbent catalog cards; missing covers retain the existing fallback.
- `equipment-1440.png`: photographs and readable illustration labels fit the existing ruled rows without adding elevated cards.
- `spaces-1920.png`: illustrated room photography sits within existing green-tinted room cards, with the filter recap and secondary pending panel retained.
- `manage-copies-1920.png`: copies remain identified by barcode and parent title, with shared cover thumbnails and a separate visibility label.
- `room-editor-bottom-1920.png`: image preview, remove action, checked illustration control, cancel, and save are visible together after scrolling.

Full-page editor screenshots show the fixed backdrop only over the 1000px browser viewport; the undimmed document below that area is a full-page capture artifact, not evidence that the dialog backdrop fails in the viewport.

## Incumbent drift and limits

The existing design documents accurately describe the overall world, but their examples are not exhaustive specifications for every staff workflow. Compact management tables inherit 12px body text, 11px headers, and smaller metadata from the earlier stylesheets; the extension does not create a new compact reading scale. The inherited editor uses an 18px field gap, 30px modal padding, and a 16px modal radius, which are not enumerated as staff-modal tokens in `DESIGN.md`.

There is one concrete pre-existing sidecar mismatch: its Status Chip preview uses a 10px font and fully rounded corners, while the desktop implementation uses 11px text and inherits a 5px corner radius from `desktop.css`. `DESIGN.md` already states the desktop 11px status size. No status-chip styling is added by this resource extension. Existing room-card colors and other supporting greens are also literal tonal variants in `campus.css`, rather than individually listed frontmatter tokens. These observations do not justify expanding or rewriting the system for this extension.

This pass reviews source and saved desktop evidence. It is not a new mobile review, live keyboard audit, backend regression run, or independent image-license/embedded-metadata certification.

## Resource documentation accuracy

`docs/resource-management.md` accurately describes the reviewed implementation: separate titles/copies, four independent visibility fields, staff edit/hide controls, admin-only soft deletion with a history-preserving confirmation, photo upload/preview/remove, and a room/equipment illustration flag that clears when a replacement file is selected. Source spot checks in `app/resources.php` agree with the documented soft-delete timestamp, active-loan/request deletion guards, accepted JPG/PNG/WebP content, 2 MB limit, 8000px dimension limit, and randomized upload names.

`docs/resource-image-import.json` contains 16 book mappings, 9 room mappings, and 9 equipment mappings across 25 distinct asset paths, agreeing with the documentation. Reusing illustration images across resources is explicit in the manifest and in the visible illustration labels. Source/author/license entries are present for room/equipment images; book entries record the supplied local source paths. The manifest records import provenance rather than a promise that every resource has a distinct image.

The existing system documents intentionally do not enumerate these new task-specific controls. Keeping the feature behavior and image provenance in the resource documentation preserves that separation without making the incumbent design contract inaccurate.
