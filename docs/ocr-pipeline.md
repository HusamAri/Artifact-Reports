# OCR / Screenshot Ingestion

## Goal

Let users paste a screenshot of a native analytics screen (Instagram Insights,
TikTok Studio, YouTube Studio, etc.) and have the numeric KPIs extracted
into `metrics_snapshots` with `source='ocr'`.

## Pipeline

```
Flutter image_picker
   │
   ▼
Supabase Storage: screenshots/ (private, 30d TTL)
   │
   ▼
Edge fn: ocr-screenshot
   │  ├─ Apple Vision (on-device, M5 fast path) ──► structured numbers
   │  └─ Claude Vision API   (fallback / cloud)  ──► structured JSON
   ▼
Validate against expected schema for platform
   │
   ▼
metrics_snapshots (source='ocr', raw_payload = OCR JSON)
ocr_usage (workspace_id, model, tokens, cents)  ← billing metering
```

## Cost control

- Free tier: N OCR calls / month, hard cap.
- Pro / Agency: rate-limited per minute, soft cap with overage notice.
- Apple Vision on-device tried first when client uploads from iOS — saves
  Claude tokens for ambiguous screenshots.

## Prompting (Claude Vision)

Single-shot system prompt with platform context (Instagram vs TikTok layout
differs). Response forced to JSON via `tool_use`. Reject if any field is
non-numeric where the schema demands a number.

## Privacy

- Buckets are private; signed URLs only.
- Auto-purge after 30 days unless user pins the screenshot to a report.
- No PII OCR'd from comments / user lists — system prompt explicitly
  refuses non-aggregate data.
