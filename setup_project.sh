#!/bin/bash

echo "=========================================="
echo "   Student Attendance Tracker - Setup"
echo "=========================================="
echo ""
read -rp "Enter a project name (e.g. cohort26): " input

if [ -z "$input" ]; then
    echo "ERROR: Project name cannot be empty. Exiting."
    exit 1
fi

PROJECT_DIR="attendance_tracker_${input}"

cleanup() {
    echo ""
    echo "Script interrupted! Cleaning up..."
    if [ -d "$PROJECT_DIR" ]; then
        tar -czf "${PROJECT_DIR}_archive.tar.gz" "$PROJECT_DIR"
        echo "Archive created: ${PROJECT_DIR}_archive.tar.gz"
        rm -rf "$PROJECT_DIR"
        echo "Incomplete directory deleted."
    fi
    echo "Exiting."
    exit 1
}

trap cleanup SIGINT

echo ""
echo "Creating project directory structure..."

if [ -d "$PROJECT_DIR" ]; then
    echo "ERROR: Directory already exists. Exiting."
    exit 1
fi

mkdir -p "${PROJECT_DIR}/Helpers"
mkdir -p "${PROJECT_DIR}/reports"
echo "Directories created."

cat > "${PROJECT_DIR}/attendance_checker.py" << 'PYEOF'
import csv
import json
import os
from datetime import datetime

def run_attendance_check():
    with open('Helpers/config.json', 'r') as f:
        config = json.load(f)
    if os.path.exists('reports/reports.log'):
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        os.rename('reports/reports.log', f'reports/reports_{timestamp}.log.archive')
    with open('Helpers/assets.csv', mode='r') as f, open('reports/reports.log', 'w') as log:
        reader = csv.DictReader(f)
        total_sessions = config['total_sessions']
        log.write(f"--- Attendance Report Run: {datetime.now()} ---\n")
        for row in reader:
            name = row['Names']
            email = row['Email']
            attended = int(row['Attendance Count'])
            attendance_pct = (attended / total_sessions) * 100
            message = ""
            if attendance_pct < config['thresholds']['failure']:
                message = f"URGENT: {name}, your attendance is {attendance_pct:.1f}%. You will fail this class."
            elif attendance_pct < config['thresholds']['warning']:
                message = f"WARNING: {name}, your attendance is {attendance_pct:.1f}%. Please be careful."
            if message:
                if config['run_mode'] == "live":
                    log.write(f"[{datetime.now()}] ALERT SENT TO {email}: {message}\n")
                    print(f"Logged alert for {name}")
                else:
                    print(f"[DRY RUN] Email to {email}: {message}")

if __name__ == "__main__":
    run_attendance_check()
PYEOF
echo "attendance_checker.py created."

cat > "${PROJECT_DIR}/Helpers/assets.csv" << 'CSVEOF'
Email,Names,Attendance Count,Absence Count
alice@example.com,Alice Johnson,14,1
bob@example.com,Bob Smith,7,8
charlie@example.com,Charlie Davis,4,11
diana@example.com,Diana Prince,15,0
CSVEOF
echo "assets.csv created."

cat > "${PROJECT_DIR}/Helpers/config.json" << 'JSONEOF'
{
    "thresholds": {
        "warning": 75,
        "failure": 50
    },
    "run_mode": "live",
    "total_sessions": 15
}
JSONEOF
echo "config.json created."

cat > "${PROJECT_DIR}/reports/reports.log" << 'LOGEOF'
--- Attendance Report Run: 2026-02-06 18:10:01.468726 ---
[2026-02-06 18:10:01.469363] ALERT SENT TO bob@example.com: URGENT: Bob Smith, your attendance is 46.7%. You will fail this class.
[2026-02-06 18:10:01.469424] ALERT SENT TO charlie@example.com: URGENT: Charlie Davis, your attendance is 26.7%. You will fail this class.
LOGEOF
echo "reports.log created."

echo ""
echo "=========================================="
echo "   Configuration Update"
echo "=========================================="
read -rp "Do you want to update the attendance thresholds? (yes/no): " update_choice

if [[ "$update_choice" == "yes" || "$update_choice" == "y" ]]; then
    read -rp "Enter new WARNING threshold (default 75): " new_warning
    if [ -z "$new_warning" ]; then
        new_warning=75
    fi
    if ! echo "$new_warning" | grep -qE '^[0-9]+$'; then
        echo "ERROR: Must be a number. Using default 75."
        new_warning=75
    fi
    read -rp "Enter new FAILURE threshold (default 50): " new_failure
    if [ -z "$new_failure" ]; then
        new_failure=50
    fi
    if ! echo "$new_failure" | grep -qE '^[0-9]+$'; then
        echo "ERROR: Must be a number. Using default 50."
        new_failure=50
    fi
    sed -i "s/\"warning\": [0-9]*/\"warning\": ${new_warning}/" "${PROJECT_DIR}/Helpers/config.json"
    sed -i "s/\"failure\": [0-9]*/\"failure\": ${new_failure}/" "${PROJECT_DIR}/Helpers/config.json"
    echo "config.json updated — warning: ${new_warning}%, failure: ${new_failure}%"
else
    echo "Keeping default thresholds (warning: 75%, failure: 50%)."
fi

echo ""
echo "=========================================="
echo "   Environment Health Check"
echo "=========================================="

if python3 --version > /dev/null 2>&1; then
    PY_VERSION=$(python3 --version)
    echo "Python3 is installed: ${PY_VERSION}"
else
    echo "WARNING: python3 is NOT installed."
fi

echo ""
echo "Verifying project structure..."
STRUCTURE_OK=true

for path in \
    "${PROJECT_DIR}/attendance_checker.py" \
    "${PROJECT_DIR}/Helpers/assets.csv" \
    "${PROJECT_DIR}/Helpers/config.json" \
    "${PROJECT_DIR}/reports/reports.log"
do
    if [ -f "$path" ]; then
        echo "  OK: $path"
    else
        echo "  MISSING: $path"
        STRUCTURE_OK=false
    fi
done

if [ "$STRUCTURE_OK" = true ]; then
    echo "All files verified. Project '${PROJECT_DIR}' is ready!"
else
    echo "Some files are missing."
fi

echo ""
echo "=========================================="
echo "   Setup Complete!"
echo "=========================================="
