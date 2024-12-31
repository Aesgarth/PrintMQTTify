#!/bin/bash

# Copy the custom cupsd.conf file
echo "Copying custom cupsd.conf..."
cp /app/cupsd.conf /etc/cups/cupsd.conf

# Ensure permissions are correct
## The following 2 lines are specific to the Sewoo printer I have been using. 
#chmod 755 /usr/lib/cups/filter/rastertosewoo
#chmod +x /usr/lib/cups/filter/rastertosewoo
# The following 2 lines are for the cups config file
chmod 644 /etc/cups/cupsd.conf
chown root:lp /etc/cups/cupsd.conf

# Start CUPS service
echo "Starting CUPS service..."
service cups start

# Wait for CUPS to initialize
sleep 2

# Configure USB printer if connected
# THis should be modified or removed to match your printer
#if [ -e /dev/usb/lp0 ]; then
#  lpadmin -p My_Printer -E -v usb:/dev/usb/lp0 -m everywhere
#fi

#Install drivers - Modify for your own printer and driver
#This driver is for SEWOO LKT series printers. Tested only on an LK-T100 printer.
#Modify for your own needs.
#lpadmin -p My_Printer -E -v usb:/dev/usb/lp0 -m SEWOOLKT.ppd 

# Configure the printer (Replace with your printer details)
# lpadmin -p My_Printer -E -v ipp://printer_ip/printer_queue -m everywhere
cupsctl --remote-admin --remote-any --share-printers

# Tail the CUPS log in the background
tail -f /var/log/cups/error_log &

# Start the MQTT handler
python3 /app/printer_mqtt_handler.py
