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
        Schema::create('user_oauth_accounts', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->char('user_id', 36);
            $table->string('provider', 30);
            $table->string('provider_uid', 255);
            $table->text('access_token')->nullable();
            $table->text('refresh_token')->nullable();
            $table->timestamp('token_expires')->nullable();
            $table->timestamp('created_at')->nullable()->useCurrent();

            // Indexes
            $table->unique(['provider', 'provider_uid'], 'uq_oauth_provider_uid');

            // Foreign keys
            $table->foreign('user_id')
                ->references('id')
                ->on('users')
                ->onDelete('cascade');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('user_oauth_accounts');
    }
};
