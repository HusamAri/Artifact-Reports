# Google Business Profile (formerly Google My Business)

## Account types

- Google Business Profile (location owner / manager)

## App setup

1. Google Cloud Console → enable:
   - **Business Profile Performance API**
   - **My Business Account Management API**
   - **My Business Business Information API**
2. Apply for access via the Business Profile API request form (review
   required — note this is gated, not self-serve).
3. Redirect URI: `https://<supabase-project>.supabase.co/functions/v1/oauth-gmb/callback`

## Scopes

- `https://www.googleapis.com/auth/business.manage`
- `https://www.googleapis.com/auth/plus.business.manage` (legacy)

## Metrics of interest

- Business Profile Performance API:
  - `BUSINESS_IMPRESSIONS_MOBILE_SEARCH`
  - `BUSINESS_IMPRESSIONS_DESKTOP_SEARCH`
  - `BUSINESS_IMPRESSIONS_MOBILE_MAPS`
  - `BUSINESS_DIRECTION_REQUESTS`
  - `CALL_CLICKS`
  - `WEBSITE_CLICKS`

## Endpoints (M8)

- `GET /v1/locations/{name}:fetchMultiDailyMetricsTimeSeries`
- `GET /v4/accounts/{accountId}/locations/{locationId}/reviews`
