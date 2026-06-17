#!/bin/bash
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "خطأ: يجب تحديد ملف الباكب واسم قاعدة البيانات الجديدة!"
    echo "الاستخدام: ./restore_odoo.sh [ملف_الباك_اب] [اسم_القاعدة]"
    exit 1
fi
# ... باقي السكريبت ...
BACKUP_FILE=$1
NEW_DB=$2

TEMP_DIR="/tmp/restore_temp"
mkdir -p "$TEMP_DIR"
tar -xzf "$BACKUP_FILE" -C "$TEMP_DIR"

# إنشاء القاعدة بصلاحية abdo
createdb "$NEW_DB"

# استعادة القاعدة
pg_restore -d "$NEW_DB" -F c "$TEMP_DIR/dump.sql"

# نقل الـ filestore
mkdir -p "/home/abdo/.local/share/Odoo/filestore/$NEW_DB"
cp -r "$TEMP_DIR/filestore/"* "/home/abdo/.local/share/Odoo/filestore/$NEW_DB/"

rm -rf "$TEMP_DIR"
echo "تمت الاستعادة بنجاح بصلاحية المستخدم $USER"
