#!/bin/bash

# Start the CUPS service
service cups start

# Wait for CUPS to initialize
sleep 2

# Configure USB printer if connected
if [ -e /dev/usb/lp0 ]; then
  lpadmin -p USB_Printer -E -v usb:/dev/usb/lp0 -m everywhere
fi

# Configure the printer (Replace with your printer details)
lpadmin -p My_Printer -E -v ipp://printer_ip/printer_queue -m everywhere
cupsctl --remote-admin --remote-any --share-printers

# Tail the CUPS log in the background
tail -f /var/log/cups/error_log &

# Start the MQTT handler
python3 /app/printer_mqtt_handler.py
