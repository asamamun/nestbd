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
        Schema::create('dispute_messages', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->unsignedInteger('dispute_id');
            $table->char('sender_id', 36);
            $table->text('message');
            $table->boolean('is_internal')->default(false)->comment('admin-only internal note');
            $table->timestamp('created_at')->nullable()->useCurrent();

            // Foreign keys
            $table->foreign('dispute_id')
                ->references('id')
                ->on('disputes');

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
        Schema::dropIfExists('dispute_messages');
    }
};
