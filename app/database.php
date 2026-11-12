<?php

declare(strict_types=1);
require_once __DIR__.'/sql_names.php';

final class Database
{
    private static ?PDO $connection = null;

    public static function connection(): PDO
    {
        if (self::$connection instanceof PDO) {
            return self::$connection;
        }

        $dsn = sprintf('mysql:host=%s;port=%s;dbname=%s;charset=utf8mb4', DB_HOST, DB_PORT, getenv('NEXUS_DB_NAME') ?: DB_NAME);
        self::$connection = new NexusPDO($dsn, DB_USER, DB_PASS, [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES => false,
        ]);
        self::$connection->setAttribute(PDO::ATTR_STATEMENT_CLASS,[NexusStatement::class,[self::$connection]]);

        // Match the web application's Asia/Bangkok calendar for all SQL date functions.
        self::$connection->exec("SET time_zone = '+07:00'");

        return self::$connection;
    }
}
