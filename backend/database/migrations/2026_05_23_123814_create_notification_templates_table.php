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
        Schema::create('notification_templates', function (Blueprint $table) {
            $table->unsignedInteger('id')->primary();
            $table->string('event_key', 200)->comment('booking_confirmed, review_reminder, etc.');
            $table->enum('channel', ['push', 'sms', 'email', 'in_app']);
            $table->char('language', 2)->default('en');
            $table->string('subject', 255)->nullable();
            $table->text('body_template');
            $table->boolean('is_active')->default(true);
            $table->timestamp('updated_at')->nullable()->useCurrent()->useCurrentOnUpdate();

            // Indexes
            $table->unique('event_key', 'uq_notif_template_key');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('notification_templates');
    }
};
