# Regression tests

## Circulation extension

After cloning a dedicated test database and running `php scripts/migrate-circulation.php --apply` against that test database, run `python tests/circulation.py` with the same `NEXUS_DB_*` environment. It starts hidden PHP servers on ports 8014/8015 and tests role/CSRF enforcement, full admin profiles, atomic multi-item counter loans, online-to-receipt links, ownership, returns, inventory reconciliation, stale versions, audit logging and two sessions competing for the last equipment unit. It only accepts `resource_center_test_<digits>`. Fixtures remain in that test database. The JSON result and server log are written under ignored `tests/output/`. Optional `NEXUS_TEST_PASS` changes the demo login password for this test.

`php tests/schema-circulation.php` creates a new database named `resource_center_test_<timestamp><random>` (refusing an existing name), loads the actual schema/seed, runs the migration twice, verifies inventory balances, and directly checks the new FK, UNIQUE and CHECK protections. It leaves this isolated database for inspection. The local database user therefore needs permission to create test databases. `docs/teacher-demo.sql` contains read-only demonstration queries for Workbench.

`node tests/circulation-ui.cjs` checks the shipped asynchronous inventory/trace renderers with reversed success/error responses and sign-out invalidation. It uses an isolated mocked DOM and deferred API promises; it does not access the browser or database.

## Existing regression suite

Tests create and edit fixtures only in a dedicated MySQL database named
`resource_center_test_<digits>`. They refuse to run without that explicit name.
The test database is disposable; never point this runner at the working database.

Prerequisites: PHP with PDO MySQL, Node.js, Playwright and Chrome.
Clone the schema and seed data (or a backup) into your dedicated test database first.
The app credentials in `app/config.php` must have access to that database.

PowerShell:

```powershell
$env:NEXUS_DB_NAME = 'resource_center_test_20261103'
node tests/regression.cjs
Remove-Item Env:NEXUS_DB_NAME
```

Optional environment variables: `NEXUS_PHP`, `NEXUS_CHROME`,
`NEXUS_PLAYWRIGHT_MODULE` (an existing Playwright package path).
Ports 8011 and 8012 must be free. The runner stops its two PHP servers on exit.

Coverage: anonymous access, roles, student ownership, CSRF, resource validation,
stale edits, image uploads, two concurrent approvals competing for the last copy,
duplicate approval, final equipment unit, overlapping room bookings, maintenance
on return, password migration, and desktop flows for all three demo roles.

Concurrency checks hold an InnoDB row lock, start requests against two independent
PHP servers, then release the lock. This exercises real database contention instead
of relying on a single-threaded server or a shared PHP session to serialize work.

Fixtures remain in the dedicated test database for inspection. Results and images
are written to `tests/output/`; this directory is ignored by git.

## MySQL integrity constraints

On an isolated database cloned from a backup, run the migration and direct SQL tests:

```powershell
$env:NEXUS_DB_NAME = 'resource_center_test_2026110401'
php scripts/migrate-integrity.php --apply
php tests/integrity.php
node tests/regression.cjs
```

`integrity.php` rolls back all its fixtures. It checks invalid quantities, stock,
date ordering, NULL-sensitive return state, calculated late days, extension limits,
room times, duplicate active loans and re-borrowing after return. Regression also
checks that forged client return results cannot override the dates, repeated return
is rejected, and equipment maintenance survives return.

To verify fresh schema/seed and generated-column-aware dump restoration, provide
two new database names which do not already exist:

```powershell
php tests/bootstrap-integrity.php resource_center_test_2026110404 resource_center_test_2026110403
```

The bootstrap refuses non-test names and unexpected USE statements in schema/seed.
It compares all restored row data, including generated values and timestamps.
The example target names were used in the local validation; choose new names on rerun.
