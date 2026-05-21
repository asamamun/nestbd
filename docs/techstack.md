# NestBD — Detailed Tech Stack & Package Reference

**Platform:** Airbnb-style short-term rental marketplace for Bangladesh  
**Backend:** Laravel (PHP) · **Frontend:** React (JavaScript)  
**Last Updated:** May 2026  
**Note:** JavaScript (no TypeScript)

---

## Table of Contents

1. [Architecture Overview](#1-architecture-overview)
2. [Backend — Laravel](#2-backend--laravel)
3. [Frontend — React](#3-frontend--react)
4. [Mobile App](#4-mobile-app)
5. [Database & Storage](#5-database--storage)
6. [Infrastructure & DevOps](#6-infrastructure--devops)
7. [Third-Party Integrations](#7-third-party-integrations)
8. [Development Tooling](#8-development-tooling)
9. [Security Packages](#9-security-packages)
10. [Package Version Matrix](#10-package-version-matrix)

---

## 1. Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                        CLIENT LAYER                             │
│  React SPA (Web)      React Native (iOS/Android)                │
│  Vite + JavaScript    Expo + JavaScript                         │
└────────────────────────────┬────────────────────────────────────┘
                             │ HTTPS / REST + WebSocket
┌────────────────────────────▼────────────────────────────────────┐
│                      CDN / EDGE LAYER                           │
│  Cloudflare (WAF, DDoS, Caching, SSL termination)              │
└────────────────────────────┬────────────────────────────────────┘
                             │
┌────────────────────────────▼────────────────────────────────────┐
│                       API GATEWAY                               │
│  Laravel Sanctum Auth · Rate Limiting · Request Validation      │
└──────┬────────────────────┬──────────────────────┬─────────────┘
       │                    │                      │
┌──────▼──────┐    ┌────────▼───────┐    ┌────────▼────────┐
│  Laravel    │    │  Laravel       │    │  Laravel        │
│  REST API   │    │  WebSocket     │    │  Queue Worker   │
│  (Octane)   │    │  (Reverb)      │    │  (Horizon)      │
└──────┬──────┘    └────────────────┘    └────────┬────────┘
       │                                          │
┌──────▼──────────────────────────────────────────▼─────────────┐
│                     DATA LAYER                                  │
│   MariaDB/MySQL (primary)  ·  Redis (cache/queue/sessions)     │
│   Meilisearch (search)  ·  S3-compatible storage (media)       │
└────────────────────────────────────────────────────────────────┘
```

**Architecture Pattern:** Monolithic Laravel API with modular service classes and Action pattern. React SPA consumes the API. Real-time features use Laravel Reverb (WebSocket). Background jobs use Laravel Horizon + Redis queues.

---

## 2. Backend — Laravel

### 2.1 Core Framework

| Package | Version | Purpose |
|---------|---------|---------|
| `php` | `^8.3` | Runtime |
| `laravel/framework` | `^11.x` | Core framework |
| `laravel/octane` | `^2.x` | High-performance app server (FrankenPHP) |

### 2.2 Authentication & Authorisation

| Package | Version | Purpose |
|---------|---------|---------|
| `laravel/sanctum` | `^4.x` | SPA + mobile API token authentication |
| `spatie/laravel-permission` | `^6.x` | Role-based access control (RBAC) for admin roles |
| `pragmarx/google2fa-laravel` | `^2.x` | TOTP-based MFA for admin users |
| `lcobucci/jwt` | `^5.x` | JWT generation for third-party integrations |

### 2.3 API & Routing

| Package | Version | Purpose |
|---------|---------|---------|
| `laravel/api-resources` | built-in | API resource transformers |
| `spatie/laravel-query-builder` | `^5.x` | Filterable, sortable, paginated API endpoints |
| `knuckleswtf/scribe` | `^4.x` | Auto-generate API documentation |
| `fruitcake/laravel-cors` | built-in (`config/cors.php`) | CORS configuration |

### 2.4 Database & ORM

| Package | Version | Purpose |
|---------|---------|---------|
| `doctrine/dbal` | `^3.x` | Advanced schema migrations |
| `staudenmeir/eloquent-json-relations` | `^1.x` | JSON column relationships |
| `grimzy/laravel-mysql-spatial` | `^6.x` | MySQL spatial queries (geo-search for listings) |
| `spatie/laravel-sluggable` | `^3.x` | Auto-generate URL slugs for listings |

### 2.5 Caching & Performance

| Package | Version | Purpose |
|---------|---------|---------|
| `predis/predis` | `^2.x` | Redis PHP client |
| `laravel/octane` | `^2.x` | FrankenPHP/Swoole server for 10x throughput |
| `spatie/laravel-responsecache` | `^7.x` | Full-response caching for public listing pages |
| `mattiasgeniar/php-percentages` | — | Use custom service for Superhost score calc |

### 2.6 Queue & Background Jobs

| Package | Version | Purpose |
|---------|---------|---------|
| `laravel/horizon` | `^5.x` | Queue management dashboard + Redis queues |
| `laravel/scheduler` | built-in | Cron-based scheduled tasks (Superhost assessment, reminders) |

**Key Background Jobs:**
- `ProcessBookingPayment` — escrow hold + gateway webhook handler
- `ReleaseHostPayout` — triggered 24 hrs after guest check-in
- `AssessSuperhost` — runs quarterly
- `PublishBlindReviews` — publishes reviews when both submitted or 14-day window closes
- `SendCheckInReminder` — 48 hrs before check-in
- `SyncICalCalendar` — syncs Booking.com/Agoda iCal feeds
- `GenerateTaxCertificate` — annual PDF generation for hosts

### 2.7 Real-Time (WebSocket)

| Package | Version | Purpose |
|---------|---------|---------|
| `laravel/reverb` | `^1.x` | Official Laravel WebSocket server |
| `laravel/echo` | `^2.x` (JS) | Frontend WebSocket client |
| `pusher/pusher-php-server` | `^7.x` | Pusher protocol compatibility |

**Broadcast Events:** `NewMessage`, `BookingStatusChanged`, `PaymentReceived`, `NewBookingRequest`

### 2.8 Notifications

| Package | Version | Purpose |
|---------|---------|---------|
| `laravel/notifications` | built-in | Notification system (email, SMS, database) |
| `laravel-notification-channels/fcm` | `^5.x` | Firebase push notifications (Android/iOS) |
| `laravel-notification-channels/apn` | `^3.x` | APNs direct push (iOS fallback) |

**Custom SMS channel** via SSL Wireless or Infobip (Bangladesh gateway):

```php
// app/Channels/SslWirelessSmsChannel.php
class SslWirelessSmsChannel {
    public function send($notifiable, Notification $notification): void {
        Http::post(config('services.ssl_wireless.url'), [
            'api_token' => config('services.ssl_wireless.token'),
            'sid'       => config('services.ssl_wireless.sid'),
            'msisdn'    => $notifiable->mobile_number,
            'sms'       => $notification->toSms($notifiable),
        ]);
    }
}
```

### 2.9 File Storage & Media

| Package | Version | Purpose |
|---------|---------|---------|
| `league/flysystem-aws-s3-v3` | `^3.x` | S3-compatible storage (listing photos, ID docs) |
| `spatie/laravel-medialibrary` | `^11.x` | Media management, conversions, thumbnails |
| `intervention/image-laravel` | `^1.x` | Image resizing and watermarking |
| `spatie/image-optimizer` | `^1.x` | Lossless image compression pipeline |

**Media Collections per Listing:** `cover_photo`, `gallery`, `floor_plan`  
**Conversions:** `thumbnail (400×300)`, `medium (800×600)`, `large (1600×1200)`, `webp` variant for each

### 2.10 Search

| Package | Version | Purpose |
|---------|---------|---------|
| `laravel/scout` | `^10.x` | Search abstraction layer |
| `meilisearch/meilisearch-php` | `^1.x` | Meilisearch PHP client |

**Meilisearch Index: `listings`**  
Searchable attributes: `title_en`, `title_bn`, `description_en`, `district_name`, `division_name`, `area_name`  
Filterable attributes: `property_type`, `district_id`, `price_per_night`, `num_bedrooms`, `avg_rating`, `instant_book_enabled`, `amenity_ids`  
Sortable: `price_per_night`, `avg_rating`, `total_reviews`

### 2.11 Payment Integrations

| Package / Service | Purpose |
|-------------------|---------|
| `sslcommerz/sslcommerz-laravel` | SSLCOMMERZ gateway (cards, internet banking) |
| bKash Merchant API (custom service) | bKash PGW integration |
| Nagad API (custom service) | Nagad PGW integration |
| `stripe/stripe-php` (optional) | International card fallback |

**Payment Service Architecture:**

```
PaymentService (interface)
├── BkashPaymentDriver
├── NagadPaymentDriver
├── RocketPaymentDriver
└── SslCommerzPaymentDriver
```

### 2.12 PDF Generation

| Package | Version | Purpose |
|---------|---------|---------|
| `barryvdh/laravel-dompdf` | `^3.x` | Booking receipts, tax certificates, payout statements |
| `spatie/browsershot` | `^4.x` | Complex HTML → PDF (annual reports) via Puppeteer |

### 2.13 Email

| Package | Version | Purpose |
|---------|---------|---------|
| `laravel/mail` | built-in | Mail system |
| `symfony/mailgun-mailer` | `^7.x` | Mailgun transactional email (primary) |
| Mailtrap | — | Dev/staging email sandbox |

### 2.14 Localisation (Bangla / English)

| Package | Version | Purpose |
|---------|---------|---------|
| `mcamara/laravel-localization` | `^2.x` | URL-based locale routing (`/en/`, `/bn/`) |
| `laravel/lang` | built-in | Translation files |
| Custom `TranslationService` | — | Wrap Google Translate API for auto message translation |

### 2.15 Utilities & Helpers

| Package | Version | Purpose |
|---------|---------|---------|
| `spatie/laravel-data` | `^4.x` | Typed Data Transfer Objects (DTOs) for requests |
| `spatie/laravel-activity-log` | `^4.x` | Admin audit log (all model changes) |
| `spatie/laravel-backup` | `^9.x` | Automated DB + S3 backups |
| `spatie/laravel-health` | `^1.x` | Health check endpoints for uptime monitoring |
| `spatie/laravel-rate-limited-job-middleware` | `^2.x` | Rate-limit queue jobs (e.g. SMS bursts) |
| `propaganistas/laravel-phone` | `^5.x` | Bangladesh phone number validation (`+8801XXXXXXXXX`) |
| `nesbot/carbon` | `^3.x` | Date/time with Bangla locale support |
| `lorisleiva/laravel-actions` | `^2.x` | Action pattern (single-responsibility business logic classes) |
| `tightenco/ziggy` | `^2.x` | Share Laravel named routes with React frontend |

### 2.16 Testing (Backend)

| Package | Version | Purpose |
|---------|---------|---------|
| `phpunit/phpunit` | `^11.x` | Unit & feature tests |
| `pestphp/pest` | `^3.x` | Elegant test syntax (used on top of PHPUnit) |
| `pestphp/pest-plugin-laravel` | `^3.x` | Laravel-specific Pest helpers |
| `fakerphp/faker` | `^1.x` | Test data generation (with Bangla locale data) |
| `laravel/dusk` | `^8.x` | Browser/E2E tests |
| `mockery/mockery` | `^1.x` | Mocking in unit tests |

---

## 3. Frontend — React

### 3.1 Core Framework & Build

| Package | Version | Purpose |
|---------|---------|---------|
| `react` | `^19.x` | UI library |
| `react-dom` | `^19.x` | DOM renderer |
| `vite` | `^6.x` | Build tool and dev server |
| `@vitejs/plugin-react` | `^4.x` | React fast refresh |

### 3.2 Routing

| Package | Version | Purpose |
|---------|---------|---------|
| `react-router-dom` | `^7.x` | SPA routing with nested layouts |

> **Note:** For simpler projects, `react-router-dom` is sufficient. TypeScript-typed routing is not required with JavaScript.

### 3.3 State Management

| Package | Version | Purpose |
|---------|---------|---------|
| `@tanstack/react-query` | `^5.x` | Server state management (API fetching, caching, mutations) |
| `zustand` | `^5.x` | Lightweight global client state (auth, cart, UI state) |
| `immer` | `^10.x` | Immutable state updates in Zustand stores |

**State Split:**
- **TanStack Query** — all API data (listings, bookings, user profile)
- **Zustand** — auth session, search filters, map state, booking wizard state, UI modals

### 3.4 UI Components & Styling

| Package | Version | Purpose |
|---------|---------|---------|
| `tailwindcss` | `^4.x` | Utility-first CSS |
| `@tailwindcss/vite` | `^4.x` | Vite plugin for Tailwind v4 |
| `shadcn/ui` | latest | Accessible, composable component primitives |
| `@radix-ui/react-*` | `^1.x` | Headless accessible components (used by shadcn) |
| `framer-motion` | `^11.x` | Animations (listing cards, map popups, booking wizard) |
| `lucide-react` | `^0.4x` | Icon set |
| `class-variance-authority` | `^0.7.x` | Variant-driven component styling |
| `clsx` | `^2.x` | Conditional class merging |
| `tailwind-merge` | `^2.x` | Smart Tailwind class merging |

### 3.5 Forms & Validation

| Package | Version | Purpose |
|---------|---------|---------|
| `react-hook-form` | `^7.x` | Performant form management |
| `zod` | `^3.x` | Schema validation (runtime validation for JavaScript) |

### 3.6 Maps & Geo

| Package | Version | Purpose |
|---------|---------|---------|
| `maplibre-gl` | `^4.x` | Open-source map rendering (no Google Maps API cost) |
| `react-map-gl` | `^7.x` | React wrapper for MapLibre |
| Tile source: **OpenStreetMap + Protomaps** | — | Free tile server, Bangladesh coverage excellent |
| `@turf/turf` | `^6.x` | Geospatial calculations (radius search, polygon checks) |

> **Why MapLibre over Google Maps?** No per-request billing, full control over tile styling in Bangla, open-source.

### 3.7 Date & Calendar

| Package | Version | Purpose |
|---------|---------|---------|
| `react-day-picker` | `^9.x` | Availability calendar / date range picker |
| `date-fns` | `^4.x` | Date manipulation (lightweight, tree-shakeable) |
| `@date-io/date-fns` | — | MUI/picker adapters if needed |

> Integrate `date-fns/locale/bn` for Bangla month/day names.

### 3.8 Real-Time & WebSocket

| Package | Version | Purpose |
|---------|---------|---------|
| `laravel-echo` | `^2.x` | Laravel Reverb WebSocket client |
| `pusher-js` | `^8.x` | Pusher protocol client (used by Echo) |

### 3.9 File Upload & Media

| Package | Version | Purpose |
|---------|---------|---------|
| `react-dropzone` | `^14.x` | Drag-and-drop photo upload |
| `browser-image-compression` | `^2.x` | Client-side image compression before upload |
| `react-image-gallery` | `^1.x` | Listing photo gallery / lightbox |
| `@cloudinary/react` | optional | Advanced image delivery with transformations |

### 3.10 Payment UI

| Package | Version | Purpose |
|---------|---------|---------|
| `@stripe/react-stripe-js` | `^2.x` | Card input UI (international cards via Stripe) |
| Custom bKash/Nagad components | — | Redirect-based flow for MFS payments |

### 3.11 Data Display & Charts

| Package | Version | Purpose |
|---------|---------|---------|
| `recharts` | `^2.x` | Host earnings charts, admin dashboards |
| `@tanstack/react-table` | `^8.x` | Admin data tables (bookings, users, disputes) |
| `react-hot-toast` | `^2.x` | Toast notifications |
| `sonner` | `^1.x` | Elegant toast notifications (alternative) |

### 3.12 Localisation (Bangla / English)

| Package | Version | Purpose |
|---------|---------|---------|
| `react-i18next` | `^15.x` | i18n framework |
| `i18next` | `^24.x` | i18n core |
| `i18next-http-backend` | `^3.x` | Lazy-load translation JSON files |
| `i18next-browser-languagedetector` | `^8.x` | Auto-detect browser language |

**Translation files:** `public/locales/en/` and `public/locales/bn/`  
**Bangla numerals:** Custom `formatBnNumber()` utility to render ০১২৩৪৫৬৭৮৯ vs 0–9.

### 3.13 SEO & Meta

| Package | Version | Purpose |
|---------|---------|---------|
| `react-helmet-async` | `^2.x` | Dynamic `<head>` meta tags per listing page |

> For full SEO, implement **SSR via Inertia.js** (see Section 3.15) or a separate Next.js frontend for the public listing pages.

### 3.14 Accessibility & UX

| Package | Version | Purpose |
|---------|---------|---------|
| `@radix-ui/react-*` | built into shadcn | WAI-ARIA compliant components |
| `focus-trap-react` | `^10.x` | Focus management for modals/drawers |
| `react-aria` (Adobe) | `^3.x` | Optional: extra a11y hooks for custom components |

### 3.15 Inertia.js (Optional but Recommended)

| Package | Version | Purpose |
|---------|---------|---------|
| `@inertiajs/react` | `^2.x` | Glue layer between Laravel and React — no separate API needed for SSR pages |
| `inertiajs/inertia-laravel` | `^2.x` | Laravel adapter |

> **Recommendation:** Use Inertia.js for the main site (server-driven SPA with SSR). Use pure REST API + React for the admin panel and mobile. This gives you the best of both worlds: SEO-friendly listing pages + SPA experience. JavaScript works seamlessly with Inertia.js without TypeScript.

### 3.16 Testing (Frontend)

| Package | Version | Purpose |
|---------|---------|---------|
| `vitest` | `^2.x` | Unit test runner (Vite-native) |
| `@testing-library/react` | `^16.x` | Component testing |
| `@testing-library/user-event` | `^14.x` | User interaction simulation |
| `msw` | `^2.x` | API mocking (Mock Service Worker) |
| `playwright` | `^1.x` | E2E browser tests |
| `@playwright/test` | `^1.x` | Playwright test runner |

---

## 4. Mobile App

| Package | Version | Purpose |
|---------|---------|---------|
| `expo` | `^52.x` | Managed React Native workflow |
| `react-native` | `^0.76.x` | Core |
| `expo-router` | `^4.x` | File-based routing for Expo |
| `@tanstack/react-query` | `^5.x` | API state (shared logic with web) |
| `zustand` | `^5.x` | Global state (shared logic with web) |
| `react-hook-form` + `zod` | same as web | Forms & validation (shared logic) |
| `expo-notifications` | `^0.29.x` | FCM + APNs push notifications |
| `expo-location` | `^17.x` | GPS location for "nearby" search |
| `expo-image-picker` | `^15.x` | Photo upload from camera/gallery |
| `expo-secure-store` | `^13.x` | Secure token storage (replaces localStorage) |
| `@shopify/flash-list` | `^1.x` | Performant listing/booking lists |
| `react-native-maps` | `^1.x` | Map view for listing search |
| `react-native-mmkv` | `^3.x` | Fast key-value storage for offline data |
| `react-i18next` | same as web | Bangla/English (shared translation files) |
| `react-native-reanimated` | `^3.x` | Smooth animations |
| `react-native-gesture-handler` | `^2.x` | Gesture support |
| `react-native-safe-area-context` | `^4.x` | Safe area (notch-aware) |
| `nativewind` | `^4.x` | Tailwind CSS for React Native |

---

## 5. Database & Storage

| Technology | Version | Purpose |
|------------|---------|---------|
| **MariaDB/MySQL** | `8.0.x` | Primary relational database |
| **Redis** | `7.x` | Cache, sessions, queues, pub/sub for WebSocket |
| **Meilisearch** | `1.x` | Full-text search (listings in Bangla + English) |
| **MinIO** / AWS S3 | — | Object storage (photos, ID docs, PDFs) |
| **AWS CloudFront** / Cloudflare R2 | — | CDN for listing photos |

**Database Drivers (PHP):**
- `ext-pdo_mysql` — MySQL/MariaDB PDO driver
- `ext-redis` — Redis PHP extension (preferred over predis for Octane)

---

## 6. Infrastructure & DevOps

### 6.1 Server & Containerisation

| Tool | Purpose |
|------|---------|
| **Docker** + `docker-compose` | Local development environment |
| **Dockerfile** (PHP 8.3 + FrankenPHP) | Production container |
| **Kubernetes (K8s)** or **AWS ECS** | Container orchestration |
| **Nginx** | Reverse proxy / static asset serving |
| **FrankenPHP** | Laravel Octane server (replaces PHP-FPM) |

### 6.2 CI/CD

| Tool | Purpose |
|------|---------|
| **GitHub Actions** | CI/CD pipelines |
| `laravel/pint` | PHP code style (CI check) |
| `pestphp/pest` | Automated tests in CI |
| `vitest` + `playwright` | Frontend tests in CI |
| **Laravel Envoy** | Zero-downtime deployment scripts |

### 6.3 Monitoring & Observability

| Tool | Purpose |
|------|---------|
| **Laravel Telescope** | Debug/dev: queries, jobs, emails, requests |
| **Laravel Horizon** | Queue monitoring dashboard |
| **Sentry** (`sentry/sentry-laravel`, `@sentry/react`) | Error tracking (backend + frontend) |
| **Prometheus + Grafana** | Metrics and infrastructure dashboards |
| **Uptime Kuma** | Uptime monitoring + alerts |
| **Laravel Pulse** | `^1.x` — Real-time application performance dashboard |

### 6.4 Hosting Recommendation (Bangladesh Context)

| Layer | Provider |
|-------|----------|
| Compute | AWS (Singapore ap-southeast-1) or Azure Southeast Asia — lowest latency from BD |
| CDN | Cloudflare (free tier or Pro) — excellent Bangladesh PoPs |
| Database | AWS RDS MariaDB/MySQL (Multi-AZ) or DigitalOcean Managed MySQL |
| Object Storage | AWS S3 + CloudFront or Cloudflare R2 |
| Email | Mailgun / Amazon SES |
| SMS | SSL Wireless (primary BD gateway) + Infobip (fallback) |

---

## 7. Third-Party Integrations

### 7.1 Payment Gateways

| Service | Integration Method |
|---------|-------------------|
| **bKash PGW** | REST API (Merchant credentials required) |
| **Nagad PGW** | REST API (Merchant credentials required) |
| **Rocket (DBBL)** | REST API |
| **SSLCOMMERZ** | `sslcommerz/sslcommerz-laravel` package |
| **Stripe** (international) | `stripe/stripe-php` |

### 7.2 SMS Gateways

| Service | Purpose |
|---------|---------|
| **SSL Wireless** | Primary OTP + transactional SMS (BD) |
| **Infobip** | Fallback SMS, international numbers |

### 7.3 Identity Verification

| Service | Purpose |
|---------|---------|
| **Jumio / Onfido** | NID/Passport liveness check + OCR |
| Bangladesh NID API (if available) | EC Bangladesh ID validation |
| Google Vision API | Document OCR fallback |

### 7.4 Maps & Location

| Service | Purpose |
|---------|---------|
| **MapLibre GL + OpenStreetMap** | Map display (free) |
| **Nominatim** | Geocoding (address → coordinates) |
| **Overpass API** | POI data near listings |

### 7.5 Communication & Translation

| Service | Purpose |
|---------|---------|
| **Firebase Cloud Messaging (FCM)** | Android + iOS push notifications |
| **Google Translate API** | Auto message translation (Bangla ↔ English) |
| **Mailgun** | Transactional email |

### 7.6 Analytics & Tracking

| Service | Purpose |
|---------|---------|
| **PostHog** (self-hosted) | Product analytics, funnels, session recording |
| **Google Analytics 4** | Web traffic |
| **Meta Pixel** | Facebook/Instagram ad retargeting |

---

## 8. Development Tooling

### 8.1 Backend

| Tool | Purpose |
|------|---------|
| `laravel/pint` | PHP CS Fixer (PSR-12 + Laravel opinionated rules) |
| `phpstan/phpstan` + `larastan/larastan` | Static analysis (Level 8 target) |
| `rector/rector` | Automated PHP upgrades |
| Laravel Herd | Local dev (macOS) |
| **Laragon** | Local dev (Windows — common in BD) |

### 8.2 Frontend

| Tool | Purpose |
|------|---------|
| `eslint` | JavaScript linting |
| `prettier` | Code formatting |
| `husky` | Git hooks (pre-commit linting) |
| `lint-staged` | Run linters only on staged files |
| `@commitlint/cli` | Enforce conventional commits |
| Storybook | Component library documentation |

### 8.3 API Development

| Tool | Purpose |
|------|---------|
| **Bruno** / Postman | API testing collections |
| `knuckleswtf/scribe` | Auto-generate OpenAPI docs from Laravel code |
| **Swagger UI** | API documentation UI |

---

## 9. Security Packages

| Package | Purpose |
|---------|---------|
| `laravel/sanctum` | CSRF protection + SPA auth |
| `spatie/laravel-csp` | Content Security Policy headers |
| `bepsvpt/secure-headers` | Security HTTP headers (HSTS, X-Frame, etc.) |
| `pragmarx/google2fa-laravel` | Admin MFA |
| `owen-it/laravel-auditing` | Tamper-evident audit trail for financial records |
| `paragonie/random_compat` | Cryptographically secure random (PHP < 8 fallback) |
| Laravel built-in `Hash::make()` | bcrypt/argon2 password hashing |
| Cloudflare WAF | DDoS protection, bot filtering, rate limiting at edge |

---

## 10. Package Version Matrix

### Laravel (composer.json)

```json
{
  "require": {
    "php": "^8.3",
    "laravel/framework": "^11.0",
    "laravel/octane": "^2.5",
    "laravel/sanctum": "^4.0",
    "laravel/horizon": "^5.25",
    "laravel/reverb": "^1.0",
    "laravel/scout": "^10.10",
    "laravel/pulse": "^1.0",
    "spatie/laravel-permission": "^6.10",
    "spatie/laravel-medialibrary": "^11.10",
    "spatie/laravel-activity-log": "^4.9",
    "spatie/laravel-data": "^4.11",
    "spatie/laravel-query-builder": "^5.8",
    "spatie/laravel-backup": "^9.0",
    "spatie/laravel-health": "^1.30",
    "spatie/laravel-responsecache": "^7.6",
    "spatie/laravel-sluggable": "^3.6",
    "grimzy/laravel-mysql-spatial": "^6.0",
    "lorisleiva/laravel-actions": "^2.8",
    "tightenco/ziggy": "^2.3",
    "propaganistas/laravel-phone": "^5.3",
    "mcamara/laravel-localization": "^2.0",
    "pragmarx/google2fa-laravel": "^2.2",
    "barryvdh/laravel-dompdf": "^3.0",
    "knuckleswtf/scribe": "^4.39",
    "predis/predis": "^2.3",
    "intervention/image-laravel": "^1.3",
    "league/flysystem-aws-s3-v3": "^3.28",
    "meilisearch/meilisearch-php": "^1.10",
    "bepsvpt/secure-headers": "^8.0",
    "spatie/laravel-csp": "^2.10",
    "owen-it/laravel-auditing": "^14.0",
    "nesbot/carbon": "^3.8",
    "staudenmeir/eloquent-json-relations": "^1.11"
  },
  "require-dev": {
    "pestphp/pest": "^3.4",
    "pestphp/pest-plugin-laravel": "^3.0",
    "fakerphp/faker": "^1.23",
    "laravel/dusk": "^8.2",
    "laravel/pint": "^1.18",
    "phpstan/phpstan": "^1.12",
    "larastan/larastan": "^3.0",
    "laravel/telescope": "^5.2",
    "mockery/mockery": "^1.6",
    "nunomaduro/collision": "^8.4"
  }
}
```

### React (package.json)

```json
{
  "dependencies": {
    "react": "^19.0.0",
    "react-dom": "^19.0.0",
    "@inertiajs/react": "^2.0.0",
    "@tanstack/react-query": "^5.65.0",
    "@tanstack/react-table": "^8.20.0",
    "zustand": "^5.0.0",
    "immer": "^10.1.0",
    "react-hook-form": "^7.54.0",
    "zod": "^3.24.0",
    "tailwindcss": "^4.0.0",
    "framer-motion": "^11.15.0",
    "@radix-ui/react-dialog": "^1.1.0",
    "@radix-ui/react-dropdown-menu": "^2.1.0",
    "@radix-ui/react-select": "^2.1.0",
    "@radix-ui/react-slider": "^1.2.0",
    "@radix-ui/react-tabs": "^1.1.0",
    "lucide-react": "^0.469.0",
    "class-variance-authority": "^0.7.0",
    "clsx": "^2.1.0",
    "tailwind-merge": "^2.6.0",
    "maplibre-gl": "^4.7.0",
    "react-map-gl": "^7.1.0",
    "@turf/turf": "^6.5.0",
    "react-day-picker": "^9.4.0",
    "date-fns": "^4.1.0",
    "react-dropzone": "^14.3.0",
    "browser-image-compression": "^2.0.0",
    "react-image-gallery": "^1.3.0",
    "recharts": "^2.14.0",
    "laravel-echo": "^2.1.0",
    "pusher-js": "^8.4.0",
    "react-i18next": "^15.2.0",
    "i18next": "^24.2.0",
    "i18next-http-backend": "^3.0.0",
    "i18next-browser-languagedetector": "^8.0.0",
    "react-helmet-async": "^2.0.0",
    "react-hot-toast": "^2.4.0",
    "sonner": "^1.7.0",
    "@stripe/react-stripe-js": "^2.9.0",
    "@stripe/stripe-js": "^5.4.0",
    "@sentry/react": "^8.47.0"
  },
  "devDependencies": {
    "vite": "^6.0.0",
    "@vitejs/plugin-react": "^4.3.0",
    "vitest": "^2.1.0",
    "@testing-library/react": "^16.1.0",
    "@testing-library/user-event": "^14.5.0",
    "msw": "^2.7.0",
    "playwright": "^1.49.0",
    "@playwright/test": "^1.49.0",
    "eslint": "^9.17.0",
    "prettier": "^3.4.0",
    "husky": "^9.1.0",
    "lint-staged": "^15.3.0",
    "@commitlint/cli": "^19.6.0",
    "@commitlint/config-conventional": "^19.6.0"
  }
}
```

---

## Quick Reference — Key Architectural Decisions

| Decision | Choice | Reason |
|----------|--------|--------|
| API layer | Inertia.js (SSR) + REST | SEO for listing pages + SPA for dashboard |
| Auth | Laravel Sanctum | SPA cookies (secure) + mobile tokens |
| Real-time | Laravel Reverb | Official, self-hosted, no Pusher billing |
| Search | Meilisearch | Bangla typo-tolerance, fast, self-hosted |
| Maps | MapLibre + OSM | Zero API cost, Bangla tile support |
| Queue | Horizon + Redis | Visibility, monitoring, priority queues |
| Media | Spatie MediaLibrary + S3 | Auto-conversion, CDN-ready |
| State (web) | TanStack Query + Zustand | Best-in-class server/client state split |
| Forms | React Hook Form + Zod | Performance + shared validation schemas |
| Styling | Tailwind v4 + shadcn/ui | Rapid UI, accessible, Bangladesh-localised |
| Mobile | Expo (managed) | Fastest iteration, OTA updates |
| SMS | SSL Wireless | Local BD gateway, Bangla SMS support |
| Payments | bKash + Nagad + SSLCOMMERZ | Covers 95%+ of BD digital payment users |
