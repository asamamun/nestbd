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
        Schema::create('listing_house_rules', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->char('listing_id', 36);
            $table->string('rule_key', 100)->nullable()->comment('no_smoking, no_pets, no_parties, quiet_hours');
            $table->text('rule_text_en');
            $table->text('rule_text_bn')->nullable();
            $table->smallInteger('sort_order')->default(0);

            // Foreign keys
            $table->foreign('listing_id')
                ->references('id')
                ->on('listings')
                ->onDelete('cascade');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('listing_house_rules');
    }
};
