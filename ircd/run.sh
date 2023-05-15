#!/usr/bin/env bash
set -e

update_contacts() {
  env | while IFS='=' read -r name value ; do
    if [[ $name == 'IRCD_CONTACT_'* ]]; then
      contact="${name#IRCD_CONTACT_}"
      echo "Adding contact: ${contact} : ${value}"
      CONFIG_VAL="[contacts.\"${contact}\"]
contact_pubkey=\"${value}\""
      echo "${CONFIG_VAL}" >> /root/.config/darkfi/ircd_config.toml
    fi
  done
}

setup_tor_hostname() {
  while [ ! -f /var/lib/tor/ircd/hostname ]
  do
    echo "Waiting for Tor to start..."
    sleep 15 # or less like 0.2
  done
  EXTERNAL_ADDR="tor://$(cat /var/lib/tor/ircd/hostname):25551"
  echo "Tor address for ircd: ${EXTERNAL_ADDR}"
}

setup_private_key() { 
  if [[ -z "${PRIVATE_KEY}" ]]; then
    echo "Generating a new private key..."
    PRIVATE_KEY=$(ircd --gen-secret)
  else 
    echo "Using provided private key..."
  fi
  PUBLIC_KEY="$(ircd --recover-pubkey ${PRIVATE_KEY} | awk '{print $NF}')"
  echo "Private key: ********"
  echo "Public key: ${PUBLIC_KEY}"
  echo "Adding the private key to ircd config..."
  echo "[private_key.\"${PRIVATE_KEY}\"]" >> /root/.config/darkfi/ircd_config.toml
}

wait_for_tor(){
  rm -f /var/lib/tor/ircd/hostname
  while [ ! -f /var/lib/tor/ircd/hostname ] 
    do
      echo "Waiting for Tor to start..."
      sleep 5 # or less like 0.
  done
}
setup_tor_hostname
setup_private_key
update_contacts
cat /root/.config/darkfi/ircd_config.toml
echo "Starting ircd..."
exec ircd --external-addr "${EXTERNAL_ADDR}"
