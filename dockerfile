# Base image
FROM debian:bullseye

# Install necessary packages
RUN apt-get update && apt-get install -y \
    cups \
    cups-client \
    python3 \
    python3-pip \
    && apt-get clean

# Expose the CUPS web interface
EXPOSE 631

# Copy the pre-configured cupsd.conf and entrypoint script
COPY configs/cupsd.conf /etc/cups/cupsd.conf
COPY entrypoint.sh /app/entrypoint.sh

# Ensure permissions are correct
RUN chmod 644 /etc/cups/cupsd.conf \
    && chmod +x /app/entrypoint.sh

# Install MQTT Python library
RUN pip3 install paho-mqtt

# Copy MQTT handler script into the container
COPY app/printer_mqtt_handler.py /app/printer_mqtt_handler.py
WORKDIR /app

# Use entrypoint script for runtime configuration and startup
ENTRYPOINT ["/app/entrypoint.sh"]
