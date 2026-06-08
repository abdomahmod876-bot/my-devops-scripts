#!/bin/bash

# 1. Variables Initialization
LOG_FILE="/var/log/nginx/odoo_access.log"

echo "=================================================="
echo "📊  DEVOPS TRAFFIC MONITORING REPORT  📊"
echo "=================================================="

# 2. Check if log file exists (If-Condition)
if [ ! -f "$LOG_FILE" ]; then
    echo "❌ Error: Log file not found! Please run the stress test first."
    exit 1
fi

# 3. Data Parsing (Linux Filters)
TOTAL_REQUESTS=$(wc -l < "$LOG_FILE")
SUCCESS_200=$(grep -c " 200 " "$LOG_FILE")
REDIRECT_301=$(grep -c " 301 " "$LOG_FILE")
BAD_GATEWAY_502=$(grep -c " 502 " "$LOG_FILE")

# 4. Printing the Dashboard Results
echo "📈 Total Incoming Requests : $TOTAL_REQUESTS"
echo "✅ Successful Requests (200 OK)  : $SUCCESS_200"
echo "🔀 Redirected Requests (301)     : $REDIRECT_301"
echo "⚠️  Bad Gateway Errors   (502)     : $BAD_GATEWAY_502"
echo "=================================================="
echo "🕒 Report Generated At: $(date)"
echo "=================================================="
