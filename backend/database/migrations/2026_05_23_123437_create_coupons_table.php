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
        Schema::create('coupons', function (Blueprint $table) {
            $table->unsignedInteger('id')->primary();
            $table->string('code', 50);
            $table->text('description_en')->nullable();
            $table->text('description_bn')->nullable();
            $table->enum('discount_type', ['flat_bdt', 'percentage']);
            $table->decimal('discount_value', 12, 2);
            $table->decimal('max_discount_bdt', 12, 2)->nullable();
            $table->decimal('min_booking_amount', 12, 2)->default(0.00);
            $table->integer('usage_limit_total')->nullable()->comment('NULL = unlimited');
            $table->unsignedSmallInteger('usage_limit_per_user')->default(1);
            $table->unsignedInteger('current_usage_count')->default(0);
            $table->timestamp('valid_from');
            $table->timestamp('valid_to')->nullable();
            $table->json('applicable_property_ids')->nullable()->comment('JSON array of listing UUIDs; NULL = all');
            $table->char('created_by', 36)->nullable();
            $table->boolean('is_active')->default(true);
            $table->timestamp('created_at')->nullable()->useCurrent();

            // Indexes
            $table->unique('code', 'uq_coupons_code');

            // Foreign keys
            $table->foreign('created_by')
                ->references('id')
                ->on('users');
        });

        // Add foreign key from payments to coupons
        Schema::table('payments', function (Blueprint $table) {
            $table->foreign('coupon_id')
                ->references('id')
                ->on('coupons');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('payments', function (Blueprint $table) {
            $table->dropForeign(['coupon_id']);
        });

        Schema::dropIfExists('coupons');
    }
};
