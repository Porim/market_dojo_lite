#!/bin/bash

# Simple GCP Deployment Script

echo "=== Simple GCP Deployment ==="
echo ""

PROJECT_ID="market-dojo-lite-1754153513"
REGION="europe-west2"
IMAGE_URL="${REGION}-docker.pkg.dev/${PROJECT_ID}/market-dojo-repo/market-dojo-lite:latest"

echo "Configuration:"
echo "  Project: $PROJECT_ID"
echo "  Region: $REGION (London)"
echo "  Image: $IMAGE_URL"
echo ""

# Step 1: Enable APIs
echo "Step 1: Enabling APIs (one by one)..."
echo "Please make sure billing is enabled first!"
echo "Visit: https://console.cloud.google.com/billing/linkedaccount?project=$PROJECT_ID"
echo "Press Enter when billing is enabled..."
read

gcloud services enable run.googleapis.com --project=$PROJECT_ID
gcloud services enable artifactregistry.googleapis.com --project=$PROJECT_ID
gcloud services enable secretmanager.googleapis.com --project=$PROJECT_ID
gcloud services enable cloudbuild.googleapis.com --project=$PROJECT_ID

echo "✓ APIs enabled"

# Step 2: Create repository if needed
echo ""
echo "Step 2: Creating Artifact Registry repository..."
gcloud artifacts repositories create market-dojo-repo \
    --repository-format=docker \
    --location=$REGION \
    --project=$PROJECT_ID 2>/dev/null || echo "Repository already exists"

# Step 3: Create secrets if needed
echo ""
echo "Step 3: Creating secrets..."
SECRET_KEY_BASE=$(openssl rand -hex 64)
echo -n "$SECRET_KEY_BASE" | gcloud secrets create rails-secret --data-file=- --project=$PROJECT_ID 2>/dev/null || echo "Secret already exists"
echo -n "sqlite3:///data/production.sqlite3" | gcloud secrets create database-url --data-file=- --project=$PROJECT_ID 2>/dev/null || echo "Secret already exists"

# Grant access
PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')
gcloud secrets add-iam-policy-binding rails-secret \
    --member="serviceAccount:${PROJECT_NUMBER}-compute@developer.gserviceaccount.com" \
    --role="roles/secretmanager.secretAccessor" \
    --project=$PROJECT_ID 2>/dev/null

gcloud secrets add-iam-policy-binding database-url \
    --member="serviceAccount:${PROJECT_NUMBER}-compute@developer.gserviceaccount.com" \
    --role="roles/secretmanager.secretAccessor" \
    --project=$PROJECT_ID 2>/dev/null

echo "✓ Secrets configured"

# Step 4: Build Docker image
echo ""
echo "Step 4: Building Docker image..."
docker build -t $IMAGE_URL .

if [ $? -ne 0 ]; then
    echo "Docker build failed!"
    exit 1
fi

echo "✓ Docker image built"

# Step 5: Push to registry
echo ""
echo "Step 5: Pushing to Artifact Registry..."
docker push $IMAGE_URL

if [ $? -ne 0 ]; then
    echo "Docker push failed!"
    exit 1
fi

echo "✓ Image pushed"

# Step 6: Deploy to Cloud Run
echo ""
echo "Step 6: Deploying to Cloud Run..."
gcloud run deploy market-dojo-lite \
    --image $IMAGE_URL \
    --platform managed \
    --region $REGION \
    --project $PROJECT_ID \
    --allow-unauthenticated \
    --port 8080 \
    --memory 512Mi \
    --cpu 1 \
    --timeout 300 \
    --max-instances 3 \
    --set-env-vars "RAILS_ENV=production,RAILS_SERVE_STATIC_FILES=true,RAILS_LOG_TO_STDOUT=true" \
    --set-secrets "SECRET_KEY_BASE=rails-secret:latest,DATABASE_URL=database-url:latest"

if [ $? -eq 0 ]; then
    echo ""
    echo "=== Deployment Successful! ==="
    SERVICE_URL=$(gcloud run services describe market-dojo-lite --region=$REGION --project=$PROJECT_ID --format="value(status.url)")
    echo "Your app is live at: $SERVICE_URL"
    echo ""
    echo "Estimated monthly cost: $5-20 (with light usage)"
else
    echo "Deployment failed!"
    exit 1
fi