# Base image
FROM debian:bullseye

# Install necessary packages
RUN apt-get update && apt-get install -y \
    cups \
    cups-client \
    python3 \
    python3-pip

# Expose the CUPS web interface
EXPOSE 631

# Copy a pre-configured cupsd.conf into the container
COPY cupsd.conf /etc/cups/cupsd.conf

# Ensure permissions are correct
RUN chmod 644 /etc/cups/cupsd.conf && chmod 644 /etc/cups/printers.conf

# Start the CUPS service on container startup
CMD ["bash", "-c", "service cups start && tail -f /var/log/cups/error_log"]
RUN lpadmin -p My_Printer -E -v ipp://printer_ip/printer_queue -m everywhere
RUN cupsctl --remote-admin --remote-any --share-printers

# Install MQTT Python library
RUN pip3 install paho-mqtt

# Copy MQTT handler script into the container
COPY printer_mqtt_handler.py /app/
WORKDIR /app

# Start the MQTT handler script and CUPS service
CMD ["/bin/bash", "-c", "service cups start && python3 printer_mqtt_handler.py"]
