import paho.mqtt.client as mqtt
import os
import subprocess
import json

# Read broker, username, and password from environment variables
broker = os.getenv("MQTT_BROKER", "localhost")
username = os.getenv("MQTT_USERNAME")
password = os.getenv("MQTT_PASSWORD")
topic = os.getenv("MQTT_TOPIC", "printer/commands")

def on_connect(client, userdata, flags, rc):
    """Callback for when the client connects to the MQTT broker."""
    if rc == 0:
        print("Connected to MQTT broker!")
        client.subscribe(topic)
    else:
        print(f"Failed to connect, return code {rc}")

def on_message(client, userdata, msg):
    """Callback for when a message is received."""
    print(f"Received message: {msg.payload.decode()} on topic {msg.topic}")
    try:
        # Parse the message payload
        payload = json.loads(msg.payload.decode())
        printer_name = payload.get("printer_name")
        message = payload.get("message")
        
        if printer_name and message:
            # Send the message to the specified printer
            print_message(printer_name, message)
        else:
            print("Invalid message format. Expected 'printer_name' and 'message'.")
    except json.JSONDecodeError as e:
        print(f"Error decoding JSON: {e}")
    except Exception as e:
        print(f"Error processing message: {e}")

def print_message(printer_name, message):
    """Send a print job to the specified printer using the CUPS lp command."""
    try:
        result = subprocess.run(
            ["lp", "-d", printer_name],
            input=message.encode(),
            text=True,
            capture_output=True
        )
        if result.returncode == 0:
            print(f"Successfully printed to {printer_name}: {message}")
        else:
            print(f"Failed to print. Error: {result.stderr}")
    except Exception as e:
        print(f"Error sending print job: {e}")

# Create an MQTT client instance
client = mqtt.Client(protocol=mqtt.MQTTv311)

# Set username and password if provided
if username and password:
    client.username_pw_set(username, password)

# Assign callback functions
client.on_connect = on_connect
client.on_message = on_message

# Connect to the broker
client.connect(broker, 1883, 60)

# Start the MQTT loop
client.loop_forever()
