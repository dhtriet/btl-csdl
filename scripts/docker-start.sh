#!/bin/sh
set -eu
cd /var/www/html
if [ -n "${NEXUS_EBOOK_BUNDLE_URL:-}" ]; then
    python3 scripts/restore-ebooks.py
    php scripts/index-assistant.php
    chown -R www-data:www-data storage/ebooks storage/assistant
fi
exec apache2-foreground
