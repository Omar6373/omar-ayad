-- Omar RP / MariaDB schema v1. Run on a fresh database.
CREATE TABLE accounts (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 username VARCHAR(24) NOT NULL UNIQUE,
 password_hash VARCHAR(255) NOT NULL,
 cash BIGINT NOT NULL DEFAULT 2000,
 bank_balance BIGINT NOT NULL DEFAULT 0,
 admin_level TINYINT UNSIGNED NOT NULL DEFAULT 0,
 created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 last_login_at TIMESTAMP NULL,
 CHECK (cash >= 0),
 CHECK (bank_balance >= 0),
 CHECK (admin_level <= 4)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE ledger (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 account_id BIGINT UNSIGNED NOT NULL,
 transaction_key VARCHAR(80) NOT NULL,
 kind VARCHAR(32) NOT NULL,
 cash_delta BIGINT NOT NULL DEFAULT 0,
 bank_delta BIGINT NOT NULL DEFAULT 0,
 created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 UNIQUE KEY uniq_account_tx (account_id, transaction_key),
 INDEX idx_ledger_account_time (account_id, created_at),
 FOREIGN KEY (account_id) REFERENCES accounts(id)
) ENGINE=InnoDB;

CREATE TABLE job_progress (
 account_id BIGINT UNSIGNED PRIMARY KEY,
 job_code VARCHAR(32) NOT NULL DEFAULT 'none',
 active_seconds INT UNSIGNED NOT NULL DEFAULT 0,
 last_payout_at TIMESTAMP NULL,
 FOREIGN KEY (account_id) REFERENCES accounts(id)
) ENGINE=InnoDB;

CREATE TABLE families (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 name VARCHAR(48) NOT NULL UNIQUE,
 leader_account_id BIGINT UNSIGNED NOT NULL,
 treasury BIGINT NOT NULL DEFAULT 0,
 created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 CHECK (treasury >= 0),
 FOREIGN KEY (leader_account_id) REFERENCES accounts(id)
) ENGINE=InnoDB;

CREATE TABLE family_members (
 family_id BIGINT UNSIGNED NOT NULL,
 account_id BIGINT UNSIGNED NOT NULL UNIQUE,
 rank TINYINT UNSIGNED NOT NULL DEFAULT 0,
 joined_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 PRIMARY KEY (family_id, account_id),
 FOREIGN KEY (family_id) REFERENCES families(id),
 FOREIGN KEY (account_id) REFERENCES accounts(id)
) ENGINE=InnoDB;

CREATE TABLE admin_audit (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 admin_account_id BIGINT UNSIGNED NOT NULL,
 target_account_id BIGINT UNSIGNED NULL,
 action VARCHAR(64) NOT NULL,
 reason VARCHAR(255) NOT NULL,
 created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY (admin_account_id) REFERENCES accounts(id),
 FOREIGN KEY (target_account_id) REFERENCES accounts(id)
) ENGINE=InnoDB;
