# Custom Domain Setup for Cloud Run

## Option 1: Using Cloudflare (Free - Recommended)

1. Sign up for a free Cloudflare account at https://cloudflare.com
2. Add your domain `tracetrail.app` to Cloudflare
3. Update nameservers in Porkbun to Cloudflare's nameservers
4. In Cloudflare, create a Page Rule:
   - URL: `tracetrail.app/*`
   - Setting: Forwarding URL (301)
   - Destination: `https://market-dojo-lite-688981654642.europe-west2.run.app/$1`

## Option 2: Using Porkbun URL Forwarding

1. Log in to Porkbun
2. Go to your domain management for `tracetrail.app`
3. Look for "URL Forwarding" or "Web Forwarding"
4. Set up:
   - Forward from: `tracetrail.app`
   - Forward to: `https://market-dojo-lite-688981654642.europe-west2.run.app`
   - Type: 301 (Permanent)
   - Include www: Yes

## Option 3: Verify Domain with Google (More Complex)

1. Add a TXT record in Porkbun:
   - Type: `TXT`
   - Host: `@`
   - Answer: `google-site-verification=YOUR_VERIFICATION_CODE`

2. Verify domain:
   ```bash
   gcloud domains verify tracetrail.app
   ```

3. Once verified, create domain mapping:
   ```bash
   gcloud beta run domain-mappings create \
     --service=market-dojo-lite \
     --domain=tracetrail.app \
     --region=europe-west2
   ```

4. Add DNS records provided by Google to Porkbun

## Quick Solution for Interview

Since this is temporary for an interview, the URL forwarding option (#2) is the simplest and will work within minutes.