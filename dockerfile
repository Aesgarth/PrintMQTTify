# Base image
FROM debian:bullseye

# Install necessary packages
RUN apt-get update && apt-get install -y \
    cups \
    cups-client \
    python3 \
    python3-pip \
    libcupsimage2 \
    && apt-get clean

# Expose the CUPS web interface
EXPOSE 631

# Copy the pre-configured cupsd.conf and entrypoint script
COPY /configs/cupsd.conf /app/cupsd.conf
COPY entrypoint.sh /app/entrypoint.sh

# Copy printer drivers into the container
COPY drivers/SEWOO/sewoocupsinstall_amd64.tar.gz /tmp/sewoocupsinstall_amd64.tar.gz

# Extract and install the drivers
RUN tar -zxvf /tmp/sewoocupsinstall_amd64.tar.gz -C /tmp && \
    cd /tmp/sewoocupsinstall_amd64 && \
    chmod +x setup.sh && \
    sh setup.sh

# Ensure permissions are correct
RUN chmod 644 /app/cupsd.conf \
    && chmod +x /app/entrypoint.sh

# Install MQTT Python library
RUN pip3 install paho-mqtt

# Copy MQTT handler script into the container
COPY app/printer_mqtt_handler.py /app/printer_mqtt_handler.py
WORKDIR /app

# Use entrypoint script for runtime configuration and startup
ENTRYPOINT ["/app/entrypoint.sh"]
