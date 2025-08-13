#!/bin/bash

echo "==============================================="
echo "MMS Listener Application Test Script"
echo "==============================================="
echo

echo "Building the application..."
mvn clean package -DskipTests

if [ $? -ne 0 ]; then
    echo "Build failed!"
    exit 1
fi

echo
echo "Build successful!"
echo

echo "Starting in LISTENER mode..."
echo "Make sure the MMS backend is running on http://localhost:8080"
echo
read -p "Press Enter to continue..."
java -jar target/mms-listener-1.0.0-SNAPSHOT.jar
