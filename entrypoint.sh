#!/bin/bash

# Copy the custom cupsd.conf file
echo "Copying custom cupsd.conf..."
cp /app/cupsd.conf /etc/cups/cupsd.conf

# Ensure permissions are correct
chmod 644 /etc/cups/cupsd.conf
chown root:lp /etc/cups/cupsd.conf

# Start CUPS service
echo "Starting CUPS service..."
service cups start

# Wait for CUPS to initialize
sleep 2

# Configure USB printer if connected
if [ -e /dev/usb/lp0 ]; then
  lpadmin -p USB_Printer -E -v usb:/dev/usb/lp0 -m everywhere
fi

#Install drivers - Modify for your own printer and driver
lpadmin -p My_Printer -E -v usb:/dev/usb/lp0 -m SEWOOLKT.ppd 

# Configure the printer (Replace with your printer details)
# lpadmin -p My_Printer -E -v ipp://printer_ip/printer_queue -m everywhere
cupsctl --remote-admin --remote-any --share-printers

# Tail the CUPS log in the background
tail -f /var/log/cups/error_log &

# Start the MQTT handler
python3 /app/printer_mqtt_handler.py
