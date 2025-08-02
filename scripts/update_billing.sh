#!/bin/bash

# Update Billing Account Script

echo "=== Updating Billing Account ==="
echo ""

PROJECT_ID="market-dojo-lite-1754153513"
NEW_BILLING_ACCOUNT="0173C3-F900B6-A765F8"
REGION="europe-west2"

echo "Linking new billing account: MDJ ($NEW_BILLING_ACCOUNT)"
gcloud billing projects link $PROJECT_ID --billing-account=$NEW_BILLING_ACCOUNT

# Verify billing is enabled
echo ""
echo "Verifying billing status..."
gcloud billing projects describe $PROJECT_ID

echo ""
echo "✓ Billing account updated!"
echo ""
echo "Now run: ./scripts/simple_gcp_deploy.sh"