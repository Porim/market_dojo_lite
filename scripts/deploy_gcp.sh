#!/bin/bash

# Deployment script for Market Dojo Lite to GCP

echo "=== Market Dojo Lite - GCP Deployment Script ==="
echo ""

# Load configuration
if [ -f .gcp-config ]; then
    source .gcp-config
else
    echo "Error: .gcp-config not found. Please run ./scripts/setup_gcp.sh first"
    exit 1
fi

echo "Using configuration:"
echo "  Project: $PROJECT_ID"
echo "  Region: $REGION"
echo "  Registry: $REGISTRY_URL"
echo ""

# Build Docker image
echo "1. Building Docker image..."
docker build -t ${REGISTRY_URL}/market-dojo-lite:latest .

if [ $? -ne 0 ]; then
    echo "Error: Docker build failed"
    exit 1
fi

echo "✓ Docker image built successfully"

# Push to Artifact Registry
echo ""
echo "2. Pushing image to Artifact Registry..."
docker push ${REGISTRY_URL}/market-dojo-lite:latest

if [ $? -ne 0 ]; then
    echo "Error: Docker push failed"
    exit 1
fi

echo "✓ Image pushed successfully"

# Deploy to Cloud Run
echo ""
echo "3. Deploying to Cloud Run..."

DEPLOY_CMD="gcloud run deploy market-dojo-lite \
    --image ${REGISTRY_URL}/market-dojo-lite:latest \
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
    --set-secrets SECRET_KEY_BASE=rails-secret:latest,DATABASE_URL=database-url:latest"

if [ -n "$DB_INSTANCE_NAME" ]; then
    DEPLOY_CMD="$DEPLOY_CMD --add-cloudsql-instances $PROJECT_ID:$REGION:$DB_INSTANCE_NAME"
fi

eval $DEPLOY_CMD

if [ $? -ne 0 ]; then
    echo "Error: Cloud Run deployment failed"
    exit 1
fi

echo "✓ Deployed successfully"

# Get service URL
echo ""
echo "4. Getting service URL..."
SERVICE_URL=$(gcloud run services describe market-dojo-lite --region=$REGION --format="value(status.url)")

echo ""
echo "=== Deployment Complete ==="
echo ""
echo "Your application is now live at:"
echo "$SERVICE_URL"
echo ""
echo "To view logs:"
echo "  gcloud run services logs read market-dojo-lite --region=$REGION"
echo ""
echo "To update the deployment, run this script again after making changes."