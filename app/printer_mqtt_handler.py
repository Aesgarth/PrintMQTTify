import paho.mqtt.client as mqtt
import os
import subprocess
from reportlab.pdfgen import canvas
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
        payload = json.loads(msg.payload.decode())
        printer_name = payload.get("printer_name")
        title = payload.get("title", "Print Job")
        message = payload.get("message", "No message provided")

        if not printer_name:
            raise ValueError("Missing 'printer_name' in payload")

        # Generate a formatted PDF
        pdf_path = generate_pdf(title, message)

        # Send the PDF to the printer
        send_to_printer(printer_name, pdf_path)

    except json.JSONDecodeError as e:
        print(f"Error decoding JSON: {e}")
    except Exception as e:
        print(f"Error handling message: {e}")

def generate_pdf(title, message):
    """Generate a PDF with the given title and message."""
    pdf_path = "/tmp/print_job.pdf"
    c = canvas.Canvas(pdf_path)
    c.setFont("Helvetica-Bold", 16)
    c.drawString(100, 750, title)
    c.setFont("Helvetica", 12)
    c.drawString(100, 700, message)
    c.showPage()
    c.save()
    return pdf_path

def send_to_printer(printer_name, pdf_path):
    """Send the generated PDF to the printer."""
    try:
        result = subprocess.run(
            ["lp", "-d", printer_name, pdf_path],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            check=True
        )
        print(f"Printed successfully: {result.stdout.decode()}")
    except subprocess.CalledProcessError as e:
        print(f"Failed to print. Error: {e.stderr.decode()}")

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
