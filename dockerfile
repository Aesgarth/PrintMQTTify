# Base image
FROM debian:bullseye

# Install necessary packages
RUN apt-get update && apt-get install -y \
    cups \
    cups-client \
    python3 \
    python3-pip \
    libcupsimage2 \
    avahi-daemon \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Expose the CUPS web interface
EXPOSE 631

# Set environment variables for flexibility
ENV CUPS_CONF_DIR=/etc/cups \
    APP_DIR=/app \
    DRIVER_ARCHIVE=/tmp/sewoocupsinstall_amd64.tar.gz \
    DRIVER_TMP_DIR=/tmp/sewoocupsinstall_amd64

# Copy the pre-configured CUPS config and entrypoint script
COPY configs/cupsd.conf $APP_DIR/cupsd.conf
COPY entrypoint.sh $APP_DIR/entrypoint.sh

# Copy and install the SEWOO drivers
COPY drivers/SEWOO/sewoocupsinstall_amd64.tar.gz $DRIVER_ARCHIVE
RUN tar -zxvf $DRIVER_ARCHIVE -C /tmp && \
    cd $DRIVER_TMP_DIR && \
    chmod +x setup.sh && \
    sh setup.sh && \
    rm -rf $DRIVER_TMP_DIR $DRIVER_ARCHIVE

# Ensure permissions are correct
RUN chmod 644 $APP_DIR/cupsd.conf && chmod +x $APP_DIR/entrypoint.sh

# Install Python dependencies
RUN pip3 install paho-mqtt

# Install Flask
RUN pip3 install flask

# Install ReportLab for advanced PDF generation
RUN pip3 install reportlab

# Copy the MQTT handler script
COPY app/printer_mqtt_handler.py $APP_DIR/printer_mqtt_handler.py
# Copy the web control panel script
COPY app/web_control_panel.py $APP_DIR/web_control_panel.py
WORKDIR $APP_DIR

# Use entrypoint script for runtime configuration and startup
ENTRYPOINT ["/app/entrypoint.sh"]
