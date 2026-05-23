<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('listings', function (Blueprint $table) {
            $table->char('id', 36)->primary();
            $table->char('host_id', 36);
            $table->enum('status', ['draft', 'pending_review', 'active', 'inactive', 'suspended', 'deleted'])->default('draft');

            // Classification
            $table->enum('property_type', ['entire_place', 'private_room', 'shared_room', 'hotel_room']);
            $table->enum('property_subtype', ['apartment', 'house', 'villa', 'guesthouse', 'resort_cabin', 'houseboat', 'tree_house', 'beach_hut', 'tea_garden_cottage', 'hostel', 'boutique_hotel', 'serviced_apartment', 'farmhouse', 'other'])->default('apartment');

            // Content
            $table->string('title_en', 255);
            $table->string('title_bn', 255)->nullable();
            $table->text('description_en');
            $table->text('description_bn')->nullable();
            $table->text('space_description_en')->nullable();
            $table->text('space_description_bn')->nullable();
            $table->text('neighborhood_description_en')->nullable();
            $table->text('neighborhood_description_bn')->nullable();
            $table->text('getting_around_en')->nullable();
            $table->text('getting_around_bn')->nullable();

            // Location
            $table->unsignedSmallInteger('division_id');
            $table->unsignedSmallInteger('district_id');
            $table->unsignedSmallInteger('upazila_id')->nullable();
            $table->unsignedSmallInteger('thana_id')->nullable();
            $table->unsignedInteger('area_id')->nullable();
            $table->text('address_line1');
            $table->text('address_line2')->nullable();
            $table->string('postal_code', 10)->nullable();
            $table->decimal('latitude', 10, 8);
            $table->decimal('longitude', 11, 8);
            $table->boolean('exact_address_visible')->default(false);

            // Capacity
            $table->unsignedSmallInteger('max_guests')->default(1);
            $table->unsignedSmallInteger('num_bedrooms')->default(1);
            $table->unsignedSmallInteger('num_beds')->default(1);
            $table->decimal('num_bathrooms', 3, 1)->default(1.0);

            // Pricing
            $table->decimal('price_per_night', 12, 2);
            $table->decimal('weekend_price', 12, 2)->nullable()->comment('Thu/Fri premium');
            $table->decimal('cleaning_fee', 12, 2)->default(0.00);
            $table->decimal('extra_guest_fee', 12, 2)->default(0.00);
            $table->unsignedSmallInteger('extra_guest_after')->default(1);
            $table->decimal('security_deposit', 12, 2)->default(0.00);
            $table->unsignedSmallInteger('min_nights')->default(1);
            $table->unsignedSmallInteger('max_nights')->default(365);
            $table->decimal('weekly_discount_pct', 5, 2)->default(0.00);
            $table->decimal('monthly_discount_pct', 5, 2)->default(0.00);

            // Booking settings
            $table->boolean('instant_book_enabled')->default(false);
            $table->enum('cancellation_policy', ['flexible', 'moderate', 'strict', 'super_strict'])->default('moderate');
            $table->unsignedSmallInteger('advance_notice_hours')->default(24);
            $table->unsignedSmallInteger('preparation_time_days')->default(0);
            $table->time('check_in_start')->default('14:00:00');
            $table->time('check_in_end')->default('22:00:00');
            $table->time('checkout_time')->default('11:00:00');
            $table->enum('check_in_method', ['host_greets', 'self_checkin_keypad', 'self_checkin_lockbox', 'self_checkin_qr', 'other'])->default('host_greets');
            $table->text('check_in_instructions')->nullable();

            // Guest requirements
            $table->boolean('require_verified_phone')->default(false);
            $table->boolean('require_verified_id')->default(false);
            $table->unsignedSmallInteger('require_min_reviews')->default(0);

            // Bangladesh-specific
            $table->boolean('tourist_police_reg_required')->default(false);
            $table->string('unmarried_couple_policy', 20)->default('allowed')->comment('allowed, id_required, not_allowed');
            $table->boolean('eid_pricing_enabled')->default(false);

            // Moderation
            $table->text('moderation_notes')->nullable();
            $table->char('moderated_by', 36)->nullable();
            $table->timestamp('moderated_at')->nullable();

            // Denormalised performance counters
            $table->unsignedInteger('total_reviews')->default(0);
            $table->decimal('avg_rating', 3, 2)->nullable();
            $table->decimal('avg_cleanliness', 3, 2)->nullable();
            $table->decimal('avg_accuracy', 3, 2)->nullable();
            $table->decimal('avg_checkin', 3, 2)->nullable();
            $table->decimal('avg_communication', 3, 2)->nullable();
            $table->decimal('avg_location', 3, 2)->nullable();
            $table->decimal('avg_value', 3, 2)->nullable();
            $table->unsignedInteger('total_bookings')->default(0);
            $table->unsignedInteger('wishlist_count')->default(0);

            $table->boolean('is_featured')->default(false);
            $table->smallInteger('search_rank_boost')->default(0);

            $table->timestamp('created_at')->nullable()->useCurrent();
            $table->timestamp('updated_at')->nullable()->useCurrent()->useCurrentOnUpdate();
            $table->timestamp('published_at')->nullable();
            $table->softDeletes();

            // Indexes
            $table->index('host_id', 'idx_listings_host');
            $table->index(['status', 'deleted_at'], 'idx_listings_status');
            $table->index(['district_id', 'status'], 'idx_listings_district');
            $table->index('price_per_night', 'idx_listings_price');
            $table->fullText(['title_en', 'description_en'], 'idx_listings_search');

            // Foreign keys
            $table->foreign('host_id')
                ->references('id')
                ->on('users');

            $table->foreign('division_id')
                ->references('id')
                ->on('divisions');

            $table->foreign('district_id')
                ->references('id')
                ->on('districts');

            $table->foreign('upazila_id')
                ->references('id')
                ->on('upazilas');

            $table->foreign('thana_id')
                ->references('id')
                ->on('thanas');

            $table->foreign('area_id')
                ->references('id')
                ->on('areas');

            $table->foreign('moderated_by')
                ->references('id')
                ->on('users');
        });

        // Add POINT spatial column after table creation
        DB::statement('ALTER TABLE listings ADD COLUMN location_point POINT NOT NULL DEFAULT (POINT(0, 0)) AFTER longitude');
        DB::statement('ALTER TABLE listings ADD SPATIAL INDEX idx_listings_location (location_point)');
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('listings');
    }
};
