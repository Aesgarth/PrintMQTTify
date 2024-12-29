#!/bin/bash
set -e

# Replace placeholders in CUPS configuration files if necessary
if [[ -n "$CUPS_ADMIN_USER" && -n "$CUPS_ADMIN_PASSWORD" ]]; then
    echo "Setting up CUPS admin credentials..."
    lpadmin -u "$CUPS_ADMIN_USER" -p "$CUPS_ADMIN_PASSWORD"
fi

# Ensure correct permissions for configuration files
chown -R root:lp /etc/cups
chmod 644 /etc/cups/cupsd.conf

# Start the CUPS daemon
echo "Starting CUPS daemon..."
service cups start

# Wait for CUPS to initialize
sleep 5

# Optionally preconfigure printers
if [ -f /etc/cups/printers.conf ]; then
    echo "Loading preconfigured printers..."
    service cups restart
fi

# Start the MQTT handler in the background
echo "Starting MQTT handler..."
python3 /app/printer_mqtt_handler.py &

# Keep the container running
exec "$@"
