#!/bin/bash

# ==========================================
# ODOO AUTOMATED BACKUP & RETENTION SCRIPT
# ==========================================
# Checked and optimized for dev branch
# 1. Variables Definition
DB_NAME="abdo"
BACKUP_DIR="/var/backups/odoo/daily"
LOG_FILE="/var/log/odoo_backup/backup_status.log"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_FILE="$BACKUP_DIR/${DB_NAME}_backup_$TIMESTAMP.sql"

echo "=== Backup Process Started at $(date) ===" >> "$LOG_FILE"

# 2. Execute PostgreSQL Database Backup (Odoo Data)
# We use pg_dump to extract the database structure and rows
pg_dump -U odoo -h 127.0.0.1 -F c -b -v -f "$BACKUP_FILE" "$DB_NAME" 2>> "$LOG_FILE"

# 3. Check if the Backup Command Succeeded (Exit Status Check)
if [ $? -eq 0 ]; then
    echo "✅ Success: Database '$DB_NAME' backed up to $BACKUP_FILE" >> "$LOG_FILE"
else
    echo "❌ Error: Database backup failed! Check PostgreSQL logs." >> "$LOG_FILE"
    exit 1
fi

# 4. Retention Policy (Delete backups older than 7 days to save space)
echo "🧹 Running Retention Policy Management..." >> "$LOG_FILE"
find "$BACKUP_DIR" -type f -name "*.sql" -mtime +7 -exec rm {} \; 2>> "$LOG_FILE"
echo "🧹 Old backups (older than 7 days) cleared successfully." >> "$LOG_FILE"

echo "=== Backup Process Ended at $(date) ===" >> "$LOG_FILE"
echo "--------------------------------------------------" >> "$LOG_FILE"
