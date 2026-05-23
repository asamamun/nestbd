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
        Schema::create('referrals', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->char('referrer_id', 36);
            $table->char('referee_id', 36);
            $table->decimal('referrer_bonus_bdt', 12, 2)->default(0.00);
            $table->decimal('referee_bonus_bdt', 12, 2)->default(0.00);
            $table->string('status', 50)->default('pending')->comment('pending, credited, expired');
            $table->char('qualifying_booking_id', 36)->nullable();
            $table->timestamp('credited_at')->nullable();
            $table->timestamp('created_at')->nullable()->useCurrent();

            // Foreign keys
            $table->foreign('referrer_id')
                ->references('id')
                ->on('users');

            $table->foreign('referee_id')
                ->references('id')
                ->on('users');

            $table->foreign('qualifying_booking_id')
                ->references('id')
                ->on('bookings');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('referrals');
    }
};
