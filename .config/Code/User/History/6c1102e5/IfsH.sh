#!/bin/sh


# Run the server (publishes message)
echo "Starting server..."
python3 server.py

sleep 2

# Run the client (subscribes to messages)
#echo "Starting client..."
#python3 client.py