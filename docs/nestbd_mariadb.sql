-- =============================================================================
-- Thikana — Airbnb Bangladesh
-- Database: MariaDB 10.11+
-- Encoding: utf8mb4 (required for Bangla Unicode + emoji support)
-- Currency: All monetary values stored as DECIMAL(12,2) in BDT
-- Laravel 12 conventions: snake_case tables, BIGINT AUTO_INCREMENT PKs,
--   CHAR(36) for UUID PKs, JSON for jsonb, TIMESTAMP for timestamptz,
--   created_at / updated_at / deleted_at naming
-- =============================================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;
SET SQL_MODE = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO';

-- =============================================================================
-- SECTION 1: GEOGRAPHY — Bangladesh Administrative Divisions
-- =============================================================================

CREATE TABLE divisions (
    id              SMALLINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name_en         VARCHAR(100) NOT NULL,
    name_bn         VARCHAR(100) NOT NULL,
    created_at      TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE districts (
    id              SMALLINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    division_id     SMALLINT UNSIGNED NOT NULL,
    name_en         VARCHAR(100) NOT NULL,
    name_bn         VARCHAR(100) NOT NULL,
    created_at      TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_districts_division FOREIGN KEY (division_id) REFERENCES divisions(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE upazilas (
    id              SMALLINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    district_id     SMALLINT UNSIGNED NOT NULL,
    name_en         VARCHAR(150) NOT NULL,
    name_bn         VARCHAR(150) NOT NULL,
    created_at      TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_upazilas_district FOREIGN KEY (district_id) REFERENCES districts(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE thanas (
    id              SMALLINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    upazila_id      SMALLINT UNSIGNED NOT NULL,
    name_en         VARCHAR(150) NOT NULL,
    name_bn         VARCHAR(150) NOT NULL,
    created_at      TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_thanas_upazila FOREIGN KEY (upazila_id) REFERENCES upazilas(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE areas (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    thana_id        SMALLINT UNSIGNED NULL,
    district_id     SMALLINT UNSIGNED NULL,
    name_en         VARCHAR(200) NOT NULL,
    name_bn         VARCHAR(200) NULL,
    area_type       VARCHAR(50) NULL COMMENT 'neighbourhood, beach_zone, tourist_area, city_ward',
    is_tourist_area TINYINT(1) NOT NULL DEFAULT 0,
    latitude        DECIMAL(10,8) NULL,
    longitude       DECIMAL(11,8) NULL,
    created_at      TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_areas_thana    FOREIGN KEY (thana_id)    REFERENCES thanas(id),
    CONSTRAINT fk_areas_district FOREIGN KEY (district_id) REFERENCES districts(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- SECTION 2: USERS
-- =============================================================================

CREATE TABLE users (
    id                      CHAR(36) NOT NULL PRIMARY KEY,
    role                    ENUM('guest','host','both','admin') NOT NULL DEFAULT 'guest',
    status                  ENUM('pending_verification','active','suspended','banned','deactivated','deleted') NOT NULL DEFAULT 'pending_verification',

    -- Basic identity
    first_name              VARCHAR(100) NOT NULL,
    last_name               VARCHAR(100) NULL,
    display_name            VARCHAR(200) NULL,
    email                   VARCHAR(255) NULL,
    mobile_number           VARCHAR(20) NOT NULL,
    date_of_birth           DATE NULL,
    gender                  VARCHAR(20) NULL COMMENT 'male, female, other, prefer_not_to_say',
    profile_photo_url       TEXT NULL,
    bio                     TEXT NULL,
    preferred_language      ENUM('bn','en') NOT NULL DEFAULT 'bn',

    -- Verification flags
    email_verified          TINYINT(1) NOT NULL DEFAULT 0,
    mobile_verified         TINYINT(1) NOT NULL DEFAULT 0,
    id_verified             ENUM('not_submitted','pending','approved','rejected','expired') NOT NULL DEFAULT 'not_submitted',

    -- Address (personal, not property)
    address_line1           TEXT NULL,
    address_line2           TEXT NULL,
    thana_id                SMALLINT UNSIGNED NULL,
    district_id             SMALLINT UNSIGNED NULL,
    division_id             SMALLINT UNSIGNED NULL,
    postal_code             VARCHAR(10) NULL,

    -- Auth
    password_hash           TEXT NULL COMMENT 'NULL if OAuth only',
    last_login_at           TIMESTAMP NULL,
    mfa_enabled             TINYINT(1) NOT NULL DEFAULT 0,
    mfa_secret              TEXT NULL COMMENT 'TOTP secret, encrypt at app level',

    -- Platform metadata
    referral_code           VARCHAR(20) NULL,
    referred_by_user_id     CHAR(36) NULL,
    profile_completeness    TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '0–100 percent',
    is_superhost            TINYINT(1) NOT NULL DEFAULT 0,
    superhost_since         DATE NULL,
    account_notes           TEXT NULL,

    created_at              TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at              TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at              TIMESTAMP NULL,

    UNIQUE KEY uq_users_email         (email),
    UNIQUE KEY uq_users_mobile        (mobile_number),
    UNIQUE KEY uq_users_referral_code (referral_code),
    KEY idx_users_role_status         (role, status),
    CONSTRAINT fk_users_thana         FOREIGN KEY (thana_id)            REFERENCES thanas(id),
    CONSTRAINT fk_users_district      FOREIGN KEY (district_id)          REFERENCES districts(id),
    CONSTRAINT fk_users_division      FOREIGN KEY (division_id)          REFERENCES divisions(id),
    CONSTRAINT fk_users_referred_by   FOREIGN KEY (referred_by_user_id)  REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE user_oauth_accounts (
    id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id         CHAR(36) NOT NULL,
    provider        VARCHAR(30) NOT NULL COMMENT 'google, facebook',
    provider_uid    VARCHAR(255) NOT NULL,
    access_token    TEXT NULL,
    refresh_token   TEXT NULL,
    token_expires   TIMESTAMP NULL,
    created_at      TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_oauth_provider_uid (provider, provider_uid),
    CONSTRAINT fk_oauth_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE user_id_verifications (
    id                  BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id             CHAR(36) NOT NULL,
    doc_type            ENUM('nid','passport','driving_licence','birth_certificate') NOT NULL,
    doc_number          VARCHAR(100) NOT NULL,
    doc_front_url       TEXT NOT NULL,
    doc_back_url        TEXT NULL,
    selfie_url          TEXT NULL,
    status              ENUM('not_submitted','pending','approved','rejected','expired') NOT NULL DEFAULT 'pending',
    reviewer_admin_id   CHAR(36) NULL,
    reviewer_notes      TEXT NULL,
    submitted_at        TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    reviewed_at         TIMESTAMP NULL,
    expires_at          TIMESTAMP NULL,
    CONSTRAINT fk_id_verif_user     FOREIGN KEY (user_id)           REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_id_verif_reviewer FOREIGN KEY (reviewer_admin_id) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE user_emergency_contacts (
    id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id         CHAR(36) NOT NULL,
    name            VARCHAR(200) NOT NULL,
    relationship    VARCHAR(100) NULL,
    mobile_number   VARCHAR(20) NOT NULL,
    email           VARCHAR(255) NULL,
    created_at      TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_emergency_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- SECTION 3: ADMIN ROLES & PERMISSIONS
-- =============================================================================

CREATE TABLE admin_roles (
    id          SMALLINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    description TEXT NULL,
    created_at  TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_admin_roles_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE admin_permissions (
    id          SMALLINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    code        VARCHAR(100) NOT NULL COMMENT 'manage_users, view_finances, etc.',
    description TEXT NULL,
    UNIQUE KEY uq_admin_permissions_code (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE admin_role_permissions (
    role_id         SMALLINT UNSIGNED NOT NULL,
    permission_id   SMALLINT UNSIGNED NOT NULL,
    PRIMARY KEY (role_id, permission_id),
    CONSTRAINT fk_arp_role       FOREIGN KEY (role_id)       REFERENCES admin_roles(id),
    CONSTRAINT fk_arp_permission FOREIGN KEY (permission_id) REFERENCES admin_permissions(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE admin_users (
    user_id         CHAR(36) NOT NULL PRIMARY KEY,
    admin_role_id   SMALLINT UNSIGNED NOT NULL,
    assigned_by     CHAR(36) NULL,
    assigned_at     TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    is_active       TINYINT(1) NOT NULL DEFAULT 1,
    CONSTRAINT fk_admin_users_user        FOREIGN KEY (user_id)       REFERENCES users(id),
    CONSTRAINT fk_admin_users_role        FOREIGN KEY (admin_role_id) REFERENCES admin_roles(id),
    CONSTRAINT fk_admin_users_assigned_by FOREIGN KEY (assigned_by)   REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE admin_audit_logs (
    id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    admin_id        CHAR(36) NOT NULL,
    action          VARCHAR(200) NOT NULL,
    entity_type     VARCHAR(100) NULL COMMENT 'user, listing, booking, etc.',
    entity_id       TEXT NULL,
    old_values      JSON NULL,
    new_values      JSON NULL,
    ip_address      VARCHAR(45) NULL,
    user_agent      TEXT NULL,
    created_at      TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_audit_admin FOREIGN KEY (admin_id) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- SECTION 4: PROPERTY LISTINGS
-- =============================================================================

CREATE TABLE amenities (
    id              SMALLINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    category        VARCHAR(100) NOT NULL COMMENT 'basics, bathroom, kitchen, power, safety, outdoor, bangladesh_specific',
    name_en         VARCHAR(150) NOT NULL,
    name_bn         VARCHAR(150) NULL,
    icon_key        VARCHAR(100) NULL,
    is_highlight    TINYINT(1) NOT NULL DEFAULT 0,
    sort_order      SMALLINT NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE listings (
    id                          CHAR(36) NOT NULL PRIMARY KEY,
    host_id                     CHAR(36) NOT NULL,
    status                      ENUM('draft','pending_review','active','inactive','suspended','deleted') NOT NULL DEFAULT 'draft',

    -- Classification
    property_type               ENUM('entire_place','private_room','shared_room','hotel_room') NOT NULL,
    property_subtype            ENUM('apartment','house','villa','guesthouse','resort_cabin','houseboat','tree_house','beach_hut','tea_garden_cottage','hostel','boutique_hotel','serviced_apartment','farmhouse','other') NOT NULL DEFAULT 'apartment',

    -- Content
    title_en                    VARCHAR(255) NOT NULL,
    title_bn                    VARCHAR(255) NULL,
    description_en              TEXT NOT NULL,
    description_bn              TEXT NULL,
    space_description_en        TEXT NULL,
    space_description_bn        TEXT NULL,
    neighborhood_description_en TEXT NULL,
    neighborhood_description_bn TEXT NULL,
    getting_around_en           TEXT NULL,
    getting_around_bn           TEXT NULL,

    -- Location
    division_id                 SMALLINT UNSIGNED NOT NULL,
    district_id                 SMALLINT UNSIGNED NOT NULL,
    upazila_id                  SMALLINT UNSIGNED NULL,
    thana_id                    SMALLINT UNSIGNED NULL,
    area_id                     INT UNSIGNED NULL,
    address_line1               TEXT NOT NULL,
    address_line2               TEXT NULL,
    postal_code                 VARCHAR(10) NULL,
    latitude                    DECIMAL(10,8) NOT NULL,
    longitude                   DECIMAL(11,8) NOT NULL,
    -- MariaDB spatial point for geo-queries (replaces PostGIS GEOGRAPHY)
    -- Must be NOT NULL for SPATIAL KEY to work in MariaDB
    location_point              POINT NOT NULL DEFAULT (POINT(0, 0)),
    exact_address_visible       TINYINT(1) NOT NULL DEFAULT 0,

    -- Capacity
    max_guests                  SMALLINT UNSIGNED NOT NULL DEFAULT 1,
    num_bedrooms                SMALLINT UNSIGNED NOT NULL DEFAULT 1,
    num_beds                    SMALLINT UNSIGNED NOT NULL DEFAULT 1,
    num_bathrooms               DECIMAL(3,1) NOT NULL DEFAULT 1.0,

    -- Pricing
    price_per_night             DECIMAL(12,2) NOT NULL,
    weekend_price               DECIMAL(12,2) NULL COMMENT 'Thu/Fri premium',
    cleaning_fee                DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    extra_guest_fee             DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    extra_guest_after           SMALLINT UNSIGNED NOT NULL DEFAULT 1,
    security_deposit            DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    min_nights                  SMALLINT UNSIGNED NOT NULL DEFAULT 1,
    max_nights                  SMALLINT UNSIGNED NOT NULL DEFAULT 365,
    weekly_discount_pct         DECIMAL(5,2) NOT NULL DEFAULT 0.00,
    monthly_discount_pct        DECIMAL(5,2) NOT NULL DEFAULT 0.00,

    -- Booking settings
    instant_book_enabled        TINYINT(1) NOT NULL DEFAULT 0,
    cancellation_policy         ENUM('flexible','moderate','strict','super_strict') NOT NULL DEFAULT 'moderate',
    advance_notice_hours        SMALLINT UNSIGNED NOT NULL DEFAULT 24,
    preparation_time_days       SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    check_in_start              TIME NOT NULL DEFAULT '14:00:00',
    check_in_end                TIME NOT NULL DEFAULT '22:00:00',
    checkout_time               TIME NOT NULL DEFAULT '11:00:00',
    check_in_method             ENUM('host_greets','self_checkin_keypad','self_checkin_lockbox','self_checkin_qr','other') NOT NULL DEFAULT 'host_greets',
    check_in_instructions       TEXT NULL,

    -- Guest requirements
    require_verified_phone      TINYINT(1) NOT NULL DEFAULT 0,
    require_verified_id         TINYINT(1) NOT NULL DEFAULT 0,
    require_min_reviews         SMALLINT UNSIGNED NOT NULL DEFAULT 0,

    -- Bangladesh-specific
    tourist_police_reg_required TINYINT(1) NOT NULL DEFAULT 0,
    unmarried_couple_policy     VARCHAR(20) NOT NULL DEFAULT 'allowed' COMMENT 'allowed, id_required, not_allowed',
    eid_pricing_enabled         TINYINT(1) NOT NULL DEFAULT 0,

    -- Moderation
    moderation_notes            TEXT NULL,
    moderated_by                CHAR(36) NULL,
    moderated_at                TIMESTAMP NULL,

    -- Denormalised performance counters
    total_reviews               INT UNSIGNED NOT NULL DEFAULT 0,
    avg_rating                  DECIMAL(3,2) NULL,
    avg_cleanliness             DECIMAL(3,2) NULL,
    avg_accuracy                DECIMAL(3,2) NULL,
    avg_checkin                 DECIMAL(3,2) NULL,
    avg_communication           DECIMAL(3,2) NULL,
    avg_location                DECIMAL(3,2) NULL,
    avg_value                   DECIMAL(3,2) NULL,
    total_bookings              INT UNSIGNED NOT NULL DEFAULT 0,
    wishlist_count              INT UNSIGNED NOT NULL DEFAULT 0,

    is_featured                 TINYINT(1) NOT NULL DEFAULT 0,
    search_rank_boost           SMALLINT NOT NULL DEFAULT 0,

    created_at                  TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at                  TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    published_at                TIMESTAMP NULL,
    deleted_at                  TIMESTAMP NULL,

    KEY idx_listings_host           (host_id),
    KEY idx_listings_status         (status, deleted_at),
    KEY idx_listings_district       (district_id, status),
    KEY idx_listings_price          (price_per_night),
    SPATIAL KEY idx_listings_location (location_point),
    FULLTEXT KEY idx_listings_search  (title_en, description_en),

    CONSTRAINT fk_listings_host      FOREIGN KEY (host_id)      REFERENCES users(id),
    CONSTRAINT fk_listings_division  FOREIGN KEY (division_id)  REFERENCES divisions(id),
    CONSTRAINT fk_listings_district  FOREIGN KEY (district_id)  REFERENCES districts(id),
    CONSTRAINT fk_listings_upazila   FOREIGN KEY (upazila_id)   REFERENCES upazilas(id),
    CONSTRAINT fk_listings_thana     FOREIGN KEY (thana_id)     REFERENCES thanas(id),
    CONSTRAINT fk_listings_area      FOREIGN KEY (area_id)      REFERENCES areas(id),
    CONSTRAINT fk_listings_moderated FOREIGN KEY (moderated_by) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE listing_beds (
    id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    listing_id      CHAR(36) NOT NULL,
    room_number     SMALLINT UNSIGNED NOT NULL,
    bed_type        VARCHAR(50) NOT NULL COMMENT 'king, queen, double, single, bunk, sofa_bed, floor_mattress',
    quantity        SMALLINT UNSIGNED NOT NULL DEFAULT 1,
    CONSTRAINT fk_listing_beds_listing FOREIGN KEY (listing_id) REFERENCES listings(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE listing_amenities (
    listing_id  CHAR(36) NOT NULL,
    amenity_id  SMALLINT UNSIGNED NOT NULL,
    notes       TEXT NULL,
    PRIMARY KEY (listing_id, amenity_id),
    CONSTRAINT fk_la_listing FOREIGN KEY (listing_id) REFERENCES listings(id) ON DELETE CASCADE,
    CONSTRAINT fk_la_amenity FOREIGN KEY (amenity_id) REFERENCES amenities(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE listing_photos (
    id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    listing_id      CHAR(36) NOT NULL,
    url             TEXT NOT NULL,
    thumbnail_url   TEXT NULL,
    caption_en      VARCHAR(255) NULL,
    caption_bn      VARCHAR(255) NULL,
    room_type       VARCHAR(100) NULL COMMENT 'bedroom, bathroom, kitchen, living_room, exterior, view',
    sort_order      SMALLINT NOT NULL DEFAULT 0,
    is_cover        TINYINT(1) NOT NULL DEFAULT 0,
    uploaded_at     TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_listing_photos_listing FOREIGN KEY (listing_id) REFERENCES listings(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE listing_house_rules (
    id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    listing_id      CHAR(36) NOT NULL,
    rule_key        VARCHAR(100) NULL COMMENT 'no_smoking, no_pets, no_parties, quiet_hours',
    rule_text_en    TEXT NOT NULL,
    rule_text_bn    TEXT NULL,
    sort_order      SMALLINT NOT NULL DEFAULT 0,
    CONSTRAINT fk_house_rules_listing FOREIGN KEY (listing_id) REFERENCES listings(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE listing_price_overrides (
    id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    listing_id      CHAR(36) NOT NULL,
    label_en        VARCHAR(200) NULL,
    label_bn        VARCHAR(200) NULL,
    start_date      DATE NOT NULL,
    end_date        DATE NOT NULL,
    price_per_night DECIMAL(12,2) NOT NULL,
    min_nights      SMALLINT UNSIGNED NULL,
    created_at      TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_price_overrides_listing FOREIGN KEY (listing_id) REFERENCES listings(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE listing_ical_syncs (
    id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    listing_id      CHAR(36) NOT NULL,
    source_name     VARCHAR(100) NOT NULL COMMENT 'booking.com, agoda, airbnb_export',
    ical_url        TEXT NOT NULL,
    last_synced_at  TIMESTAMP NULL,
    sync_status     VARCHAR(50) NOT NULL DEFAULT 'active',
    CONSTRAINT fk_ical_syncs_listing FOREIGN KEY (listing_id) REFERENCES listings(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE listing_cohosts (
    id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    listing_id      CHAR(36) NOT NULL,
    host_id         CHAR(36) NOT NULL,
    cohost_id       CHAR(36) NOT NULL,
    permission      ENUM('view_only','manage_calendar','manage_bookings','full_access') NOT NULL DEFAULT 'manage_bookings',
    invited_at      TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    accepted_at     TIMESTAMP NULL,
    is_active       TINYINT(1) NOT NULL DEFAULT 1,
    UNIQUE KEY uq_listing_cohost (listing_id, cohost_id),
    CONSTRAINT fk_cohosts_listing FOREIGN KEY (listing_id) REFERENCES listings(id) ON DELETE CASCADE,
    CONSTRAINT fk_cohosts_host    FOREIGN KEY (host_id)    REFERENCES users(id),
    CONSTRAINT fk_cohosts_cohost  FOREIGN KEY (cohost_id)  REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- SECTION 5: AVAILABILITY CALENDAR
-- =============================================================================

CREATE TABLE listing_availability (
    id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    listing_id      CHAR(36) NOT NULL,
    date            DATE NOT NULL,
    availability    ENUM('available','blocked_by_host','blocked_by_booking','blocked_by_ical') NOT NULL DEFAULT 'available',
    price_override  DECIMAL(12,2) NULL COMMENT 'NULL = use listing base price',
    min_nights      SMALLINT UNSIGNED NULL,
    note            TEXT NULL,
    UNIQUE KEY uq_listing_date (listing_id, date),
    KEY idx_availability_listing_date (listing_id, date),
    CONSTRAINT fk_availability_listing FOREIGN KEY (listing_id) REFERENCES listings(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- SECTION 6: BOOKINGS
-- =============================================================================

CREATE TABLE bookings (
    id                      CHAR(36) NOT NULL PRIMARY KEY,
    booking_ref             VARCHAR(20) NOT NULL,
    listing_id              CHAR(36) NOT NULL,
    guest_id                CHAR(36) NOT NULL,
    host_id                 CHAR(36) NOT NULL,
    status                  ENUM('inquiry','pending_payment','pending_host_approval','confirmed','cancelled_by_guest','cancelled_by_host','cancelled_by_admin','checked_in','completed','disputed','expired') NOT NULL DEFAULT 'inquiry',

    -- Dates
    check_in_date           DATE NOT NULL,
    checkout_date           DATE NOT NULL,
    num_nights              SMALLINT UNSIGNED NOT NULL,
    num_guests              SMALLINT UNSIGNED NOT NULL DEFAULT 1,

    -- Guest details
    additional_guest_names  JSON NULL COMMENT '[{name, age}]',
    guest_message           TEXT NULL,

    -- Pricing snapshot at time of booking
    price_per_night         DECIMAL(12,2) NOT NULL,
    num_nights_charged      SMALLINT UNSIGNED NOT NULL,
    nightly_subtotal        DECIMAL(12,2) NOT NULL,
    cleaning_fee            DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    extra_guest_fee         DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    discount_amount         DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    coupon_discount         DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    guest_service_fee       DECIMAL(12,2) NOT NULL,
    host_service_fee        DECIMAL(12,2) NOT NULL,
    vat_amount              DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    security_deposit        DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    total_guest_pays        DECIMAL(12,2) NOT NULL,
    host_payout_amount      DECIMAL(12,2) NOT NULL,
    platform_revenue        DECIMAL(12,2) NOT NULL,

    -- Cancellation
    cancellation_policy     ENUM('flexible','moderate','strict','super_strict') NOT NULL,
    cancelled_at            TIMESTAMP NULL,
    cancellation_reason     TEXT NULL,
    refund_amount           DECIMAL(12,2) NOT NULL DEFAULT 0.00,

    -- Check-in / out tracking
    actual_check_in         TIMESTAMP NULL,
    actual_checkout         TIMESTAMP NULL,
    check_in_pin            VARCHAR(20) NULL,

    -- Flags
    is_instant_book         TINYINT(1) NOT NULL DEFAULT 0,
    host_approval_deadline  TIMESTAMP NULL,
    request_approved_at     TIMESTAMP NULL,

    created_at              TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at              TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    UNIQUE KEY uq_bookings_ref      (booking_ref),
    KEY idx_bookings_guest          (guest_id, status),
    KEY idx_bookings_host           (host_id, status),
    KEY idx_bookings_listing        (listing_id, check_in_date, checkout_date),
    KEY idx_bookings_dates          (check_in_date, checkout_date),

    CONSTRAINT fk_bookings_listing  FOREIGN KEY (listing_id) REFERENCES listings(id),
    CONSTRAINT fk_bookings_guest    FOREIGN KEY (guest_id)   REFERENCES users(id),
    CONSTRAINT fk_bookings_host     FOREIGN KEY (host_id)    REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE booking_modifications (
    id                      BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    booking_id              CHAR(36) NOT NULL,
    requested_by            CHAR(36) NOT NULL,
    original_check_in       DATE NULL,
    original_checkout       DATE NULL,
    original_guests         SMALLINT UNSIGNED NULL,
    new_check_in            DATE NULL,
    new_checkout            DATE NULL,
    new_guests              SMALLINT UNSIGNED NULL,
    price_difference        DECIMAL(12,2) NULL,
    status                  VARCHAR(50) NOT NULL DEFAULT 'pending' COMMENT 'pending, approved, rejected, withdrawn',
    responded_at            TIMESTAMP NULL,
    created_at              TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_book_mod_booking  FOREIGN KEY (booking_id)    REFERENCES bookings(id),
    CONSTRAINT fk_book_mod_requester FOREIGN KEY (requested_by) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- SECTION 7: PAYMENTS & PAYOUTS
-- =============================================================================

CREATE TABLE payments (
    id                      CHAR(36) NOT NULL PRIMARY KEY,
    booking_id              CHAR(36) NOT NULL,
    payer_id                CHAR(36) NOT NULL,
    payment_method          ENUM('bkash','nagad','rocket','visa','mastercard','internet_banking','bank_transfer','cash_on_arrival','platform_credit') NOT NULL,
    status                  ENUM('initiated','pending','completed','failed','refunded','partially_refunded','disputed') NOT NULL DEFAULT 'initiated',

    amount                  DECIMAL(12,2) NOT NULL,
    currency                CHAR(3) NOT NULL DEFAULT 'BDT',

    -- Gateway details
    gateway_name            VARCHAR(50) NULL COMMENT 'sslcommerz, bkash_pgw, nagad_pgw',
    gateway_transaction_id  VARCHAR(255) NULL,
    gateway_ref_id          VARCHAR(255) NULL,
    gateway_response        JSON NULL,

    -- Mobile banking
    mobile_number           VARCHAR(20) NULL,

    -- Tokenised card (no raw card data)
    card_last_four          CHAR(4) NULL,
    card_brand              VARCHAR(20) NULL,

    coupon_id               INT UNSIGNED NULL,
    initiated_at            TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    completed_at            TIMESTAMP NULL,
    failed_reason           TEXT NULL,
    receipt_url             TEXT NULL,

    KEY idx_payments_booking (booking_id),
    KEY idx_payments_status  (status),
    CONSTRAINT fk_payments_booking FOREIGN KEY (booking_id) REFERENCES bookings(id),
    CONSTRAINT fk_payments_payer   FOREIGN KEY (payer_id)   REFERENCES users(id)
    -- fk_payments_coupon added after coupons table
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE refunds (
    id                      CHAR(36) NOT NULL PRIMARY KEY,
    payment_id              CHAR(36) NOT NULL,
    booking_id              CHAR(36) NOT NULL,
    initiated_by            CHAR(36) NOT NULL,
    amount                  DECIMAL(12,2) NOT NULL,
    currency                CHAR(3) NOT NULL DEFAULT 'BDT',
    reason                  TEXT NULL,
    status                  ENUM('initiated','pending','completed','failed','refunded','partially_refunded','disputed') NOT NULL DEFAULT 'pending',
    gateway_refund_id       VARCHAR(255) NULL,
    processed_at            TIMESTAMP NULL,
    created_at              TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_refunds_payment     FOREIGN KEY (payment_id)   REFERENCES payments(id),
    CONSTRAINT fk_refunds_booking     FOREIGN KEY (booking_id)   REFERENCES bookings(id),
    CONSTRAINT fk_refunds_initiated   FOREIGN KEY (initiated_by) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE host_payout_accounts (
    id                      BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    host_id                 CHAR(36) NOT NULL,
    method                  ENUM('bkash','nagad','rocket','visa','mastercard','internet_banking','bank_transfer','cash_on_arrival','platform_credit') NOT NULL,
    account_name            VARCHAR(200) NOT NULL,
    account_number          VARCHAR(100) NULL,
    bank_name               VARCHAR(200) NULL,
    branch_name             VARCHAR(200) NULL,
    routing_number          VARCHAR(20) NULL,
    is_primary              TINYINT(1) NOT NULL DEFAULT 1,
    is_verified             TINYINT(1) NOT NULL DEFAULT 0,
    created_at              TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_payout_accounts_host FOREIGN KEY (host_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE payouts (
    id                      CHAR(36) NOT NULL PRIMARY KEY,
    host_id                 CHAR(36) NOT NULL,
    booking_id              CHAR(36) NULL,
    payout_account_id       BIGINT UNSIGNED NULL,
    status                  ENUM('pending','processing','completed','failed','on_hold','cancelled') NOT NULL DEFAULT 'pending',

    gross_amount            DECIMAL(12,2) NOT NULL,
    platform_fee            DECIMAL(12,2) NOT NULL,
    tds_withheld            DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    vat_on_fee              DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    net_amount              DECIMAL(12,2) NOT NULL,
    currency                CHAR(3) NOT NULL DEFAULT 'BDT',

    gateway_ref_id          VARCHAR(255) NULL,
    gateway_response        JSON NULL,
    failure_reason          TEXT NULL,
    retry_count             SMALLINT UNSIGNED NOT NULL DEFAULT 0,

    scheduled_at            TIMESTAMP NULL,
    processed_at            TIMESTAMP NULL,
    created_at              TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,

    KEY idx_payouts_host (host_id, status),
    CONSTRAINT fk_payouts_host    FOREIGN KEY (host_id)           REFERENCES users(id),
    CONSTRAINT fk_payouts_booking FOREIGN KEY (booking_id)        REFERENCES bookings(id),
    CONSTRAINT fk_payouts_account FOREIGN KEY (payout_account_id) REFERENCES host_payout_accounts(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE tax_certificates (
    id                      BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    host_id                 CHAR(36) NOT NULL,
    fiscal_year             VARCHAR(10) NOT NULL COMMENT 'e.g. 2025-26',
    total_earnings          DECIMAL(12,2) NULL,
    total_tds_deducted      DECIMAL(12,2) NULL,
    total_vat_collected     DECIMAL(12,2) NULL,
    certificate_url         TEXT NULL,
    generated_at            TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_tax_cert_host FOREIGN KEY (host_id) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- SECTION 8: PLATFORM FEES & PRICING CONFIGURATION
-- =============================================================================

CREATE TABLE platform_fee_configs (
    id                      BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name                    VARCHAR(200) NOT NULL,
    guest_service_fee_pct   DECIMAL(5,2) NOT NULL DEFAULT 12.00,
    host_service_fee_pct    DECIMAL(5,2) NOT NULL DEFAULT 3.00,
    vat_on_service_fee_pct  DECIMAL(5,2) NOT NULL DEFAULT 15.00 COMMENT 'Bangladesh VAT',
    tds_rate_pct            DECIMAL(5,2) NOT NULL DEFAULT 5.00 COMMENT 'TDS on host payouts',
    tds_threshold_bdt       DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    applicable_from         DATE NOT NULL,
    applicable_to           DATE NULL,
    is_active               TINYINT(1) NOT NULL DEFAULT 1,
    created_by              CHAR(36) NULL,
    created_at              TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_fee_config_creator FOREIGN KEY (created_by) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- SECTION 9: COUPONS & PROMOTIONS
-- =============================================================================

CREATE TABLE coupons (
    id                      INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    code                    VARCHAR(50) NOT NULL,
    description_en          TEXT NULL,
    description_bn          TEXT NULL,
    discount_type           ENUM('flat_bdt','percentage') NOT NULL,
    discount_value          DECIMAL(12,2) NOT NULL,
    max_discount_bdt        DECIMAL(12,2) NULL,
    min_booking_amount      DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    usage_limit_total       INT NULL COMMENT 'NULL = unlimited',
    usage_limit_per_user    SMALLINT UNSIGNED NOT NULL DEFAULT 1,
    current_usage_count     INT UNSIGNED NOT NULL DEFAULT 0,
    valid_from              TIMESTAMP NOT NULL,
    valid_to                TIMESTAMP NULL,
    -- applicable_property_ids: stored as JSON array of UUIDs (replaces PostgreSQL UUID[])
    applicable_property_ids JSON NULL COMMENT 'JSON array of listing UUIDs; NULL = all',
    created_by              CHAR(36) NULL,
    is_active               TINYINT(1) NOT NULL DEFAULT 1,
    created_at              TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_coupons_code (code),
    CONSTRAINT fk_coupons_creator FOREIGN KEY (created_by) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Add FK from payments to coupons now that the table exists
ALTER TABLE payments
    ADD CONSTRAINT fk_payments_coupon FOREIGN KEY (coupon_id) REFERENCES coupons(id);

CREATE TABLE coupon_usages (
    id               BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    coupon_id        INT UNSIGNED NOT NULL,
    user_id          CHAR(36) NOT NULL,
    booking_id       CHAR(36) NOT NULL,
    discount_applied DECIMAL(12,2) NOT NULL,
    used_at          TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_coupon_usages_coupon  FOREIGN KEY (coupon_id)  REFERENCES coupons(id),
    CONSTRAINT fk_coupon_usages_user    FOREIGN KEY (user_id)    REFERENCES users(id),
    CONSTRAINT fk_coupon_usages_booking FOREIGN KEY (booking_id) REFERENCES bookings(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE referrals (
    id                    BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    referrer_id           CHAR(36) NOT NULL,
    referee_id            CHAR(36) NOT NULL,
    referrer_bonus_bdt    DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    referee_bonus_bdt     DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    status                VARCHAR(50) NOT NULL DEFAULT 'pending' COMMENT 'pending, credited, expired',
    qualifying_booking_id CHAR(36) NULL,
    credited_at           TIMESTAMP NULL,
    created_at            TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_referrals_referrer FOREIGN KEY (referrer_id)           REFERENCES users(id),
    CONSTRAINT fk_referrals_referee  FOREIGN KEY (referee_id)            REFERENCES users(id),
    CONSTRAINT fk_referrals_booking  FOREIGN KEY (qualifying_booking_id) REFERENCES bookings(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE user_credits (
    id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id         CHAR(36) NOT NULL,
    amount          DECIMAL(12,2) NOT NULL COMMENT 'positive = credit, negative = debit',
    balance_after   DECIMAL(12,2) NOT NULL,
    reason          TEXT NOT NULL,
    reference_type  VARCHAR(100) NULL COMMENT 'referral, refund, dispute_compensation, promo',
    reference_id    TEXT NULL,
    expires_at      TIMESTAMP NULL,
    created_by      CHAR(36) NULL,
    created_at      TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_user_credits_user       FOREIGN KEY (user_id)    REFERENCES users(id),
    CONSTRAINT fk_user_credits_created_by FOREIGN KEY (created_by) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- SECTION 10: REVIEWS
-- =============================================================================

CREATE TABLE reviews (
    id                      CHAR(36) NOT NULL PRIMARY KEY,
    booking_id              CHAR(36) NOT NULL,
    review_type             ENUM('guest_to_listing','host_to_guest') NOT NULL,
    reviewer_id             CHAR(36) NOT NULL,
    reviewee_id             CHAR(36) NOT NULL,
    listing_id              CHAR(36) NULL,

    -- Ratings (1.0 – 5.0)
    overall_rating          DECIMAL(3,2) NOT NULL,
    cleanliness_rating      DECIMAL(3,2) NULL,
    accuracy_rating         DECIMAL(3,2) NULL,
    checkin_rating          DECIMAL(3,2) NULL,
    communication_rating    DECIMAL(3,2) NULL,
    location_rating         DECIMAL(3,2) NULL,
    value_rating            DECIMAL(3,2) NULL,

    comment_en              TEXT NULL,
    comment_bn              TEXT NULL,

    submitted_at            TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    published_at            TIMESTAMP NULL,
    is_published            TINYINT(1) NOT NULL DEFAULT 0,

    -- Host public response
    response_text           TEXT NULL,
    response_at             TIMESTAMP NULL,

    -- Moderation
    is_flagged              TINYINT(1) NOT NULL DEFAULT 0,
    flagged_reason          TEXT NULL,
    moderated_by            CHAR(36) NULL,
    moderated_at            TIMESTAMP NULL,
    is_removed              TINYINT(1) NOT NULL DEFAULT 0,

    created_at              TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,

    UNIQUE KEY uq_review_booking_type (booking_id, review_type),
    KEY idx_reviews_listing   (listing_id, is_published),
    KEY idx_reviews_reviewee  (reviewee_id, review_type, is_published),

    CONSTRAINT fk_reviews_booking    FOREIGN KEY (booking_id)   REFERENCES bookings(id),
    CONSTRAINT fk_reviews_reviewer   FOREIGN KEY (reviewer_id)  REFERENCES users(id),
    CONSTRAINT fk_reviews_reviewee   FOREIGN KEY (reviewee_id)  REFERENCES users(id),
    CONSTRAINT fk_reviews_listing    FOREIGN KEY (listing_id)   REFERENCES listings(id),
    CONSTRAINT fk_reviews_moderator  FOREIGN KEY (moderated_by) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE review_flags (
    id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    review_id       CHAR(36) NOT NULL,
    flagged_by      CHAR(36) NOT NULL,
    reason          TEXT NOT NULL,
    created_at      TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_review_flags_review FOREIGN KEY (review_id)  REFERENCES reviews(id),
    CONSTRAINT fk_review_flags_user   FOREIGN KEY (flagged_by) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- SECTION 11: MESSAGING
-- =============================================================================

CREATE TABLE conversations (
    id              CHAR(36) NOT NULL PRIMARY KEY,
    booking_id      CHAR(36) NULL,
    listing_id      CHAR(36) NULL,
    host_id         CHAR(36) NOT NULL,
    guest_id        CHAR(36) NOT NULL,
    subject         VARCHAR(255) NULL,
    is_archived     TINYINT(1) NOT NULL DEFAULT 0,
    last_message_at TIMESTAMP NULL,
    created_at      TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    KEY idx_conversations_booking (booking_id),
    CONSTRAINT fk_conv_booking FOREIGN KEY (booking_id) REFERENCES bookings(id),
    CONSTRAINT fk_conv_listing FOREIGN KEY (listing_id) REFERENCES listings(id),
    CONSTRAINT fk_conv_host    FOREIGN KEY (host_id)    REFERENCES users(id),
    CONSTRAINT fk_conv_guest   FOREIGN KEY (guest_id)   REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE messages (
    id                  BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    conversation_id     CHAR(36) NOT NULL,
    sender_id           CHAR(36) NOT NULL,
    body_original       TEXT NOT NULL,
    body_translated     TEXT NULL,
    original_language   CHAR(2) NULL COMMENT 'bn, en',
    translated_language CHAR(2) NULL,
    attachment_url      TEXT NULL,
    attachment_type     VARCHAR(50) NULL COMMENT 'image, document',
    is_system_message   TINYINT(1) NOT NULL DEFAULT 0,
    is_read             TINYINT(1) NOT NULL DEFAULT 0,
    read_at             TIMESTAMP NULL,
    is_flagged          TINYINT(1) NOT NULL DEFAULT 0,
    created_at          TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    KEY idx_messages_conversation (conversation_id, created_at),
    CONSTRAINT fk_messages_conv   FOREIGN KEY (conversation_id) REFERENCES conversations(id) ON DELETE CASCADE,
    CONSTRAINT fk_messages_sender FOREIGN KEY (sender_id)       REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- SECTION 12: NOTIFICATIONS
-- =============================================================================

CREATE TABLE notification_templates (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    event_key       VARCHAR(200) NOT NULL COMMENT 'booking_confirmed, review_reminder, etc.',
    channel         ENUM('push','sms','email','in_app') NOT NULL,
    language        CHAR(2) NOT NULL DEFAULT 'en',
    subject         VARCHAR(255) NULL,
    body_template   TEXT NOT NULL,
    is_active       TINYINT(1) NOT NULL DEFAULT 1,
    updated_at      TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_notif_template_key (event_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Renamed to platform_notifications to avoid conflict with Laravel's built-in notifications table
CREATE TABLE platform_notifications (
    id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id         CHAR(36) NOT NULL,
    template_id     INT UNSIGNED NULL,
    channel         ENUM('push','sms','email','in_app') NOT NULL,
    status          ENUM('pending','sent','delivered','failed','read') NOT NULL DEFAULT 'pending',
    subject         VARCHAR(255) NULL,
    body            TEXT NOT NULL,
    reference_type  VARCHAR(100) NULL,
    reference_id    TEXT NULL,
    gateway_msg_id  VARCHAR(255) NULL,
    sent_at         TIMESTAMP NULL,
    delivered_at    TIMESTAMP NULL,
    read_at         TIMESTAMP NULL,
    failed_reason   TEXT NULL,
    created_at      TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    KEY idx_notifications_user (user_id, status, created_at),
    CONSTRAINT fk_notif_user     FOREIGN KEY (user_id)     REFERENCES users(id),
    CONSTRAINT fk_notif_template FOREIGN KEY (template_id) REFERENCES notification_templates(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- SECTION 13: WISHLISTS
-- =============================================================================

CREATE TABLE wishlists (
    id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id     CHAR(36) NOT NULL,
    name        VARCHAR(200) NOT NULL DEFAULT 'Saved',
    is_public   TINYINT(1) NOT NULL DEFAULT 0,
    created_at  TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_wishlists_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE wishlist_listings (
    wishlist_id     INT UNSIGNED NOT NULL,
    listing_id      CHAR(36) NOT NULL,
    added_at        TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (wishlist_id, listing_id),
    CONSTRAINT fk_wl_wishlist FOREIGN KEY (wishlist_id) REFERENCES wishlists(id) ON DELETE CASCADE,
    CONSTRAINT fk_wl_listing  FOREIGN KEY (listing_id)  REFERENCES listings(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- SECTION 14: DISPUTES
-- =============================================================================

CREATE TABLE disputes (
    id                      INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    booking_id              CHAR(36) NOT NULL,
    raised_by               ENUM('guest','host','admin') NOT NULL,
    raised_by_user_id       CHAR(36) NOT NULL,
    category                VARCHAR(100) NOT NULL COMMENT 'property_not_as_described, safety_concern, payment_issue, host_cancelled_late',
    description             TEXT NOT NULL,
    status                  ENUM('open','under_review','awaiting_evidence','resolved','escalated','closed') NOT NULL DEFAULT 'open',
    ruling                  ENUM('favour_guest','favour_host','partial_refund','no_action','pending') NOT NULL DEFAULT 'pending',
    assigned_admin_id       CHAR(36) NULL,
    guest_refund_amount     DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    host_deduction_amount   DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    admin_notes             TEXT NULL,
    resolution_summary      TEXT NULL,
    sla_deadline            TIMESTAMP NULL,
    resolved_at             TIMESTAMP NULL,
    created_at              TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at              TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    KEY idx_disputes_booking (booking_id),
    KEY idx_disputes_admin   (assigned_admin_id, status),
    CONSTRAINT fk_disputes_booking       FOREIGN KEY (booking_id)        REFERENCES bookings(id),
    CONSTRAINT fk_disputes_raised_by     FOREIGN KEY (raised_by_user_id) REFERENCES users(id),
    CONSTRAINT fk_disputes_assigned      FOREIGN KEY (assigned_admin_id) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE dispute_evidence (
    id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    dispute_id      INT UNSIGNED NOT NULL,
    submitted_by    CHAR(36) NOT NULL,
    file_url        TEXT NOT NULL,
    file_type       VARCHAR(50) NULL,
    description     TEXT NULL,
    submitted_at    TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_disp_ev_dispute   FOREIGN KEY (dispute_id)   REFERENCES disputes(id),
    CONSTRAINT fk_disp_ev_submitter FOREIGN KEY (submitted_by) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE dispute_messages (
    id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    dispute_id      INT UNSIGNED NOT NULL,
    sender_id       CHAR(36) NOT NULL,
    message         TEXT NOT NULL,
    is_internal     TINYINT(1) NOT NULL DEFAULT 0 COMMENT 'admin-only internal note',
    created_at      TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_disp_msg_dispute FOREIGN KEY (dispute_id) REFERENCES disputes(id),
    CONSTRAINT fk_disp_msg_sender  FOREIGN KEY (sender_id)  REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- SECTION 15: LISTING REPORTS
-- =============================================================================

CREATE TABLE listing_reports (
    id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    listing_id      CHAR(36) NOT NULL,
    reporter_id     CHAR(36) NOT NULL,
    category        VARCHAR(100) NOT NULL COMMENT 'inaccurate, fraudulent, offensive, spam, safety',
    description     TEXT NULL,
    status          VARCHAR(50) NOT NULL DEFAULT 'open',
    reviewed_by     CHAR(36) NULL,
    reviewed_at     TIMESTAMP NULL,
    created_at      TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_listing_reports_listing    FOREIGN KEY (listing_id)  REFERENCES listings(id),
    CONSTRAINT fk_listing_reports_reporter   FOREIGN KEY (reporter_id) REFERENCES users(id),
    CONSTRAINT fk_listing_reports_reviewer   FOREIGN KEY (reviewed_by) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- SECTION 16: SUPERHOST ASSESSMENTS
-- =============================================================================

CREATE TABLE superhost_assessments (
    id                          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    host_id                     CHAR(36) NOT NULL,
    assessment_period           VARCHAR(20) NOT NULL COMMENT 'Q1-2026, Q2-2026',
    response_rate               DECIMAL(5,2) NULL,
    acceptance_rate             DECIMAL(5,2) NULL,
    completed_stays             INT UNSIGNED NULL,
    completed_nights            INT UNSIGNED NULL,
    avg_rating                  DECIMAL(3,2) NULL,
    passed_response_rate        TINYINT(1) NULL,
    passed_acceptance_rate      TINYINT(1) NULL,
    passed_stays_or_nights      TINYINT(1) NULL,
    passed_rating               TINYINT(1) NULL,
    is_superhost_awarded        TINYINT(1) NULL,
    assessed_at                 TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_superhost_host FOREIGN KEY (host_id) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- SECTION 17: ANALYTICS EVENTS
-- =============================================================================

CREATE TABLE analytics_events (
    id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    event_type      VARCHAR(100) NOT NULL COMMENT 'search, listing_view, booking_started, booking_completed',
    user_id         CHAR(36) NULL,
    session_id      VARCHAR(100) NULL,
    listing_id      CHAR(36) NULL,
    booking_id      CHAR(36) NULL,
    properties      JSON NULL,
    device_type     VARCHAR(50) NULL COMMENT 'android, ios, web',
    ip_address      VARCHAR(45) NULL,
    created_at      TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    KEY idx_analytics_event_type (event_type, created_at),
    KEY idx_analytics_user       (user_id, created_at),
    CONSTRAINT fk_analytics_user    FOREIGN KEY (user_id)    REFERENCES users(id),
    CONSTRAINT fk_analytics_listing FOREIGN KEY (listing_id) REFERENCES listings(id),
    CONSTRAINT fk_analytics_booking FOREIGN KEY (booking_id) REFERENCES bookings(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- SECTION 18: SYSTEM AUDIT LOGS
-- =============================================================================

CREATE TABLE system_audit_logs (
    id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    table_name      VARCHAR(100) NOT NULL,
    record_id       TEXT NOT NULL,
    operation       CHAR(1) NOT NULL COMMENT 'I=Insert, U=Update, D=Delete',
    old_data        JSON NULL,
    new_data        JSON NULL,
    changed_by      CHAR(36) NULL,
    changed_at      TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- SECTION 19: FEATURE FLAGS
-- =============================================================================

CREATE TABLE feature_flags (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    flag_key        VARCHAR(200) NOT NULL,
    description     TEXT NULL,
    is_enabled      TINYINT(1) NOT NULL DEFAULT 0,
    rollout_pct     TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '0–100 percent of users',
    user_segment    JSON NULL,
    updated_by      CHAR(36) NULL,
    updated_at      TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_feature_flags_key (flag_key),
    CONSTRAINT fk_feature_flags_user FOREIGN KEY (updated_by) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- SECTION 20: SYSTEM CONFIGURATION
-- =============================================================================

CREATE TABLE system_configs (
    `key`       VARCHAR(200) NOT NULL PRIMARY KEY,
    value       TEXT NOT NULL,
    value_type  VARCHAR(20) NOT NULL DEFAULT 'string' COMMENT 'string, integer, boolean, json',
    description TEXT NULL,
    updated_by  CHAR(36) NULL,
    updated_at  TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_system_configs_user FOREIGN KEY (updated_by) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- SECTION 21: VIEWS FOR COMMON QUERIES
-- =============================================================================

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
    d.name_en   AS district_name,
    dv.name_en  AS division_name,
    u.id        AS host_id,
    u.display_name AS host_name,
    u.profile_photo_url AS host_photo,
    u.is_superhost,
    (SELECT lp.url FROM listing_photos lp WHERE lp.listing_id = l.id AND lp.is_cover = 1 LIMIT 1) AS cover_photo
FROM listings l
JOIN users     u  ON l.host_id     = u.id
JOIN districts d  ON l.district_id = d.id
JOIN divisions dv ON l.division_id = dv.id
WHERE l.status = 'active' AND l.deleted_at IS NULL;

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
    (SELECT lp.url FROM listing_photos lp WHERE lp.listing_id = l.id AND lp.is_cover = 1 LIMIT 1) AS listing_photo,
    u.display_name AS host_name
FROM bookings b
JOIN listings l ON b.listing_id = l.id
JOIN users    u ON b.host_id    = u.id;

CREATE OR REPLACE VIEW v_host_earnings AS
SELECT
    p.host_id,
    COUNT(*)                            AS total_payouts,
    SUM(p.gross_amount)                 AS total_gross,
    SUM(p.platform_fee)                 AS total_fees,
    SUM(p.tds_withheld)                 AS total_tds,
    SUM(p.net_amount)                   AS total_net,
    DATE_FORMAT(p.created_at, '%Y-%m') AS month
FROM payouts p
WHERE p.status = 'completed'
GROUP BY p.host_id, DATE_FORMAT(p.created_at, '%Y-%m');

-- =============================================================================
-- SECTION 22: ADDITIONAL INDEXES
-- =============================================================================

CREATE INDEX idx_users_mobile       ON users(mobile_number);
CREATE INDEX idx_users_email        ON users(email);

-- MariaDB full-text search on listings (replaces PostgreSQL GIN/tsvector)
-- Note: already defined inline on the table; kept here for documentation.
-- ALTER TABLE listings ADD FULLTEXT INDEX idx_listings_ft (title_en, title_bn, description_en);

SET FOREIGN_KEY_CHECKS = 1;

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
-- SEED DATA: System Configs
-- =============================================================================

INSERT INTO system_configs (`key`, value, value_type, description) VALUES
('default_currency',             'BDT',          'string',  'Platform currency'),
('default_language',             'bn',            'string',  'Default UI language (bn or en)'),
('booking_hold_hours',           '24',            'integer', 'Hours payment is held before releasing to host after check-in'),
('host_approval_deadline_hours', '24',            'integer', 'Hours host has to respond to a booking request'),
('review_window_days',           '14',            'integer', 'Days after checkout in which reviews can be submitted'),
('max_listing_photos',           '50',            'integer', 'Maximum photos per listing'),
('superhost_min_rating',         '4.8',           'string',  'Minimum average rating for Superhost'),
('superhost_min_response_rate',  '90',            'integer', 'Minimum response rate % for Superhost'),
('superhost_min_acceptance_rate','90',            'integer', 'Minimum acceptance rate % for Superhost'),
('superhost_min_stays',          '10',            'integer', 'Minimum completed stays per year for Superhost'),
('platform_support_phone',       '16XXX',         'string',  'Bangladesh customer support number'),
('sms_gateway_provider',         'ssl_wireless',  'string',  'Active SMS gateway'),
('payout_retry_max',             '3',             'integer', 'Max payout retry attempts');

-- =============================================================================
-- SEED DATA: Core Amenities (Bangladesh-specific)
-- =============================================================================

INSERT INTO amenities (category, name_en, name_bn, is_highlight) VALUES
-- Basics
('basics',              'WiFi',                          'ওয়াইফাই',                   1),
('basics',              'Air Conditioning (AC)',          'এয়ার কন্ডিশনার',           1),
('basics',              'Ceiling Fan',                    'সিলিং ফ্যান',               0),
('basics',              'TV',                             'টেলিভিশন',                  0),
('basics',              'Washing Machine',                'ওয়াশিং মেশিন',              0),
-- Power (Bangladesh-specific)
('power',               'Generator Backup',               'জেনারেটর ব্যাকআপ',          1),
('power',               'IPS / Inverter Backup',          'আইপিএস / ইনভার্টার',        1),
('power',               'Solar Power',                    'সোলার বিদ্যুৎ',              0),
-- Kitchen
('kitchen',             'Kitchen',                        'রান্নাঘর',                   1),
('kitchen',             'Gas Stove (Cylinder)',            'গ্যাস চুলা (সিলিন্ডার)',    0),
('kitchen',             'Gas Stove (Piped)',               'গ্যাস চুলা (পাইপড)',        0),
('kitchen',             'Microwave',                      'মাইক্রোওয়েভ',               0),
('kitchen',             'Refrigerator',                   'রেফ্রিজারেটর',              0),
-- Water
('water',               'WASA Water Supply',              'ওয়াসার পানি',               0),
('water',               'Deep Tube Well Water',           'গভীর নলকূপের পানি',         0),
('water',               'Water Filter / Purifier',        'পানি ফিল্টার',              0),
-- Safety
('safety',              'Smoke Detector',                 'স্মোক ডিটেক্টর',             0),
('safety',              'Fire Extinguisher',              'ফায়ার এক্সটিংগুইশার',       0),
('safety',              'First Aid Kit',                  'প্রাথমিক চিকিৎসা কিট',      0),
('safety',              'CCTV (Common Areas)',            'সিসিটিভি',                  0),
('safety',              '24-hour Security Guard',         '২৪ ঘণ্টা নিরাপত্তা',       0),
-- Bangladesh-specific
('bangladesh_specific', 'Mosquito Net',                   'মশারি',                     1),
('bangladesh_specific', 'Mosquito Repellent',             'মশা তাড়ানোর স্প্রে',       0),
('bangladesh_specific', 'Prayer Mat & Qibla Direction',   'জায়নামাজ ও কেবলা',         1),
('bangladesh_specific', 'Ramadan Sehri Alarm',            'সেহরির অ্যালার্ম',          0),
('bangladesh_specific', 'Rooftop Access',                 'ছাদে প্রবেশাধিকার',         1),
('bangladesh_specific', 'Balcony',                        'বারান্দা',                   1),
-- Outdoor / Parking
('outdoor',             'Free Parking',                   'বিনামূল্যে পার্কিং',        1),
('outdoor',             'Private Pool',                   'প্রাইভেট পুল',              0),
('outdoor',             'Garden',                         'বাগান',                     0),
('outdoor',             'Lift / Elevator',                'লিফট',                      0);

-- =============================================================================
-- END OF SCHEMA
-- Total tables: 46 | Views: 3
-- MariaDB 10.11+ compatible | Laravel 12 conventions
-- UTF8MB4 throughout for full Bangla Unicode + emoji support
-- =============================================================================
