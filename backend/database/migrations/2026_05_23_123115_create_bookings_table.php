<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('bookings', function (Blueprint $table) {
            $table->char('id', 36)->primary();
            $table->string('booking_ref', 20);
            $table->char('listing_id', 36);
            $table->char('guest_id', 36);
            $table->char('host_id', 36);
            $table->enum('status', ['inquiry', 'pending_payment', 'pending_host_approval', 'confirmed', 'cancelled_by_guest', 'cancelled_by_host', 'cancelled_by_admin', 'checked_in', 'completed', 'disputed', 'expired'])->default('inquiry');

            // Dates
            $table->date('check_in_date');
            $table->date('checkout_date');
            $table->unsignedSmallInteger('num_nights');
            $table->unsignedSmallInteger('num_guests')->default(1);

            // Guest details
            $table->json('additional_guest_names')->nullable()->comment('[{name, age}]');
            $table->text('guest_message')->nullable();

            // Pricing snapshot at time of booking
            $table->decimal('price_per_night', 12, 2);
            $table->unsignedSmallInteger('num_nights_charged');
            $table->decimal('nightly_subtotal', 12, 2);
            $table->decimal('cleaning_fee', 12, 2)->default(0.00);
            $table->decimal('extra_guest_fee', 12, 2)->default(0.00);
            $table->decimal('discount_amount', 12, 2)->default(0.00);
            $table->decimal('coupon_discount', 12, 2)->default(0.00);
            $table->decimal('guest_service_fee', 12, 2);
            $table->decimal('host_service_fee', 12, 2);
            $table->decimal('vat_amount', 12, 2)->default(0.00);
            $table->decimal('security_deposit', 12, 2)->default(0.00);
            $table->decimal('total_guest_pays', 12, 2);
            $table->decimal('host_payout_amount', 12, 2);
            $table->decimal('platform_revenue', 12, 2);

            // Cancellation
            $table->enum('cancellation_policy', ['flexible', 'moderate', 'strict', 'super_strict']);
            $table->timestamp('cancelled_at')->nullable();
            $table->text('cancellation_reason')->nullable();
            $table->decimal('refund_amount', 12, 2)->default(0.00);

            // Check-in / out tracking
            $table->timestamp('actual_check_in')->nullable();
            $table->timestamp('actual_checkout')->nullable();
            $table->string('check_in_pin', 20)->nullable();

            // Flags
            $table->boolean('is_instant_book')->default(false);
            $table->timestamp('host_approval_deadline')->nullable();
            $table->timestamp('request_approved_at')->nullable();

            $table->timestamp('created_at')->nullable()->useCurrent();
            $table->timestamp('updated_at')->nullable()->useCurrent()->useCurrentOnUpdate();

            // Indexes
            $table->unique('booking_ref', 'uq_bookings_ref');
            $table->index(['guest_id', 'status'], 'idx_bookings_guest');
            $table->index(['host_id', 'status'], 'idx_bookings_host');
            $table->index(['listing_id', 'check_in_date', 'checkout_date'], 'idx_bookings_listing');
            $table->index(['check_in_date', 'checkout_date'], 'idx_bookings_dates');

            // Foreign keys
            $table->foreign('listing_id')
                ->references('id')
                ->on('listings');

            $table->foreign('guest_id')
                ->references('id')
                ->on('users');

            $table->foreign('host_id')
                ->references('id')
                ->on('users');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('bookings');
    }
};
