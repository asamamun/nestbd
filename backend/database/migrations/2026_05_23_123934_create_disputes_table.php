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
        Schema::create('disputes', function (Blueprint $table) {
            $table->unsignedInteger('id')->primary();
            $table->char('booking_id', 36);
            $table->enum('raised_by', ['guest', 'host', 'admin']);
            $table->char('raised_by_user_id', 36);
            $table->string('category', 100)->comment('property_not_as_described, safety_concern, payment_issue, host_cancelled_late');
            $table->text('description');
            $table->enum('status', ['open', 'under_review', 'awaiting_evidence', 'resolved', 'escalated', 'closed'])->default('open');
            $table->enum('ruling', ['favour_guest', 'favour_host', 'partial_refund', 'no_action', 'pending'])->default('pending');
            $table->char('assigned_admin_id', 36)->nullable();
            $table->decimal('guest_refund_amount', 12, 2)->default(0.00);
            $table->decimal('host_deduction_amount', 12, 2)->default(0.00);
            $table->text('admin_notes')->nullable();
            $table->text('resolution_summary')->nullable();
            $table->timestamp('sla_deadline')->nullable();
            $table->timestamp('resolved_at')->nullable();
            $table->timestamp('created_at')->nullable()->useCurrent();
            $table->timestamp('updated_at')->nullable()->useCurrent()->useCurrentOnUpdate();

            // Indexes
            $table->index('booking_id', 'idx_disputes_booking');
            $table->index(['assigned_admin_id', 'status'], 'idx_disputes_admin');

            // Foreign keys
            $table->foreign('booking_id')
                ->references('id')
                ->on('bookings');

            $table->foreign('raised_by_user_id')
                ->references('id')
                ->on('users');

            $table->foreign('assigned_admin_id')
                ->references('id')
                ->on('users');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('disputes');
    }
};
