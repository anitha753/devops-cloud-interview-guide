#!/bin/bash

FILE="users.csv"

tail -n +2 "$FILE" | while read line
do
        username=$(echo $line | cut -d',' -f1)
        password=$(echo $line | cut -d',' -f2)


        useradd "$username"

        echo "$username:$password" | chpasswd

        echo "Created the user: $username"

done
#!/bin/bash

########################
# Your application writes logs to /var/log/myapp/. You want to:
#    Compress logs older than 7 days
#    Delete logs older than 30 days
#    Automate it via a daily cron job
#########################

# Directory where logs are stored
LOG_DIR="/var/log/myapp"
LOG_FILE="/var/log/myapp/log_rotation.log"

# Ensure the log directory exists
if [ ! -d "$LOG_DIR" ]; then
    echo "[$(date)] ERROR: Log directory $LOG_DIR does not exist!" >> "$LOG_FILE"
    exit 1
fi

# Compress logs older than 7 days (but newer than 30)
find "$LOG_DIR" -type f -name "*.log" -mtime +7 -mtime -30 ! -name "*.gz" -exec gzip {} \; -exec echo "[$(date)] Compressed: {}" >> "$LOG_FILE" \;

# Delete compressed logs older than 30 days
find "$LOG_DIR" -type f -name "*.gz" -mtime +30 -exec rm -f {} \; -exec echo "[$(date)] Deleted: {}" >> "$LOG_FILE" \;

# Optional: Delete uncompressed logs older than 30 days
find "$LOG_DIR" -type f -name "*.log" -mtime +30 -exec rm -f {} \; -exec echo "[$(date)] Deleted (uncompressed): {}" >> "$LOG_FILE" \;

# Done
echo "[$(date)] Log rotation completed successfully." >> "$LOG_FILE"
#!/bin/bash

# List of services to monitor
services=("nginx" "sshd" "docker")

echo "-----------------------------------"
echo " Service Health Check Report"
echo "-----------------------------------"

# Loop through each service
for service in "${services[@]}"; do
    # Check service status
    if systemctl is-active --quiet "$service"; then
        echo "$service is ✅ RUNNING"
    else
        echo "$service is ❌ STOPPED"

        # Optional: Try to restart the service
        echo "Attempting to restart $service..."
        sudo systemctl restart "$service"

        # Re-check status
        if systemctl is-active --quiet "$service"; then
            echo "$service has been ✅ restarted successfully."
        else
            echo "⚠️  Failed to restart $service. Check logs."
        fi
    fi
    echo "-----------------------------------"
done
