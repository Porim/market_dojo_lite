#!/bin/bash

# Fix GCP Setup Script

echo "=== Fixing GCP Setup ==="
echo ""

# Load existing config
source .gcp-config

# Fix region
echo "1. Fixing region (uk -> europe-west2)"
REGION="europe-west2"
gcloud config set run/region $REGION

# Enable billing properly
echo ""
echo "2. Please ensure billing is enabled:"
echo "   Visit: https://console.cloud.google.com/billing/linkedaccount?project=$PROJECT_ID"
echo "   Link the billing account: 018ED1-8F23B0-C17D43"
echo "   Press Enter when done..."
read

# Enable APIs one by one
echo ""
echo "3. Enabling required APIs..."

# Enable each API individually
for api in run.googleapis.com cloudbuild.googleapis.com secretmanager.googleapis.com artifactregistry.googleapis.com
do
    echo "Enabling $api..."
    gcloud services enable $api --project=$PROJECT_ID || echo "Failed to enable $api"
done

# Create Artifact Registry in correct region
echo ""
echo "4. Creating Artifact Registry repository in correct region"
gcloud artifacts repositories create market-dojo-repo \
    --repository-format=docker \
    --location=$REGION \
    --description="Docker repository for Market Dojo Lite" \
    --project=$PROJECT_ID 2>/dev/null || echo "Repository might already exist"

# Configure Docker for correct region
echo ""
echo "5. Configuring Docker authentication"
gcloud auth configure-docker ${REGION}-docker.pkg.dev

# Create secrets (without Cloud SQL for now)
echo ""
echo "6. Creating secrets"
SECRET_KEY_BASE=$(openssl rand -hex 64)

# Create rails-secret
echo -n "$SECRET_KEY_BASE" | gcloud secrets create rails-secret \
    --data-file=- \
    --project=$PROJECT_ID 2>/dev/null || echo "Secret rails-secret might already exist"

# Create database-url for SQLite
echo -n "sqlite3:///data/production.sqlite3" | gcloud secrets create database-url \
    --data-file=- \
    --project=$PROJECT_ID 2>/dev/null || echo "Secret database-url might already exist"

# Grant Cloud Run access to secrets
PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')
SERVICE_ACCOUNT="${PROJECT_NUMBER}-compute@developer.gserviceaccount.com"

echo ""
echo "7. Granting secret access to Cloud Run service account"
for secret in rails-secret database-url
do
    gcloud secrets add-iam-policy-binding $secret \
        --member="serviceAccount:${SERVICE_ACCOUNT}" \
        --role="roles/secretmanager.secretAccessor" \
        --project=$PROJECT_ID 2>/dev/null || echo "IAM binding might already exist for $secret"
done

# Update config file
echo ""
echo "8. Updating configuration"
cat > .gcp-config << EOF
PROJECT_ID=$PROJECT_ID
REGION=$REGION
DB_INSTANCE_NAME=
REGISTRY_URL=${REGION}-docker.pkg.dev/$PROJECT_ID/market-dojo-repo
EOF

echo ""
echo "=== Setup Fixed ==="
echo ""
echo "Project ID: $PROJECT_ID"
echo "Region: $REGION (London)"
echo "Registry: ${REGION}-docker.pkg.dev/$PROJECT_ID/market-dojo-repo"
echo ""
echo "Next steps:"
echo "1. Build Docker image:"
echo "   docker build -t ${REGION}-docker.pkg.dev/$PROJECT_ID/market-dojo-repo/market-dojo-lite:latest ."
echo ""
echo "2. Push to registry:"
echo "   docker push ${REGION}-docker.pkg.dev/$PROJECT_ID/market-dojo-repo/market-dojo-lite:latest"
echo ""
echo "3. Deploy to Cloud Run:"
echo "   ./scripts/deploy_gcp.sh"
echo ""
echo "Estimated monthly cost: $5-20 (using SQLite, no Cloud SQL)"