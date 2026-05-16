# TikTok Business API

## Account types

- TikTok for Business / Creator (with Insights opt-in)

## App setup

1. Register at https://developers.tiktok.com/
2. Apply for the **Display API** + **Research API** product (or Marketing
   API for ads-side metrics).
3. OAuth redirect: `https://<supabase-project>.supabase.co/functions/v1/oauth-tiktok/callback`

## Scopes

- `user.info.basic`
- `user.info.stats`
- `video.list`
- `video.insights`

## App Review

TikTok requires a sandbox demo + screencast + privacy URL before production
access. Note: free tier rate limits are strict — design `sync-metrics`
backoff accordingly.

## Endpoints (M8)

- `POST /v2/user/info/`
- `POST /v2/video/list/`
- `POST /v2/research/video/query/` (research API)
