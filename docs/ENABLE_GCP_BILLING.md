# How to Enable Billing for Google Cloud Platform

## Quick Steps

### Option 1: Direct Link (Easiest)
1. Click this link: https://console.cloud.google.com/billing/linkedaccount?project=market-dojo-lite-1754153513
2. You'll see a page to link a billing account
3. Select **"018ED1-8F23B0-C17D43"** (My Billing Account) from the dropdown
4. Click **"SET ACCOUNT"**

### Option 2: Through Console
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Make sure your project **"market-dojo-lite-1754153513"** is selected in the top dropdown
3. Click the hamburger menu (☰) in the top left
4. Navigate to **Billing** → **Link a billing account**
5. Select your billing account: **"018ED1-8F23B0-C17D43"**
6. Click **"SET ACCOUNT"**

### Option 3: Using Command Line
```bash
# Link billing account to project
gcloud billing projects link market-dojo-lite-1754153513 \
    --billing-account=018ED1-8F23B0-C17D43
```

## Visual Guide

### Step 1: Go to Billing Page
![Billing Menu](https://cloud.google.com/static/billing/docs/images/billing-menu.png)
- Click on "Billing" in the navigation menu

### Step 2: Link Billing Account
You'll see a page like this:
```
This project has no billing account

To use Google Cloud services, you must enable billing for this project.

[Dropdown: Select billing account ▼]
[SET ACCOUNT button]
```

### Step 3: Select Your Account
- Choose: **018ED1-8F23B0-C17D43 (My Billing Account)**
- Click: **SET ACCOUNT**

## Verify Billing is Enabled

After enabling billing, verify it worked:

```bash
# Check billing status
gcloud billing projects describe market-dojo-lite-1754153513

# Should show:
# billingAccountName: billingAccounts/018ED1-8F23B0-C17D43
# billingEnabled: true
```

## Important Notes

1. **Free Tier**: Google Cloud offers $300 in free credits for new accounts
2. **Budget Alerts**: Set up budget alerts to avoid unexpected charges
3. **Estimated Costs**: Your app will cost approximately $5-20/month

## Set Up Budget Alerts (Recommended)

1. Go to [Budgets & Alerts](https://console.cloud.google.com/billing/budgets)
2. Click **CREATE BUDGET**
3. Set a monthly budget (e.g., $25)
4. Set alerts at 50%, 90%, and 100%
5. Add your email for notifications

## After Billing is Enabled

Run the deployment script:
```bash
./scripts/simple_gcp_deploy.sh
```

The script will now be able to:
- Enable APIs
- Create resources
- Deploy your application

## Troubleshooting

### "Billing account is not open"
- Make sure the billing account is active
- Check if you have a valid payment method attached

### "Permission denied"
- Ensure you're logged in with the correct Google account
- The account needs to be a Billing Account Administrator

### Still Having Issues?
1. Try logging out and back in:
   ```bash
   gcloud auth logout
   gcloud auth login
   ```

2. Check your current account:
   ```bash
   gcloud auth list
   ```

3. Make sure you're using the right project:
   ```bash
   gcloud config set project market-dojo-lite-1754153513
   ```