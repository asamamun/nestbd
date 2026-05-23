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
        Schema::create('messages', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->char('conversation_id', 36);
            $table->char('sender_id', 36);
            $table->text('body_original');
            $table->text('body_translated')->nullable();
            $table->char('original_language', 2)->nullable()->comment('bn, en');
            $table->char('translated_language', 2)->nullable();
            $table->text('attachment_url')->nullable();
            $table->string('attachment_type', 50)->nullable()->comment('image, document');
            $table->boolean('is_system_message')->default(false);
            $table->boolean('is_read')->default(false);
            $table->timestamp('read_at')->nullable();
            $table->boolean('is_flagged')->default(false);
            $table->timestamp('created_at')->nullable()->useCurrent();

            // Indexes
            $table->index(['conversation_id', 'created_at'], 'idx_messages_conversation');

            // Foreign keys
            $table->foreign('conversation_id')
                ->references('id')
                ->on('conversations')
                ->onDelete('cascade');

            $table->foreign('sender_id')
                ->references('id')
                ->on('users');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('messages');
    }
};
