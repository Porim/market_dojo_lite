# Sentry Error Monitoring Setup

This guide covers setting up Sentry for error monitoring in the Market Dojo Lite application.

## Prerequisites

1. Create a Sentry account at https://sentry.io
2. Create a new Rails project in Sentry
3. Copy your DSN from the project settings

## Configuration

### 1. Update the Sentry DSN in Google Secret Manager

```bash
# Update the existing secret with your actual Sentry DSN
echo -n "YOUR_ACTUAL_SENTRY_DSN" | gcloud secrets versions add sentry-dsn --data-file=- --project=market-dojo-lite-1754153513
```

Replace `YOUR_ACTUAL_SENTRY_DSN` with the DSN from your Sentry project settings.

### 2. Verify Deployment

The GitHub Actions workflow is already configured to include the Sentry DSN in deployments. After updating the secret, trigger a new deployment.

### 3. Test Sentry Integration

In development:
```bash
rails s
# Visit http://localhost:3000/sentry_test
```

In production (requires test key for security):
```
https://your-app-url/sentry_test?test_key=YOUR_TEST_KEY
```

## Features Configured

- **User Context**: Automatically captures user information (ID, email, role, company)
- **Browser Context**: Captures user agent and IP address
- **Performance Monitoring**: Tracks transaction performance with 50% sampling
- **Release Tracking**: Associates errors with specific deployments
- **Sensitive Data Filtering**: Automatically filters passwords and API tokens
- **Smart Sampling**: Lower sampling for health checks, higher for application endpoints

## Excluded Exceptions

The following exceptions are not reported to reduce noise:
- `ActionController::RoutingError` (404s)
- `ActiveRecord::RecordNotFound` (404s)
- `ActionController::UnknownFormat` (format errors)

## Dashboard Views

Once configured, you'll have access to:
- Real-time error tracking
- Performance monitoring
- User impact analysis
- Release health metrics
- Custom dashboards and alerts

## Security Considerations

- Sentry DSN is stored securely in Google Secret Manager
- Sensitive data is filtered before sending to Sentry
- Test endpoint is protected in production with a test key
- No personally identifiable information is logged beyond user ID and email