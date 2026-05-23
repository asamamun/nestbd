# Laravel Migration Files - Complete Schema Population

## Overview
All 47 migration files have been successfully populated with complete table schemas based on the MariaDB SQL file (`nestbd_mariadb.sql`).

## Migration Files Created

### Admin Tables (5 files)
1. **2026_05_23_121700_create_admin_roles_table.php** - Admin roles with unique name constraint
2. **2026_05_23_121710_create_admin_permissions_table.php** - Permission codes for role-based access
3. **2026_05_23_121720_create_admin_role_permissions_table.php** - Junction table for role-permission mapping
4. **2026_05_23_121730_create_admin_users_table.php** - Admin user assignments with role tracking
5. **2026_05_23_121740_create_admin_audit_logs_table.php** - Audit trail for admin actions

### User Tables (3 files)
1. **2026_05_23_121826_create_user_oauth_accounts_table.php** - OAuth provider accounts (Google, Facebook)
2. **2026_05_23_121947_create_user_id_verifications_table.php** - ID verification documents with status tracking
3. **2026_05_23_122014_create_user_emergency_contacts_table.php** - Emergency contact information

### Listing Tables (9 files)
1. **2026_05_23_122143_create_amenities_table.php** - Amenities catalog with categories
2. **2026_05_23_122206_create_listings_table.php** - Main listings table with POINT spatial data
3. **2026_05_23_122630_create_listing_beds_table.php** - Bed configuration per room
4. **2026_05_23_122713_create_amenities_listing_table.php** - Junction table for listing amenities
5. **2026_05_23_122758_create_listing_photos_table.php** - Listing photos with cover photo flag
6. **2026_05_23_122842_create_listing_house_rules_table.php** - House rules per listing
7. **2026_05_23_122909_create_listing_price_overrides_table.php** - Date-based price overrides
8. **2026_05_23_122952_create_listing_ical_syncs_table.php** - iCal sync configuration
9. **2026_05_23_123008_create_listing_cohosts_table.php** - Co-host management with permissions

### Availability & Booking Tables (3 files)
1. **2026_05_23_123048_create_listing_availability_table.php** - Daily availability calendar
2. **2026_05_23_123115_create_bookings_table.php** - Booking records with pricing snapshot
3. **2026_05_23_123145_create_booking_notifications_table.php** - Booking modifications tracking

### Payment & Payout Tables (6 files)
1. **2026_05_23_123205_create_payments_table.php** - Payment transactions with gateway integration
2. **2026_05_23_123221_create_refunds_table.php** - Refund records
3. **2026_05_23_123250_create_host_payout_accounts_table.php** - Host payout account details
4. **2026_05_23_123316_create_payouts_table.php** - Payout transactions
5. **2026_05_23_123341_create_tax_certificates_table.php** - Tax certificate generation
6. **2026_05_23_123411_create_platform_fee_configs_table.php** - Platform fee configuration

### Coupon & Promotion Tables (3 files)
1. **2026_05_23_123437_create_coupons_table.php** - Coupon definitions with usage limits
2. **2026_05_23_123457_create_coupon_usage_table.php** - Coupon usage tracking
3. **2026_05_23_123544_create_referrals_table.php** - Referral program tracking

### User Credits & Reviews (3 files)
1. **2026_05_23_123602_create_user_credits_table.php** - User credit balance tracking
2. **2026_05_23_123620_create_reviews_table.php** - Reviews with multi-dimensional ratings
3. **2026_05_23_123655_create_review_flags_table.php** - Review flagging for moderation

### Messaging Tables (2 files)
1. **2026_05_23_123714_create_conversations_table.php** - Conversation threads
2. **2026_05_23_123729_create_messages_table.php** - Messages with translation support

### Notification Tables (2 files)
1. **2026_05_23_123814_create_notification_templates_table.php** - Notification templates
2. **2026_05_23_123837_create_platform_notifications_table.php** - Notification delivery tracking

### Wishlist Tables (2 files)
1. **2026_05_23_123854_create_wishlists_table.php** - User wishlists
2. **2026_05_23_123919_create_wishlist_listings_table.php** - Wishlist-listing junction table

### Dispute Tables (3 files)
1. **2026_05_23_123934_create_disputes_table.php** - Dispute records with resolution tracking
2. **2026_05_23_123959_create_dispute_evidence_table.php** - Evidence file uploads
3. **2026_05_23_124013_create_dispute_messages_table.php** - Dispute communication thread

