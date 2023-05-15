#!/usr/bin/env bash
# Create the default config file
rm /var/lib/tor/ircd/hostname
while [ ! -f /var/lib/tor/ircd/hostname ]
do
  echo "Waiting for Tor to start..."
  sleep 15 # or less like 0.2
done
EXTERNAL_ADDR=$(cat /var/lib/tor/ircd/hostname)
echo "Tor address for ircd: tor://${EXTERNAL_ADDR}:25551"
echo "Starting ircd..."
ircd --external-addr "tor://${EXTERNAL_ADDR}:25551" 
