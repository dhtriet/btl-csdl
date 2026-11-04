-- Run once against the existing resource_center database.
SET @sql = IF(
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
     WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'room_requests' AND COLUMN_NAME = 'reviewed_at') = 0,
    'ALTER TABLE room_requests ADD COLUMN reviewed_at DATETIME NULL AFTER created_at',
    'SELECT 1'
);
PREPARE migration_statement FROM @sql;
EXECUTE migration_statement;
DEALLOCATE PREPARE migration_statement;

SET @sql = IF(
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
     WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'room_requests' AND COLUMN_NAME = 'review_note') = 0,
    'ALTER TABLE room_requests ADD COLUMN review_note VARCHAR(255) NULL AFTER reviewed_at',
    'SELECT 1'
);
PREPARE migration_statement FROM @sql;
EXECUTE migration_statement;
DEALLOCATE PREPARE migration_statement;
