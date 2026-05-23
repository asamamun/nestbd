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
        Schema::create('payments', function (Blueprint $table) {
            $table->char('id', 36)->primary();
            $table->char('booking_id', 36);
            $table->char('payer_id', 36);
            $table->enum('payment_method', ['bkash', 'nagad', 'rocket', 'visa', 'mastercard', 'internet_banking', 'bank_transfer', 'cash_on_arrival', 'platform_credit']);
            $table->enum('status', ['initiated', 'pending', 'completed', 'failed', 'refunded', 'partially_refunded', 'disputed'])->default('initiated');

            $table->decimal('amount', 12, 2);
            $table->char('currency', 3)->default('BDT');

            // Gateway details
            $table->string('gateway_name', 50)->nullable()->comment('sslcommerz, bkash_pgw, nagad_pgw');
            $table->string('gateway_transaction_id', 255)->nullable();
            $table->string('gateway_ref_id', 255)->nullable();
            $table->json('gateway_response')->nullable();

            // Mobile banking
            $table->string('mobile_number', 20)->nullable();

            // Tokenised card (no raw card data)
            $table->char('card_last_four', 4)->nullable();
            $table->string('card_brand', 20)->nullable();

            $table->unsignedInteger('coupon_id')->nullable();
            $table->timestamp('initiated_at')->nullable()->useCurrent();
            $table->timestamp('completed_at')->nullable();
            $table->text('failed_reason')->nullable();
            $table->text('receipt_url')->nullable();

            // Indexes
            $table->index('booking_id', 'idx_payments_booking');
            $table->index('status', 'idx_payments_status');

            // Foreign keys
            $table->foreign('booking_id')
                ->references('id')
                ->on('bookings');

            $table->foreign('payer_id')
                ->references('id')
                ->on('users');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('payments');
    }
};
