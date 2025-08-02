# Google Cloud Platform Deployment Guide

## Overview
This guide covers deploying Market Dojo Lite to Google Cloud Platform using various services. We'll explore multiple deployment options with cost estimates for each.

## Prerequisites
- Google Cloud account with billing enabled
- `gcloud` CLI installed and configured
- Docker installed (for containerized deployments)

## Deployment Options

### Option 1: Google Cloud Run (Recommended for this app)
Cloud Run is a fully managed serverless platform perfect for containerized Rails apps.

#### Steps:
1. **Enable required APIs**
```bash
gcloud services enable run.googleapis.com \
  cloudbuild.googleapis.com \
  secretmanager.googleapis.com \
  sqladmin.googleapis.com
```

2. **Create Cloud SQL instance** (for production database)
```bash
gcloud sql instances create market-dojo-db \
  --database-version=POSTGRES_15 \
  --tier=db-f1-micro \
  --region=us-central1
```

3. **Build and push container**
```bash
# Configure Docker for GCP
gcloud auth configure-docker

# Build and tag
docker build -t gcr.io/YOUR_PROJECT_ID/market-dojo-lite .

# Push to Container Registry
docker push gcr.io/YOUR_PROJECT_ID/market-dojo-lite
```

4. **Deploy to Cloud Run**
```bash
gcloud run deploy market-dojo-lite \
  --image gcr.io/YOUR_PROJECT_ID/market-dojo-lite \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated \
  --add-cloudsql-instances YOUR_PROJECT_ID:us-central1:market-dojo-db \
  --set-env-vars "RAILS_ENV=production" \
  --set-secrets "SECRET_KEY_BASE=rails-secret:latest" \
  --set-secrets "DATABASE_URL=database-url:latest"
```

#### Estimated Monthly Cost:
- **Cloud Run**: ~$5-20/month (2M free requests, then $0.40/million)
- **Cloud SQL (db-f1-micro)**: ~$10-15/month
- **Cloud Storage**: ~$0.02/GB for assets
- **Total**: ~$15-40/month for light usage

### Option 2: Google Kubernetes Engine (GKE)
Better for larger scale deployments with multiple services.

#### Steps:
1. **Create GKE cluster**
```bash
gcloud container clusters create market-dojo-cluster \
  --num-nodes=2 \
  --machine-type=e2-small \
  --region=us-central1
```

2. **Create Kubernetes manifests**
```yaml
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: market-dojo-lite
spec:
  replicas: 2
  selector:
    matchLabels:
      app: market-dojo-lite
  template:
    metadata:
      labels:
        app: market-dojo-lite
    spec:
      containers:
      - name: app
        image: gcr.io/YOUR_PROJECT_ID/market-dojo-lite
        ports:
        - containerPort: 8080
        env:
        - name: RAILS_ENV
          value: "production"
```

3. **Deploy to GKE**
```bash
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl apply -f ingress.yaml
```

#### Estimated Monthly Cost:
- **GKE Cluster (2 e2-small nodes)**: ~$50-70/month
- **Cloud SQL**: ~$10-15/month
- **Load Balancer**: ~$20/month
- **Total**: ~$80-105/month

### Option 3: Google App Engine (Flexible Environment)
Traditional PaaS option for Rails apps.

#### Steps:
1. **Create app.yaml**
```yaml
runtime: ruby
env: flex

runtime_config:
  ruby_version: "3.4"

env_variables:
  RAILS_ENV: "production"

automatic_scaling:
  min_num_instances: 1
  max_num_instances: 3

resources:
  cpu: 1
  memory_gb: 1.5
  disk_size_gb: 10
```

2. **Deploy**
```bash
gcloud app deploy
```

#### Estimated Monthly Cost:
- **App Engine Flexible**: ~$50-100/month (1 instance minimum)
- **Cloud SQL**: ~$10-15/month
- **Total**: ~$60-115/month

### Option 4: Compute Engine VMs
Traditional VM approach, most control but requires more management.

