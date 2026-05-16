# Artifact-Reports

Social media analytics & reporting app for iPhone. Connect business accounts
via API, upload CSV/JSON, enter data manually, or paste a screenshot — and
get a clean dashboard, PDF export, and shareable web link.

> Status: **M1 — repository skeleton.** No runnable code yet beyond stubs.

## Stack

- **App**: Flutter (iOS-first, Android door open) · Riverpod · go_router · freezed
- **Backend**: Supabase (Postgres + Auth + Storage + Edge Functions on Deno)
- **Payments**: Apple StoreKit 2 direct (no RevenueCat) via `in_app_purchase`
- **Web report**: Next.js 15 (App Router) at `/r/[publicId]`
- **i18n**: TR + EN (`intl` + `.arb`)

## Supported platforms (data sources)

Instagram · TikTok · YouTube · X (Twitter) · LinkedIn · Google Business Profile · Uberall

Each via official API (where available) **plus** CSV/JSON upload, manual
entry, and AI/OCR from screenshots.

## Monorepo

```
app/           Flutter iOS app
supabase/      Postgres migrations, edge functions, config
web-report/    Next.js shareable report viewer
packages/      Shared generated types
docs/          Architecture, schema, design system, per-platform API setup
scripts/       bootstrap, gen-types, new-migration
.github/       Workflows + PR template
```

## Quick start

```bash
./scripts/bootstrap.sh
```

Installs Flutter deps, generates localizations, installs `web-report/`
packages, and starts Supabase locally (if Docker is running).

## Roadmap

| Milestone | Scope |
|---|---|
| M1 | Skeleton, schema DDL, CI, docs (this PR) |
| M2 | Auth, workspace CRUD, RLS, token encryption |
| M3 | Instagram OAuth + sync pilot |
| M4 | Dashboard UI matching reference design |
| M5 | CSV / manual / screenshot OCR ingestion |
| M6 | StoreKit 2 + paywall |
| M7 | PDF export + shareable web link |
| M8 | TikTok, YouTube, X, LinkedIn, GBP, Uberall |
| M9 | TestFlight + App Review |

## Project tracking

Notion: **Artifact Studio › Projects › Artifact-Reports** (link added once
the page is created).

## License

Proprietary — see [LICENSE](./LICENSE).
