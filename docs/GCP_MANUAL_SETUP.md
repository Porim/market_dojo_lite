# Google Cloud Platform Manual Setup Guide

Since you have the authentication code, follow these steps to complete the GCP setup:

## 1. Complete Authentication

Open a new terminal and run:
```bash
gcloud auth login
```

When prompted, paste your verification code:
```
4/0AVMBsJhNyec4y3s-G9SEi94AXZX8pcR_A5iGL0VO-C9xAJFn20OT7Khm2HrZOgNDCQn5kA
```

## 2. Quick Setup Commands

Once authenticated, run these commands to set up your GCP project:

```bash
# Set your project ID (replace with your actual project ID or create a new one)
PROJECT_ID="market-dojo-lite-demo"
REGION="us-central1"

# Create new project (skip if you already have one)
gcloud projects create $PROJECT_ID --name="Market Dojo Lite Demo"

# Set the project
gcloud config set project $PROJECT_ID

# Link billing account (you'll need to do this in the console)
echo "Please link a billing account at: https://console.cloud.google.com/billing/linkedaccount?project=$PROJECT_ID"
echo "Press Enter when done..."
read

# Enable required APIs
gcloud services enable \
  run.googleapis.com \
  cloudbuild.googleapis.com \
  secretmanager.googleapis.com \
  containerregistry.googleapis.com \
  artifactregistry.googleapis.com

# Create Artifact Registry repository
gcloud artifacts repositories create market-dojo-repo \
  --repository-format=docker \
  --location=$REGION \
  --description="Docker repository for Market Dojo Lite"

# Configure Docker
gcloud auth configure-docker ${REGION}-docker.pkg.dev

# Create secrets
SECRET_KEY_BASE=$(openssl rand -hex 64)
echo -n "$SECRET_KEY_BASE" | gcloud secrets create rails-secret --data-file=-
echo -n "sqlite3:///data/production.sqlite3" | gcloud secrets create database-url --data-file=-

# Grant Cloud Run access to secrets
gcloud secrets add-iam-policy-binding rails-secret \
  --member="serviceAccount:$(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')-compute@developer.gserviceaccount.com" \
  --role="roles/secretmanager.secretAccessor"

gcloud secrets add-iam-policy-binding database-url \
  --member="serviceAccount:$(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')-compute@developer.gserviceaccount.com" \
  --role="roles/secretmanager.secretAccessor"
```

## 3. Build and Deploy

```bash
# Build Docker image
IMAGE_URL="${REGION}-docker.pkg.dev/$PROJECT_ID/market-dojo-repo/market-dojo-lite:latest"
docker build -t $IMAGE_URL .

# Push to Artifact Registry
docker push $IMAGE_URL

# Deploy to Cloud Run
gcloud run deploy market-dojo-lite \
  --image $IMAGE_URL \
  --platform managed \
  --region $REGION \
  --allow-unauthenticated \
  --port 8080 \
  --memory 512Mi \
  --cpu 1 \
  --timeout 300 \
  --concurrency 80 \
  --max-instances 10 \
  --set-env-vars RAILS_ENV=production,RAILS_SERVE_STATIC_FILES=true,RAILS_LOG_TO_STDOUT=true \
  --set-secrets SECRET_KEY_BASE=rails-secret:latest,DATABASE_URL=database-url:latest
```

## 4. Alternative: Using Cloud Shell

If you have issues with local authentication, you can use Google Cloud Shell:

1. Go to https://console.cloud.google.com/
2. Click the Cloud Shell icon (terminal icon in the top right)
3. Clone your repository in Cloud Shell
4. Run the deployment commands from there

## 5. Verify Deployment

After deployment, you'll get a URL like:
```
https://market-dojo-lite-xxxxx-uc.a.run.app
```

Visit this URL to see your deployed application.

## 6. View Logs

To troubleshoot any issues:
```bash
gcloud run services logs read market-dojo-lite --region=$REGION
```

## Cost Estimate

With this setup (using SQLite instead of Cloud SQL):
- Cloud Run: ~$5-15/month for light usage
- Artifact Registry: ~$0.10/GB/month
- Secrets Manager: ~$0.06/secret/month
- **Total: ~$5-20/month**

## Next Steps

1. Set up a custom domain (optional)
2. Enable Cloud CDN for better performance
3. Set up monitoring and alerts
4. Consider upgrading to Cloud SQL for production