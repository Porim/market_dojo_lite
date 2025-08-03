#!/bin/bash

# Google Cloud Platform Setup Script for Market Dojo Lite

echo "=== Market Dojo Lite - GCP Setup Script ==="
echo ""
echo "This script will help you set up your GCP deployment."
echo ""

# Function to prompt for input
prompt_for_input() {
    local prompt="$1"
    local var_name="$2"
    read -p "$prompt: " value
    eval "$var_name='$value'"
}

echo "1. First, you need to authenticate with Google Cloud."
echo "   Please run: gcloud auth login"
echo "   After authentication, press Enter to continue..."
read

# Check if authenticated
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" &>/dev/null; then
    echo "Error: Not authenticated. Please run 'gcloud auth login' first."
    exit 1
fi

echo "✓ Authenticated successfully"
echo ""

# Get or create project
echo "2. Setting up GCP Project"
prompt_for_input "Enter your GCP Project ID (or press Enter to create a new one)" PROJECT_ID

if [ -z "$PROJECT_ID" ]; then
    PROJECT_ID="market-dojo-lite-$(date +%s)"
    echo "Creating new project: $PROJECT_ID"
    gcloud projects create $PROJECT_ID --name="Market Dojo Lite"
else
    echo "Using existing project: $PROJECT_ID"
fi

# Set the project
gcloud config set project $PROJECT_ID

# Get billing account
echo ""
echo "3. Checking billing accounts..."
BILLING_ACCOUNTS=$(gcloud billing accounts list --format="value(name)" 2>/dev/null)
if [ -z "$BILLING_ACCOUNTS" ]; then
    echo "No billing accounts found. Please set up billing at: https://console.cloud.google.com/billing"
    echo "Press Enter after setting up billing..."
    read
else
    echo "Available billing accounts:"
    gcloud billing accounts list --format="table(displayName,name)"
    prompt_for_input "Enter billing account ID" BILLING_ACCOUNT_ID
    gcloud billing projects link $PROJECT_ID --billing-account=$BILLING_ACCOUNT_ID
fi

# Enable required APIs
echo ""
echo "4. Enabling required APIs..."
gcloud services enable \
    run.googleapis.com \
    cloudbuild.googleapis.com \
    secretmanager.googleapis.com \
    sqladmin.googleapis.com \
    containerregistry.googleapis.com \
    artifactregistry.googleapis.com

echo "✓ APIs enabled"

# Set region
echo ""
echo "5. Setting default region"
prompt_for_input "Enter preferred region (default: us-central1)" REGION
REGION=${REGION:-us-central1}
gcloud config set run/region $REGION

# Create Cloud SQL instance
echo ""
echo "6. Setting up Cloud SQL database"
echo "This will create a db-f1-micro instance (lowest cost tier)"
prompt_for_input "Create Cloud SQL instance? (y/n)" CREATE_DB

if [[ "$CREATE_DB" == "y" ]]; then
    DB_INSTANCE_NAME="market-dojo-db"
    echo "Creating Cloud SQL instance: $DB_INSTANCE_NAME"
    
    # Generate secure passwords
    ROOT_PASSWORD=$(openssl rand -base64 32)
    RAILS_PASSWORD=$(openssl rand -base64 32)
    
    gcloud sql instances create $DB_INSTANCE_NAME \
        --database-version=POSTGRES_15 \
        --tier=db-f1-micro \
        --region=$REGION \
        --root-password="$ROOT_PASSWORD" \
        --database-flags=max_connections=50
    
    # Store root password in Secret Manager
    echo -n "$ROOT_PASSWORD" | gcloud secrets create database-root-password \
        --data-file=- \
        --replication-policy="automatic" 2>/dev/null || echo "Secret database-root-password already exists"
    
    # Create database
    gcloud sql databases create market_dojo_production \
        --instance=$DB_INSTANCE_NAME
    
    # Create user
    gcloud sql users create rails_user \
        --instance=$DB_INSTANCE_NAME \
        --password="$RAILS_PASSWORD"
    
    # Store rails user password in Secret Manager
    echo -n "$RAILS_PASSWORD" | gcloud secrets create database-rails-password \
        --data-file=- \
        --replication-policy="automatic" 2>/dev/null || echo "Secret database-rails-password already exists"
    
    echo "✓ Cloud SQL instance created"
fi

# Create secrets
echo ""
echo "7. Setting up Secret Manager"
SECRET_KEY_BASE=$(openssl rand -hex 64)
echo -n "$SECRET_KEY_BASE" | gcloud secrets create rails-secret --data-file=-

if [[ "$CREATE_DB" == "y" ]]; then
    # Get Cloud SQL connection name
    CONNECTION_NAME=$(gcloud sql instances describe $DB_INSTANCE_NAME --format="value(connectionName)")
    DATABASE_URL="postgresql://rails_user:${RAILS_PASSWORD}@localhost/market_dojo_production?host=/cloudsql/$CONNECTION_NAME"
    echo -n "$DATABASE_URL" | gcloud secrets create database-url --data-file=-
else
    # Use SQLite for simplicity if no Cloud SQL
    echo -n "sqlite3:///data/production.sqlite3" | gcloud secrets create database-url --data-file=-
fi

echo "✓ Secrets created"

# Create Artifact Registry repository
echo ""
echo "8. Creating Artifact Registry repository"
gcloud artifacts repositories create market-dojo-repo \
    --repository-format=docker \
    --location=$REGION \
    --description="Docker repository for Market Dojo Lite" 2>/dev/null || echo "Repository already exists"

# Configure Docker
gcloud auth configure-docker ${REGION}-docker.pkg.dev

# Summary
echo ""
echo "=== Setup Complete ==="
echo ""
echo "Project ID: $PROJECT_ID"
echo "Region: $REGION"
echo "Cloud SQL Instance: ${DB_INSTANCE_NAME:-Not created}"
echo ""
echo "Next steps:"
echo "1. Build and push Docker image:"
echo "   docker build -t ${REGION}-docker.pkg.dev/$PROJECT_ID/market-dojo-repo/market-dojo-lite:latest ."
echo "   docker push ${REGION}-docker.pkg.dev/$PROJECT_ID/market-dojo-repo/market-dojo-lite:latest"
echo ""
echo "2. Deploy to Cloud Run:"
echo "   gcloud run deploy market-dojo-lite \\"
echo "     --image ${REGION}-docker.pkg.dev/$PROJECT_ID/market-dojo-repo/market-dojo-lite:latest \\"
echo "     --platform managed \\"
echo "     --region $REGION \\"
echo "     --allow-unauthenticated \\"
echo "     --set-secrets SECRET_KEY_BASE=rails-secret:latest,DATABASE_URL=database-url:latest"

if [[ "$CREATE_DB" == "y" ]]; then
    echo "     --add-cloudsql-instances $PROJECT_ID:$REGION:$DB_INSTANCE_NAME"
fi

echo ""
echo "Configuration saved to: .gcp-config"

# Save configuration
cat > .gcp-config << EOF
PROJECT_ID=$PROJECT_ID
REGION=$REGION
DB_INSTANCE_NAME=${DB_INSTANCE_NAME:-}
REGISTRY_URL=${REGION}-docker.pkg.dev/$PROJECT_ID/market-dojo-repo
EOF

echo ""
echo "Run ./scripts/deploy_gcp.sh to deploy your application"