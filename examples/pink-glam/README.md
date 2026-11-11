# Nexus Pink Glam — React component example

The running application remains PHP + HTML + vanilla JavaScript. Its complete HTML is in `public/views/app.php`; the desktop skin is `public/assets/pink-glam.css`, loaded after the existing styles. No React runtime or build step was added to that application.

`NexusStudentPortal.jsx` provides the corresponding React dashboard with named components: `Sidebar`, `PortalHeader`, `DiscoveryBanner`, `PopularBooks`, and `PersonalStudyRail`. It imports the same real CSS rather than maintaining a second palette. Use it inside an existing React bundler project (React 18+), preserving the import paths or copying the referenced styles and self-hosted font assets together.

```jsx
import NexusStudentPortal from './examples/pink-glam/NexusStudentPortal.jsx';

// Load the authenticated user and resource data through your application layer.
// The callback functions connect the dashboard to your router and dialogs.
<NexusStudentPortal
  user={user}
  stats={{ borrowed: 0, overdue: 0, pending: 0, rooms: 0 }}
  books={popularBooks}
  loans={activeLoans}
  requests={recentRequests}
  onNavigate={navigateToView}
  onSearch={searchCatalog}
  onOpenBook={openBookDetails}
  onCreateKit={openLearningKit}
  onProfile={openProfile}
  onLogout={logout}
/>
```

The zero statistics in this usage snippet illustrate the empty state; replace them with API values. The component never submits borrowing requests or changes accounts itself. Required callback props must be supplied by the host application.

Data contracts:

| Prop | Shape |
| --- | --- |
| `user` | `{ full_name: string }` |
| `stats` | `{ borrowed: number, overdue: number, pending: number, rooms: number }` |
| `books` | `[{ id, title, authors, borrow_count, cover_url? }]` |
| `loans` | `[{ id, resource_type, resource_name, due_label, quantity, overdue }]` sorted by return deadline; `resource_type` is `book` or `equipment`, `due_label` is the formatted return date, and positive `overdue` marks an overdue loan |
| `requests` | `[{ id, title, created_label, description, status_label, tone? }]` where tone is `warning`, `danger`, or empty |
| `date` | Optional `Date`; defaults to the current date, displayed in Vietnam time |

The desktop skin starts at 1000px, matching the requested web-only scope. Existing narrower-screen rules are retained. The React component mounts the same `mountGlamEffects()` module as PHP and cleans it up on unmount. It adds floating stardust, a glossy heart ornament, a moving hero highlight, pointer sparkle trails and button click bursts. The round sparkle control pauses effects and remembers the choice locally. Loops pause when the page is hidden; banner and heading loops pause when offscreen. Canvas frames run only while particles are alive (maximum 90, device pixel ratio capped at 1.5). `prefers-reduced-motion` keeps static decoration and disables particle motion. Inputs, navigation and actions retain visible keyboard focus. Frosted surfaces have solid-color fallbacks when backdrop filtering is unavailable.
