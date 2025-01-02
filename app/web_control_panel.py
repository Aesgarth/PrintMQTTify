from flask import Flask, render_template, request, jsonify
import subprocess
import os
import paho.mqtt.client as mqtt

app = Flask(__name__)

# Read environment variables for initial settings
mqtt_broker = os.getenv("MQTT_BROKER", "localhost")
mqtt_topic = os.getenv("MQTT_TOPIC", "printer/commands")
cups_admin_user = os.getenv("ADMIN_USER", "admin")
cups_admin_pass = os.getenv("ADMIN_PASS", "adminpassword")

@app.route('/')
def index():
    """Render the main control panel."""
    return render_template('index.html', mqtt_broker=mqtt_broker, mqtt_topic=mqtt_topic, cups_admin_user=cups_admin_user)

@app.route('/update-settings', methods=['POST'])
def update_settings():
    """Update settings from the control panel."""
    global mqtt_broker, mqtt_topic, cups_admin_user, cups_admin_pass
    mqtt_broker = request.form.get('mqtt_broker', mqtt_broker)
    mqtt_topic = request.form.get('mqtt_topic', mqtt_topic)
    cups_admin_user = request.form.get('cups_admin_user', cups_admin_user)
    cups_admin_pass = request.form.get('cups_admin_pass', cups_admin_pass)
    return jsonify({"success": True, "message": "Settings updated!"})

@app.route('/status', methods=['GET'])
def status():
    """Get the current status of the system."""
    try:
        # Get printers from CUPS
        printers = subprocess.check_output(["lpstat", "-p"], text=True)
        return jsonify({"printers": printers.strip().split("\n")})
    except Exception as e:
        return jsonify({"error": str(e)})

@app.route('/test-print', methods=['POST'])
def test_print():
    """Send a test print command."""
    printer_name = request.form.get("printer_name", "default")
    try:
        result = subprocess.run(["lp", "-d", printer_name, "/app/test_print.txt"], check=True, capture_output=True, text=True)
        return jsonify({"success": True, "output": result.stdout})
    except subprocess.CalledProcessError as e:
        return jsonify({"success": False, "error": e.stderr})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
