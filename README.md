# PrintMQTTify

PrintMQTTify is a Docker-based solution that bridges MQTT messages to a CUPS printer, allowing you to print messages from your MQTT broker seamlessly. This is particularly useful in smart home setups for automating printing tasks, such as printing shopping lists or event reminders directly from Home Assistant. This project provides an easy way to connect printers to your smart home system, such as Home Assistant, and send print commands using MQTT.

---

## Features

- Provides a fully functional CUPS server, capable of managing multiple printers and supporting advanced configurations. While the integration is designed for seamless operation, certain CUPS features like network discovery and complex job queuing may depend on additional host configurations.
- Listens for MQTT messages to process print jobs.
- Supports USB printers with custom drivers.
- Designed for use with Home Assistant and other MQTT-enabled systems.

---

## Prerequisites

1. **Docker**: Ensure Docker is installed and running on your system.

   - [Install Docker](https://docs.docker.com/get-docker/)

2. **Git**: Ensure Git is installed to clone the repository.

   - [Install Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)

3. **MQTT Broker**: A working MQTT broker (e.g., Mosquitto) is required. Note the broker’s IP address, username, and password.

---

## Identifying Your USB Printer

To ensure the correct USB printer is passed to the container, follow these steps:

1. **List USB Devices**:
   Run the following command on your host machine to list all connected USB devices:
   ```bash
   lsusb
   ```
   Example output:
   ```
   Bus 002 Device 002: ID 0525:a700 Netchip Technology, Inc.
   ```

2. **Find the Printer Path**:
   Once you identify your printer, use the following command to locate the device path:
   ```bash
   dmesg | grep usb
   ```
   Look for a log entry indicating the device's path, such as `/dev/usb/lp0`.

3. **Verify Device Path**:
   Ensure the device path exists:
   ```bash
   ls /dev/usb/lp*
   ```
   Example output:
   ```
   /dev/usb/lp0
   ```

4. **Use the Device Path**:
   Pass the verified device path (e.g., `/dev/usb/lp0`) to the container using the `--device` flag in `docker run` or in the `devices` section of your Docker Compose file.

---

## Installation

### 1. Clone the Repository

Before cloning, ensure you have installed Docker, Git, and have a working MQTT broker. Clone the PrintMQTTify repository to your local machine:

```bash
git clone https://github.com/Aesgarth/PrintMQTTify.git
cd PrintMQTTify
```

### 2. Build the Docker Image

Build the Docker image using the included `Dockerfile`:

```bash
docker build -t printmqttify .
```

### 3. Run the Docker Container

Start the container with the following command:

The `docker run` command includes the following flags:

- `--name printmqttify_container`: Names the container for easier management.
- `-d`: Runs the container in detached mode.
- `--privileged`: Grants the container extended privileges, necessary for USB access.
- `-p 631:631`: Maps the container's CUPS web interface port to the host.
- `--device=/dev/usb/lp0:/dev/usb/lp0`: Maps the USB printer device to the container.
- `-e`: Sets environment variables like MQTT broker credentials and admin user details for CUPS.

```bash
docker run --name printmqttify_container \
  -d \
  --privileged \
  -p 631:631 \
  --device=/dev/usb/lp0:/dev/usb/lp0 \
  -e MQTT_BROKER="<your-mqtt-broker-ip>" \
  -e MQTT_USERNAME="<your-mqtt-username>" \
  -e MQTT_PASSWORD="<your-mqtt-password>" \
  -e MQTT_TOPIC="printer/commands" \
  -e ADMIN_USER="admin" \
  -e ADMIN_PASS="adminpassword" \
  printmqttify
```

Replace the placeholders (`<your-mqtt-broker-ip>`, `<your-mqtt-username>`, etc.) with your actual MQTT broker details.

---

## Using Docker Compose

Alternatively, you can use Docker Compose to manage the container. Create a `docker-compose.yml` file with the following content:

```yaml
version: '3.8'

services:
  printmqttify:
    image: printmqttify
    container_name: printmqttify_container
    privileged: true
    ports:
      - "631:631"
    devices:
      - "/dev/usb/lp0:/dev/usb/lp0"
    environment:
      - MQTT_BROKER=<your-mqtt-broker-ip>
      - MQTT_USERNAME=<your-mqtt-username>
      - MQTT_PASSWORD=<your-mqtt-password>
      - MQTT_TOPIC=printer/commands
      - ADMIN_USER=admin
      - ADMIN_PASS=adminpassword
    stdin_open: true
    tty: true
```

Then start the container with:

```bash
docker-compose up -d
```

---

## Setup

### 1. Access the CUPS Web Interface

1. Open a browser and navigate to:

   ```
   https://<host-ip>:631
   ```

   Replace `<host-ip>` with the IP address of the machine running the container.

2. Log in using the CUPS admin credentials:

   - Username: `admin` (or as set in `ADMIN_USER`)
   - Password: `adminpassword` (or as set in `ADMIN_PASS`)

### 2. Add a Printer

1. In the CUPS interface, go to **Administration** > **Add Printer**.
2. Select the connected USB printer.
3. Choose the appropriate driver (e.g., SEWOO LKT-Series).
4. Complete the setup and test the printer by printing a test page.

---

## Verification with Home Assistant

### 1. Send a Test Message

If your printer doesn't print the message, ensure the following:

- The `printer_name` in the payload matches the name configured in the CUPS web interface.
- The MQTT broker details in the container are correct.
- The printer is connected and has no pending errors in the CUPS interface.
- Check the logs for any errors:
  ```bash
  docker logs printmqttify_container
  ```

Use Home Assistant to send a message to your printer via MQTT:

1. Go to **Developer Tools** > **Services** in Home Assistant.
2. Select the `mqtt.publish` service.
3. Enter the following data:
   ```yaml
   service: mqtt.publish
   data:
     topic: "printer/commands"
     payload: '{"printer_name": "SEWOO_LK-T100", "message": "Hello, World!"}'
   ```
4. Click **Call Service**.

### 2. Verify the Output

Check your printer to confirm that the message has been printed. If the message does not print, check the container logs for errors:

```bash
docker logs printmqttify_container
```

---

## Troubleshooting

### Changing Port Mapping

If the default port `631` is already in use by another service (e.g., a host-installed CUPS instance), you can modify the port mapping in the Docker run or Compose configuration:

- For `docker run`, replace `-p 631:631` with an alternative mapping like `-p 1631:631`.
- For Docker Compose, update the `ports` section to:
  ```yaml
  ports:
    - "1631:631"
  ```

Ensure you update the port in the browser URL to match the new mapping (e.g., `https://<host-ip>:1631`).

### Common Issues

1. **Cannot Access CUPS Web Interface**:

   - Ensure the container is running.
   - Confirm that port `631` is not blocked by a firewall.

2. **Printer Not Printing**:

   - Check the printer status in the CUPS web interface.
   - Ensure the correct driver is installed.

3. **MQTT Issues**:

   - Verify the MQTT broker details in the container environment variables.
   - Check the MQTT topic for incoming messages.

---

## Contributing

Contributions are welcome! Feel free to submit issues or pull requests on GitHub.

---

## License

This project is licensed under the Creative Commons Zero v1.0
