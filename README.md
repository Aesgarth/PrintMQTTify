# PrintMQTTify

PrintMQTTify is a Docker-based solution that bridges MQTT messages to a CUPS printer, allowing you to print messages from your MQTT broker seamlessly. This is particularly useful in smart home setups for automating printing tasks, such as printing shopping lists or event reminders directly from Home Assistant. This project provides an easy way to connect printers to your smart home system, such as Home Assistant, and send print commands using MQTT.

---

## Features

- **CUPS Integration**: Provides a fully functional CUPS server, capable of managing multiple printers and supporting advanced configurations.
- **MQTT Print Jobs**: Listens for MQTT messages to process print jobs efficiently.
- **USB Printer Support**: Compatible with USB printers and supports custom drivers.
- **Customizable Output**: Allows for tailored print outputs, such as formatted receipts or shopping lists.
- **Web-Based Control Panel**: Includes an optional web interface for managing basic settings and monitoring.
- **Designed for Home Automation**: Perfect for smart home environments like Home Assistant.

---

## Use Cases

Here are some scenarios where PrintMQTTify shines:

1. **Smart Home Shopping Lists**:
   - Automatically print unchecked items from a Home Assistant shopping list.
   - Example scripts are available in the [HA Script Examples](https://github.com/Aesgarth/PrintMQTTify/blob/main/docs/HA%20Script%20Examples.md).

2. **Event Reminders**:
   - Print reminders or daily schedules directly from your smart home system.

3. **Custom Receipts**:
   - Generate and print receipts with tailored formatting for events or transactions.

4. **Dynamic Content Printing**:
   - Send custom messages, recipes, or instructions directly to your printer via MQTT.

---

## Prerequisites

1. **Docker**: Ensure Docker is installed and running on your system.

   - [Install Docker](https://docs.docker.com/get-docker/)

2. **Git**: Ensure Git is installed to clone the repository.

   - [Install Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)

3. **MQTT Broker**: A working MQTT broker (e.g., Mosquitto) is required. Note the broker’s IP address, username, and password.

4. **USB Printer Identification**:
   - Use `lsusb` and `dmesg | grep usb` to locate the device path of your printer.
   - Ensure the path (e.g., `/dev/usb/lp0`) is passed to the container.

   Example:
   ```bash
   lsusb
   dmesg | grep usb
   ```

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

For troubleshooting steps and common issues, see the [Troubleshooting Documentation](https://github.com/Aesgarth/PrintMQTTify/blob/main/docs/troubleshooting.md).

---

## Contributing

Contributions are welcome! Feel free to submit issues or pull requests on GitHub.

---

## License

This project is licensed under the Creative Commons Zero v1.0 Universal (CC0 1.0) License. See the [LICENSE](https://github.com/Aesgarth/PrintMQTTify/blob/main/LICENSE) file for more details.

