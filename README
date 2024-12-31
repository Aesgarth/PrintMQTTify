# PrintMQTTify

PrintMQTTify is a Docker-based solution that bridges MQTT messages to a CUPS printer, allowing you to print messages from your MQTT broker seamlessly. This project provides an easy way to connect printers to your smart home system, such as Home Assistant, and send print commands using MQTT.

---

## Features
- Provides a fully functional CUPS server.
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

## Installation

### 1. Clone the Repository
Clone the PrintMQTTify repository to your local machine:
```bash
git clone https://github.com/<your-username>/PrintMQTTify.git
cd PrintMQTTify
```

### 2. Build the Docker Image
Build the Docker image using the included `Dockerfile`:
```bash
docker build -t printmqttify .
```

### 3. Run the Docker Container
Start the container with the following command:
```bash
docker run --name printmqttify_container \
  -d \
  --privileged \
  -p 1631:631 \
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

## Setup

### 1. Access the CUPS Web Interface
1. Open a browser and navigate to:
   ```
   https://<host-ip>:1631
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

1. **Cannot Access CUPS Web Interface**:
   - Ensure the container is running.
   - Confirm that port `1631` is not blocked by a firewall.

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
This project is licensed under the Creative Commons Zero v1.0 Universal (CC0 1.0). See the `LICENSE` file for details.


