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
        Schema::create('payouts', function (Blueprint $table) {
            $table->char('id', 36)->primary();
            $table->char('host_id', 36);
            $table->char('booking_id', 36)->nullable();
            $table->unsignedBigInteger('payout_account_id')->nullable();
            $table->enum('status', ['pending', 'processing', 'completed', 'failed', 'on_hold', 'cancelled'])->default('pending');

            $table->decimal('gross_amount', 12, 2);
            $table->decimal('platform_fee', 12, 2);
            $table->decimal('tds_withheld', 12, 2)->default(0.00);
            $table->decimal('vat_on_fee', 12, 2)->default(0.00);
            $table->decimal('net_amount', 12, 2);
            $table->char('currency', 3)->default('BDT');

            $table->string('gateway_ref_id', 255)->nullable();
            $table->json('gateway_response')->nullable();
            $table->text('failure_reason')->nullable();
            $table->unsignedSmallInteger('retry_count')->default(0);

            $table->timestamp('scheduled_at')->nullable();
            $table->timestamp('processed_at')->nullable();
            $table->timestamp('created_at')->nullable()->useCurrent();

            // Indexes
            $table->index(['host_id', 'status'], 'idx_payouts_host');

            // Foreign keys
            $table->foreign('host_id')
                ->references('id')
                ->on('users');

            $table->foreign('booking_id')
                ->references('id')
                ->on('bookings');

            $table->foreign('payout_account_id')
                ->references('id')
                ->on('host_payout_accounts');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('payouts');
    }
};
