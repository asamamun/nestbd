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
        Schema::create('coupon_usages', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->unsignedInteger('coupon_id');
            $table->char('user_id', 36);
            $table->char('booking_id', 36);
            $table->decimal('discount_applied', 12, 2);
            $table->timestamp('used_at')->nullable()->useCurrent();

            // Foreign keys
            $table->foreign('coupon_id')
                ->references('id')
                ->on('coupons');

            $table->foreign('user_id')
                ->references('id')
                ->on('users');

            $table->foreign('booking_id')
                ->references('id')
                ->on('bookings');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('coupon_usages');
    }
};
