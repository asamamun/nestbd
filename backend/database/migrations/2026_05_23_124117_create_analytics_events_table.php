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
        Schema::create('analytics_events', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->string('event_type', 100)->comment('search, listing_view, booking_started, booking_completed');
            $table->char('user_id', 36)->nullable();
            $table->string('session_id', 100)->nullable();
            $table->char('listing_id', 36)->nullable();
            $table->char('booking_id', 36)->nullable();
            $table->json('properties')->nullable();
            $table->string('device_type', 50)->nullable()->comment('android, ios, web');
            $table->string('ip_address', 45)->nullable();
            $table->timestamp('created_at')->nullable()->useCurrent();

            // Indexes
            $table->index(['event_type', 'created_at'], 'idx_analytics_event_type');
            $table->index(['user_id', 'created_at'], 'idx_analytics_user');

            // Foreign keys
            $table->foreign('user_id')
                ->references('id')
                ->on('users');

            $table->foreign('listing_id')
                ->references('id')
                ->on('listings');

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
        Schema::dropIfExists('analytics_events');
    }
};
