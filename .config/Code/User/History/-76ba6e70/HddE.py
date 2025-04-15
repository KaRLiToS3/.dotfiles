import sys

import paho.mqtt.client as paho
import threading
import time

def testClient():
    time.sleep(2)
    for i in range(10):
        client = paho.Client(protocol=paho.MQTTv5)

        print("Connecting to the mqtt broker...")

        if client.connect("mosquitto", 1883, 60) != 0:
            print("Couldn't connect to the mqtt broker")
            sys.exit(1)

        client.publish("test_topic", "Hi, paho mqtt client works fine!", 0)
        time.sleep(1)

    client.disconnect()

def message_handling(client, userdata, msg):
    print(f"{msg.topic}: {msg.payload.decode()}")

print("OK")
hilo = threading.Thread(target=testClient)
hilo.start()
print("Hilo empezado")
client = paho.Client(protocol=paho.MQTTv5)
print("We made it")
client.on_message = message_handling

if client.connect("mosquitto", 1883, 60) != 0:
    print("Couldn't connect to the mqtt broker")
    sys.exit(1)

client.subscribe("test_topic")

try:
    print("Press CTRL+C to exit...")
    client.loop_forever()
except Exception:
    print("Caught an Exception, something went wrong...")
finally:
    print("Disconnecting from the MQTT broker")
    client.disconnect()