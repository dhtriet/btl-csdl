-- Add the librarian's explicit on-time/late result to each loan detail.
SET @sql = IF(
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
     WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'loan_details' AND COLUMN_NAME = 'return_status') = 0,
    "ALTER TABLE loan_details ADD COLUMN return_status ENUM('on_time', 'late') NULL AFTER return_date",
    'SELECT 1'
);
PREPARE migration_statement FROM @sql;
EXECUTE migration_statement;
DEALLOCATE PREPARE migration_statement;

SET @sql = IF(
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
     WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'loan_details' AND COLUMN_NAME = 'late_days') = 0,
    'ALTER TABLE loan_details ADD COLUMN late_days SMALLINT UNSIGNED NOT NULL DEFAULT 0 AFTER return_status',
    'SELECT 1'
);
PREPARE migration_statement FROM @sql;
EXECUTE migration_statement;
DEALLOCATE PREPARE migration_statement;

SET @sql = IF(
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
     WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'equipment_loan_details' AND COLUMN_NAME = 'return_status') = 0,
    "ALTER TABLE equipment_loan_details ADD COLUMN return_status ENUM('on_time', 'late') NULL AFTER return_date",
    'SELECT 1'
);
PREPARE migration_statement FROM @sql;
EXECUTE migration_statement;
DEALLOCATE PREPARE migration_statement;

SET @sql = IF(
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
     WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'equipment_loan_details' AND COLUMN_NAME = 'late_days') = 0,
    'ALTER TABLE equipment_loan_details ADD COLUMN late_days SMALLINT UNSIGNED NOT NULL DEFAULT 0 AFTER return_status',
    'SELECT 1'
);
PREPARE migration_statement FROM @sql;
EXECUTE migration_statement;
DEALLOCATE PREPARE migration_statement;
