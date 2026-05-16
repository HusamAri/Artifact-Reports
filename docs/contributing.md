# Contributing

## Branch naming

`feature/<short-slug>`, `fix/<short-slug>`, `chore/<short-slug>`.

## Commit style

Conventional commits encouraged:
- `feat(app): add KPI card widget`
- `fix(supabase): include role in is_workspace_member helper`
- `docs(api-setup): note TikTok review requirements`

## Local setup

```bash
./scripts/bootstrap.sh
```

Runs `flutter pub get` in `app/`, `npm install` in `web-report/`, and
`supabase start` if Docker is up.

## Pull requests

- Open as **draft** until CI is green.
- Link the Notion project page (Artifact Studio > Projects > Artifact-Reports).
- Use the PR template; fill the milestone field.

## Migrations

Use `./scripts/new-migration.sh <name>` to scaffold a timestamped file
under `supabase/migrations/`. Never edit a migration that has been merged
to `main`.

## Style

- Dart: `dart format` + `flutter analyze` clean (very_good_analysis).
- TS: `eslint` + `tsc --noEmit`.
- SQL: lowercase keywords, snake_case identifiers.