#### Steps:
1. **Create VM**
```bash
gcloud compute instances create market-dojo-vm \
  --machine-type=e2-micro \
  --image-family=ubuntu-2204-lts \
  --image-project=ubuntu-os-cloud \
  --boot-disk-size=20GB
```

2. **Install dependencies and deploy manually**
```bash
# SSH into VM
gcloud compute ssh market-dojo-vm

# Install Ruby, Rails, PostgreSQL, etc.
# Clone repo and set up app
```

#### Estimated Monthly Cost:
- **e2-micro VM**: ~$6-10/month
- **Persistent Disk**: ~$0.80/month (20GB)
- **Static IP**: ~$3/month
- **Total**: ~$10-15/month (cheapest but requires manual management)

## Additional Services & Costs

### Cloud CDN for Assets
- ~$0.08/GB for cache egress
- Improves performance globally

### Cloud Armor for Security
- ~$5/month + $0.75/million requests
- DDoS protection and WAF

### Cloud Monitoring
- Free tier covers basic monitoring
- ~$0.258/GB for logs beyond free tier

### Secrets Manager
- ~$0.06/secret/month
- ~$0.03/10,000 access operations

## Production Considerations

### Database Setup
```bash
# Create database user
gcloud sql users create rails_user \
  --instance=market-dojo-db \
  --password=SECURE_PASSWORD

# Create database
gcloud sql databases create market_dojo_production \
  --instance=market-dojo-db
```

### Environment Variables
Store sensitive data in Secret Manager:
```bash
# Create secrets
echo -n "your-secret-key" | gcloud secrets create rails-secret --data-file=-
echo -n "postgres://user:pass@/db?host=/cloudsql/..." | gcloud secrets create database-url --data-file=-
```

### Asset Compilation
Modify Dockerfile to precompile assets:
```dockerfile
RUN SECRET_KEY_BASE_DUMMY=1 bundle exec rails assets:precompile
```

### Health Checks
Add to your Rails routes:
```ruby
get '/health', to: proc { [200, {}, ['OK']] }
```

## Migration from Fly.io

1. **Export database**
```bash
fly postgres connect -a your-db-app
pg_dump market_dojo_production > backup.sql
```

2. **Import to Cloud SQL**
```bash
gcloud sql import sql market-dojo-db gs://your-bucket/backup.sql \
  --database=market_dojo_production
```

3. **Update environment variables**
- Change DATABASE_URL to Cloud SQL connection string
- Update any Fly-specific configurations

## Cost Optimization Tips

1. **Use Cloud Run** for automatic scaling and pay-per-use
2. **Enable autoscaling** to scale down during low traffic
3. **Use Cloud CDN** for static assets
4. **Set up budget alerts** in GCP Console
5. **Use preemptible VMs** for non-critical workloads
6. **Reserve instances** for consistent workloads (up to 57% discount)

## Estimated Total Monthly Costs by Option

| Deployment Option | Minimum Cost | Typical Cost | High Traffic Cost |
|------------------|--------------|--------------|-------------------|
| Cloud Run        | $15          | $30-40       | $100-200         |
| GKE              | $80          | $100-150     | $200-500         |
| App Engine Flex  | $60          | $80-120      | $150-300         |
| Compute Engine   | $10          | $15-25       | $50-100          |

## Free Tier Benefits
- Cloud Run: 2 million requests/month free
- Cloud SQL: $300 credit for new users
- Compute Engine: 1 e2-micro instance free
- Cloud Storage: 5GB free
- Network Egress: 1GB free/month

## Recommendation
For Market Dojo Lite, **Cloud Run** is recommended because:
- Serverless scaling (scales to zero)
- Pay only for what you use
- Fully managed (no server maintenance)
- Easy integration with Cloud SQL
- Built-in HTTPS and custom domains
- Ideal for Rails applications

## Next Steps
1. Create a GCP account and project
2. Install gcloud CLI: `brew install google-cloud-sdk`
3. Follow the Cloud Run deployment steps above
4. Set up monitoring and alerts
5. Configure a custom domain (optional)