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
        Schema::create('booking_modifications', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->char('booking_id', 36);
            $table->char('requested_by', 36);
            $table->date('original_check_in')->nullable();
            $table->date('original_checkout')->nullable();
            $table->unsignedSmallInteger('original_guests')->nullable();
            $table->date('new_check_in')->nullable();
            $table->date('new_checkout')->nullable();
            $table->unsignedSmallInteger('new_guests')->nullable();
            $table->decimal('price_difference', 12, 2)->nullable();
            $table->string('status', 50)->default('pending')->comment('pending, approved, rejected, withdrawn');
            $table->timestamp('responded_at')->nullable();
            $table->timestamp('created_at')->nullable()->useCurrent();

            // Foreign keys
            $table->foreign('booking_id')
                ->references('id')
                ->on('bookings');

            $table->foreign('requested_by')
                ->references('id')
                ->on('users');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('booking_modifications');
    }
};
