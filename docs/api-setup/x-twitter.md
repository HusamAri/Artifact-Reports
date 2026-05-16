# X (Twitter) API v2

## Account types

- Any X account, but **metrics endpoints require paid tier** (Basic or Pro).

## App setup

1. Apply for developer access at https://developer.x.com/
2. Create a Project + App.
3. OAuth 2.0 with PKCE. Redirect: `https://<supabase-project>.supabase.co/functions/v1/oauth-x/callback`

## Scopes

- `tweet.read`
- `users.read`
- `offline.access` (for refresh tokens)

## Pricing reality

- **Free**: write-only, no analytics. Not viable for our use-case.
- **Basic** (~$200/mo): 10k tweet reads/month — viable for a small set
  of tracked accounts.
- **Pro** (~$5k/mo): only justified if customers demand X heavily.

Document the tier requirement in the connect UI before user attempts to
link an X account.

## Endpoints (M8)

- `GET /2/users/me?user.fields=public_metrics`
- `GET /2/users/:id/tweets?tweet.fields=public_metrics,created_at`
