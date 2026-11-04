#!/bin/sh
set -eu
cd /var/www/html
if [ -n "${NEXUS_EBOOK_BUNDLE_URL:-}" ]; then
    python3 scripts/restore-ebooks.py
    mkdir -p storage/assistant
    chown -R www-data:www-data storage/ebooks storage/assistant
    # Start Apache while CPU-intensive PDF extraction runs in the background.
    (php scripts/index-assistant.php && chown -R www-data:www-data storage/assistant) &
fi
exec apache2-foreground
