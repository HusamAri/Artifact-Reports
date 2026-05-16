# StoreKit 2 Flow

## Why direct (no RevenueCat)

- No extra SaaS bill / data residency surface.
- Apple's `Transaction.currentEntitlements` + Server Notifications v2 cover
  every renewal/refund/grace state we need.
- Flutter plugin: `in_app_purchase` + `in_app_purchase_storekit`.

## Client (Flutter) responsibilities

1. Surface paywall (`features/subscription/`) with localized product list
   loaded from `InAppPurchase.instance.queryProductDetails(...)`.
2. On purchase / restore, send the App Store JWS to
   `storekit-verify` edge function. Server is source of truth.
3. Reflect entitlement via Riverpod provider; gate premium features.

## Server (edge fn) responsibilities

- `storekit-verify`: client-initiated, verifies JWS against Apple's public
  keys, upserts `subscriptions` row, returns current tier.
- `storekit-webhook`: receives ASN v2 notifications, JWS-verifies, updates
  `subscriptions.status` / `current_period_end`.

## Subscription tiers (initial)

| Tier | Product ID (TBD) | Limits |
|---|---|---|
| Free | — | 1 workspace, 1 connected account, 7-day history |
| Pro | `com.artifactreports.pro.monthly` | 3 workspaces, 10 accounts, 12-month history, PDF export |
| Agency | `com.artifactreports.agency.monthly` | Unlimited, web report link, team roles |

## App Store policy guardrails

- All premium unlocks **must** flow through StoreKit (Guideline 3.1.1).
- No external payment links in the iOS app.
- Restore purchases button required and reachable from settings.
