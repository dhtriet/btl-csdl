# Nexus Resource Center

<!-- impeccable:product-schema 1 -->

## Platform

web

## Users

Students discover books, request loans, reserve study rooms, borrow equipment, and track their own activity. Librarians process requests and returns; administrators manage accounts and resources. The user confirmed that this redesign prioritizes the student experience.

## Product Purpose

Bring the center's learning resources and students' borrowing activity into one Vietnamese application.

## Capabilities and Constraints

Students can create a learning kit from a goal, number of weeks, daily study time and current level. Recommendations contain up to three real catalog books, suggested reading focus, available PDF sources and weekly practice. The latest kit is private to each account. Adding selected books to the existing cart requires a separate borrowing submission. Preserve the distinction between catalog metadata, verified PDF passages and suggested exercises.

Existing PHP/MySQL backend and plain HTML, CSS, JavaScript frontend. Preserve authentication, permissions, CSRF, existing data, resource workflows, PDF reading, and the learning assistant. Keep staff workflows available. No database changes are required for this frontend redesign.

## Evidence on Hand

README.md, public/views/app.php, public/assets/app.js, assistant.js, manage.js, and the existing API. Resource availability and activity must come from the API; do not invent inventory, recommendations, or opening hours.

## Brand Commitments

Retain Nexus and Vietnamese product terminology. No visual palette or typography has been pinned by the user.

## Product Principles

- Make finding and using learning resources easy.
- Keep personal deadlines and request status clear.
- Preserve actual availability and permission boundaries.
- Support keyboard navigation and smaller viewports.
