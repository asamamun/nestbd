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
        Schema::create('refunds', function (Blueprint $table) {
            $table->char('id', 36)->primary();
            $table->char('payment_id', 36);
            $table->char('booking_id', 36);
            $table->char('initiated_by', 36);
            $table->decimal('amount', 12, 2);
            $table->char('currency', 3)->default('BDT');
            $table->text('reason')->nullable();
            $table->enum('status', ['initiated', 'pending', 'completed', 'failed', 'refunded', 'partially_refunded', 'disputed'])->default('pending');
            $table->string('gateway_refund_id', 255)->nullable();
            $table->timestamp('processed_at')->nullable();
            $table->timestamp('created_at')->nullable()->useCurrent();

            // Foreign keys
            $table->foreign('payment_id')
                ->references('id')
                ->on('payments');

            $table->foreign('booking_id')
                ->references('id')
                ->on('bookings');

            $table->foreign('initiated_by')
                ->references('id')
                ->on('users');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('refunds');
    }
};
