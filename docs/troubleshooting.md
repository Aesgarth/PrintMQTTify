Troubleshooting

Changing Port Mapping

If the default port 631 is already in use by another service (e.g., a host-installed CUPS instance), you can modify the port mapping in the Docker run or Compose configuration:

For docker run, replace -p 631:631 with an alternative mapping like -p 1631:631.

For Docker Compose, update the ports section to:

ports:
  - "1631:631"

Ensure you update the port in the browser URL to match the new mapping (e.g., https://<host-ip>:1631).

Common Issues

Cannot Access CUPS Web Interface:

Ensure the container is running.

Confirm that port 631 is not blocked by a firewall.

Printer Not Printing:

Check the printer status in the CUPS web interface.

Ensure the correct driver is installed.

MQTT Issues:

Verify the MQTT broker details in the container environment variables.

Check the MQTT topic for incoming messages.

