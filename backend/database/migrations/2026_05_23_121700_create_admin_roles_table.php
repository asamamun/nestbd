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
        Schema::create('admin_roles', function (Blueprint $table) {
            $table->smallIncrements('id');
            $table->string('name', 100);
            $table->text('description')->nullable();
            $table->timestamp('created_at')->nullable()->useCurrent();

            // Indexes
            $table->unique('name', 'uq_admin_roles_name');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('admin_roles');
    }
};
