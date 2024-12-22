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

# Install MQTT Python library
RUN pip3 install paho-mqtt

# Copy MQTT handler script into the container
COPY printer_mqtt_handler.py /app/
WORKDIR /app

# Start the MQTT handler script and CUPS service
CMD ["/bin/bash", "-c", "service cups start && python3 printer_mqtt_handler.py"]
