# Project-Specific Guidelines for Market Dojo Lite

## Pre-commit Checklist

**ALWAYS run these commands before staging and committing:**

1. **Run RuboCop** to check code style:
   ```bash
   bundle exec rubocop
   ```
   If there are issues, fix them with:
   ```bash
   bundle exec rubocop -A
   ```

2. **Run RSpec** tests:
   ```bash
   bundle exec rspec
   ```

3. **Check for TypeScript/JavaScript issues** (if applicable):
   ```bash
   npm run lint
   npm run typecheck
   ```

## Deployment Commands

### Deploy to GCP
The deployment happens automatically via GitHub Actions when pushing to main branch.

### Manual deployment commands:
```bash
# Build and push Docker image
docker buildx build --platform linux/amd64 --push -t europe-west2-docker.pkg.dev/market-dojo-lite-1754153513/market-dojo-lite/market-dojo-lite:latest .

# Deploy to Cloud Run
gcloud run deploy market-dojo-lite \
  --image europe-west2-docker.pkg.dev/market-dojo-lite-1754153513/market-dojo-lite/market-dojo-lite:latest \
  --region europe-west2 \
  --project market-dojo-lite-1754153513
```

## Important URLs
- Production: https://market-dojo-lite-688981654642.europe-west2.run.app
- GitHub: https://github.com/Porim/market_dojo_lite

## Sentry Error Monitoring
- DSN is stored in Google Secret Manager as `sentry-dsn`
- Test endpoint: `/sentry_test` (protected in production)

## Database
- Development: SQLite
- Production: PostgreSQL (Cloud SQL)

## Known Issues
- gcloud describe returns incorrect URL (US region instead of Europe) - hardcoded workaround in GitHub Actions