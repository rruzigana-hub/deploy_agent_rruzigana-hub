# deploy_agent_rruzigana-hub

## Student Attendance Tracker — Automated Project Bootstrapper

This shell script automates the creation of a fully structured workspace for the Student Attendance Tracker application.

---

## How to Run the Script

**1. Clone the repository**
git clone https://github.com/rruzigana-hub/deploy_agent_rruzigana-hub.git
cd deploy_agent_rruzigana-hub

**2. Give the script execute permission**
chmod +x setup_project.sh

**3. Run the script**
./setup_project.sh

**4. Follow the prompts:**
- Enter a project name (e.g. cohort26)
- Choose whether to update attendance thresholds
- The script will handle the rest automatically

---

## What the Script Does

- Creates attendance_tracker_{input}/ with the required structure
- Writes all 4 source files into the correct locations
- Prompts to update warning and failure thresholds via sed
- Checks that python3 is installed
- Verifies all files exist in the correct structure

---

## Directory Structure Created

attendance_tracker_{input}/
├── attendance_checker.py
├── Helpers/
│   ├── assets.csv
│   └── config.json
└── reports/
    └── reports.log

---

## How to Trigger the Archive Feature (SIGINT Trap)

While the script is running, press Ctrl+C to interrupt it.

The script will:
1. Catch the interrupt signal (SIGINT)
2. Bundle the current project directory into a .tar.gz archive named attendance_tracker_{input}_archive.tar.gz
3. Delete the incomplete directory to keep the workspace clean

---

## Requirements

- Bash shell (Linux/macOS)
- python3 (optional — script will warn if missing)
- sed, tar, mkdir (standard Linux tools — pre-installed)
