# Thikana — Cost Audit & Free Alternatives
**For a Student Project with Zero Budget**
Last Updated: May 2026

> **Good news first:** Every single package in the tech stack (all Laravel composer packages and all npm packages) is **100% free and open-source**. You will never pay a single taka for them. The cost question is entirely about **hosted services and infrastructure**, not code libraries.

---

## Table of Contents
1. [The Short Answer](#1-the-short-answer)
2. [What Costs Money — Full Breakdown](#2-what-costs-money--full-breakdown)
3. [Free Alternatives — Complete Replacement Plan](#3-free-alternatives--complete-replacement-plan)
4. [Zero-Budget Infrastructure Map](#4-zero-budget-infrastructure-map)
5. [The One Thing You Cannot Avoid](#5-the-one-thing-you-cannot-avoid)
6. [Student Programme Discounts](#6-student-programme-discounts)
7. [Summary Table](#7-summary-table)

---

## 1. The Short Answer

| Category | Original Stack Cost/month | Free Alternative | Cost |
|----------|--------------------------|-----------------|------|
| All composer packages | ৳0 | Same — all MIT/open-source | ৳0 |
| All npm packages | ৳0 | Same — all MIT/open-source | ৳0 |
| **Server / Hosting** | ~$20–80/mo | Railway / Render free tier | **৳0** |
| **Database (PostgreSQL)** | ~$15–25/mo | Supabase free tier | **৳0** |
| **File Storage (S3)** | ~$5–20/mo | Cloudflare R2 free tier | **৳0** |
| **CDN** | ~$20/mo | Cloudflare free plan | **৳0** |
| **Email (Mailgun)** | ~$15/mo | Brevo (Sendinblue) free | **৳0** |
| **Search (Meilisearch Cloud)** | ~$30/mo | Self-host on free server | **৳0** |
| **Push Notifications (FCM)** | $0 already | Firebase free Spark plan | **৳0** |
| **SMS (SSL Wireless)** | ~$5–20/mo | **Cannot be free — see Section 5** | **~৳500–1,000** |
| **Maps (Google Maps)** | ~$7/1000 loads | MapLibre + OSM (already chosen) | **৳0** |
| **Translation (Google)** | ~$20/mo | LibreTranslate self-hosted | **৳0** |
| **Error tracking (Sentry)** | ~$26/mo | Sentry free tier (5k errors) | **৳0** |
| **Analytics (PostHog)** | ~$0 self-host | PostHog free cloud (1M events) | **৳0** |
| **Identity Verify (Jumio)** | ~$1–3/verification | Skip for student project | **৳0** |
| **Domain** | ~$10–15/yr | You already have one ✓ | **৳0** |
| **SSL Certificate** | ~$50–200/yr | Cloudflare / Let's Encrypt free | **৳0** |

**Total monthly cost with free alternatives: ৳0 — except SMS**

---

## 2. What Costs Money — Full Breakdown

### 2.1 🔴 Server / Hosting
**Original choice:** AWS EC2 (Singapore) or DigitalOcean Droplet

| Provider | Cost |
|----------|------|
| AWS EC2 t3.small | ~$17/month |
| DigitalOcean Basic Droplet (2GB) | $18/month |
| Vultr | $12/month |

You need a server that can run PHP 8.3, PostgreSQL, Redis, and Meilisearch simultaneously. This costs money on every major cloud provider beyond their free trial periods.

---

### 2.2 🔴 Database Hosting
**Original choice:** AWS RDS PostgreSQL or DigitalOcean Managed PostgreSQL

| Provider | Cost |
|----------|------|
| AWS RDS db.t3.micro | ~$15–25/month |
| DigitalOcean Managed DB | $15/month |
| Supabase Pro | $25/month |

Managed databases with automatic backups cost money after free tiers expire.

---

### 2.3 🔴 Object Storage (Photos, ID docs, PDFs)
**Original choice:** AWS S3

| Provider | Free Tier | After Free Tier |
|----------|-----------|-----------------|
| AWS S3 | 5 GB for 12 months (new accounts only) | ~$0.023/GB/month |
| Backblaze B2 | 10 GB free forever | $0.006/GB/month |
| Cloudflare R2 | **10 GB free forever, zero egress fees** | $0.015/GB after 10 GB |

The AWS S3 free tier expires after 12 months and only applies to new AWS accounts.

---

### 2.4 🔴 Transactional Email
**Original choice:** Mailgun

| Provider | Free Tier | After Free Tier |
|----------|-----------|-----------------|
| Mailgun | 100 emails/day for 3 months only | $15/month |
| SendGrid | 100 emails/day forever (free plan) | $19.95/month |
| Brevo (Sendinblue) | **300 emails/day forever** | $25/month |
| Resend | 3,000 emails/month free | $20/month |

---

### 2.5 🔴 SMS Gateway (Bangladesh)
**Original choice:** SSL Wireless, Infobip

This is the **only cost you genuinely cannot avoid** for a working prototype, because:
- OTP verification requires SMS delivery to Bangladeshi numbers
- There is no free SMS API for Bangladesh
- You cannot build the authentication system without it

| Provider | Cost |
|----------|------|
| SSL Wireless | ~৳0.35–0.50 per SMS (masked) |
| BulkSMS BD | ~৳0.30–0.45 per SMS |
| Infobip | ~$0.04 per SMS |

For a student demo with ~500 OTPs sent, expect to spend roughly **৳150–250 total** (one-time top-up). This is the only unavoidable expense.

> **Workaround for demos/presentations:** Disable real SMS in `.env` and log OTPs to `storage/logs/laravel.log` instead. This works perfectly for demos and presentations without any cost.

---

### 2.6 🔴 Search (Meilisearch Cloud)
**Original choice:** Meilisearch Cloud

| Plan | Cost |
|------|------|
| Meilisearch Cloud Build | $30/month |
| Algolia | $0.50/1,000 search requests |
| Typesense Cloud | $10/month |

The cloud-hosted versions cost money. Meilisearch itself is open-source.

---

### 2.7 🔴 Maps (if you had chosen Google Maps)
**Original choice was already MapLibre + OpenStreetMap — free.**
Just documenting this for awareness:

| Provider | Cost |
|----------|------|
| Google Maps JS API | $7 per 1,000 map loads |
| Mapbox | Free up to 50,000 loads/month |
| MapLibre + OpenStreetMap | **Free forever** ✓ Already chosen |

No action needed — your stack already uses the free option.

---

### 2.8 🔴 Google Translate API
**Original choice:** Google Translate API

| Provider | Cost |
|----------|------|
| Google Translate API | $20 per 1 million characters |
| DeepL API | $0 for 500,000 chars/month (free tier) |
| LibreTranslate | **Free — self-hosted** |

---

### 2.9 🔴 Error Tracking (Sentry)
**Original choice:** Sentry

| Plan | Cost |
|------|------|
| Sentry Developer (free) | 5,000 errors/month — **sufficient for student project** |
| Sentry Team | $26/month |

Sentry has a **free plan** that is more than adequate for a student project.

---

### 2.10 🔴 Identity Verification (Jumio / Onfido)
**Original choice:** Jumio or Onfido for NID/liveness check

| Provider | Cost |
|----------|------|
| Jumio | ~$1–3 per verification |
| Onfido | ~$1.50–5 per verification |
| Stripe Identity | $1.50 per verification |

For a student project, **skip this entirely.** Just store the uploaded NID photo and do manual review in the admin panel. Zero cost.

---

### 2.11 🔴 Payment Gateways (Cannot Process Real Money Without Them)
**For a student demo, you don't need real payment integration.**

| Gateway | Requirement |
|---------|-------------|
| bKash PGW | Requires registered business + trade licence |
| Nagad PGW | Requires registered business |
| SSLCOMMERZ | Requires registered business + bank account |
| Stripe | Requires business registration (or international card) |

These gateways are **free to integrate** (no monthly fee), but you need a registered business to get merchant credentials. For a student project, use the **sandbox/test mode** which is completely free and doesn't require business registration.

> Use SSLCOMMERZ sandbox, bKash sandbox, and Nagad sandbox — all free for testing.

---

## 3. Free Alternatives — Complete Replacement Plan

### 3.1 Server Hosting — Use Railway or Render (Free Tier)

**Railway.app Free Tier:**
- $5 free credit every month (enough for a demo app)
- Supports PHP/Laravel, PostgreSQL, Redis all in one platform
- Deploy directly from GitHub

**Render.com Free Tier:**
- Free web service (spins down after 15 min inactivity — fine for demos)
- Free PostgreSQL database (90 days, then $7/month — but enough to finish project)
- Free Redis instance

**Fly.io Free Tier:**
- 3 shared VMs free
- 3 GB storage
- Supports Docker-based Laravel deployments

> **Best choice for your project: Railway** — simplest Laravel deployment with a free monthly credit.

---

### 3.2 Database — Use Supabase Free Tier

**Supabase Free Tier:**
- **PostgreSQL** with full PostGIS support ✓
- 500 MB database storage
- 2 GB file storage (replaces S3 for small projects)
- Automatic daily backups
- No credit card required

Connection string works directly with Laravel's `config/database.php`.

---

### 3.3 File Storage — Use Cloudflare R2

**Cloudflare R2 Free Tier:**
- **10 GB storage free forever**
- **Zero egress fees** (huge advantage over S3)
- S3-compatible API — works with `league/flysystem-aws-s3-v3` as-is, just change the endpoint URL
- Requires a free Cloudflare account (no credit card for free tier)

```php
// config/filesystems.php — just change endpoint
's3' => [
    'driver'   => 's3',
    'key'      => env('R2_ACCESS_KEY'),
    'secret'   => env('R2_SECRET_KEY'),
    'region'   => 'auto',
    'bucket'   => env('R2_BUCKET'),
    'endpoint' => env('R2_ENDPOINT'), // https://<accountid>.r2.cloudflarestorage.com
    'use_path_style_endpoint' => true,
],
```

---

### 3.4 Email — Use Brevo (Free Forever)

**Brevo (formerly Sendinblue) Free Plan:**
- **300 emails/day — free forever**
- No credit card required
- Supports SMTP and API
- Works with Laravel's built-in mail system

```env
MAIL_MAILER=smtp
MAIL_HOST=smtp-relay.brevo.com
MAIL_PORT=587
MAIL_USERNAME=your_brevo_login_email
MAIL_PASSWORD=your_brevo_smtp_key
MAIL_FROM_ADDRESS=noreply@thikana.com.bd
```

---

### 3.5 Search — Self-Host Meilisearch on Railway/Render

Meilisearch is **open-source** and can be deployed as a Docker container alongside your Laravel app on Railway for free.

```dockerfile
# docker-compose.yml (local dev)
meilisearch:
  image: getmeili/meilisearch:latest
  ports:
    - "7700:7700"
  environment:
    MEILI_MASTER_KEY: ${MEILISEARCH_KEY}
  volumes:
    - meilisearch_data:/meili_data
```

On Railway, deploy it as a separate service from the Meilisearch Docker image at zero cost within the free credit.

---

### 3.6 Push Notifications — Firebase (Already Free)

**Firebase Cloud Messaging (FCM):**
- **Completely free forever** — no limits on push notifications
- Google's Spark (free) plan includes FCM with no message limits
- No credit card required for FCM

This was already in the tech stack and costs nothing. Just create a Firebase project at console.firebase.google.com.

---

### 3.7 Translation — Skip or Use LibreTranslate

**Option A (Recommended for student project):** Skip auto-translation. Build the UI in both Bangla and English using static translation files (`i18n`). This is already planned with `react-i18next`. You just write the translations manually — no API needed.

**Option B:** Self-host LibreTranslate on Railway free tier.
- Open-source, supports Bangla ↔ English
- REST API identical in shape to Google Translate
- Free to run on your own server

---

### 3.8 Error Tracking — Sentry Free Plan

**Sentry Developer Plan (Free):**
- 5,000 errors/month
- 1 user
- 30-day data retention
- No credit card required
- More than enough for a student project

Sign up at sentry.io → create project → paste DSN into `.env`.

---

### 3.9 Analytics — PostHog Free Cloud

**PostHog Free Plan:**
- **1 million events/month free**
- Session recording, funnels, heatmaps included
- No credit card required
- Just add the snippet to your React app

---

### 3.10 CDN & SSL — Cloudflare Free Plan

**Cloudflare Free Plan:**
- Full CDN with global PoPs (including good coverage for Bangladesh)
- **Free SSL certificate** (terminates at Cloudflare edge) — no Let's Encrypt setup needed
- DDoS protection
- WAF (basic rules)
- Just point your domain's nameservers to Cloudflare

Since you already have a domain, this takes 5 minutes to set up and replaces:
- AWS CloudFront (~$0.01/GB)
- Any paid SSL certificate (~$50–200/year)

---

### 3.11 SMS — The Only Real Problem

There is no free SMS API for Bangladesh. Your options:

**Option A — Minimal spend (~৳150–500 total):**
Top up SSL Wireless or BulkSMS BD with the minimum amount. Use it only for essential OTPs during demo.

**Option B — Free for development (recommended):**
Disable SMS in dev/staging and log OTPs to the Laravel log file:

```php
// app/Channels/SslWirelessSmsChannel.php
public function send($notifiable, Notification $notification): void {
    if (app()->environment('local', 'staging')) {
        // Log OTP instead of sending SMS — FREE
        Log::info('SMS OTP for ' . $notifiable->mobile_number . ': ' . $notification->toSms($notifiable));
        return;
    }
    // Real SMS only in production
    Http::post(...);
}
```

**Option C — Use email OTP instead:**
Replace SMS OTP with email OTP for the student project. Email is free (Brevo). Change the registration flow to use email as primary verification instead of mobile number. This is a valid architectural decision for a demo.

---

## 4. Zero-Budget Infrastructure Map

```
Your Domain (already owned)
        │
        ▼
Cloudflare (Free Plan)
  • CDN, SSL, WAF, DDoS protection
  • Point nameservers here
        │
        ▼
Railway.app (Free $5 credit/month)
  ├── Laravel App (PHP 8.3 + FrankenPHP)
  ├── Redis (built-in Railway service — free)
  └── Meilisearch (Docker image — free)
        │
        ▼
Supabase (Free Tier)
  • PostgreSQL + PostGIS
  • 500 MB database
  • Auth helpers (optional)
        │
        ▼
Cloudflare R2 (Free Tier)
  • 10 GB file storage
  • Listing photos, ID docs, PDFs
        │
        ▼
Brevo (Free Forever)
  • 300 transactional emails/day
        │
        ▼
Firebase (Free Forever)
  • Push notifications (FCM)
        │
        ▼
Sentry Free Plan
  • Error tracking
        │
        ▼
PostHog Free Cloud
  • Analytics
```

**Total monthly infrastructure cost: ৳0**

---

## 5. The One Thing You Cannot Avoid

### SMS for Bangladesh OTP

| Scenario | Cost Estimate |
|----------|---------------|
| Development (log to file) | ৳0 |
| Demo / presentation (disable SMS) | ৳0 |
| Light testing (~200 real OTPs) | ~৳70–100 one-time |
| Working prototype with real users (~500 OTPs) | ~৳175–250 one-time |

**Recommendation:** For your student project submission and presentation, use **Option B** (log OTPs to file). If your university evaluators need to see real SMS working, top up SSL Wireless with ৳200–300 (minimum recharge). This is a one-time cost, not monthly.

---

## 6. Student Programme Discounts

Even though you can run everything for free, these programmes give you extra credits if needed in the future:

| Programme | What You Get | How to Apply |
|-----------|-------------|--------------|
| **GitHub Student Developer Pack** | Free domains, free Sentry Team, DigitalOcean $200 credit, free Mailgun, and 20+ more tools | github.com/education — requires `.edu` email or student ID |
| **AWS Educate** | $100 AWS credits/year | aws.amazon.com/education/awseducate |
| **Google for Startups / Students** | $1,000 Google Cloud credits | cloud.google.com/for-startups |
| **Cloudflare for Students** | Already free — no application needed | — |
| **Supabase OSS Programme** | Free Pro tier for open-source projects | supabase.com/oss |
| **Railway Student** | Extra free credits | railway.app — apply via GitHub Student Pack |
| **Vercel for Students** | Free Pro tier via GitHub Student Pack | vercel.com/education |

> **Action:** Apply for the **GitHub Student Developer Pack** first. It unlocks most of the above in one application and is free for any student with a university email address.

---

## 7. Summary Table

### All Packages — Cost Status

| Package / Service | Type | Free? | Free Alternative |
|-------------------|------|-------|-----------------|
| All `composer.json` packages | PHP library | ✅ Free (MIT/Apache) | N/A |
| All `package.json` dependencies | JS library | ✅ Free (MIT) | N/A |
| PHP 8.3 | Runtime | ✅ Free | N/A |
| PostgreSQL | Database | ✅ Free (open-source) | N/A |
| Redis | Cache/Queue | ✅ Free (open-source) | N/A |
| Meilisearch | Search | ✅ Free (self-host) | N/A |
| Laravel Reverb | WebSocket | ✅ Free (self-host) | N/A |
| Firebase FCM | Push notifications | ✅ Free forever | N/A |
| MapLibre + OSM | Maps | ✅ Free forever | N/A |
| Cloudflare Free | CDN + SSL + WAF | ✅ Free forever | N/A |
| Sentry Free | Error tracking | ✅ Free (5k errors/mo) | N/A |
| PostHog Free | Analytics | ✅ Free (1M events/mo) | N/A |
| Google Analytics 4 | Analytics | ✅ Free forever | N/A |
| Meta Pixel | Ad tracking | ✅ Free forever | N/A |
| Brevo Free | Email (300/day) | ✅ Free forever | replaces Mailgun |
| Cloudflare R2 | File storage (10 GB) | ✅ Free forever | replaces AWS S3 |
| Supabase Free | PostgreSQL hosting | ✅ Free (500 MB) | replaces AWS RDS |
| Railway Free | App hosting | ✅ Free ($5 credit/mo) | replaces AWS EC2 |
| LibreTranslate | Translation | ✅ Free (self-host) | replaces Google Translate API |
| bKash / Nagad / SSLCOMMERZ | Payment (sandbox) | ✅ Free (sandbox mode) | N/A |
| **SSL Wireless SMS** | **OTP SMS** | **⚠️ Paid (~৳0.35/SMS)** | Log to file for demos |
| ~~AWS S3~~ | ~~Storage~~ | ❌ Paid after trial | → Cloudflare R2 |
| ~~Mailgun~~ | ~~Email~~ | ❌ Paid after 3 months | → Brevo |
| ~~AWS EC2/RDS~~ | ~~Hosting~~ | ❌ Paid after 12 months | → Railway + Supabase |
| ~~Meilisearch Cloud~~ | ~~Search~~ | ❌ $30/month | → Self-host on Railway |
| ~~Google Translate API~~ | ~~Translation~~ | ❌ Paid per character | → LibreTranslate or skip |
| ~~Jumio / Onfido~~ | ~~ID verification~~ | ❌ $1–3 per check | → Skip for student project |
| ~~Sentry Team~~ | ~~Error tracking~~ | ❌ $26/month | → Sentry free plan |
| ~~Pusher~~ | ~~WebSocket~~ | ❌ $49/month | → Laravel Reverb (already chosen) |
| ~~Google Maps API~~ | ~~Maps~~ | ❌ $7/1000 loads | → MapLibre + OSM (already chosen) |

---

### Final Verdict

| Item | Monthly Cost |
|------|-------------|
| All code packages and libraries | ৳0 |
| Hosting, database, storage, CDN, email | ৳0 |
| Push notifications, maps, analytics, error tracking | ৳0 |
| Payment sandbox testing | ৳0 |
| **SMS OTP (demo mode — log to file)** | **৳0** |
| **SMS OTP (if you need real SMS, one-time top-up)** | **~৳200–300 one-time** |
| **TOTAL monthly running cost** | **৳0** |
| **TOTAL one-time cost (optional SMS top-up)** | **৳200–300** |

You can build, run, and demo the **entire Thikana platform for ৳0 per month**. The only optional spend is a one-time ৳200–300 SMS top-up if your evaluators need to see real OTPs being delivered to real phones.
