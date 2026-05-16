# LinkedIn Marketing API

## Account types

- LinkedIn Company Page (admin required)
- Personal profiles: only basic profile, no analytics — direct users to
  CSV / OCR fallback.

## App setup

1. Create app at https://www.linkedin.com/developers/
2. Request product: **Marketing Developer Platform** (review required).
3. Redirect URI: `https://<supabase-project>.supabase.co/functions/v1/oauth-linkedin/callback`

## Scopes

- `r_organization_social`
- `rw_organization_admin`
- `r_organization_admin`

## Approval

LinkedIn Marketing Developer Platform requires written approval (multiple
weeks). Document Plan B (CSV upload from LinkedIn Page Admin export) in
the connect UI.

## Endpoints (M8)

- `GET /v2/organizationalEntityShareStatistics`
- `GET /v2/organizationPageStatistics`
- `GET /v2/organizationalEntityFollowerStatistics`
