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
        Schema::create('admin_users', function (Blueprint $table) {
            $table->char('user_id', 36)->primary();
            $table->unsignedSmallInteger('admin_role_id');
            $table->char('assigned_by', 36)->nullable();
            $table->timestamp('assigned_at')->nullable()->useCurrent();
            $table->boolean('is_active')->default(true);

            // Foreign keys
            $table->foreign('user_id')
                ->references('id')
                ->on('users');

            $table->foreign('admin_role_id')
                ->references('id')
                ->on('admin_roles');

            $table->foreign('assigned_by')
                ->references('id')
                ->on('users');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('admin_users');
    }
};
