-- =============================================================================
-- Airbnb Bangladesh — Complete Database Schema
-- Database: PostgreSQL 15+
-- Encoding: UTF-8 (required for Bangla Unicode support)
-- Currency: All monetary values stored as NUMERIC(12,2) in BDT (Bangladeshi Taka)
-- =============================================================================

-- Enable useful extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "postgis";          -- Geo-spatial queries
CREATE EXTENSION IF NOT EXISTS "pg_trgm";          -- Fuzzy text search (listings)
CREATE EXTENSION IF NOT EXISTS "btree_gin";        -- Multi-column GIN indexes

-- =============================================================================
-- SECTION 1: GEOGRAPHY — Bangladesh Administrative Divisions
-- =============================================================================

CREATE TABLE divisions (
    id              SMALLSERIAL PRIMARY KEY,
    name_en         VARCHAR(100) NOT NULL,
    name_bn         VARCHAR(100) NOT NULL,
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE districts (
    id              SMALLSERIAL PRIMARY KEY,
    division_id     SMALLINT NOT NULL REFERENCES divisions(id),
    name_en         VARCHAR(100) NOT NULL,
    name_bn         VARCHAR(100) NOT NULL,
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE upazilas (
    id              SMALLSERIAL PRIMARY KEY,
    district_id     SMALLINT NOT NULL REFERENCES districts(id),
    name_en         VARCHAR(150) NOT NULL,
    name_bn         VARCHAR(150) NOT NULL,
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE thanas (
    id              SMALLSERIAL PRIMARY KEY,
    upazila_id      SMALLINT NOT NULL REFERENCES upazilas(id),
    name_en         VARCHAR(150) NOT NULL,
    name_bn         VARCHAR(150) NOT NULL,
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE areas (
    id              SERIAL PRIMARY KEY,
    thana_id        SMALLINT REFERENCES thanas(id),
    district_id     SMALLINT REFERENCES districts(id),  -- for city-level areas
    name_en         VARCHAR(200) NOT NULL,
    name_bn         VARCHAR(200),
    area_type       VARCHAR(50),   -- 'neighbourhood', 'beach_zone', 'tourist_area', 'city_ward'
    is_tourist_area BOOLEAN DEFAULT FALSE,
    latitude        DECIMAL(10,8),
    longitude       DECIMAL(11,8),
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================================================
-- SECTION 2: USERS
-- =============================================================================

CREATE TYPE user_role AS ENUM ('guest', 'host', 'both', 'admin');
CREATE TYPE user_status AS ENUM ('pending_verification', 'active', 'suspended', 'banned', 'deactivated', 'deleted');
CREATE TYPE id_doc_type AS ENUM ('nid', 'passport', 'driving_licence', 'birth_certificate');
CREATE TYPE verification_status AS ENUM ('not_submitted', 'pending', 'approved', 'rejected', 'expired');
CREATE TYPE preferred_language AS ENUM ('bn', 'en');

CREATE TABLE users (
    id                      UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    role                    user_role NOT NULL DEFAULT 'guest',
    status                  user_status NOT NULL DEFAULT 'pending_verification',

    -- Basic identity
    first_name              VARCHAR(100) NOT NULL,
    last_name               VARCHAR(100),
    display_name            VARCHAR(200),
    email                   VARCHAR(255) UNIQUE,
    mobile_number           VARCHAR(20) UNIQUE NOT NULL,   -- e.g. +8801XXXXXXXXX
    date_of_birth           DATE,
    gender                  VARCHAR(20),                   -- 'male','female','other','prefer_not_to_say'
    profile_photo_url       TEXT,
    bio                     TEXT,
    preferred_language      preferred_language DEFAULT 'bn',

    -- Verification flags
    email_verified          BOOLEAN DEFAULT FALSE,
    mobile_verified         BOOLEAN DEFAULT FALSE,
    id_verified             verification_status DEFAULT 'not_submitted',

    -- Address (optional personal address, not property)
    address_line1           TEXT,
    address_line2           TEXT,
    thana_id                SMALLINT REFERENCES thanas(id),
    district_id             SMALLINT REFERENCES districts(id),
    division_id             SMALLINT REFERENCES divisions(id),
    postal_code             VARCHAR(10),

    -- Auth
    password_hash           TEXT,                          -- NULL if OAuth only
    last_login_at           TIMESTAMPTZ,
    mfa_enabled             BOOLEAN DEFAULT FALSE,
    mfa_secret              TEXT,                          -- TOTP secret (encrypted at app level)

    -- Platform metadata
    referral_code           VARCHAR(20) UNIQUE,
    referred_by_user_id     UUID REFERENCES users(id),
    profile_completeness    SMALLINT DEFAULT 0,            -- 0–100 %
    is_superhost            BOOLEAN DEFAULT FALSE,
    superhost_since         DATE,
    account_notes           TEXT,                          -- internal admin notes

    created_at              TIMESTAMPTZ DEFAULT NOW(),
    updated_at              TIMESTAMPTZ DEFAULT NOW(),
    deleted_at              TIMESTAMPTZ                    -- soft delete
);

CREATE TABLE user_oauth_accounts (
    id              SERIAL PRIMARY KEY,
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    provider        VARCHAR(30) NOT NULL,                  -- 'google', 'facebook'
    provider_uid    VARCHAR(255) NOT NULL,
    access_token    TEXT,
    refresh_token   TEXT,
    token_expires   TIMESTAMPTZ,
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE (provider, provider_uid)
);

CREATE TABLE user_id_verifications (
    id                  SERIAL PRIMARY KEY,
    user_id             UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    doc_type            id_doc_type NOT NULL,
    doc_number          VARCHAR(100) NOT NULL,
    doc_front_url       TEXT NOT NULL,
    doc_back_url        TEXT,
    selfie_url          TEXT,
    status              verification_status DEFAULT 'pending',
    reviewer_admin_id   UUID REFERENCES users(id),
    reviewer_notes      TEXT,
    submitted_at        TIMESTAMPTZ DEFAULT NOW(),
    reviewed_at         TIMESTAMPTZ,
    expires_at          TIMESTAMPTZ
);

-- Emergency contact stored for guest safety (REQ-G-080)
CREATE TABLE user_emergency_contacts (
    id              SERIAL PRIMARY KEY,
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name            VARCHAR(200) NOT NULL,
    relationship    VARCHAR(100),
    mobile_number   VARCHAR(20) NOT NULL,
    email           VARCHAR(255),
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================================================
-- SECTION 3: ADMIN ROLES & PERMISSIONS
-- =============================================================================

CREATE TABLE admin_roles (
    id          SMALLSERIAL PRIMARY KEY,
    name        VARCHAR(100) UNIQUE NOT NULL,   -- 'super_admin', 'finance_manager', etc.
    description TEXT,
    created_at  TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE admin_permissions (
    id          SMALLSERIAL PRIMARY KEY,
    code        VARCHAR(100) UNIQUE NOT NULL,   -- 'manage_users', 'view_finances', etc.
    description TEXT
);

CREATE TABLE admin_role_permissions (
    role_id         SMALLINT NOT NULL REFERENCES admin_roles(id),
    permission_id   SMALLINT NOT NULL REFERENCES admin_permissions(id),
    PRIMARY KEY (role_id, permission_id)
);

CREATE TABLE admin_users (
    user_id         UUID PRIMARY KEY REFERENCES users(id),
    admin_role_id   SMALLINT NOT NULL REFERENCES admin_roles(id),
    assigned_by     UUID REFERENCES users(id),
    assigned_at     TIMESTAMPTZ DEFAULT NOW(),
    is_active       BOOLEAN DEFAULT TRUE
);

CREATE TABLE admin_audit_logs (
    id              BIGSERIAL PRIMARY KEY,
    admin_id        UUID NOT NULL REFERENCES users(id),
    action          VARCHAR(200) NOT NULL,
    entity_type     VARCHAR(100),                 -- 'user', 'listing', 'booking', etc.
    entity_id       TEXT,
    old_values      JSONB,
    new_values      JSONB,
    ip_address      INET,
    user_agent      TEXT,
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================================================
-- SECTION 4: PROPERTY LISTINGS
-- =============================================================================

CREATE TYPE listing_status AS ENUM ('draft', 'pending_review', 'active', 'inactive', 'suspended', 'deleted');
CREATE TYPE property_type AS ENUM ('entire_place', 'private_room', 'shared_room', 'hotel_room');
CREATE TYPE property_subtype AS ENUM (
    'apartment', 'house', 'villa', 'guesthouse', 'resort_cabin',
    'houseboat', 'tree_house', 'beach_hut', 'tea_garden_cottage',
    'hostel', 'boutique_hotel', 'serviced_apartment', 'farmhouse', 'other'
);
CREATE TYPE cancellation_policy AS ENUM ('flexible', 'moderate', 'strict', 'super_strict');
CREATE TYPE check_in_method AS ENUM ('host_greets', 'self_checkin_keypad', 'self_checkin_lockbox', 'self_checkin_qr', 'other');

CREATE TABLE listings (
    id                          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    host_id                     UUID NOT NULL REFERENCES users(id),
    status                      listing_status NOT NULL DEFAULT 'draft',

    -- Classification
    property_type               property_type NOT NULL,
    property_subtype            property_subtype NOT NULL DEFAULT 'apartment',

    -- Content
    title_en                    VARCHAR(255) NOT NULL,
    title_bn                    VARCHAR(255),
    description_en              TEXT NOT NULL,
    description_bn              TEXT,
    space_description_en        TEXT,
    space_description_bn        TEXT,
    neighborhood_description_en TEXT,
    neighborhood_description_bn TEXT,
    getting_around_en           TEXT,
    getting_around_bn           TEXT,

    -- Location
    division_id                 SMALLINT NOT NULL REFERENCES divisions(id),
    district_id                 SMALLINT NOT NULL REFERENCES districts(id),
    upazila_id                  SMALLINT REFERENCES upazilas(id),
    thana_id                    SMALLINT REFERENCES thanas(id),
    area_id                     INT REFERENCES areas(id),
    address_line1               TEXT NOT NULL,
    address_line2               TEXT,
    postal_code                 VARCHAR(10),
    latitude                    DECIMAL(10,8) NOT NULL,
    longitude                   DECIMAL(11,8) NOT NULL,
    location_point              GEOGRAPHY(POINT, 4326),  -- PostGIS point for geo-queries
    exact_address_visible       BOOLEAN DEFAULT FALSE,   -- shown only after booking

    -- Capacity
    max_guests                  SMALLINT NOT NULL DEFAULT 1,
    num_bedrooms                SMALLINT NOT NULL DEFAULT 1,
    num_beds                    SMALLINT NOT NULL DEFAULT 1,
    num_bathrooms               NUMERIC(3,1) NOT NULL DEFAULT 1.0,  -- allows 1.5

    -- Pricing
    price_per_night             NUMERIC(12,2) NOT NULL,
    weekend_price               NUMERIC(12,2),           -- Thu/Fri premium
    cleaning_fee                NUMERIC(12,2) DEFAULT 0,
    extra_guest_fee             NUMERIC(12,2) DEFAULT 0,
    extra_guest_after           SMALLINT DEFAULT 1,
    security_deposit            NUMERIC(12,2) DEFAULT 0,
    min_nights                  SMALLINT DEFAULT 1,
    max_nights                  SMALLINT DEFAULT 365,
    weekly_discount_pct         NUMERIC(5,2) DEFAULT 0,
    monthly_discount_pct        NUMERIC(5,2) DEFAULT 0,

    -- Booking settings
    instant_book_enabled        BOOLEAN DEFAULT FALSE,
    cancellation_policy         cancellation_policy DEFAULT 'moderate',
    advance_notice_hours        SMALLINT DEFAULT 24,     -- minimum hours before check-in to book
    preparation_time_days       SMALLINT DEFAULT 0,      -- buffer days between bookings
    check_in_start              TIME DEFAULT '14:00',
    check_in_end                TIME DEFAULT '22:00',
    checkout_time               TIME DEFAULT '11:00',
    check_in_method             check_in_method DEFAULT 'host_greets',
    check_in_instructions       TEXT,

    -- Guest requirements
    require_verified_phone      BOOLEAN DEFAULT FALSE,
    require_verified_id         BOOLEAN DEFAULT FALSE,
    require_min_reviews         SMALLINT DEFAULT 0,

    -- Bangladesh-specific flags
    tourist_police_reg_required BOOLEAN DEFAULT FALSE,   -- Cox's Bazar coastal regulation
    unmarried_couple_policy     VARCHAR(20) DEFAULT 'allowed', -- 'allowed','id_required','not_allowed'
    eid_pricing_enabled         BOOLEAN DEFAULT FALSE,

    -- Moderation
    moderation_notes            TEXT,
    moderated_by                UUID REFERENCES users(id),
    moderated_at                TIMESTAMPTZ,

    -- Performance (denormalised for speed)
    total_reviews               INT DEFAULT 0,
    avg_rating                  NUMERIC(3,2),
    avg_cleanliness             NUMERIC(3,2),
    avg_accuracy                NUMERIC(3,2),
    avg_checkin                 NUMERIC(3,2),
    avg_communication           NUMERIC(3,2),
    avg_location                NUMERIC(3,2),
    avg_value                   NUMERIC(3,2),
    total_bookings              INT DEFAULT 0,
    wishlist_count              INT DEFAULT 0,

    is_featured                 BOOLEAN DEFAULT FALSE,
    search_rank_boost           SMALLINT DEFAULT 0,

    created_at                  TIMESTAMPTZ DEFAULT NOW(),
    updated_at                  TIMESTAMPTZ DEFAULT NOW(),
    published_at                TIMESTAMPTZ,
    deleted_at                  TIMESTAMPTZ
);

-- Spatial index for proximity searches
CREATE INDEX idx_listings_location ON listings USING GIST(location_point);
CREATE INDEX idx_listings_status ON listings(status) WHERE deleted_at IS NULL;
CREATE INDEX idx_listings_host ON listings(host_id);
CREATE INDEX idx_listings_district ON listings(district_id, status);
CREATE INDEX idx_listings_price ON listings(price_per_night);
CREATE INDEX idx_listings_search ON listings USING GIN(to_tsvector('english', title_en || ' ' || description_en));

-- Beds breakdown per bedroom
CREATE TABLE listing_beds (
    id              SERIAL PRIMARY KEY,
    listing_id      UUID NOT NULL REFERENCES listings(id) ON DELETE CASCADE,
    room_number     SMALLINT NOT NULL,           -- bedroom index
    bed_type        VARCHAR(50) NOT NULL,        -- 'king','queen','double','single','bunk','sofa_bed','floor_mattress'
    quantity        SMALLINT NOT NULL DEFAULT 1
);

-- Amenities catalogue
CREATE TABLE amenities (
    id              SMALLSERIAL PRIMARY KEY,
    category        VARCHAR(100) NOT NULL,       -- 'basics','bathroom','kitchen','power','safety','outdoor','bangladesh_specific'
    name_en         VARCHAR(150) NOT NULL,
    name_bn         VARCHAR(150),
    icon_key        VARCHAR(100),
    is_highlight    BOOLEAN DEFAULT FALSE,       -- shown prominently on listing card
    sort_order      SMALLINT DEFAULT 0
);

CREATE TABLE listing_amenities (
    listing_id  UUID NOT NULL REFERENCES listings(id) ON DELETE CASCADE,
    amenity_id  SMALLINT NOT NULL REFERENCES amenities(id),
    notes       TEXT,                            -- e.g. 'IPS backup for 4 hours'
    PRIMARY KEY (listing_id, amenity_id)
);

-- Photos
CREATE TABLE listing_photos (
    id              SERIAL PRIMARY KEY,
    listing_id      UUID NOT NULL REFERENCES listings(id) ON DELETE CASCADE,
    url             TEXT NOT NULL,
    thumbnail_url   TEXT,
    caption_en      VARCHAR(255),
    caption_bn      VARCHAR(255),
    room_type       VARCHAR(100),                -- 'bedroom','bathroom','kitchen','living_room','exterior','view'
    sort_order      SMALLINT DEFAULT 0,
    is_cover        BOOLEAN DEFAULT FALSE,
    uploaded_at     TIMESTAMPTZ DEFAULT NOW()
);

-- House rules
CREATE TABLE listing_house_rules (
    id              SERIAL PRIMARY KEY,
    listing_id      UUID NOT NULL REFERENCES listings(id) ON DELETE CASCADE,
    rule_key        VARCHAR(100),                -- 'no_smoking','no_pets','no_parties','quiet_hours'
    rule_text_en    TEXT NOT NULL,
    rule_text_bn    TEXT,
    sort_order      SMALLINT DEFAULT 0
);

-- Seasonal / special pricing overrides
CREATE TABLE listing_price_overrides (
    id              SERIAL PRIMARY KEY,
    listing_id      UUID NOT NULL REFERENCES listings(id) ON DELETE CASCADE,
    label_en        VARCHAR(200),               -- 'Eid ul-Fitr 2026', 'Cox's Bazar Winter Peak'
    label_bn        VARCHAR(200),
    start_date      DATE NOT NULL,
    end_date        DATE NOT NULL,
    price_per_night NUMERIC(12,2) NOT NULL,
    min_nights      SMALLINT,
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- iCal sync sources (Booking.com, Agoda, etc.)
CREATE TABLE listing_ical_syncs (
    id              SERIAL PRIMARY KEY,
    listing_id      UUID NOT NULL REFERENCES listings(id) ON DELETE CASCADE,
    source_name     VARCHAR(100) NOT NULL,      -- 'booking.com', 'agoda', 'airbnb_export'
    ical_url        TEXT NOT NULL,
    last_synced_at  TIMESTAMPTZ,
    sync_status     VARCHAR(50) DEFAULT 'active'
);

-- Co-host assignments
CREATE TYPE cohost_permission AS ENUM ('view_only', 'manage_calendar', 'manage_bookings', 'full_access');

CREATE TABLE listing_cohosts (
    id              SERIAL PRIMARY KEY,
    listing_id      UUID NOT NULL REFERENCES listings(id) ON DELETE CASCADE,
    host_id         UUID NOT NULL REFERENCES users(id),
    cohost_id       UUID NOT NULL REFERENCES users(id),
    permission      cohost_permission DEFAULT 'manage_bookings',
    invited_at      TIMESTAMPTZ DEFAULT NOW(),
    accepted_at     TIMESTAMPTZ,
    is_active       BOOLEAN DEFAULT TRUE,
    UNIQUE (listing_id, cohost_id)
);

-- =============================================================================
-- SECTION 5: AVAILABILITY CALENDAR
-- =============================================================================

CREATE TYPE availability_type AS ENUM ('available', 'blocked_by_host', 'blocked_by_booking', 'blocked_by_ical');

CREATE TABLE listing_availability (
    id              BIGSERIAL PRIMARY KEY,
    listing_id      UUID NOT NULL REFERENCES listings(id) ON DELETE CASCADE,
    date            DATE NOT NULL,
    availability    availability_type NOT NULL DEFAULT 'available',
    price_override  NUMERIC(12,2),              -- NULL = use listing base price
    min_nights      SMALLINT,
    note            TEXT,                        -- internal note for blocked dates
    UNIQUE (listing_id, date)
);

CREATE INDEX idx_availability_listing_date ON listing_availability(listing_id, date);

-- =============================================================================
-- SECTION 6: BOOKINGS
-- =============================================================================

CREATE TYPE booking_status AS ENUM (
    'inquiry', 'pending_payment', 'pending_host_approval',
    'confirmed', 'cancelled_by_guest', 'cancelled_by_host', 'cancelled_by_admin',
    'checked_in', 'completed', 'disputed', 'expired'
);

CREATE TABLE bookings (
    id                      UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    booking_ref             VARCHAR(20) UNIQUE NOT NULL,  -- BRN e.g. 'ABD-2026-XXXXXX'
    listing_id              UUID NOT NULL REFERENCES listings(id),
    guest_id                UUID NOT NULL REFERENCES users(id),
    host_id                 UUID NOT NULL REFERENCES users(id),
    status                  booking_status NOT NULL DEFAULT 'inquiry',

    -- Dates
    check_in_date           DATE NOT NULL,
    checkout_date           DATE NOT NULL,
    num_nights              SMALLINT NOT NULL,
    num_guests              SMALLINT NOT NULL DEFAULT 1,

    -- Guest details
    additional_guest_names  JSONB,               -- [{name, age}]
    guest_message           TEXT,

    -- Pricing snapshot (at time of booking)
    price_per_night         NUMERIC(12,2) NOT NULL,
    num_nights_charged      SMALLINT NOT NULL,
    nightly_subtotal        NUMERIC(12,2) NOT NULL,
    cleaning_fee            NUMERIC(12,2) DEFAULT 0,
    extra_guest_fee         NUMERIC(12,2) DEFAULT 0,
    discount_amount         NUMERIC(12,2) DEFAULT 0,  -- weekly/monthly discount
    coupon_discount         NUMERIC(12,2) DEFAULT 0,
    guest_service_fee       NUMERIC(12,2) NOT NULL,
    host_service_fee        NUMERIC(12,2) NOT NULL,
    vat_amount              NUMERIC(12,2) DEFAULT 0,
    security_deposit        NUMERIC(12,2) DEFAULT 0,
    total_guest_pays        NUMERIC(12,2) NOT NULL,
    host_payout_amount      NUMERIC(12,2) NOT NULL,
    platform_revenue        NUMERIC(12,2) NOT NULL,

    -- Cancellation / policy
    cancellation_policy     cancellation_policy NOT NULL,
    cancelled_at            TIMESTAMPTZ,
    cancellation_reason     TEXT,
    refund_amount           NUMERIC(12,2) DEFAULT 0,

    -- Check-in / out tracking
    actual_check_in         TIMESTAMPTZ,
    actual_checkout         TIMESTAMPTZ,
    check_in_pin            VARCHAR(20),         -- digital check-in code

    -- Flags
    is_instant_book         BOOLEAN DEFAULT FALSE,
    host_approval_deadline  TIMESTAMPTZ,
    request_approved_at     TIMESTAMPTZ,

    created_at              TIMESTAMPTZ DEFAULT NOW(),
    updated_at              TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_bookings_guest ON bookings(guest_id, status);
CREATE INDEX idx_bookings_host ON bookings(host_id, status);
CREATE INDEX idx_bookings_listing ON bookings(listing_id, check_in_date, checkout_date);
CREATE INDEX idx_bookings_ref ON bookings(booking_ref);
CREATE INDEX idx_bookings_dates ON bookings(check_in_date, checkout_date);

-- Booking modification history
CREATE TABLE booking_modifications (
    id                      SERIAL PRIMARY KEY,
    booking_id              UUID NOT NULL REFERENCES bookings(id),
    requested_by            UUID NOT NULL REFERENCES users(id),
    original_check_in       DATE,
    original_checkout       DATE,
    original_guests         SMALLINT,
    new_check_in            DATE,
    new_checkout            DATE,
    new_guests              SMALLINT,
    price_difference        NUMERIC(12,2),
    status                  VARCHAR(50) DEFAULT 'pending', -- 'pending','approved','rejected','withdrawn'
    responded_at            TIMESTAMPTZ,
    created_at              TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================================================
-- SECTION 7: PAYMENTS & PAYOUTS
-- =============================================================================

CREATE TYPE payment_method_type AS ENUM (
    'bkash', 'nagad', 'rocket', 'visa', 'mastercard',
    'internet_banking', 'bank_transfer', 'cash_on_arrival', 'platform_credit'
);
CREATE TYPE payment_status AS ENUM ('initiated', 'pending', 'completed', 'failed', 'refunded', 'partially_refunded', 'disputed');
CREATE TYPE payout_status AS ENUM ('pending', 'processing', 'completed', 'failed', 'on_hold', 'cancelled');

CREATE TABLE payments (
    id                      UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    booking_id              UUID NOT NULL REFERENCES bookings(id),
    payer_id                UUID NOT NULL REFERENCES users(id),
    payment_method          payment_method_type NOT NULL,
    status                  payment_status NOT NULL DEFAULT 'initiated',

    amount                  NUMERIC(12,2) NOT NULL,
    currency                CHAR(3) DEFAULT 'BDT',

    -- Gateway details
    gateway_name            VARCHAR(50),          -- 'sslcommerz','bkash_pgw','nagad_pgw'
    gateway_transaction_id  VARCHAR(255),
    gateway_ref_id          VARCHAR(255),
    gateway_response        JSONB,

    -- Mobile banking
    mobile_number           VARCHAR(20),          -- bKash/Nagad sender number

    -- Tokenised card info (no raw card data)
    card_last_four          CHAR(4),
    card_brand              VARCHAR(20),

    coupon_id               INT,                  -- FK added below after coupons table
    initiated_at            TIMESTAMPTZ DEFAULT NOW(),
    completed_at            TIMESTAMPTZ,
    failed_reason           TEXT,

    -- Receipt
    receipt_url             TEXT
);

CREATE INDEX idx_payments_booking ON payments(booking_id);
CREATE INDEX idx_payments_status ON payments(status);

CREATE TABLE refunds (
    id                      UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    payment_id              UUID NOT NULL REFERENCES payments(id),
    booking_id              UUID NOT NULL REFERENCES bookings(id),
    initiated_by            UUID NOT NULL REFERENCES users(id),  -- guest, admin, or system
    amount                  NUMERIC(12,2) NOT NULL,
    currency                CHAR(3) DEFAULT 'BDT',
    reason                  TEXT,
    status                  payment_status NOT NULL DEFAULT 'pending',
    gateway_refund_id       VARCHAR(255),
    processed_at            TIMESTAMPTZ,
    created_at              TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE host_payout_accounts (
    id                      SERIAL PRIMARY KEY,
    host_id                 UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    method                  payment_method_type NOT NULL,
    account_name            VARCHAR(200) NOT NULL,
    account_number          VARCHAR(100),         -- bank account or mobile wallet number
    bank_name               VARCHAR(200),
    branch_name             VARCHAR(200),
    routing_number          VARCHAR(20),          -- Bangladesh bank routing number
    is_primary              BOOLEAN DEFAULT TRUE,
    is_verified             BOOLEAN DEFAULT FALSE,
    created_at              TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE payouts (
    id                      UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    host_id                 UUID NOT NULL REFERENCES users(id),
    booking_id              UUID REFERENCES bookings(id),
    payout_account_id       INT REFERENCES host_payout_accounts(id),
    status                  payout_status NOT NULL DEFAULT 'pending',

    gross_amount            NUMERIC(12,2) NOT NULL,
    platform_fee            NUMERIC(12,2) NOT NULL,
    tds_withheld            NUMERIC(12,2) DEFAULT 0,  -- Tax Deducted at Source
    vat_on_fee              NUMERIC(12,2) DEFAULT 0,
    net_amount              NUMERIC(12,2) NOT NULL,
    currency                CHAR(3) DEFAULT 'BDT',

    gateway_ref_id          VARCHAR(255),
    gateway_response        JSONB,
    failure_reason          TEXT,
    retry_count             SMALLINT DEFAULT 0,

    scheduled_at            TIMESTAMPTZ,
    processed_at            TIMESTAMPTZ,
    created_at              TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_payouts_host ON payouts(host_id, status);

-- Tax certificates and annual summaries
CREATE TABLE tax_certificates (
    id                      SERIAL PRIMARY KEY,
    host_id                 UUID NOT NULL REFERENCES users(id),
    fiscal_year             VARCHAR(10) NOT NULL,  -- e.g. '2025-26'
    total_earnings          NUMERIC(12,2),
    total_tds_deducted      NUMERIC(12,2),
    total_vat_collected     NUMERIC(12,2),
    certificate_url         TEXT,
    generated_at            TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================================================
-- SECTION 8: PLATFORM FEES & PRICING CONFIGURATION
-- =============================================================================

CREATE TABLE platform_fee_configs (
    id                      SERIAL PRIMARY KEY,
    name                    VARCHAR(200) NOT NULL,
    guest_service_fee_pct   NUMERIC(5,2) NOT NULL DEFAULT 12.00,
    host_service_fee_pct    NUMERIC(5,2) NOT NULL DEFAULT 3.00,
    vat_on_service_fee_pct  NUMERIC(5,2) NOT NULL DEFAULT 15.00,  -- Bangladesh VAT
    tds_rate_pct            NUMERIC(5,2) NOT NULL DEFAULT 5.00,   -- TDS on host payouts above threshold
    tds_threshold_bdt       NUMERIC(12,2) DEFAULT 0,
    applicable_from         DATE NOT NULL,
    applicable_to           DATE,
    is_active               BOOLEAN DEFAULT TRUE,
    created_by              UUID REFERENCES users(id),
    created_at              TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================================================
-- SECTION 9: COUPONS & PROMOTIONS
-- =============================================================================

CREATE TYPE discount_type AS ENUM ('flat_bdt', 'percentage');

CREATE TABLE coupons (
    id                      SERIAL PRIMARY KEY,
    code                    VARCHAR(50) UNIQUE NOT NULL,
    description_en          TEXT,
    description_bn          TEXT,
    discount_type           discount_type NOT NULL,
    discount_value          NUMERIC(12,2) NOT NULL,
    max_discount_bdt        NUMERIC(12,2),         -- cap for percentage discounts
    min_booking_amount      NUMERIC(12,2) DEFAULT 0,
    usage_limit_total       INT,                   -- NULL = unlimited
    usage_limit_per_user    SMALLINT DEFAULT 1,
    current_usage_count     INT DEFAULT 0,
    valid_from              TIMESTAMPTZ NOT NULL,
    valid_to                TIMESTAMPTZ,
    applicable_property_ids UUID[],                -- NULL = all properties
    created_by              UUID REFERENCES users(id),
    is_active               BOOLEAN DEFAULT TRUE,
    created_at              TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE coupon_usages (
    id          SERIAL PRIMARY KEY,
    coupon_id   INT NOT NULL REFERENCES coupons(id),
    user_id     UUID NOT NULL REFERENCES users(id),
    booking_id  UUID NOT NULL REFERENCES bookings(id),
    discount_applied NUMERIC(12,2) NOT NULL,
    used_at     TIMESTAMPTZ DEFAULT NOW()
);

-- Add FK from payments to coupons
ALTER TABLE payments ADD CONSTRAINT fk_payment_coupon FOREIGN KEY (coupon_id) REFERENCES coupons(id);

-- Referral programme
CREATE TABLE referrals (
    id                  SERIAL PRIMARY KEY,
    referrer_id         UUID NOT NULL REFERENCES users(id),
    referee_id          UUID NOT NULL REFERENCES users(id),
    referrer_bonus_bdt  NUMERIC(12,2) DEFAULT 0,
    referee_bonus_bdt   NUMERIC(12,2) DEFAULT 0,
    status              VARCHAR(50) DEFAULT 'pending',   -- 'pending','credited','expired'
    qualifying_booking_id UUID REFERENCES bookings(id),
    credited_at         TIMESTAMPTZ,
    created_at          TIMESTAMPTZ DEFAULT NOW()
);

-- Platform credits (from refunds, referral bonuses, admin compensation)
CREATE TABLE user_credits (
    id              BIGSERIAL PRIMARY KEY,
    user_id         UUID NOT NULL REFERENCES users(id),
    amount          NUMERIC(12,2) NOT NULL,          -- positive = credit, negative = debit
    balance_after   NUMERIC(12,2) NOT NULL,
    reason          TEXT NOT NULL,
    reference_type  VARCHAR(100),                    -- 'referral','refund','dispute_compensation','promo'
    reference_id    TEXT,
    expires_at      TIMESTAMPTZ,
    created_by      UUID REFERENCES users(id),
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================================================
-- SECTION 10: REVIEWS
-- =============================================================================

CREATE TYPE review_type AS ENUM ('guest_to_listing', 'host_to_guest');

CREATE TABLE reviews (
    id                      UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    booking_id              UUID NOT NULL REFERENCES bookings(id),
    review_type             review_type NOT NULL,
    reviewer_id             UUID NOT NULL REFERENCES users(id),
    reviewee_id             UUID NOT NULL REFERENCES users(id),   -- host (for guest_to_listing) or guest
    listing_id              UUID REFERENCES listings(id),

    -- Ratings (1.0 – 5.0)
    overall_rating          NUMERIC(3,2) NOT NULL,
    cleanliness_rating      NUMERIC(3,2),
    accuracy_rating         NUMERIC(3,2),
    checkin_rating          NUMERIC(3,2),
    communication_rating    NUMERIC(3,2),
    location_rating         NUMERIC(3,2),
    value_rating            NUMERIC(3,2),

    comment_en              TEXT,
    comment_bn              TEXT,

    -- Blind review: set submitted_at when reviewer submits; published once both submit or 14 days pass
    submitted_at            TIMESTAMPTZ DEFAULT NOW(),
    published_at            TIMESTAMPTZ,
    is_published            BOOLEAN DEFAULT FALSE,

    -- Host public response to guest review
    response_text           TEXT,
    response_at             TIMESTAMPTZ,

    -- Moderation
    is_flagged              BOOLEAN DEFAULT FALSE,
    flagged_reason          TEXT,
    moderated_by            UUID REFERENCES users(id),
    moderated_at            TIMESTAMPTZ,
    is_removed              BOOLEAN DEFAULT FALSE,

    created_at              TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE (booking_id, review_type)
);

CREATE INDEX idx_reviews_listing ON reviews(listing_id, is_published);
CREATE INDEX idx_reviews_reviewee ON reviews(reviewee_id, review_type, is_published);

-- Review flags by users
CREATE TABLE review_flags (
    id              SERIAL PRIMARY KEY,
    review_id       UUID NOT NULL REFERENCES reviews(id),
    flagged_by      UUID NOT NULL REFERENCES users(id),
    reason          TEXT NOT NULL,
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================================================
-- SECTION 11: MESSAGING
-- =============================================================================

CREATE TABLE conversations (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    booking_id      UUID REFERENCES bookings(id),
    listing_id      UUID REFERENCES listings(id),
    host_id         UUID NOT NULL REFERENCES users(id),
    guest_id        UUID NOT NULL REFERENCES users(id),
    subject         VARCHAR(255),
    is_archived     BOOLEAN DEFAULT FALSE,
    last_message_at TIMESTAMPTZ,
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE messages (
    id                  BIGSERIAL PRIMARY KEY,
    conversation_id     UUID NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
    sender_id           UUID NOT NULL REFERENCES users(id),
    body_original       TEXT NOT NULL,
    body_translated     TEXT,
    original_language   CHAR(2),                 -- 'bn','en'
    translated_language CHAR(2),
    attachment_url      TEXT,
    attachment_type     VARCHAR(50),             -- 'image','document'
    is_system_message   BOOLEAN DEFAULT FALSE,   -- automated platform messages
    is_read             BOOLEAN DEFAULT FALSE,
    read_at             TIMESTAMPTZ,
    is_flagged          BOOLEAN DEFAULT FALSE,
    created_at          TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_messages_conversation ON messages(conversation_id, created_at);

-- =============================================================================
-- SECTION 12: NOTIFICATIONS
-- =============================================================================

CREATE TYPE notification_channel AS ENUM ('push', 'sms', 'email', 'in_app');
CREATE TYPE notification_status AS ENUM ('pending', 'sent', 'delivered', 'failed', 'read');

CREATE TABLE notification_templates (
    id              SERIAL PRIMARY KEY,
    event_key       VARCHAR(200) UNIQUE NOT NULL, -- 'booking_confirmed','review_reminder', etc.
    channel         notification_channel NOT NULL,
    language        CHAR(2) NOT NULL DEFAULT 'en',
    subject         VARCHAR(255),                 -- for email
    body_template   TEXT NOT NULL,                -- Mustache/Handlebars template
    is_active       BOOLEAN DEFAULT TRUE,
    updated_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE notifications (
    id              BIGSERIAL PRIMARY KEY,
    user_id         UUID NOT NULL REFERENCES users(id),
    template_id     INT REFERENCES notification_templates(id),
    channel         notification_channel NOT NULL,
    status          notification_status DEFAULT 'pending',
    subject         VARCHAR(255),
    body            TEXT NOT NULL,
    reference_type  VARCHAR(100),
    reference_id    TEXT,
    gateway_msg_id  VARCHAR(255),
    sent_at         TIMESTAMPTZ,
    delivered_at    TIMESTAMPTZ,
    read_at         TIMESTAMPTZ,
    failed_reason   TEXT,
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_notifications_user ON notifications(user_id, status, created_at DESC);

-- =============================================================================
-- SECTION 13: WISHLISTS
-- =============================================================================

CREATE TABLE wishlists (
    id          SERIAL PRIMARY KEY,
    user_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name        VARCHAR(200) NOT NULL DEFAULT 'Saved',
    is_public   BOOLEAN DEFAULT FALSE,
    created_at  TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE wishlist_listings (
    wishlist_id     INT NOT NULL REFERENCES wishlists(id) ON DELETE CASCADE,
    listing_id      UUID NOT NULL REFERENCES listings(id) ON DELETE CASCADE,
    added_at        TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY (wishlist_id, listing_id)
);

-- =============================================================================
-- SECTION 14: DISPUTES
-- =============================================================================

CREATE TYPE dispute_raised_by AS ENUM ('guest', 'host', 'admin');
CREATE TYPE dispute_status AS ENUM ('open', 'under_review', 'awaiting_evidence', 'resolved', 'escalated', 'closed');
CREATE TYPE dispute_ruling AS ENUM ('favour_guest', 'favour_host', 'partial_refund', 'no_action', 'pending');

CREATE TABLE disputes (
    id                      SERIAL PRIMARY KEY,
    booking_id              UUID NOT NULL REFERENCES bookings(id),
    raised_by               dispute_raised_by NOT NULL,
    raised_by_user_id       UUID NOT NULL REFERENCES users(id),
    category                VARCHAR(100) NOT NULL,  -- 'property_not_as_described','safety_concern','payment_issue','host_cancelled_late', etc.
    description             TEXT NOT NULL,
    status                  dispute_status DEFAULT 'open',
    ruling                  dispute_ruling DEFAULT 'pending',
    assigned_admin_id       UUID REFERENCES users(id),
    guest_refund_amount     NUMERIC(12,2) DEFAULT 0,
    host_deduction_amount   NUMERIC(12,2) DEFAULT 0,
    admin_notes             TEXT,
    resolution_summary      TEXT,
    sla_deadline            TIMESTAMPTZ,
    resolved_at             TIMESTAMPTZ,
    created_at              TIMESTAMPTZ DEFAULT NOW(),
    updated_at              TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE dispute_evidence (
    id              SERIAL PRIMARY KEY,
    dispute_id      INT NOT NULL REFERENCES disputes(id),
    submitted_by    UUID NOT NULL REFERENCES users(id),
    file_url        TEXT NOT NULL,
    file_type       VARCHAR(50),
    description     TEXT,
    submitted_at    TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE dispute_messages (
    id              SERIAL PRIMARY KEY,
    dispute_id      INT NOT NULL REFERENCES disputes(id),
    sender_id       UUID NOT NULL REFERENCES users(id),
    message         TEXT NOT NULL,
    is_internal     BOOLEAN DEFAULT FALSE,   -- admin-only internal note
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================================================
-- SECTION 15: LISTING REPORTS (User-reported issues)
-- =============================================================================

CREATE TABLE listing_reports (
    id              SERIAL PRIMARY KEY,
    listing_id      UUID NOT NULL REFERENCES listings(id),
    reporter_id     UUID NOT NULL REFERENCES users(id),
    category        VARCHAR(100) NOT NULL,   -- 'inaccurate','fraudulent','offensive','spam','safety'
    description     TEXT,
    status          VARCHAR(50) DEFAULT 'open',
    reviewed_by     UUID REFERENCES users(id),
    reviewed_at     TIMESTAMPTZ,
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================================================
-- SECTION 16: SUPERHOST ASSESSMENT HISTORY
-- =============================================================================

CREATE TABLE superhost_assessments (
    id                          SERIAL PRIMARY KEY,
    host_id                     UUID NOT NULL REFERENCES users(id),
    assessment_period           VARCHAR(20) NOT NULL,   -- 'Q1-2026', 'Q2-2026'
    response_rate               NUMERIC(5,2),
    acceptance_rate             NUMERIC(5,2),
    completed_stays             INT,
    completed_nights            INT,
    avg_rating                  NUMERIC(3,2),
    passed_response_rate        BOOLEAN,
    passed_acceptance_rate      BOOLEAN,
    passed_stays_or_nights      BOOLEAN,
    passed_rating               BOOLEAN,
    is_superhost_awarded        BOOLEAN,
    assessed_at                 TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================================================
-- SECTION 17: PLATFORM ANALYTICS & EVENTS (lightweight event stream)
-- =============================================================================

CREATE TABLE analytics_events (
    id              BIGSERIAL PRIMARY KEY,
    event_type      VARCHAR(100) NOT NULL,   -- 'search','listing_view','booking_started','booking_completed'
    user_id         UUID REFERENCES users(id),
    session_id      VARCHAR(100),
    listing_id      UUID REFERENCES listings(id),
    booking_id      UUID REFERENCES bookings(id),
    properties      JSONB,
    device_type     VARCHAR(50),             -- 'android','ios','web'
    ip_address      INET,
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_analytics_event_type ON analytics_events(event_type, created_at);
CREATE INDEX idx_analytics_user ON analytics_events(user_id, created_at);

-- =============================================================================
-- SECTION 18: AUDIT LOGS (system-level, separate from admin actions)
-- =============================================================================

CREATE TABLE system_audit_logs (
    id              BIGSERIAL PRIMARY KEY,
    table_name      VARCHAR(100) NOT NULL,
    record_id       TEXT NOT NULL,
    operation       CHAR(1) NOT NULL,        -- 'I','U','D'
    old_data        JSONB,
    new_data        JSONB,
    changed_by      UUID,
    changed_at      TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================================================
-- SECTION 19: FEATURE FLAGS
-- =============================================================================

CREATE TABLE feature_flags (
    id              SERIAL PRIMARY KEY,
    flag_key        VARCHAR(200) UNIQUE NOT NULL,
    description     TEXT,
    is_enabled      BOOLEAN DEFAULT FALSE,
    rollout_pct     SMALLINT DEFAULT 0,          -- 0–100 % of users
    user_segment    JSONB,                        -- JSON filter criteria
    updated_by      UUID REFERENCES users(id),
    updated_at      TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================================================
-- SECTION 20: SYSTEM CONFIGURATION
-- =============================================================================

CREATE TABLE system_configs (
    key             VARCHAR(200) PRIMARY KEY,
    value           TEXT NOT NULL,
    value_type      VARCHAR(20) DEFAULT 'string',  -- 'string','integer','boolean','json'
    description     TEXT,
    updated_by      UUID REFERENCES users(id),
    updated_at      TIMESTAMPTZ DEFAULT NOW()
);

-- Insert default system configs
INSERT INTO system_configs (key, value, value_type, description) VALUES
('default_currency',            'BDT',          'string',   'Platform currency'),
('default_language',            'bn',           'string',   'Default UI language (bn or en)'),
('booking_hold_hours',          '24',           'integer',  'Hours payment is held before releasing to host after check-in'),
('host_approval_deadline_hours','24',           'integer',  'Hours host has to respond to a booking request'),
('review_window_days',          '14',           'integer',  'Days after checkout in which reviews can be submitted'),
('max_listing_photos',          '50',           'integer',  'Maximum photos per listing'),
('superhost_min_rating',        '4.8',          'string',   'Minimum average rating for Superhost'),
('superhost_min_response_rate', '90',           'integer',  'Minimum response rate % for Superhost'),
('superhost_min_acceptance_rate','90',          'integer',  'Minimum acceptance rate % for Superhost'),
('superhost_min_stays',         '10',           'integer',  'Minimum completed stays per year for Superhost'),
('platform_support_phone',      '16XXX',        'string',   'Bangladesh customer support number'),
('sms_gateway_provider',        'ssl_wireless', 'string',   'Active SMS gateway'),
('payout_retry_max',            '3',            'integer',  'Max payout retry attempts');

-- =============================================================================
-- SECTION 21: VIEWS FOR COMMON QUERIES
-- =============================================================================

-- Active listings with host info for search
CREATE OR REPLACE VIEW v_active_listings AS
SELECT
    l.id,
    l.title_en,
    l.title_bn,
    l.property_type,
    l.property_subtype,
    l.price_per_night,
    l.max_guests,
    l.num_bedrooms,
    l.num_bathrooms,
    l.avg_rating,
    l.total_reviews,
    l.is_featured,
    l.instant_book_enabled,
    l.latitude,
    l.longitude,
    l.district_id,
    l.division_id,
    d.name_en AS district_name,
    dv.name_en AS division_name,
    u.id AS host_id,
    u.display_name AS host_name,
    u.profile_photo_url AS host_photo,
    u.is_superhost,
    (SELECT url FROM listing_photos lp WHERE lp.listing_id = l.id AND lp.is_cover = TRUE LIMIT 1) AS cover_photo
FROM listings l
JOIN users u ON l.host_id = u.id
JOIN districts d ON l.district_id = d.id
JOIN divisions dv ON l.division_id = dv.id
WHERE l.status = 'active' AND l.deleted_at IS NULL;

-- Guest booking summary
CREATE OR REPLACE VIEW v_guest_bookings AS
SELECT
    b.id,
    b.booking_ref,
    b.status,
    b.check_in_date,
    b.checkout_date,
    b.num_nights,
    b.num_guests,
    b.total_guest_pays,
    b.created_at,
    l.title_en AS listing_title,
    l.district_id,
    (SELECT url FROM listing_photos lp WHERE lp.listing_id = l.id AND lp.is_cover = TRUE LIMIT 1) AS listing_photo,
    u.display_name AS host_name
FROM bookings b
JOIN listings l ON b.listing_id = l.id
JOIN users u ON b.host_id = u.id;

-- Host earnings summary
CREATE OR REPLACE VIEW v_host_earnings AS
SELECT
    p.host_id,
    COUNT(*) AS total_payouts,
    SUM(p.gross_amount) AS total_gross,
    SUM(p.platform_fee) AS total_fees,
    SUM(p.tds_withheld) AS total_tds,
    SUM(p.net_amount) AS total_net,
    DATE_TRUNC('month', p.created_at) AS month
FROM payouts p
WHERE p.status = 'completed'
GROUP BY p.host_id, DATE_TRUNC('month', p.created_at);

-- =============================================================================
-- SECTION 22: INDEXES (additional performance indexes)
-- =============================================================================

CREATE INDEX idx_users_mobile ON users(mobile_number);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role_status ON users(role, status);
CREATE INDEX idx_listings_full_search ON listings USING GIN(
    to_tsvector('simple', COALESCE(title_en,'') || ' ' || COALESCE(title_bn,'') || ' ' || COALESCE(description_en,''))
) WHERE status = 'active';
CREATE INDEX idx_conversations_booking ON conversations(booking_id);
CREATE INDEX idx_disputes_booking ON disputes(booking_id);
CREATE INDEX idx_disputes_admin ON disputes(assigned_admin_id, status);

-- =============================================================================
-- SEED DATA: Bangladesh Divisions
-- =============================================================================

INSERT INTO divisions (name_en, name_bn) VALUES
('Dhaka',       'ঢাকা'),
('Chittagong',  'চট্টগ্রাম'),
('Rajshahi',    'রাজশাহী'),
('Khulna',      'খুলনা'),
('Barisal',     'বরিশাল'),
('Sylhet',      'সিলেট'),
('Rangpur',     'রংপুর'),
('Mymensingh',  'ময়মনসিংহ');

-- =============================================================================
-- SEED DATA: Core Amenities (Bangladesh-specific)
-- =============================================================================

INSERT INTO amenities (category, name_en, name_bn, is_highlight) VALUES
-- Basics
('basics',              'WiFi',                     'ওয়াইফাই',              TRUE),
('basics',              'Air Conditioning (AC)',     'এয়ার কন্ডিশনার',      TRUE),
('basics',              'Ceiling Fan',               'সিলিং ফ্যান',           FALSE),
('basics',              'TV',                        'টেলিভিশন',              FALSE),
('basics',              'Washing Machine',           'ওয়াশিং মেশিন',          FALSE),
-- Power (Bangladesh-specific)
('power',               'Generator Backup',          'জেনারেটর ব্যাকআপ',      TRUE),
('power',               'IPS / Inverter Backup',     'আইপিএস / ইনভার্টার',    TRUE),
('power',               'Solar Power',               'সোলার বিদ্যুৎ',          FALSE),
-- Kitchen
('kitchen',             'Kitchen',                  'রান্নাঘর',               TRUE),
('kitchen',             'Gas Stove (Cylinder)',      'গ্যাস চুলা (সিলিন্ডার)', FALSE),
('kitchen',             'Gas Stove (Piped)',         'গ্যাস চুলা (পাইপড)',     FALSE),
('kitchen',             'Microwave',                'মাইক্রোওয়েভ',            FALSE),
('kitchen',             'Refrigerator',             'রেফ্রিজারেটর',           FALSE),
-- Water
('water',               'WASA Water Supply',        'ওয়াসার পানি',            FALSE),
('water',               'Deep Tube Well Water',     'গভীর নলকূপের পানি',     FALSE),
('water',               'Water Filter / Purifier',  'পানি ফিল্টার',           FALSE),
-- Safety
('safety',              'Smoke Detector',           'স্মোক ডিটেক্টর',          FALSE),
('safety',              'Fire Extinguisher',        'ফায়ার এক্সটিংগুইশার',    FALSE),
('safety',              'First Aid Kit',            'প্রাথমিক চিকিৎসা কিট',   FALSE),
('safety',              'CCTV (Common Areas)',      'সিসিটিভি',               FALSE),
('safety',              '24-hour Security Guard',   '২৪ ঘণ্টা নিরাপত্তা',    FALSE),
-- Bangladesh-specific
('bangladesh_specific', 'Mosquito Net',             'মশারি',                  TRUE),
('bangladesh_specific', 'Mosquito Repellent',       'মশা তাড়ানোর স্প্রে',    FALSE),
('bangladesh_specific', 'Prayer Mat & Qibla Direction', 'জায়নামাজ ও কেবলা',  TRUE),
('bangladesh_specific', 'Ramadan Sehri Alarm',      'সেহরির অ্যালার্ম',       FALSE),
('bangladesh_specific', 'Rooftop Access',           'ছাদে প্রবেশাধিকার',      TRUE),
('bangladesh_specific', 'Balcony',                  'বারান্দা',                TRUE),
-- Outdoor/Parking
('outdoor',             'Free Parking',             'বিনামূল্যে পার্কিং',     TRUE),
('outdoor',             'Private Pool',             'প্রাইভেট পুল',           FALSE),
('outdoor',             'Garden',                   'বাগান',                  FALSE),
('outdoor',             'Lift / Elevator',          'লিফট',                   FALSE);

-- =============================================================================
-- END OF SCHEMA
-- Total tables: 46  |  Views: 3  |  Extensions: 4
-- =============================================================================
