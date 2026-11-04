<?php
declare(strict_types=1);

// Copy to config.php. Local configuration is deliberately excluded from Git.
define('DB_HOST', getenv('NEXUS_DB_HOST') ?: '127.0.0.1');
define('DB_PORT', (int) (getenv('NEXUS_DB_PORT') ?: 3306));
define('DB_NAME', getenv('NEXUS_DB_NAME') ?: 'resource_center');
define('DB_USER', getenv('NEXUS_DB_USER') ?: 'root');
define('DB_PASS', getenv('NEXUS_DB_PASS') ?: '');

const APP_NAME = 'Nexus Learning Resource Center';
