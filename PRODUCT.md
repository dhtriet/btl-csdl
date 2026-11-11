# Nexus Resource Center

<!-- impeccable:product-schema 1 -->

## Platform

web

## Users

Students discover books, request loans, reserve study rooms, borrow equipment, and track their own activity. Librarians process requests and returns; administrators manage accounts and resources. The user confirmed that this redesign prioritizes the student experience.

## Product Purpose

Bring the center's learning resources and students' borrowing activity into one Vietnamese application.

## Capabilities and Constraints

Librarians can issue multi-item book or equipment loans directly to a selected student at the counter. Counter and online requests share allocation, transaction and return rules; each new receipt has an explicit unique request link. Admins can inspect full reader/librarian contact profiles and related history without authentication secrets. The canonical schema has 26 tables; normalization notes explicitly disclose derived fields and controlled denormalization. Schema reference and ERD are generated from the same live metadata.

Students can create a learning kit from a goal, number of weeks, daily study time and current level. Recommendations contain up to three real catalog books, suggested reading focus, available PDF sources and weekly practice. The latest kit is private to each account. Adding selected books to the existing cart requires a separate borrowing submission. Preserve the distinction between catalog metadata, verified PDF passages and suggested exercises.

Existing PHP/MySQL backend and plain HTML, CSS, JavaScript frontend. Preserve authentication, permissions, CSRF, existing data, resource workflows, PDF reading, and the learning assistant. Keep staff workflows available. The Pink Glam skin preserves the existing layout. The circulation extension requires the backed-up migration in scripts/migrate-circulation.php and the corresponding 26-table schema; its generated schema reference, ERD and normalization notes describe that implementation.

## Evidence on Hand

README.md, public/views/app.php, public/assets/app.js, assistant.js, manage.js, and the existing API. Resource availability and activity must come from the API; do not invent inventory, recommendations, or opening hours.

## Brand Commitments

Retain Nexus and Vietnamese product terminology. The user pinned Pink Glam / Y2K Sparkle for the desktop web interface: cream pink ground, hot pink glossy discovery banner, translucent sidebar and cards, magenta actions, plum text and restrained animated sparkles. Preserve the exact existing layout, components, text and live data. Retain the existing self-hosted typography. Phone redesign remains outside this pass. Apply the skin to the existing PHP/HTML/CSS application and provide a separate React component example without migrating the running frontend.

## Product Principles

Students request book renewals from their own active loans. Librarians approve the requested date or reject with a reason; they cannot renew directly. Pending requests do not change deadlines. A loan has at most one pending request and three approved renewals. See docs/extension-requests.md and scripts/migrate-extension-requests.php.

- Make finding and using learning resources easy.
- Keep personal deadlines and request status clear.
- Preserve actual availability and permission boundaries.
- Support keyboard navigation and smaller viewports.
