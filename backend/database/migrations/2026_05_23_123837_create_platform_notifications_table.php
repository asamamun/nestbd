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
        Schema::create('platform_notifications', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->char('user_id', 36);
            $table->unsignedInteger('template_id')->nullable();
            $table->enum('channel', ['push', 'sms', 'email', 'in_app']);
            $table->enum('status', ['pending', 'sent', 'delivered', 'failed', 'read'])->default('pending');
            $table->string('subject', 255)->nullable();
            $table->text('body');
            $table->string('reference_type', 100)->nullable();
            $table->text('reference_id')->nullable();
            $table->string('gateway_msg_id', 255)->nullable();
            $table->timestamp('sent_at')->nullable();
            $table->timestamp('delivered_at')->nullable();
            $table->timestamp('read_at')->nullable();
            $table->text('failed_reason')->nullable();
            $table->timestamp('created_at')->nullable()->useCurrent();

            // Indexes
            $table->index(['user_id', 'status', 'created_at'], 'idx_notifications_user');

            // Foreign keys
            $table->foreign('user_id')
                ->references('id')
                ->on('users');

            $table->foreign('template_id')
                ->references('id')
                ->on('notification_templates');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('platform_notifications');
    }
};
