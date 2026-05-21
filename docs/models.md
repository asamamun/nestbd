# Thikana — Laravel Models Reference

**Backend:** Laravel 11 · **Database:** MariaDB 10.11+  
**Total Models:** 46 · **Total Relationships mapped:** 100+

> **MariaDB Note:** Since you switched from PostgreSQL to MariaDB, the following changes apply to your schema:
> - Replace `UUID` primary keys with `CHAR(36)` or use auto-increment `BIGINT` (simpler for MariaDB)
> - Replace `JSONB` with `JSON` (MariaDB supports JSON natively since 10.2)
> - Replace `TIMESTAMPTZ` with `TIMESTAMP`
> - Remove PostgreSQL-only extensions (`uuid-ossp`, `postgis`, `pg_trgm`)
> - For geo-search, use MariaDB's built-in spatial types (`POINT`, `GEOMETRY`) with `SPATIAL INDEX`
> - Replace `SMALLSERIAL`/`BIGSERIAL` with `SMALLINT AUTO_INCREMENT` / `BIGINT AUTO_INCREMENT`
> - ENUM columns work identically in MariaDB ✓
> - Full-text search: use MariaDB `FULLTEXT INDEX` instead of `GIN/tsvector`

---

## Table of Contents

1. [Geography Models](#1-geography-models)
2. [User Models](#2-user-models)
3. [Admin Models](#3-admin-models)
4. [Listing Models](#4-listing-models)
5. [Availability Model](#5-availability-model)
6. [Booking Models](#6-booking-models)
7. [Payment & Payout Models](#7-payment--payout-models)
8. [Coupon & Credit Models](#8-coupon--credit-models)
9. [Review Models](#9-review-models)
10. [Messaging Models](#10-messaging-models)
11. [Notification Models](#11-notification-models)
12. [Wishlist Models](#12-wishlist-models)
13. [Dispute Models](#13-dispute-models)
14. [Report & Superhost Models](#14-report--superhost-models)
15. [System Models](#15-system-models)
16. [Artisan Commands to Generate All Models](#16-artisan-commands-to-generate-all-models)
17. [Model Relationship Map](#17-model-relationship-map)

---

## 1. Geography Models

These are read-only reference/lookup models. Use `$guarded = []` and no timestamps where noted.

---

### `Division`
**Table:** `divisions`  
**File:** `app/Models/Division.php`

| Property | Value |
|----------|-------|
| Primary Key | `id` (int) |
| Timestamps | `created_at` only |
| Soft Delete | No |

**Relationships:**
- `hasMany(District::class)`
- `hasMany(User::class)`
- `hasMany(Listing::class)`

---

### `District`
**Table:** `districts`  
**File:** `app/Models/District.php`

| Property | Value |
|----------|-------|
| Primary Key | `id` (int) |
| Timestamps | `created_at` only |
| Soft Delete | No |

**Relationships:**
- `belongsTo(Division::class)`
- `hasMany(Upazila::class)`
- `hasMany(Area::class)`
- `hasMany(User::class)`
- `hasMany(Listing::class)`

---

### `Upazila`
**Table:** `upazilas`  
**File:** `app/Models/Upazila.php`

| Property | Value |
|----------|-------|
| Primary Key | `id` (int) |
| Timestamps | `created_at` only |
| Soft Delete | No |

**Relationships:**
- `belongsTo(District::class)`
- `hasMany(Thana::class)`
- `hasMany(Listing::class)`

---

### `Thana`
**Table:** `thanas`  
**File:** `app/Models/Thana.php`

| Property | Value |
|----------|-------|
| Primary Key | `id` (int) |
| Timestamps | `created_at` only |
| Soft Delete | No |

**Relationships:**
- `belongsTo(Upazila::class)`
- `hasMany(Area::class)`
- `hasMany(User::class)`
- `hasMany(Listing::class)`

---

### `Area`
**Table:** `areas`  
**File:** `app/Models/Area.php`

| Property | Value |
|----------|-------|
| Primary Key | `id` (int) |
| Timestamps | `created_at` only |
| Soft Delete | No |

**Relationships:**
- `belongsTo(Thana::class)`
- `belongsTo(District::class)`
- `hasMany(Listing::class)`

---

## 2. User Models

---

### `User`
**Table:** `users`  
**File:** `app/Models/User.php`

| Property | Value |
|----------|-------|
| Primary Key | `id` (CHAR(36) UUID or BIGINT) |
| Timestamps | `created_at`, `updated_at` |
| Soft Delete | Yes — `deleted_at` |
| Hidden | `password_hash`, `mfa_secret` |
| Casts | `email_verified` → bool, `mobile_verified` → bool, `mfa_enabled` → bool, `is_superhost` → bool, `date_of_birth` → date, `last_login_at` → datetime, `deleted_at` → datetime |

**Relationships:**
- `hasOne(AdminUser::class)`
- `hasMany(OAuthAccount::class)`
- `hasMany(IdVerification::class)`
- `hasMany(EmergencyContact::class)`
- `hasMany(Listing::class, 'host_id')`
- `hasMany(Booking::class, 'guest_id')`
- `hasMany(Booking::class, 'host_id')`
- `hasMany(Payment::class, 'payer_id')`
- `hasMany(HostPayoutAccount::class, 'host_id')`
- `hasMany(Payout::class, 'host_id')`
- `hasMany(Review::class, 'reviewer_id')`
- `hasMany(Review::class, 'reviewee_id')`
- `hasMany(Conversation::class, 'guest_id')`
- `hasMany(Conversation::class, 'host_id')`
- `hasMany(Message::class, 'sender_id')`
- `hasMany(Wishlist::class)`
- `hasMany(Notification::class)`
- `hasMany(Dispute::class, 'raised_by_user_id')`
- `hasMany(UserCredit::class)`
- `hasMany(Referral::class, 'referrer_id')`
- `hasMany(Referral::class, 'referee_id')`
- `hasMany(ListingCohost::class, 'cohost_id')`
- `hasMany(SuperhostAssessment::class, 'host_id')`
- `belongsTo(User::class, 'referred_by_user_id')` *(self-referential)*
- `belongsTo(Division::class)`
- `belongsTo(District::class)`
- `belongsTo(Thana::class)`

**Traits to use:** `HasFactory`, `Notifiable`, `SoftDeletes`, `HasApiTokens` (Sanctum)

---

### `OAuthAccount`
**Table:** `user_oauth_accounts`  
**File:** `app/Models/OAuthAccount.php`

| Property | Value |
|----------|-------|
| Primary Key | `id` (int) |
| Timestamps | `created_at` only |
| Soft Delete | No |
| Hidden | `access_token`, `refresh_token` |

**Relationships:**
- `belongsTo(User::class)`

---

### `IdVerification`
**Table:** `user_id_verifications`  
**File:** `app/Models/IdVerification.php`

| Property | Value |
|----------|-------|
| Primary Key | `id` (int) |
| Timestamps | `submitted_at` (custom), `reviewed_at` |
| Soft Delete | No |
| Casts | `submitted_at` → datetime, `reviewed_at` → datetime, `expires_at` → datetime |

**Relationships:**
- `belongsTo(User::class)`
- `belongsTo(User::class, 'reviewer_admin_id')` → alias `reviewer`

---

### `EmergencyContact`
**Table:** `user_emergency_contacts`  
**File:** `app/Models/EmergencyContact.php`

| Property | Value |
|----------|-------|
| Primary Key | `id` (int) |
| Timestamps | `created_at` only |
| Soft Delete | No |

**Relationships:**
- `belongsTo(User::class)`

---

## 3. Admin Models

---

### `AdminRole`
**Table:** `admin_roles`  
**File:** `app/Models/AdminRole.php`

| Property | Value |
|----------|-------|
| Primary Key | `id` (int) |
| Timestamps | `created_at` only |
| Soft Delete | No |

**Relationships:**
- `belongsToMany(AdminPermission::class, 'admin_role_permissions')`
- `hasMany(AdminUser::class, 'admin_role_id')`

---

### `AdminPermission`
**Table:** `admin_permissions`  
**File:** `app/Models/AdminPermission.php`

| Property | Value |
|----------|-------|
| Primary Key | `id` (int) |
| Timestamps | No |
| Soft Delete | No |

**Relationships:**
- `belongsToMany(AdminRole::class, 'admin_role_permissions')`

---

### `AdminUser`
**Table:** `admin_users`  
**File:** `app/Models/AdminUser.php`

| Property | Value |
|----------|-------|
| Primary Key | `user_id` (non-incrementing) |
| Timestamps | `assigned_at` (custom) |
| Soft Delete | No |

**Relationships:**
- `belongsTo(User::class)`
- `belongsTo(AdminRole::class, 'admin_role_id')`
- `belongsTo(User::class, 'assigned_by')` → alias `assignedBy`

---

### `AdminAuditLog`
**Table:** `admin_audit_logs`  
**File:** `app/Models/AdminAuditLog.php`

| Property | Value |
|----------|-------|
| Primary Key | `id` (bigint) |
| Timestamps | `created_at` only |
| Soft Delete | No |
| Casts | `old_values` → array, `new_values` → array |

**Relationships:**
- `belongsTo(User::class, 'admin_id')` → alias `admin`

> This model should be **read-only** — never update or delete audit logs.

---

## 4. Listing Models

---

### `Listing`
**Table:** `listings`  
**File:** `app/Models/Listing.php`

| Property | Value |
|----------|-------|
| Primary Key | `id` (CHAR(36) UUID) |
| Timestamps | `created_at`, `updated_at` |
| Soft Delete | Yes — `deleted_at` |
| Casts | `instant_book_enabled` → bool, `is_featured` → bool, `exact_address_visible` → bool, `tourist_police_reg_required` → bool, `eid_pricing_enabled` → bool, `price_per_night` → decimal:2, `avg_rating` → decimal:2, `published_at` → datetime |

**Relationships:**
- `belongsTo(User::class, 'host_id')` → alias `host`
- `belongsTo(Division::class)`
- `belongsTo(District::class)`
- `belongsTo(Upazila::class)`
- `belongsTo(Thana::class)`
- `belongsTo(Area::class)`
- `hasMany(ListingBed::class)`
- `hasMany(ListingPhoto::class)`
- `hasMany(ListingHouseRule::class)`
- `hasMany(ListingPriceOverride::class)`
- `hasMany(ListingIcalSync::class)`
- `hasMany(ListingCohost::class)`
- `hasMany(ListingAvailability::class)`
- `hasMany(Booking::class)`
- `hasMany(Review::class)`
- `hasMany(ListingReport::class)`
- `belongsToMany(Amenity::class, 'listing_amenities')->withPivot('notes')`
- `belongsToMany(Wishlist::class, 'wishlist_listings')`

**Scopes to define:**
- `scopeActive($query)` — `where('status', 'active')`
- `scopeInDistrict($query, $districtId)`
- `scopeInstantBook($query)`
- `scopeWithinRadius($query, $lat, $lng, $km)` — uses MariaDB `ST_Distance_Sphere`

---

### `ListingBed`
**Table:** `listing_beds`  
**File:** `app/Models/ListingBed.php`

| Property | Value |
|----------|-------|
| Primary Key | `id` (int) |
| Timestamps | No |
| Soft Delete | No |

**Relationships:**
- `belongsTo(Listing::class)`

---

### `Amenity`
**Table:** `amenities`  
**File:** `app/Models/Amenity.php`

| Property | Value |
|----------|-------|
| Primary Key | `id` (int) |
| Timestamps | No |
| Soft Delete | No |
| Casts | `is_highlight` → bool |

**Relationships:**
- `belongsToMany(Listing::class, 'listing_amenities')->withPivot('notes')`

---

### `ListingPhoto`
**Table:** `listing_photos`  
**File:** `app/Models/ListingPhoto.php`

| Property | Value |
|----------|-------|
| Primary Key | `id` (int) |
| Timestamps | `uploaded_at` (custom) |
| Soft Delete | No |
| Casts | `is_cover` → bool |

**Relationships:**
- `belongsTo(Listing::class)`

---

### `ListingHouseRule`
**Table:** `listing_house_rules`  
**File:** `app/Models/ListingHouseRule.php`

| Property | Value |
|----------|-------|
| Primary Key | `id` (int) |
| Timestamps | No |
| Soft Delete | No |

**Relationships:**
- `belongsTo(Listing::class)`

---

### `ListingPriceOverride`
**Table:** `listing_price_overrides`  
**File:** `app/Models/ListingPriceOverride.php`

| Property | Value |
|----------|-------|
| Primary Key | `id` (int) |
| Timestamps | `created_at` only |
| Soft Delete | No |
| Casts | `start_date` → date, `end_date` → date, `price_per_night` → decimal:2 |

**Relationships:**
- `belongsTo(Listing::class)`

---

### `ListingIcalSync`
**Table:** `listing_ical_syncs`  
**File:** `app/Models/ListingIcalSync.php`

| Property | Value |
|----------|-------|
| Primary Key | `id` (int) |
| Timestamps | `last_synced_at` (custom) |
| Soft Delete | No |

**Relationships:**
- `belongsTo(Listing::class)`

---

### `ListingCohost`
**Table:** `listing_cohosts`  
**File:** `app/Models/ListingCohost.php`

| Property | Value |
|----------|-------|
| Primary Key | `id` (int) |
| Timestamps | `invited_at`, `accepted_at` (custom) |
| Soft Delete | No |
| Casts | `is_active` → bool |

**Relationships:**
- `belongsTo(Listing::class)`
- `belongsTo(User::class, 'host_id')` → alias `host`
- `belongsTo(User::class, 'cohost_id')` → alias `cohost`

---

## 5. Availability Model

---

### `ListingAvailability`
**Table:** `listing_availability`  
**File:** `app/Models/ListingAvailability.php`

| Property | Value |
|----------|-------|
| Primary Key | `id` (bigint) |
| Timestamps | No |
| Soft Delete | No |
| Casts | `date` → date, `price_override` → decimal:2 |

**Relationships:**
- `belongsTo(Listing::class)`

**Scopes to define:**
- `scopeAvailable($query)` — `where('availability', 'available')`
- `scopeForDateRange($query, $startDate, $endDate)`
- `scopeBlocked($query)`

---

## 6. Booking Models

---

### `Booking`
**Table:** `bookings`  
**File:** `app/Models/Booking.php`

| Property | Value |
|----------|-------|
| Primary Key | `id` (CHAR(36) UUID) |
| Timestamps | `created_at`, `updated_at` |
| Soft Delete | No |
| Casts | `check_in_date` → date, `checkout_date` → date, `additional_guest_names` → array, `is_instant_book` → bool, `total_guest_pays` → decimal:2, `host_payout_amount` → decimal:2, `cancelled_at` → datetime, `actual_check_in` → datetime, `actual_checkout` → datetime |

**Relationships:**
- `belongsTo(Listing::class)`
- `belongsTo(User::class, 'guest_id')` → alias `guest`
- `belongsTo(User::class, 'host_id')` → alias `host`
- `hasMany(Payment::class)`
- `hasMany(Refund::class)`
- `hasOne(Review::class)` *(guest review of listing)*
- `hasMany(Review::class)`
- `hasOne(Dispute::class)`
- `hasMany(BookingModification::class)`
- `hasOne(Conversation::class)`
- `hasOne(Payout::class)`

**Scopes to define:**
- `scopeUpcoming($query)`
- `scopeActive($query)` — confirmed + checked_in
- `scopeForGuest($query, $userId)`
- `scopeForHost($query, $userId)`
- `scopePendingApproval($query)`

---

### `BookingModification`
**Table:** `booking_modifications`  
**File:** `app/Models/BookingModification.php`

| Property | Value |
|----------|-------|
| Primary Key | `id` (int) |
| Timestamps | `created_at`, `responded_at` (custom) |
| Soft Delete | No |
| Casts | `original_check_in` → date, `original_checkout` → date, `new_check_in` → date, `new_checkout` → date, `price_difference` → decimal:2 |

**Relationships:**
- `belongsTo(Booking::class)`
- `belongsTo(User::class, 'requested_by')` → alias `requestedBy`

---

## 7. Payment & Payout Models

---

### `Payment`
**Table:** `payments`  
**File:** `app/Models/Payment.php`

| Property | Value |
|----------|-------|
| Primary Key | `id` (CHAR(36) UUID) |
| Timestamps | `initiated_at` (custom), `completed_at` |
| Soft Delete | No |
| Hidden | `gateway_response` |
| Casts | `amount` → decimal:2, `gateway_response` → array, `initiated_at` → datetime, `completed_at` → datetime |

**Relationships:**
- `belongsTo(Booking::class)`
- `belongsTo(User::class, 'payer_id')` → alias `payer`
- `belongsTo(Coupon::class)`
- `hasMany(Refund::class)`

---

### `Refund`
**Table:** `refunds`  
**File:** `app/Models/Refund.php`

| Property | Value |
|----------|-------|
| Primary Key | `id` (CHAR(36) UUID) |
| Timestamps | `created_at`, `processed_at` (custom) |
| Soft Delete | No |
| Casts | `amount` → decimal:2, `processed_at` → datetime |

**Relationships:**
- `belongsTo(Payment::class)`
- `belongsTo(Booking::class)`
- `belongsTo(User::class, 'initiated_by')` → alias `initiatedBy`

---

### `HostPayoutAccount`
**Table:** `host_payout_accounts`  
**File:** `app/Models/HostPayoutAccount.php`

| Property | Value |
|----------|-------|
| Primary Key | `id` (int) |
| Timestamps | `created_at` only |
| Soft Delete | No |
| Hidden | `account_number`, `routing_number` |
| Casts | `is_primary` → bool, `is_verified` → bool |

**Relationships:**
- `belongsTo(User::class, 'host_id')` → alias `host`
- `hasMany(Payout::class)`

---

### `Payout`
**Table:** `payouts`  
**File:** `app/Models/Payout.php`

| Property | Value |
|----------|-------|
| Primary Key | `id` (CHAR(36) UUID) |
| Timestamps | `created_at`, `processed_at`, `scheduled_at` (custom) |
| Soft Delete | No |
| Hidden | `gateway_response` |
| Casts | `gross_amount` → decimal:2, `net_amount` → decimal:2, `platform_fee` → decimal:2, `tds_withheld` → decimal:2, `gateway_response` → array |

**Relationships:**
- `belongsTo(User::class, 'host_id')` → alias `host`
- `belongsTo(Booking::class)`
- `belongsTo(HostPayoutAccount::class, 'payout_account_id')` → alias `payoutAccount`

---

### `TaxCertificate`
**Table:** `tax_certificates`  
**File:** `app/Models/TaxCertificate.php`

| Property | Value |
|----------|-------|
| Primary Key | `id` (int) |
| Timestamps | `generated_at` (custom) |
| Soft Delete | No |
| Casts | `total_earnings` → decimal:2, `total_tds_deducted` → decimal:2 |

**Relationships:**
- `belongsTo(User::class, 'host_id')` → alias `host`

---

### `PlatformFeeConfig`
**Table:** `platform_fee_configs`  
**File:** `app/Models/PlatformFeeConfig.php`

| Property | Value |
|----------|-------|
| Primary Key | `id` (int) |
| Timestamps | `created_at` only |
| Soft Delete | No |
| Casts | `is_active` → bool, `applicable_from` → date, `applicable_to` → date |

**Relationships:**
- `belongsTo(User::class, 'created_by')` → alias `createdBy`

---

## 8. Coupon & Credit Models

---

### `Coupon`
**Table:** `coupons`  
**File:** `app/Models/Coupon.php`

| Property | Value |
|----------|-------|
| Primary Key | `id` (int) |
| Timestamps | `created_at`, `valid_from`, `valid_to` (custom) |
| Soft Delete | No |
| Casts | `is_active` → bool, `discount_value` → decimal:2, `max_discount_bdt` → decimal:2, `valid_from` → datetime, `valid_to` → datetime |

**Relationships:**
- `belongsTo(User::class, 'created_by')` → alias `createdBy`
- `hasMany(CouponUsage::class)`
- `hasMany(Payment::class)`

**Scopes to define:**
- `scopeActive($query)` — valid, not expired, usage limit not reached
- `scopeValidForAmount($query, $amount)`

---

### `CouponUsage`
**Table:** `coupon_usages`  
**File:** `app/Models/CouponUsage.php`

| Property | Value |
|----------|-------|
| Primary Key | `id` (int) |
| Timestamps | `used_at` (custom) |
| Soft Delete | No |
| Casts | `discount_applied` → decimal:2 |

**Relationships:**
- `belongsTo(Coupon::class)`
- `belongsTo(User::class)`
- `belongsTo(Booking::class)`

---

### `Referral`
**Table:** `referrals`  
**File:** `app/Models/Referral.php`

| Property | Value |
|----------|-------|
| Primary Key | `id` (int) |
| Timestamps | `created_at`, `credited_at` (custom) |
| Soft Delete | No |
| Casts | `referrer_bonus_bdt` → decimal:2, `referee_bonus_bdt` → decimal:2 |

**Relationships:**
- `belongsTo(User::class, 'referrer_id')` → alias `referrer`
- `belongsTo(User::class, 'referee_id')` → alias `referee`
- `belongsTo(Booking::class, 'qualifying_booking_id')` → alias `qualifyingBooking`

---

### `UserCredit`
**Table:** `user_credits`  
**File:** `app/Models/UserCredit.php`

| Property | Value |
|----------|-------|
| Primary Key | `id` (bigint) |
| Timestamps | `created_at` only |
| Soft Delete | No |
| Casts | `amount` → decimal:2, `balance_after` → decimal:2, `expires_at` → datetime |

**Relationships:**
- `belongsTo(User::class)`
- `belongsTo(User::class, 'created_by')` → alias `createdBy`

---

## 9. Review Models

---

### `Review`
**Table:** `reviews`  
**File:** `app/Models/Review.php`

| Property | Value |
|----------|-------|
| Primary Key | `id` (CHAR(36) UUID) |
| Timestamps | `created_at`, `submitted_at`, `published_at`, `response_at` (custom) |
| Soft Delete | No |
| Casts | `overall_rating` → decimal:2, `cleanliness_rating` → decimal:2, `is_published` → bool, `is_flagged` → bool, `is_removed` → bool, `submitted_at` → datetime, `published_at` → datetime |

**Relationships:**
- `belongsTo(Booking::class)`
- `belongsTo(User::class, 'reviewer_id')` → alias `reviewer`
- `belongsTo(User::class, 'reviewee_id')` → alias `reviewee`
- `belongsTo(Listing::class)`
- `belongsTo(User::class, 'moderated_by')` → alias `moderator`
- `hasMany(ReviewFlag::class)`

**Scopes to define:**
- `scopePublished($query)`
- `scopeForListing($query, $listingId)`
- `scopeGuestToListing($query)`
- `scopeHostToGuest($query)`

---

### `ReviewFlag`
**Table:** `review_flags`  
**File:** `app/Models/ReviewFlag.php`

| Property | Value |
|----------|-------|
| Primary Key | `id` (int) |
| Timestamps | `created_at` only |
| Soft Delete | No |

**Relationships:**
- `belongsTo(Review::class)`
- `belongsTo(User::class, 'flagged_by')` → alias `flaggedBy`

---

## 10. Messaging Models

---

### `Conversation`
**Table:** `conversations`  
**File:** `app/Models/Conversation.php`

| Property | Value |
|----------|-------|
| Primary Key | `id` (CHAR(36) UUID) |
| Timestamps | `created_at`, `last_message_at` (custom) |
| Soft Delete | No |
| Casts | `is_archived` → bool, `last_message_at` → datetime |

**Relationships:**
- `belongsTo(Booking::class)`
- `belongsTo(Listing::class)`
- `belongsTo(User::class, 'host_id')` → alias `host`
- `belongsTo(User::class, 'guest_id')` → alias `guest`
- `hasMany(Message::class)`
- `hasOne(Message::class, 'conversation_id', 'id')` → `latestMessage` (ordered by `created_at` desc)

---

### `Message`
**Table:** `messages`  
**File:** `app/Models/Message.php`

| Property | Value |
|----------|-------|
| Primary Key | `id` (bigint) |
| Timestamps | `created_at`, `read_at` (custom) |
| Soft Delete | No |
| Casts | `is_system_message` → bool, `is_read` → bool, `is_flagged` → bool, `read_at` → datetime |

**Relationships:**
- `belongsTo(Conversation::class)`
- `belongsTo(User::class, 'sender_id')` → alias `sender`

---

## 11. Notification Models

---

### `NotificationTemplate`
**Table:** `notification_templates`  
**File:** `app/Models/NotificationTemplate.php`

| Property | Value |
|----------|-------|
| Primary Key | `id` (int) |
| Timestamps | `updated_at` only |
| Soft Delete | No |
| Casts | `is_active` → bool |

**Relationships:**
- `hasMany(Notification::class, 'template_id')`

---

### `Notification`
**Table:** `notifications`  
**File:** `app/Models/Notification.php`

> Note: Laravel has a built-in `notifications` table via `Notifiable` trait. Consider naming this `platform_notifications` to avoid conflict, or use a custom model that maps to the `notifications` table.

**Table:** `notifications` (or `platform_notifications`)  
**File:** `app/Models/PlatformNotification.php`

| Property | Value |
|----------|-------|
| Primary Key | `id` (bigint) |
| Timestamps | `created_at`, `sent_at`, `delivered_at`, `read_at` (custom) |
| Soft Delete | No |
| Casts | `sent_at` → datetime, `read_at` → datetime |

**Relationships:**
- `belongsTo(User::class)`
- `belongsTo(NotificationTemplate::class, 'template_id')` → alias `template`

---

## 12. Wishlist Models

---

### `Wishlist`
**Table:** `wishlists`  
**File:** `app/Models/Wishlist.php`

| Property | Value |
|----------|-------|
| Primary Key | `id` (int) |
| Timestamps | `created_at` only |
| Soft Delete | No |
| Casts | `is_public` → bool |

**Relationships:**
- `belongsTo(User::class)`
- `belongsToMany(Listing::class, 'wishlist_listings')->withPivot('added_at')->withTimestamps()`

---

## 13. Dispute Models

---

### `Dispute`
**Table:** `disputes`  
**File:** `app/Models/Dispute.php`

| Property | Value |
|----------|-------|
| Primary Key | `id` (int) |
| Timestamps | `created_at`, `updated_at` |
| Soft Delete | No |
| Casts | `guest_refund_amount` → decimal:2, `host_deduction_amount` → decimal:2, `sla_deadline` → datetime, `resolved_at` → datetime |

**Relationships:**
- `belongsTo(Booking::class)`
- `belongsTo(User::class, 'raised_by_user_id')` → alias `raisedBy`
- `belongsTo(User::class, 'assigned_admin_id')` → alias `assignedAdmin`
- `hasMany(DisputeEvidence::class)`
- `hasMany(DisputeMessage::class)`

---

### `DisputeEvidence`
**Table:** `dispute_evidence`  
**File:** `app/Models/DisputeEvidence.php`

| Property | Value |
|----------|-------|
| Primary Key | `id` (int) |
| Timestamps | `submitted_at` (custom) |
| Soft Delete | No |

**Relationships:**
- `belongsTo(Dispute::class)`
- `belongsTo(User::class, 'submitted_by')` → alias `submittedBy`

---

### `DisputeMessage`
**Table:** `dispute_messages`  
**File:** `app/Models/DisputeMessage.php`

| Property | Value |
|----------|-------|
| Primary Key | `id` (int) |
| Timestamps | `created_at` only |
| Soft Delete | No |
| Casts | `is_internal` → bool |

**Relationships:**
- `belongsTo(Dispute::class)`
- `belongsTo(User::class, 'sender_id')` → alias `sender`

---

## 14. Report & Superhost Models

---

### `ListingReport`
**Table:** `listing_reports`  
**File:** `app/Models/ListingReport.php`

| Property | Value |
|----------|-------|
| Primary Key | `id` (int) |
| Timestamps | `created_at`, `reviewed_at` (custom) |
| Soft Delete | No |

**Relationships:**
- `belongsTo(Listing::class)`
- `belongsTo(User::class, 'reporter_id')` → alias `reporter`
- `belongsTo(User::class, 'reviewed_by')` → alias `reviewer`

---

### `SuperhostAssessment`
**Table:** `superhost_assessments`  
**File:** `app/Models/SuperhostAssessment.php`

| Property | Value |
|----------|-------|
| Primary Key | `id` (int) |
| Timestamps | `assessed_at` (custom) |
| Soft Delete | No |
| Casts | `passed_response_rate` → bool, `passed_acceptance_rate` → bool, `passed_stays_or_nights` → bool, `passed_rating` → bool, `is_superhost_awarded` → bool |

**Relationships:**
- `belongsTo(User::class, 'host_id')` → alias `host`

---

## 15. System Models

---

### `AnalyticsEvent`
**Table:** `analytics_events`  
**File:** `app/Models/AnalyticsEvent.php`

| Property | Value |
|----------|-------|
| Primary Key | `id` (bigint) |
| Timestamps | `created_at` only |
| Soft Delete | No |
| Casts | `properties` → array |

**Relationships:**
- `belongsTo(User::class)`
- `belongsTo(Listing::class)`
- `belongsTo(Booking::class)`

> This model should be **write-only** in normal usage — no updates. Consider using a separate log/analytics table without a full Eloquent model in high-traffic scenarios.

---

### `SystemAuditLog`
**Table:** `system_audit_logs`  
**File:** `app/Models/SystemAuditLog.php`

| Property | Value |
|----------|-------|
| Primary Key | `id` (bigint) |
| Timestamps | `changed_at` (custom) |
| Soft Delete | No |
| Casts | `old_data` → array, `new_data` → array |

> Read-only model. Populated automatically by DB triggers or Laravel model observers.

---

### `FeatureFlag`
**Table:** `feature_flags`  
**File:** `app/Models/FeatureFlag.php`

| Property | Value |
|----------|-------|
| Primary Key | `id` (int) |
| Timestamps | `updated_at` only |
| Soft Delete | No |
| Casts | `is_enabled` → bool, `user_segment` → array |

**Relationships:**
- `belongsTo(User::class, 'updated_by')` → alias `updatedBy`

---

### `SystemConfig`
**Table:** `system_configs`  
**File:** `app/Models/SystemConfig.php`

| Property | Value |
|----------|-------|
| Primary Key | `key` (string, non-incrementing) |
| Timestamps | `updated_at` only |
| Soft Delete | No |

**Relationships:**
- `belongsTo(User::class, 'updated_by')` → alias `updatedBy`

```php
// Usage helper
class SystemConfig extends Model {
    protected $primaryKey = 'key';
    public $incrementing = false;
    protected $keyType = 'string';

    public static function get(string $key, mixed $default = null): mixed {
        return cache()->remember("config:{$key}", 3600, fn() =>
            static::find($key)?->value ?? $default
        );
    }
}
```

---

## 16. Artisan Commands to Generate All Models

Run these in order from your project root. The `-m` flag generates a migration alongside each model.

```bash
# ── Geography ──────────────────────────────────────────────
php artisan make:model Division -m
php artisan make:model District -m
php artisan make:model Upazila -m
php artisan make:model Thana -m
php artisan make:model Area -m

# ── Users ──────────────────────────────────────────────────
php artisan make:model User -m           # already exists, modify it
php artisan make:model OAuthAccount -m
php artisan make:model IdVerification -m
php artisan make:model EmergencyContact -m

# ── Admin ──────────────────────────────────────────────────
php artisan make:model AdminRole -m
php artisan make:model AdminPermission -m
php artisan make:model AdminUser -m
php artisan make:model AdminAuditLog -m

# ── Listings ───────────────────────────────────────────────
php artisan make:model Listing -m
php artisan make:model ListingBed -m
php artisan make:model Amenity -m
php artisan make:model ListingPhoto -m
php artisan make:model ListingHouseRule -m
php artisan make:model ListingPriceOverride -m
php artisan make:model ListingIcalSync -m
php artisan make:model ListingCohost -m

# ── Availability ───────────────────────────────────────────
php artisan make:model ListingAvailability -m

# ── Bookings ───────────────────────────────────────────────
php artisan make:model Booking -m
php artisan make:model BookingModification -m

# ── Payments & Payouts ─────────────────────────────────────
php artisan make:model Payment -m
php artisan make:model Refund -m
php artisan make:model HostPayoutAccount -m
php artisan make:model Payout -m
php artisan make:model TaxCertificate -m
php artisan make:model PlatformFeeConfig -m

# ── Coupons & Credits ──────────────────────────────────────
php artisan make:model Coupon -m
php artisan make:model CouponUsage -m
php artisan make:model Referral -m
php artisan make:model UserCredit -m

# ── Reviews ────────────────────────────────────────────────
php artisan make:model Review -m
php artisan make:model ReviewFlag -m

# ── Messaging ──────────────────────────────────────────────
php artisan make:model Conversation -m
php artisan make:model Message -m

# ── Notifications ──────────────────────────────────────────
php artisan make:model NotificationTemplate -m
php artisan make:model PlatformNotification -m

# ── Wishlists ──────────────────────────────────────────────
php artisan make:model Wishlist -m

# ── Disputes ───────────────────────────────────────────────
php artisan make:model Dispute -m
php artisan make:model DisputeEvidence -m
php artisan make:model DisputeMessage -m

# ── Reports & Superhost ────────────────────────────────────
php artisan make:model ListingReport -m
php artisan make:model SuperhostAssessment -m

# ── System ─────────────────────────────────────────────────
php artisan make:model AnalyticsEvent -m
php artisan make:model SystemAuditLog -m
php artisan make:model FeatureFlag -m
php artisan make:model SystemConfig -m
```

---

## 17. Model Relationship Map

```
Division ──────────────┬── hasMany ──► District
                       └── hasMany ──► User (address)

District ──────────────┬── hasMany ──► Upazila
                       ├── hasMany ──► Area
                       ├── hasMany ──► Listing
                       └── hasMany ──► User

Upazila ───────────────┬── hasMany ──► Thana
                       └── hasMany ──► Listing

Thana ─────────────────┬── hasMany ──► Area
                       ├── hasMany ──► Listing
                       └── hasMany ──► User

User ──────────────────┬── hasOne  ──► AdminUser
                       ├── hasMany ──► OAuthAccount
                       ├── hasMany ──► IdVerification
                       ├── hasMany ──► EmergencyContact
                       ├── hasMany ──► Listing (as host)
                       ├── hasMany ──► Booking (as guest)
                       ├── hasMany ──► Booking (as host)
                       ├── hasMany ──► Payment
                       ├── hasMany ──► HostPayoutAccount
                       ├── hasMany ──► Payout
                       ├── hasMany ──► Review (reviewer)
                       ├── hasMany ──► Review (reviewee)
                       ├── hasMany ──► Conversation (guest)
                       ├── hasMany ──► Conversation (host)
                       ├── hasMany ──► Wishlist
                       ├── hasMany ──► Notification
                       ├── hasMany ──► Dispute
                       ├── hasMany ──► UserCredit
                       └── hasMany ──► Referral

Listing ───────────────┬── belongsTo ──► User (host)
                       ├── hasMany  ──► ListingBed
                       ├── hasMany  ──► ListingPhoto
                       ├── hasMany  ──► ListingHouseRule
                       ├── hasMany  ──► ListingPriceOverride
                       ├── hasMany  ──► ListingIcalSync
                       ├── hasMany  ──► ListingCohost
                       ├── hasMany  ──► ListingAvailability
                       ├── hasMany  ──► Booking
                       ├── hasMany  ──► Review
                       ├── hasMany  ──► ListingReport
                       ├── belongsToMany ──► Amenity (via listing_amenities)
                       └── belongsToMany ──► Wishlist (via wishlist_listings)

Booking ───────────────┬── belongsTo ──► Listing
                       ├── belongsTo ──► User (guest)
                       ├── belongsTo ──► User (host)
                       ├── hasMany  ──► Payment
                       ├── hasMany  ──► Refund
                       ├── hasMany  ──► Review
                       ├── hasOne   ──► Dispute
                       ├── hasMany  ──► BookingModification
                       ├── hasOne   ──► Conversation
                       └── hasOne   ──► Payout

Payment ───────────────┬── belongsTo ──► Booking
                       ├── belongsTo ──► User (payer)
                       ├── belongsTo ──► Coupon
                       └── hasMany  ──► Refund

Coupon ────────────────┬── hasMany ──► CouponUsage
                       └── hasMany ──► Payment

Dispute ───────────────┬── belongsTo ──► Booking
                       ├── hasMany  ──► DisputeEvidence
                       └── hasMany  ──► DisputeMessage

Conversation ──────────┬── belongsTo ──► Booking
                       ├── belongsTo ──► Listing
                       └── hasMany  ──► Message

Review ────────────────┬── belongsTo ──► Booking
                       ├── belongsTo ──► Listing
                       ├── belongsTo ──► User (reviewer)
                       ├── belongsTo ──► User (reviewee)
                       └── hasMany  ──► ReviewFlag

Wishlist ──────────────┬── belongsTo ──► User
                       └── belongsToMany ──► Listing (via wishlist_listings)
```

---

## Quick Count

| Category | Model Count |
|----------|------------|
| Geography | 5 |
| Users & Auth | 4 |
| Admin | 4 |
| Listings | 8 |
| Availability | 1 |
| Bookings | 2 |
| Payments & Payouts | 6 |
| Coupons & Credits | 4 |
| Reviews | 2 |
| Messaging | 2 |
| Notifications | 2 |
| Wishlists | 1 |
| Disputes | 3 |
| Reports & Superhost | 2 |
| System | 4 |
| **Total** | **50** |

> Four extra models (`OAuthAccount`, `IdVerification`, `EmergencyContact`, `TaxCertificate`) are additions beyond the 46 tables because they deserve their own model classes with business logic methods even where the table was embedded conceptually.
