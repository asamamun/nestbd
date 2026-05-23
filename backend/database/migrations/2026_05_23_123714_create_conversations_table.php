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
        Schema::create('conversations', function (Blueprint $table) {
            $table->char('id', 36)->primary();
            $table->char('booking_id', 36)->nullable();
            $table->char('listing_id', 36)->nullable();
            $table->char('host_id', 36);
            $table->char('guest_id', 36);
            $table->string('subject', 255)->nullable();
            $table->boolean('is_archived')->default(false);
            $table->timestamp('last_message_at')->nullable();
            $table->timestamp('created_at')->nullable()->useCurrent();

            // Indexes
            $table->index('booking_id', 'idx_conversations_booking');

            // Foreign keys
            $table->foreign('booking_id')
                ->references('id')
                ->on('bookings');

            $table->foreign('listing_id')
                ->references('id')
                ->on('listings');

            $table->foreign('host_id')
                ->references('id')
                ->on('users');

            $table->foreign('guest_id')
                ->references('id')
                ->on('users');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('conversations');
    }
};