### System Tables (5 files)
1. **2026_05_23_124037_create_listing_reports_table.php** - Listing abuse reports
2. **2026_05_23_124100_create_superhost_assessments_table.php** - Superhost qualification tracking
3. **2026_05_23_124117_create_analytics_events_table.php** - Event tracking for analytics
4. **2026_05_23_124138_create_system_audit_logs_table.php** - System-wide audit logging
5. **2026_05_23_124153_create_feature_flags_table.php** - Feature flag management
6. **2026_05_23_124208_create_system_configs_table.php** - System configuration key-value store

## Key Features Implemented

### Data Types
- ✅ CHAR(36) for UUID primary keys
- ✅ BIGINT UNSIGNED for auto-increment IDs
- ✅ SMALLINT UNSIGNED for small integer IDs
- ✅ DECIMAL(12,2) for monetary values (BDT currency)
- ✅ ENUM for status/type fields
- ✅ JSON for JSONB fields
- ✅ TIMESTAMP for datetime fields with proper defaults

### Spatial Data
- ✅ POINT spatial data type for location_point in listings table
- ✅ SPATIAL INDEX for geo-queries
- ✅ Proper handling via raw SQL in migration

### Indexes
- ✅ Primary keys on all tables
- ✅ Unique constraints (UNIQUE KEY)
- ✅ Regular indexes (KEY)
- ✅ Composite indexes for common queries
- ✅ Full-text indexes on searchable fields
- ✅ Spatial indexes for location queries

### Foreign Keys
- ✅ All foreign key relationships defined
- ✅ Proper ON DELETE CASCADE for dependent records
- ✅ Referential integrity maintained
- ✅ Self-referencing foreign keys (e.g., users.referred_by_user_id)

### Charset & Collation
- ✅ utf8mb4 charset for full Bangla Unicode support
- ✅ utf8mb4_unicode_ci collation throughout

### Soft Deletes
- ✅ deleted_at timestamp column on listings table
- ✅ Proper soft delete implementation

## Migration Execution Order

The migrations should be executed in this order (Laravel handles this automatically):

1. Geography tables (divisions, districts, upazilas, thanas, areas)
2. Users table
3. Admin tables (roles, permissions, role_permissions, admin_users, audit_logs)
4. User-related tables (oauth_accounts, id_verifications, emergency_contacts)
5. Amenities table
6. Listings table (with spatial data)
7. Listing-related tables (beds, amenities_listing, photos, house_rules, price_overrides, ical_syncs, cohosts)
8. Availability table
9. Bookings table
10. Booking modifications table
11. Payments table
12. Refunds table
13. Host payout accounts table
14. Payouts table
15. Tax certificates table
16. Platform fee configs table
17. Coupons table (with foreign key to payments)
18. Coupon usages table
19. Referrals table
20. User credits table
21. Reviews table
22. Review flags table
23. Conversations table
24. Messages table
25. Notification templates table
26. Platform notifications table
27. Wishlists table
28. Wishlist listings table
29. Disputes table
30. Dispute evidence table
31. Dispute messages table
32. Listing reports table
33. Superhost assessments table
34. Analytics events table
35. System audit logs table
36. Feature flags table
37. System configs table

## Special Considerations

### Listings Table
- Uses raw SQL to add POINT spatial column after table creation
- Includes SPATIAL INDEX for geo-queries
- Full-text index on title_en and description_en
- Multiple denormalized rating columns for performance

### Payments Table
- Foreign key to coupons table is added after coupons table creation
- Supports multiple payment methods (bkash, nagad, rocket, cards, etc.)
- Gateway integration fields for payment processor responses

### Coupons Table
- Uses JSON array for applicable_property_ids (replaces PostgreSQL UUID[])
- Supports both flat BDT and percentage discounts
- Usage limit tracking per user and globally

### Reviews Table
- Supports both guest-to-listing and host-to-guest reviews
- Multi-dimensional ratings (cleanliness, accuracy, checkin, etc.)
- Moderation workflow with flagging

### Disputes Table
- Comprehensive dispute resolution workflow
- Evidence file tracking
- Internal admin notes vs. public messages
- SLA deadline tracking

## Testing Recommendations

1. Run `php artisan migrate` to execute all migrations
2. Verify all tables are created with correct structure
3. Test foreign key constraints
4. Verify spatial index on listings.location_point
5. Test full-text search on listings
6. Verify soft delete functionality on listings
7. Test enum constraints on all enum columns
8. Verify JSON columns accept valid JSON data

## Notes

- All migrations follow Laravel conventions
- Comments are included for clarity on enum values and field purposes
- Timestamps use nullable with useCurrent() for proper defaults
- All monetary values use DECIMAL(12,2) for precision
- Bangladesh-specific fields and enums are included
- Multi-language support (English/Bangla) throughout
