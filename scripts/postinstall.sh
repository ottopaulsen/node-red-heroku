# Create the flows_cred.json file with credentials from environment variables

FLOWS_CRED_FILE=.node-red/flows_cred.json
cat > $FLOWS_CRED_FILE << EOF
{
    "1183f03b.fae04": {
        "user": "${MQTT_USER}",
        "password": "${MQTT_PASSWORD}"
    },
    "d56617a5.79e518": {
        "apiKey": "${THINGSPEAK_API_KEY}"
    },
    "d11b744b.bc4f38": {
        "user": "${MQTT_PASSWORD}",
        "password": "${MQTT_PASSWORD}"
    }
}
EOF

