#!/bin/bash

# Generic GCP setup script for Market Dojo Lite
# Usage: ./scripts/setup_gcp_generic.sh PROJECT_ID BILLING_ACCOUNT_ID

set -e

if [ $# -ne 2 ]; then
    echo "Usage: $0 PROJECT_ID BILLING_ACCOUNT_ID"
    echo "Example: $0 my-project-123 0123AB-CDEF12-345678"
    exit 1
fi

PROJECT_ID=$1
BILLING_ACCOUNT_ID=$2
REGION="europe-west2"
SERVICE_NAME="market-dojo-lite"

echo "=== Setting up GCP for Market Dojo Lite ==="
echo "Project ID: $PROJECT_ID"
echo "Billing Account: $BILLING_ACCOUNT_ID"
echo "Region: $REGION"
echo ""

# Create project
echo "Creating project..."
gcloud projects create $PROJECT_ID --name="Market Dojo Lite" 2>/dev/null || echo "Project already exists"

# Set project
gcloud config set project $PROJECT_ID

# Link billing account
echo "Linking billing account..."
gcloud billing projects link $PROJECT_ID --billing-account=$BILLING_ACCOUNT_ID

# Enable required APIs
echo "Enabling required APIs..."
gcloud services enable \
    cloudbuild.googleapis.com \
    run.googleapis.com \
    artifactregistry.googleapis.com \
    secretmanager.googleapis.com \
    sqladmin.googleapis.com \
    compute.googleapis.com

# Create Artifact Registry repository
echo "Creating Artifact Registry repository..."
gcloud artifacts repositories create market-dojo-repo \
    --repository-format=docker \
    --location=$REGION \
    --description="Docker repository for Market Dojo Lite" 2>/dev/null || echo "Repository already exists"

# Configure Docker
echo "Configuring Docker..."
gcloud auth configure-docker ${REGION}-docker.pkg.dev

# Create secrets
echo "Creating secrets in Secret Manager..."
echo -n "$(openssl rand -hex 64)" | gcloud secrets create rails-secret \
    --data-file=- \
    --replication-policy="automatic" 2>/dev/null || echo "Secret rails-secret already exists"

# Create Cloud SQL instance
echo "Creating Cloud SQL instance..."
gcloud sql instances create market-dojo-db \
    --database-version=POSTGRES_15 \
    --tier=db-f1-micro \
    --region=$REGION \
    --network=default \
    --no-assign-ip 2>/dev/null || echo "Instance already exists"

# Create database
echo "Creating database..."
gcloud sql databases create market_dojo_production \
    --instance=market-dojo-db 2>/dev/null || echo "Database already exists"

# Generate secure database password
DB_PASSWORD=$(openssl rand -base64 32)

# Create database user
echo "Creating database user with secure password..."
gcloud sql users create rails_user \
    --instance=market-dojo-db \
    --password="$DB_PASSWORD" 2>/dev/null || echo "User already exists"

# Store database password in Secret Manager
echo -n "$DB_PASSWORD" | gcloud secrets create database-password \
    --data-file=- \
    --replication-policy="automatic" 2>/dev/null || echo "Secret database-password already exists"

# Create database URL secret
DB_URL="postgresql://rails_user:${DB_PASSWORD}@localhost/market_dojo_production?host=/cloudsql/${PROJECT_ID}:${REGION}:market-dojo-db"
echo -n "$DB_URL" | gcloud secrets create database-url \
    --data-file=- \
    --replication-policy="automatic" 2>/dev/null || echo "Secret database-url already exists"

echo ""
echo "=== Setup Complete ==="
echo "Next steps:"
echo "1. Build and push Docker image:"
echo "   docker buildx build --platform linux/amd64 --push -t ${REGION}-docker.pkg.dev/${PROJECT_ID}/market-dojo-repo/${SERVICE_NAME}:latest ."
echo ""
echo "2. Deploy to Cloud Run:"
echo "   gcloud run deploy ${SERVICE_NAME} \\"
echo "     --image ${REGION}-docker.pkg.dev/${PROJECT_ID}/market-dojo-repo/${SERVICE_NAME}:latest \\"
echo "     --platform managed \\"
echo "     --region $REGION \\"
echo "     --allow-unauthenticated \\"
echo "     --add-cloudsql-instances ${PROJECT_ID}:${REGION}:market-dojo-db \\"
echo "     --set-secrets SECRET_KEY_BASE=rails-secret:latest,DATABASE_URL=database-url:latest"
echo ""
echo "3. The database password has been securely generated and stored in Secret Manager as 'database-password'"