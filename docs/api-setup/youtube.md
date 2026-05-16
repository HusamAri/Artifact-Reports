# YouTube Data API v3 + YouTube Analytics API

## Account types

- Any channel owner (signed in with Google).

## App setup

1. Create a project in Google Cloud Console.
2. Enable **YouTube Data API v3** and **YouTube Analytics API**.
3. OAuth consent screen → External, with verified domain.
4. Redirect URI: `https://<supabase-project>.supabase.co/functions/v1/oauth-youtube/callback`

## Scopes

- `https://www.googleapis.com/auth/youtube.readonly`
- `https://www.googleapis.com/auth/yt-analytics.readonly`
- `https://www.googleapis.com/auth/yt-analytics-monetary.readonly` (optional)

## Quota

Each Data API call costs 1–100 units; default 10,000 units/day. Budget
`sync-metrics` carefully — channel-level reports are cheap, per-video
analytics adds up.

## Endpoints (M8)

- `GET youtube/v3/channels?part=statistics`
- `GET youtube/v3/playlistItems?part=snippet&playlistId=UU...`
- `GET youtubeAnalytics/v2/reports?ids=channel==MINE&metrics=views,likes,subscribersGained`
