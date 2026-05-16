# Instagram (Meta Graph API)

## Account types supported

- Instagram Business Account (linked to a Facebook Page)
- Instagram Creator Account

Personal accounts are **not** supported by Graph API and must use file
upload / OCR / manual instead.

## App setup

1. Create a Meta App at https://developers.facebook.com/apps/
2. Add product: **Instagram Graph API** and **Facebook Login**.
3. Configure OAuth redirect: `https://<supabase-project>.supabase.co/functions/v1/oauth-instagram/callback`

## Required permissions / scopes

- `instagram_basic`
- `instagram_manage_insights`
- `pages_show_list`
- `pages_read_engagement`
- `business_management` (only if Business Suite features are used)

## App Review

Production access requires Meta App Review with:
- Use-case write-up (what data you read and why).
- Screencast walking through the connect flow.
- Privacy policy URL (M9 — link from settings).

## Endpoints (M3)

- `GET /{ig-user-id}/insights?metric=impressions,reach,profile_views&period=day`
- `GET /{ig-user-id}/media?fields=id,caption,media_type,timestamp,like_count,comments_count`
- `GET /{ig-media-id}/insights?metric=engagement,impressions,reach,saved`
