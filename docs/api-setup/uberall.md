# Uberall (Listings & Reputation)

## Account types

- Uberall customer account (B2B SaaS, paid).

## Auth

API key (not OAuth). Each workspace stores its own Uberall key in
`social_accounts.access_token_encrypted` (we reuse the same column —
the key is opaque from our side).

Base URL: `https://uberall.com/api/`

## Endpoints (M8)

- `GET /locations/` — list of locations under the account
- `GET /reports/insights/` — aggregated listing performance
- `GET /reviews/` — review feed with sentiment

## Notes

- Uberall returns rich, normalized listings data — easier than the raw
  Google Business Profile feed for multi-location chains.
- Sync frequency: daily is usually enough; hourly would burn quota.
- No App Review process — just rate-limit-aware polling.
