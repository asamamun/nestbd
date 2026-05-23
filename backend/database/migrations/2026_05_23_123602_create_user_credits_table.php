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
        Schema::create('user_credits', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->char('user_id', 36);
            $table->decimal('amount', 12, 2)->comment('positive = credit, negative = debit');
            $table->decimal('balance_after', 12, 2);
            $table->text('reason');
            $table->string('reference_type', 100)->nullable()->comment('referral, refund, dispute_compensation, promo');
            $table->text('reference_id')->nullable();
            $table->timestamp('expires_at')->nullable();
            $table->char('created_by', 36)->nullable();
            $table->timestamp('created_at')->nullable()->useCurrent();

            // Foreign keys
            $table->foreign('user_id')
                ->references('id')
                ->on('users');

            $table->foreign('created_by')
                ->references('id')
                ->on('users');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('user_credits');
    }
};
