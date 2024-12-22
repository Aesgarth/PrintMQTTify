import paho.mqtt.client as mqtt
import subprocess
import json

# MQTT settings
MQTT_BROKER = "YOUR_MQTT_BROKER_IP"
MQTT_PORT = 1883
MQTT_TOPIC = "homeassistant/printer/+/print"  # + acts as a wildcard for printer names

# Callback when an MQTT message is received
def on_message(client, userdata, msg):
    try:
        # Extract printer name from the topic
        printer_name = msg.topic.split('/')[-2]
        
        # Parse the message payload
        payload = json.loads(msg.payload.decode())
        message = payload.get("message", "No message provided")
        
        # Send the message to the printer
        print(f"Printing to {printer_name}: {message}")
        subprocess.run(["lp", "-d", printer_name], input=message.encode())
    except Exception as e:
        print(f"Error processing message: {e}")

# Initialize MQTT client
client = mqtt.Client()
client.on_message = on_message

# Connect to the MQTT broker
client.connect(MQTT_BROKER, MQTT_PORT)
client.subscribe(MQTT_TOPIC)

# Start listening for MQTT messages
print("Listening for MQTT messages...")
client.loop_forever()
