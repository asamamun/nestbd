# Airbnb Bangladesh — Complete Requirements Analysis

**Version:** 1.0  
**Date:** May 2026  
**Scope:** A localized short-term rental marketplace platform for Bangladesh, adapted for local regulations, payment infrastructure (bKash, Nagad, Rocket, local bank transfers), and cultural norms.

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Stakeholder Perspectives](#2-stakeholder-perspectives)
   - 2.1 [Paying Guest (Traveller/Renter)](#21-paying-guest-travellerrenter)
   - 2.2 [Host (Property Owner/Manager)](#22-host-property-ownermanager)
   - 2.3 [Site Administrator](#23-site-administrator)
3. [Non-Functional Requirements](#3-non-functional-requirements)
4. [Bangladesh-Specific Localisation Requirements](#4-bangladesh-specific-localisation-requirements)
5. [Compliance & Legal Requirements](#5-compliance--legal-requirements)
6. [Glossary](#6-glossary)

---

## 1. Project Overview

The platform is a two-sided marketplace that connects property owners (Hosts) with travellers and short-term renters (Guests) across Bangladesh. The system facilitates property discovery, booking, secure payment, review, and dispute management. It operates under Bangladesh's laws, integrates with local payment rails, and supports the Bengali language alongside English.

---

## 2. Stakeholder Perspectives

### 2.1 Paying Guest (Traveller/Renter)

#### 2.1.1 Registration & Identity

- **REQ-G-001** Guests shall be able to register using a mobile phone number (mandatory), email address (optional), or via OAuth (Google, Facebook).
- **REQ-G-002** Mobile number verification via OTP (SMS) shall be mandatory before a guest can make a booking.
- **REQ-G-003** Guests shall be able to upload a government-issued photo ID (NID, passport, or driving licence) for identity verification.
- **REQ-G-004** The system shall support a tiered verification badge (Email Verified, Phone Verified, ID Verified) visible to hosts.
- **REQ-G-005** Guests shall be able to manage personal profile information: name, profile photo, bio, preferred language (Bangla/English), and date of birth.
- **REQ-G-006** The system shall allow guests to deactivate or permanently delete their account subject to no pending bookings or disputes.

#### 2.1.2 Property Search & Discovery

- **REQ-G-010** Guests shall be able to search properties by: location (division, district, upazila, city area, or map), check-in date, check-out date, and number of guests.
- **REQ-G-011** The system shall provide advanced filters: property type, price range (BDT), number of bedrooms/bathrooms, amenities (WiFi, AC, generator/IPS backup, parking, kitchen, etc.), instant booking availability, and host language.
- **REQ-G-012** Search results shall be sortable by: relevance, price (low/high), rating, number of reviews, and distance from a reference point.
- **REQ-G-013** The system shall display listings on an interactive map view using GPS coordinates.
- **REQ-G-014** Guests shall be able to save properties to a Wishlist and organise wishlists by trip.
- **REQ-G-015** The system shall support a "Nearby Properties" feature using the guest's current device location.
- **REQ-G-016** The system shall show properties with a "Superhost" badge prominently in search results.
- **REQ-G-017** The system shall support searching by popular Bangladesh destinations (Cox's Bazar, Sylhet, Sundarbans area, Bandarban, Rangamati, Dhaka, Chittagong, etc.).
- **REQ-G-018** The system shall allow guests to view the host's profile, other listings, and reviews before booking.

#### 2.1.3 Listing Detail & Evaluation

- **REQ-G-020** Each listing page shall display: property name, full description (Bangla/English), photo gallery (minimum 5 photos), location (map, neighbourhood description, exact address shown only after confirmed booking), price breakdown, house rules, cancellation policy, availability calendar, amenities list, and reviews.
- **REQ-G-021** Guests shall be able to view the price breakdown before booking: nightly rate, cleaning fee, service fee, applicable taxes (VAT per Bangladesh NBR rules), and total.
- **REQ-G-022** Guests shall be able to ask the host questions via a pre-booking message.
- **REQ-G-023** Guests shall be able to report a listing as inaccurate, fraudulent, or offensive.
- **REQ-G-024** Guests shall see a "Similar Properties" section on each listing page.
- **REQ-G-025** Guests shall be able to share a listing via a public URL or social media links.

#### 2.1.4 Booking

- **REQ-G-030** Guests shall be able to make an instant booking (if the host enables it) or submit a booking request that requires host approval.
- **REQ-G-031** For booking requests, the host shall have 24 hours to accept or decline; the guest shall receive a notification either way.
- **REQ-G-032** Guests shall be able to add a personal message to the host at the time of booking.
- **REQ-G-033** The system shall prevent double-booking: a property cannot be booked for overlapping dates.
- **REQ-G-034** Guests shall be able to book on behalf of other travellers and list the names of additional guests.
- **REQ-G-035** The system shall display a booking confirmation with a unique booking reference number (BRN).
- **REQ-G-036** Guests shall receive email and SMS confirmation of every booking.
- **REQ-G-037** Guests shall be able to view all past, current, and upcoming bookings in a "My Trips" dashboard.
- **REQ-G-038** Guests shall be able to request a booking modification (date changes, number of guests) subject to host approval and price recalculation.
- **REQ-G-039** Guests shall be able to cancel a booking and receive a refund according to the applicable cancellation policy.

#### 2.1.5 Payment

- **REQ-G-040** The platform shall support the following payment methods: bKash, Nagad, Rocket, VISA/Mastercard (local and international), internet banking (SSLCOMMERZ gateway), and cash on arrival (for specific host-approved listings).
- **REQ-G-041** All monetary amounts shall be stored and displayed in Bangladeshi Taka (BDT).
- **REQ-G-042** Payment shall be collected by the platform at the time of booking and held in escrow until 24 hours after check-in.
- **REQ-G-043** Guests shall receive a digital payment receipt/invoice in PDF format.
- **REQ-G-044** Guests shall be able to view a full payment history.
- **REQ-G-045** The platform shall support split payment (e.g., deposit at booking, balance closer to check-in) for long-duration stays (7+ nights).
- **REQ-G-046** Refunds shall be processed to the original payment method within 5–7 business days per Bangladesh banking norms.
- **REQ-G-047** Guests shall be able to apply platform-issued coupon codes or promotional discount codes.

#### 2.1.6 Communication

- **REQ-G-050** Guests shall have access to an in-platform messaging system to communicate with hosts before, during, and after a stay.
- **REQ-G-051** The messaging system shall support text, image attachments, and read receipts.
- **REQ-G-052** Guests shall receive push notifications (mobile app), SMS, and email notifications for: booking confirmations, host messages, check-in reminders (48 hours before), and review reminders (24 hours after checkout).
- **REQ-G-053** Guests shall be able to contact platform customer support via chat, email, or phone (local Bangladesh toll-free or low-cost number).
- **REQ-G-054** The system shall auto-translate messages between Bangla and English if the guest and host use different languages.

#### 2.1.7 Check-In & Stay

- **REQ-G-060** After booking confirmation, the guest shall receive the exact property address, check-in instructions, and host contact details.
- **REQ-G-061** Guests shall be able to use a digital check-in feature (host sends a PIN, key code, or QR code through the app).
- **REQ-G-062** Guests shall be able to request an early check-in or late checkout from within the app.
- **REQ-G-063** Guests shall be able to report an emergency or property issue to the platform during their stay.

#### 2.1.8 Reviews & Ratings

- **REQ-G-070** Guests shall be able to submit a review and ratings (1–5 stars) for: overall experience, cleanliness, accuracy (listing vs reality), check-in process, communication, location, and value for money.
- **REQ-G-071** Reviews shall only be publishable after checkout and within 14 days of checkout.
- **REQ-G-072** Reviews shall be published simultaneously to prevent bias (blind review system).
- **REQ-G-073** Guests shall be able to see the host's public response to their review.
- **REQ-G-074** Guests shall be able to rate and review the host as a person (reliability, accuracy, communication).

#### 2.1.9 Safety & Trust

- **REQ-G-080** Guests shall be able to share trip details with an emergency contact.
- **REQ-G-081** The platform shall provide a safety information page with local emergency numbers (Police: 999, Fire: 999, Ambulance: 999, Anti-corruption: 106).
- **REQ-G-082** Guests shall be able to flag a safety concern during an active stay, triggering a 24/7 platform response.
- **REQ-G-083** The platform shall offer optional travel insurance integration for guests (domestic travel insurance providers).

---

### 2.2 Host (Property Owner/Manager)

#### 2.2.1 Registration & Identity Verification

- **REQ-H-001** Hosts shall register using mobile number and/or email; OAuth via Google/Facebook shall also be supported.
- **REQ-H-002** Hosts shall complete enhanced identity verification: NID or passport scan, selfie verification (liveness check), and bank account or mobile banking account details for payout.
- **REQ-H-003** For commercial hosts (hotels, guesthouses, resorts), the system shall require a Trade Licence number, TIN certificate, and VAT registration number (if applicable).
- **REQ-H-004** The system shall perform background verification checks (manual or third-party) and flag accounts pending verification.
- **REQ-H-005** Hosts shall be able to manage multiple properties under a single account or separate co-host accounts.
- **REQ-H-006** The system shall allow a host to designate co-hosts with configurable permission levels (view-only, manage calendar, manage bookings, full access).

#### 2.2.2 Listing Management

- **REQ-H-010** Hosts shall be able to create, edit, publish, unpublish, and delete property listings.
- **REQ-H-011** A listing form shall capture: property type (entire place, private room, shared room, hotel room), property sub-type (apartment/flat, house, villa, guest house, resort cabin, houseboat, tree house, etc.), title, description (Bangla and English), address (division, district, upazila, thana, road, house/flat number), GPS coordinates, accommodation capacity (max guests), number of bedrooms, bathrooms, beds, and bed types.
- **REQ-H-012** Hosts shall be able to upload up to 50 high-resolution photos with captions and designate a cover photo.
- **REQ-H-013** The system shall support a curated amenities checklist including Bangladesh-specific items: generator/IPS backup, inverter, gas stove type (cylinder/piped), water source (WASA/tube-well/filter), mosquito net/repellent, prayer mat and qibla direction, Ramadan facilities (sehri/iftar timing notification), local TV channels, and rooftop/balcony access.
- **REQ-H-014** Hosts shall set house rules: no smoking, no pets, no parties, check-in/checkout times, quiet hours, unmarried couple policy (with a flag to show if couples' ID will be required at check-in per Bangladesh social norms), child policy, and additional rules in free text.
- **REQ-H-015** Hosts shall be able to set a minimum and maximum night stay requirement.
- **REQ-H-016** Hosts shall be able to configure advance notice required before a booking (same day, 1 day, 2 days, 7 days).
- **REQ-H-017** Hosts shall be able to set a preparation/buffer time between bookings.

#### 2.2.3 Pricing & Revenue Management

- **REQ-H-020** Hosts shall set a base nightly price in BDT.
- **REQ-H-021** Hosts shall be able to set weekend pricing (Thursday–Friday premium in Bangladesh context), seasonal pricing (Eid ul-Fitr, Eid ul-Adha, Pohela Boishakh, Pohela Falgun, winter peak season for Cox's Bazar/hill tracts), and special event pricing.
- **REQ-H-022** Hosts shall be able to set length-of-stay discounts (weekly discount, monthly discount).
- **REQ-H-023** Hosts shall be able to set an optional cleaning fee, extra guest fee (beyond a base number), and security deposit amount.
- **REQ-H-024** The platform shall display a Smart Pricing suggestion based on local demand, competitor pricing, and seasonal trends.
- **REQ-H-025** Hosts shall choose a cancellation policy: Flexible, Moderate, Strict, or Super Strict.
- **REQ-H-026** The system shall automatically apply the platform service fee (configurable by admin, typically 3–5% for hosts) and display the net payout to the host before the listing goes live.

#### 2.2.4 Calendar & Availability Management

- **REQ-H-030** Hosts shall manage availability via an interactive monthly/weekly calendar.
- **REQ-H-031** Hosts shall be able to manually block dates (personal use, maintenance, renovation).
- **REQ-H-032** The system shall support iCal synchronisation with external platforms (Booking.com, Agoda, etc.) to prevent double bookings.
- **REQ-H-033** Hosts shall be able to enable or disable "Instant Booking" at any time.
- **REQ-H-034** Hosts shall be able to set different check-in/checkout times per calendar period.

#### 2.2.5 Booking Management

- **REQ-H-040** Hosts shall receive real-time notifications (push, SMS, email) for: new booking requests, cancellations, booking modifications, guest messages, and upcoming check-ins.
- **REQ-H-041** Hosts shall be able to accept or decline a booking request with an optional message to the guest.
- **REQ-H-042** Hosts shall be able to pre-approve a guest (send a special invite link with a pre-set price).
- **REQ-H-043** Hosts shall be able to send a special offer with a custom price and expiry to a specific guest.
- **REQ-H-044** Hosts shall be able to view a full booking history with guest details (name, profile, verified ID status).
- **REQ-H-045** Hosts shall be able to cancel a booking (subject to penalties as configured by admin) and the system shall automatically initiate guest refund.
- **REQ-H-046** Hosts shall have a dashboard showing: upcoming check-ins/checkouts, pending requests, current occupancy, and unread messages.

#### 2.2.6 Guest Screening

- **REQ-H-050** Hosts shall be able to require guests to have: a verified phone number, a verified government ID, or a positive review history before booking.
- **REQ-H-051** Hosts shall be able to restrict bookings to guests with at least N previous reviews.
- **REQ-H-052** The system shall display a guest's verification badges, profile completeness score, and any prior negative reviews to the host.
- **REQ-H-053** Hosts shall be able to block specific guests from sending booking requests.

#### 2.2.7 Payouts

- **REQ-H-060** Hosts shall configure payout methods: bKash, Nagad, Rocket, bank transfer (BEFTN/RTGS), and VISA/Mastercard.
- **REQ-H-061** Payouts shall be released 24 hours after confirmed guest check-in, minus platform service fees and applicable taxes.
- **REQ-H-062** Hosts shall be able to set payout frequency: per booking, weekly, or monthly.
- **REQ-H-063** Hosts shall receive a payout statement (PDF/printable) summarising all transactions, platform fees deducted, and tax amounts for each payout period.
- **REQ-H-064** The system shall generate annual earning summaries for tax reporting purposes (Income Tax Ordinance 1984 compliance).
- **REQ-H-065** If a payout fails, the system shall retry and notify the host, allowing them to update payout details.

#### 2.2.8 Reviews

- **REQ-H-070** Hosts shall be able to review guests (1–5 stars) for: cleanliness, communication, adherence to house rules, and overall experience.
- **REQ-H-071** Hosts shall be able to write a public response to a guest's review of their property.
- **REQ-H-072** Reviews shall only be publishable after the guest's checkout and within 14 days.
- **REQ-H-073** The system shall display a host's overall rating and total number of reviews prominently on their listing.

#### 2.2.9 Superhost Programme

- **REQ-H-080** The system shall automatically assess hosts for Superhost status quarterly based on: response rate ≥ 90%, booking acceptance rate ≥ 90%, minimum 10 completed stays or 100 nights per year, and overall rating ≥ 4.8.
- **REQ-H-081** Superhost badge shall appear on the listing and host profile.
- **REQ-H-082** Superhosts shall receive priority in search rankings and access to exclusive features (e.g., lower service fee tier).

#### 2.2.10 Performance Analytics

- **REQ-H-090** Hosts shall have access to a performance dashboard showing: total earnings (daily, weekly, monthly, yearly), occupancy rate, average nightly rate, page views, wishlist saves, booking conversion rate, and review score trends.
- **REQ-H-091** The dashboard shall show comparative data (e.g., how the listing performs vs. similar listings in the same area).
- **REQ-H-092** Hosts shall be able to export earnings reports as CSV or PDF.

---

### 2.3 Site Administrator

#### 2.3.1 User Management

- **REQ-A-001** Admins shall have a secure, role-based admin panel with multi-factor authentication (MFA).
- **REQ-A-002** Admin roles shall include: Super Admin, Operations Manager, Finance Manager, Content Moderator, Customer Support Agent, and Compliance Officer — each with role-specific permissions.
- **REQ-A-003** Admins shall be able to view, search, filter, and export all user accounts (guests and hosts) by: registration date, verification status, location, account status, and booking activity.
- **REQ-A-004** Admins shall be able to manually verify, suspend, ban, or permanently delete user accounts with an audit trail.
- **REQ-A-005** Admins shall be able to reset user passwords and force re-verification.
- **REQ-A-006** The system shall log all admin actions with timestamp, admin ID, and action details.
- **REQ-A-007** Admins shall be able to merge duplicate accounts after verification.
- **REQ-A-008** Admins shall be able to impersonate a user account for support purposes (with full audit logging).

#### 2.3.2 Listing Moderation & Quality Control

- **REQ-A-010** Admins shall be able to review newly submitted listings before publication (manual review queue or automated checks with flagging).
- **REQ-A-011** Admins shall be able to approve, reject, request changes, or suspend any listing with a mandatory reason note sent to the host.
- **REQ-A-012** The system shall use automated image moderation (AI-based) to flag inappropriate photos.
- **REQ-A-013** Admins shall be able to run a plagiarism/duplicate listing check (same address with different host accounts).
- **REQ-A-014** Admins shall manage a category/property-type taxonomy for Bangladesh (e.g., adding "Beach Hut" for Cox's Bazar, "Tea Garden Cottage" for Sylhet).
- **REQ-A-015** Admins shall be able to feature specific listings on the homepage or in curated collections.
- **REQ-A-016** Admins shall be able to add/edit/remove promoted destination areas and neighbourhood guides.

#### 2.3.3 Booking & Dispute Management

- **REQ-A-020** Admins shall have full visibility into all bookings: status, financial breakdown, guest/host details, and communication logs.
- **REQ-A-021** Admins shall be able to manually cancel a booking, trigger refunds, and compensate either party with platform credits.
- **REQ-A-022** The system shall have a formal dispute resolution workflow: guest/host files a dispute → admin reviews evidence → admin issues a ruling → platform enforces payout/refund decision.
- **REQ-A-023** Admins shall be able to set SLAs for dispute resolution (e.g., must be resolved within 5 business days).
- **REQ-A-024** Admins shall be able to place a payout on hold pending dispute resolution.
- **REQ-A-025** The system shall allow admins to upload evidence documents and attach internal notes to a dispute case.
- **REQ-A-026** Admins shall be able to search and filter disputes by status, date, involved party, and ruling outcome.

#### 2.3.4 Financial Management

- **REQ-A-030** Admins shall manage platform fee structures: guest service fee (%), host service fee (%), special category fees, and promotional fee waivers.
- **REQ-A-031** Admins shall configure payout rules: payout timing (hours after check-in), minimum payout thresholds, and payout batch processing schedules.
- **REQ-A-032** Admins shall have a real-time financial dashboard: gross transaction volume (GTV), net platform revenue, pending payouts, refunds issued, and tax collected.
- **REQ-A-033** The system shall generate monthly financial reconciliation reports, exportable as CSV/Excel/PDF.
- **REQ-A-034** Admins shall manage VAT/AIT (Advance Income Tax) configuration per NBR (National Board of Revenue) rules. The system shall calculate and withhold applicable tax (e.g., 5% TDS on host earnings above threshold) and generate tax certificates.
- **REQ-A-035** Admins shall manage refund policies and be able to override the default refund calculation for individual bookings.
- **REQ-A-036** The system shall support integration with Bangladesh Bank's reporting requirements for digital payment operators (if applicable).
- **REQ-A-037** Admins shall manage coupon/promo codes: create, assign user segments, set discount type (flat BDT or percentage), set usage limits, and expiry dates.
- **REQ-A-038** Admins shall manage the referral programme: set referral bonus amounts for referrer and referee, set eligibility conditions, and view referral reports.

#### 2.3.5 Payment Gateway Management

- **REQ-A-040** Admins shall configure and manage payment gateway credentials (bKash Merchant API, Nagad API, SSLCOMMERZ, etc.).
- **REQ-A-041** Admins shall monitor payment gateway health: success rate, failure rate, latency, and error logs.
- **REQ-A-042** Admins shall be able to enable/disable specific payment methods platform-wide or per region.
- **REQ-A-043** Admins shall manage chargeback and dispute claims from payment gateway providers.

#### 2.3.6 Review & Content Moderation

- **REQ-A-050** Admins shall have access to all guest and host reviews before and after publication.
- **REQ-A-051** Admins shall be able to remove a review that violates the review policy (hate speech, fake review, irrelevant content) with a reason recorded.
- **REQ-A-052** Admins shall have a flagged-review queue where reported reviews are held for moderation.
- **REQ-A-053** Admins shall manage the platform's content policy and maintain a prohibited content keyword/phrase list.
- **REQ-A-054** Admins shall be able to manage in-app messages flagged by the automated moderation system.

#### 2.3.7 Notifications & Communications

- **REQ-A-060** Admins shall be able to send platform-wide notifications (email blast, push notification) to all users or targeted segments.
- **REQ-A-061** Admins shall manage notification templates (email HTML, SMS text) for all system events in Bangla and English.
- **REQ-A-062** Admins shall manage the SMS gateway provider (e.g., SSL Wireless, Infobip) configuration and monitor delivery rates.
- **REQ-A-063** Admins shall manage the platform's help centre content: FAQs, policy articles, and how-to guides in Bangla and English.

#### 2.3.8 Platform Configuration & Settings

- **REQ-A-070** Admins shall manage Bangladesh-specific region data: divisions, districts, upazilas, and thanas (synced with Bangladesh National ID database structure).
- **REQ-A-071** Admins shall manage platform-wide settings: default currency (BDT), supported languages, check-in/out time defaults, minimum/maximum booking lead time, and platform cancellation penalties.
- **REQ-A-072** Admins shall manage the property amenity catalogue and property type taxonomy.
- **REQ-A-073** Admins shall control feature flags for rolling out new features to specific user segments.
- **REQ-A-074** Admins shall manage App Store and Play Store release configurations (force update triggers, minimum app versions).

#### 2.3.9 Analytics & Reporting

- **REQ-A-080** Admins shall have a high-level analytics dashboard: total registered users, active users (DAU/MAU), total listings, active listings, total bookings, booking completion rate, and cancellation rate.
- **REQ-A-081** Admins shall view geographic heatmaps of listings and bookings across Bangladesh.
- **REQ-A-082** Admins shall generate custom reports by date range, region, property type, user segment, or booking status.
- **REQ-A-083** Admins shall access cohort analysis (new vs. returning guests, host retention rates).
- **REQ-A-084** Admins shall monitor funnel metrics: search → listing view → booking request → confirmed booking.
- **REQ-A-085** Reports shall be exportable in CSV, Excel, and PDF formats.

#### 2.3.10 Compliance & Trust & Safety

- **REQ-A-090** Admins shall manage a watchlist of flagged users and listings for ongoing monitoring.
- **REQ-A-091** The system shall integrate with a fraud detection module that scores transactions and user behaviours, flagging anomalies for admin review.
- **REQ-A-092** Admins shall be able to respond to law enforcement data requests with an appropriate secure evidence export tool.
- **REQ-A-093** The system shall maintain full audit logs of all financial transactions for a minimum of 7 years (Bangladesh tax law).
- **REQ-A-094** Admins shall manage GDPR/PDPA (Bangladesh Personal Data Protection Act when enacted) consent records and handle data subject requests (access, erasure).
- **REQ-A-095** Admins shall enforce the Tourist Policy of Bangladesh (Ministry of Civil Aviation & Tourism rules for short-term rentals where applicable).

---

## 3. Non-Functional Requirements

### 3.1 Performance
- **REQ-NF-001** Search results shall load within 2 seconds for standard queries.
- **REQ-NF-002** Booking confirmation shall be processed and confirmed within 5 seconds of payment completion.
- **REQ-NF-003** The system shall support at least 10,000 concurrent users.
- **REQ-NF-004** API response time shall not exceed 500 ms at the 95th percentile under normal load.

### 3.2 Availability & Reliability
- **REQ-NF-010** The platform shall target 99.9% uptime (≈ 8.7 hours downtime/year).
- **REQ-NF-011** The system shall implement data backups every 6 hours with a recovery point objective (RPO) of 6 hours and recovery time objective (RTO) of 2 hours.

### 3.3 Security
- **REQ-NF-020** All data in transit shall be encrypted using TLS 1.3.
- **REQ-NF-021** Passwords shall be hashed using bcrypt (cost factor ≥ 12) or Argon2.
- **REQ-NF-022** The platform shall implement rate limiting on all API endpoints to prevent brute-force attacks.
- **REQ-NF-023** PCI-DSS compliance shall be maintained for card payment data (handled by gateway tokenisation; no raw card data stored on platform servers).
- **REQ-NF-024** Mobile banking credentials shall never be stored; only transaction reference IDs shall be retained.
- **REQ-NF-025** The system shall log all authentication events (login, failed attempts, password reset) with IP and device fingerprint.

### 3.4 Scalability
- **REQ-NF-030** The architecture shall support horizontal scaling of application servers.
- **REQ-NF-031** Image storage shall use cloud object storage (e.g., AWS S3 or equivalent) with a CDN for delivery.

### 3.5 Usability
- **REQ-NF-040** The platform (web and mobile) shall be accessible in both Bangla and English.
- **REQ-NF-041** The mobile app shall support Android (version 8+) and iOS (version 14+).
- **REQ-NF-042** The web app shall be responsive and usable on screens from 320 px to 4K.
- **REQ-NF-043** The platform shall comply with WCAG 2.1 Level AA accessibility standards.

---

## 4. Bangladesh-Specific Localisation Requirements

- **REQ-BD-001** The calendar shall support Bengali (Bangla) date display (Bangla Sanat / Bengali Calendar) alongside the Gregorian calendar.
- **REQ-BD-002** Price display shall support Bangla numerals as a toggle alongside Arabic numerals.
- **REQ-BD-003** The platform shall observe national holidays for customer support scheduling: Independence Day (26 March), Eid ul-Fitr (variable), Eid ul-Adha (variable), Durga Puja, Victory Day (16 December), etc.
- **REQ-BD-004** Customer support shall operate in both Bangla and English.
- **REQ-BD-005** The platform shall integrate with the Bangladesh National ID (NID) API (if available from Election Commission Bangladesh) for automated identity verification.
- **REQ-BD-006** Hosts in Cox's Bazar shall be able to indicate proximity to Laboni Beach, Himchhari, Inani Beach, or other landmarks for better discoverability.
- **REQ-BD-007** The system shall flag listings that require "tourist police registration" at check-in (Cox's Bazar coastal area regulation).
- **REQ-BD-008** The platform shall support Islamic calendar peak pricing rules (Ramadan, Eid) as a first-class seasonal pricing type.

---

## 5. Compliance & Legal Requirements

- **REQ-C-001** The platform shall comply with the Bangladesh Telecommunication Regulation Act 2001 for data localisation requirements.
- **REQ-C-002** The platform shall comply with the Digital Security Act 2018 (now Cyber Security Act 2023) for content and user data handling.
- **REQ-C-003** Applicable VAT (15%) shall be calculated and collected on the platform service fee as per NBR VAT rules for digital services.
- **REQ-C-004** The platform shall maintain records allowing compliance with the Income Tax Ordinance 1984 (host income reporting, TDS obligations).
- **REQ-C-005** The platform shall comply with Bangladesh Bank's guidelines for Mobile Financial Services (MFS) and internet payment gateways.
- **REQ-C-006** Terms of Service and Privacy Policy shall be available in Bangla and English and require explicit consent at registration.
- **REQ-C-007** The platform shall maintain a Data Processing Agreement (DPA) log for any third-party processors of Bangladeshi user data.

---

## 6. Glossary

| Term | Definition |
|------|------------|
| BDT | Bangladeshi Taka — the official currency |
| BRN | Booking Reference Number — unique identifier for a booking |
| GTV | Gross Transaction Value — total value of all bookings processed |
| MFS | Mobile Financial Services (bKash, Nagad, Rocket) |
| NBR | National Board of Revenue — Bangladesh tax authority |
| NID | National Identity Document — Bangladesh national ID card |
| TDS | Tax Deducted at Source |
| TIN | Tax Identification Number |
| Upazila | Sub-district administrative unit in Bangladesh |
| Thana | Police administrative unit, sub-division of upazila |
| WASA | Water and Sewerage Authority — municipal water supply |
| IPS | Instant Power Supply — battery backup power system common in Bangladesh |
