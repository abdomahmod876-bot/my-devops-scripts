#!/bin/bash
DB_NAME="abdo"
BACKUP_DIR="/home/abdo/odoo_backups"
FILESTORE_PATH="/home/abdo/.local/share/Odoo/filestore/$DB_NAME"
TEMP_DIR="/tmp/backup_temp"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
FINAL_BACKUP="$BACKUP_DIR/full_odoo_backup_$TIMESTAMP.tar.gz"

rm -rf "$TEMP_DIR" && mkdir -p "$TEMP_DIR"
# إنشاء manifest
echo '{"db_name": "'$DB_NAME'", "version": "17.0"}' > "$TEMP_DIR/manifest.json"

# تصدير القاعدة (بدون su - postgres)
pg_dump -F c -f "$TEMP_DIR/dump.sql" "$DB_NAME"

# نسخ الـ filestore
cp -r "$FILESTORE_PATH" "$TEMP_DIR/filestore"

# ضغط الملف
cd "$TEMP_DIR" && tar -czf "$FINAL_BACKUP" *
rm -rf "$TEMP_DIR"
