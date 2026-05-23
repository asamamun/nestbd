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
        Schema::create('admin_role_permissions', function (Blueprint $table) {
            $table->unsignedSmallInteger('role_id');
            $table->unsignedSmallInteger('permission_id');

            // Primary key
            $table->primary(['role_id', 'permission_id']);

            // Foreign keys
            $table->foreign('role_id')
                ->references('id')
                ->on('admin_roles');

            $table->foreign('permission_id')
                ->references('id')
                ->on('admin_permissions');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('admin_role_permissions');
    }
};
