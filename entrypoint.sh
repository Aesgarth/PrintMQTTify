#!/bin/bash

# Copy the custom cupsd.conf file
echo "Copying custom cupsd.conf..."
cp /app/cupsd.conf /etc/cups/cupsd.conf

# Ensure permissions are correct
# The following 2 lines are for the cups config file
chmod 644 /etc/cups/cupsd.conf
chown root:lp /etc/cups/cupsd.conf

# Create admin user if it doesn't already exist
if ! id -u admin > /dev/null 2>&1; then
  echo "Creating admin user..."
  adduser --disabled-password --gecos "" admin
  echo "admin:adminpassword" | chpasswd
  usermod -aG lpadmin admin
else
  echo "Admin user already exists."
fi

# Start CUPS service
echo "Starting CUPS service..."
service cups start

# Wait for CUPS to initialize
sleep 2

cupsctl --remote-admin --remote-any --share-printers

# Tail the CUPS log in the background
tail -f /var/log/cups/error_log &

# Start the MQTT handler
python3 /app/printer_mqtt_handler.py
