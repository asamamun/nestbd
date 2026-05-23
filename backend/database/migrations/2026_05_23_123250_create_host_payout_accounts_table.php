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
        Schema::create('host_payout_accounts', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->char('host_id', 36);
            $table->enum('method', ['bkash', 'nagad', 'rocket', 'visa', 'mastercard', 'internet_banking', 'bank_transfer', 'cash_on_arrival', 'platform_credit']);
            $table->string('account_name', 200);
            $table->string('account_number', 100)->nullable();
            $table->string('bank_name', 200)->nullable();
            $table->string('branch_name', 200)->nullable();
            $table->string('routing_number', 20)->nullable();
            $table->boolean('is_primary')->default(true);
            $table->boolean('is_verified')->default(false);
            $table->timestamp('created_at')->nullable()->useCurrent();

            // Foreign keys
            $table->foreign('host_id')
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
        Schema::dropIfExists('host_payout_accounts');
    }
};
