# Architecture

## High-level

```
┌──────────────────────┐         ┌──────────────────────────┐
│   Flutter iOS app    │◄────────┤   Supabase (managed)     │
│  (Riverpod + GoRouter)│ HTTPS  │  Postgres + Auth + Storage│
└──────────────────────┘         │  Edge Functions (Deno)    │
         │                       └──────────────────────────┘
         │ StoreKit 2                       ▲
         ▼                                  │
┌──────────────────────┐         ┌──────────────────────────┐
│  App Store Server    │────────►│   storekit-webhook fn    │
│   Notifications v2   │  JWS    │   (JWT verify, update    │
└──────────────────────┘         │    subscriptions table)  │
                                 └──────────────────────────┘
                                            ▲
                                            │ cron (pg_cron)
                                            │
                                 ┌──────────────────────────┐
                                 │  sync-metrics function   │
                                 │  (per-platform pollers)  │
                                 └──────────────────────────┘

┌──────────────────────┐         ┌──────────────────────────┐
│   Next.js web-report │◄────────┤  Supabase anon client    │
│   /r/[publicId]      │ SSR     │  (RLS: visibility=public)│
└──────────────────────┘         └──────────────────────────┘
```

## Data flow per ingestion source

1. **API** — OAuth → tokens encrypted in `social_accounts` → `sync-metrics`
   cron writes to `metrics_snapshots`.
2. **CSV / JSON** — Uploaded to `uploads` bucket → Edge fn parses → rows in
   `metrics_snapshots` with `source='csv'`.
3. **Manual** — Flutter form → direct insert with `source='manual'`.
4. **Screenshot OCR** — Image to `screenshots` bucket → `ocr-screenshot` fn
   calls Claude Vision → structured metrics → `metrics_snapshots` with
   `source='ocr'`. `ocr_usage` table meters per-workspace cost.

## Why this stack

- **Flutter**: single codebase, near-native UI on iOS, Android door open.
- **Supabase**: Postgres + Auth + Storage + Edge + Realtime in one box,
  open-source escape hatch.
- **StoreKit 2 direct**: no extra SaaS surface area; webhook verification
  controlled in-repo.
- **Next.js for web-report**: SEO + dynamic OG image + tiny payload vs.
  Flutter web (~2 MB).

## Module boundaries

| Module | Owns |
|---|---|
| `app/lib/core` | Theme, routing, network clients, secure storage, error types |
| `app/lib/features/*` | Feature-local UI, providers, repositories, models |
| `app/lib/shared` | Cross-feature models, providers |
| `supabase/migrations` | Schema, RLS, encryption |
| `supabase/functions` | OAuth callbacks, sync, webhooks, OCR, PDF |
| `web-report` | Public shareable report viewer |
| `packages/shared-types` | Generated DB types (TS + Dart) |
