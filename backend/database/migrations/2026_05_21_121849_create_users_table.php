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
        Schema::create('users', function (Blueprint $table) {
            $table->char('id', 36)->primary();
/* 
role                    ENUM('guest','host','both','admin') NOT NULL DEFAULT 'guest',
    status                  ENUM('pending_verification','active','suspended','banned','deactivated','deleted') NOT NULL DEFAULT 'pending_verification',

    -- Basic identity
    first_name              VARCHAR(100) NOT NULL,
    last_name               VARCHAR(100) NULL,
    display_name            VARCHAR(200) NULL,
    email                   VARCHAR(255) NULL,
    mobile_number           VARCHAR(20) NOT NULL,
    date_of_birth           DATE NULL,
    gender                  VARCHAR(20) NULL COMMENT 'male, female, other, prefer_not_to_say',
    profile_photo_url       TEXT NULL,
    bio                     TEXT NULL,
    preferred_language      ENUM('bn','en') NOT NULL DEFAULT 'bn',

    -- Verification flags
    email_verified          TINYINT(1) NOT NULL DEFAULT 0,
    mobile_verified         TINYINT(1) NOT NULL DEFAULT 0,
    id_verified             ENUM('not_submitted','pending','approved','rejected','expired') NOT NULL DEFAULT 'not_submitted',

    -- Address (personal, not property)
    address_line1           TEXT NULL,
    address_line2           TEXT NULL,
    thana_id                SMALLINT UNSIGNED NULL,
    district_id             SMALLINT UNSIGNED NULL,
    division_id             SMALLINT UNSIGNED NULL,
    postal_code             VARCHAR(10) NULL,

    -- Auth
    password_hash           TEXT NULL COMMENT 'NULL if OAuth only',
    last_login_at           TIMESTAMP NULL,
    mfa_enabled             TINYINT(1) NOT NULL DEFAULT 0,
    mfa_secret              TEXT NULL COMMENT 'TOTP secret, encrypt at app level',

    -- Platform metadata
    referral_code           VARCHAR(20) NULL,
    referred_by_user_id     CHAR(36) NULL,
    profile_completeness    TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '0–100 percent',
    is_superhost            TINYINT(1) NOT NULL DEFAULT 0,
    superhost_since         DATE NULL,
    account_notes           TEXT NULL,

    created_at              TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at              TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at              TIMESTAMP NULL,

    UNIQUE KEY uq_users_email         (email),
    UNIQUE KEY uq_users_mobile        (mobile_number),
    UNIQUE KEY uq_users_referral_code (referral_code),
    KEY idx_users_role_status         (role, status),
    CONSTRAINT fk_users_thana         FOREIGN KEY (thana_id)            REFERENCES thanas(id),
    CONSTRAINT fk_users_district      FOREIGN KEY (district_id)          REFERENCES districts(id),
    CONSTRAINT fk_users_division      FOREIGN KEY (division_id)          REFERENCES divisions(id),
    CONSTRAINT fk_users_referred_by   FOREIGN KEY (referred_by_user_id)  REFERENCES users(id)
*/
            $table->string('name');
            $table->string('email')->unique();
            $table->timestamp('email_verified_at')->nullable();
            $table->string('password');
            //role
            $table->enum('role', ['guest', 'host', 'both', 'admin'])->default('guest');
            $table->enum('status', ['pending_verification', 'active', 'suspended', 'banned', 'deactivated', 'deleted'])->default('pending_verification');
            //first_name
            $table->string('first_name')->nullable();
            //last_name
            $table->string('last_name')->nullable();
            //display_name
            $table->string('display_name')->nullable();
            //mobile_number
            $table->string('mobile_number')->nullable();
            //date_of_birth
            $table->date('date_of_birth')->nullable();
            //gender
            $table->enum('gender', ['male', 'female', 'other', 'prefer_not_to_say'])->nullable();
            //profile_photo_url
            $table->text('profile_photo_url')->nullable();
            //bio
            $table->text('bio')->nullable();
            //preferred_language
            $table->enum('preferred_language', ['bn', 'en'])->default('bn');
            //email_verified
            $table->boolean('email_verified')->default(false);
            //mobile_verified
            $table->boolean('mobile_verified')->default(false);
            //id_verified
            $table->enum('id_verified', ['not_submitted', 'pending', 'approved', 'rejected', 'expired'])->default('not_submitted');
            //address_line1
            $table->text('address_line1')->nullable();
            //address_line2
            $table->text('address_line2')->nullable();
            //thana_id
            $table->unsignedSmallInteger('thana_id')->nullable();
            $table->foreign('thana_id')->references('id')->on('thanas')->onDelete('cascade');
            //district_id
            $table->unsignedSmallInteger('district_id')->nullable();
            $table->foreign('district_id')->references('id')->on('districts')->onDelete('cascade');
            //division_id
            $table->unsignedSmallInteger('division_id')->nullable();
            $table->foreign('division_id')->references('id')->on('divisions')->onDelete('cascade');
            //postal_code
            $table->string('postal_code')->nullable();
            //password_hash
            $table->text('password_hash')->nullable();
            //last_login_at
            $table->timestamp('last_login_at')->nullable();
            //mfa_enabled
            $table->boolean('mfa_enabled')->default(false);
            //mfa_secret
            $table->text('mfa_secret')->nullable();
            //referral_code
            $table->string('referral_code')->nullable();
            //referred_by_user_id
            $table->char('referred_by_user_id', 36)->nullable();
            //profile_completeness
            $table->unsignedTinyInteger('profile_completeness')->default(0);
            //is_superhost
            $table->boolean('is_superhost')->default(false);
            //superhost_since
            $table->date('superhost_since')->nullable();
            //account_notes
            $table->text('account_notes')->nullable();
            $table->rememberToken();
            $table->timestamps();
            $table->softDeletes();
        });

        Schema::create('password_reset_tokens', function (Blueprint $table) {
            $table->string('email')->primary();
            $table->string('token');
            $table->timestamp('created_at')->nullable();
        });

        Schema::create('sessions', function (Blueprint $table) {
            $table->string('id')->primary();
            $table->foreignId('user_id')->nullable()->index();
            $table->string('ip_address', 45)->nullable();
            $table->text('user_agent')->nullable();
            $table->longText('payload');
            $table->integer('last_activity')->index();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('users');
        Schema::dropIfExists('password_reset_tokens');
        Schema::dropIfExists('sessions');
    }
};
