#!/usr/bin/env bash
set -e

update_contacts() {
  env | while IFS='=' read -r name value ; do
    if [[ $name == 'IRCD_CONTACT_'* ]]; then
      contact="${name#IRCD_CONTACT_}"
      echo "Adding contact: ${contact} : ${value}"
      CONFIG_VAL="
[contact.\"${contact}\"]
contact_pubkey=\"${value}\""
      echo "${CONFIG_VAL}" >> /root/.config/darkfi/ircd_config.toml
    fi
  done
}

update_private_channels() {
  env | while IFS='=' read -r name value ; do
    if [[ $name == 'IRCD_CHANNEL_'* ]]; then
      channel="${name#IRCD_CHANNEL_}"
      echo "Adding channel: ${channel} : ${value}"
      CONFIG_VAL="
[channel.\"#${channel}\"]
secret=\"${value}\""
      echo "${CONFIG_VAL}" >> /root/.config/darkfi/ircd_config.toml
    fi
  done

}

setup_tor_hostname() {
  EXTERNAL_ADDR="tor://$(cat /var/lib/tor/ircd/hostname):25551"
  export EXTERNAL_ADDR
  echo "Tor address for ircd: ${EXTERNAL_ADDR}"
}

setup_private_key() { 
  if [[ -z "${PRIVATE_KEY}" ]]; then
    echo "Generating a new private key..."
    PRIVATE_KEY=$(ircd --gen-secret)
  else 
    echo "Detected private key in env"
  fi
  PUBLIC_KEY="$(ircd --recover-pubkey ${PRIVATE_KEY} | awk '{print $NF}')"
  export PUBLIC_KEY
  echo "Private key: **********"
  echo "Public key : ${PUBLIC_KEY}"
  echo "Private key added to config"
  echo "[private_key.\"${PRIVATE_KEY}\"]" >> /root/.config/darkfi/ircd_config.toml
}

wait_for_tor(){
  while [ ! -f /var/lib/tor/ircd/hostname ] 
    do
      echo "Waiting for Tor to start..."
      sleep 5 # or less like 0.
  done
}
setup_tor_socks_proxy() {
  IP="socks5://$(getent hosts tor | cut -d' ' -f1):9050"
  DARKFI_TOR_SOCKS5_URL=${IP}
  export DARKFI_TOR_SOCKS5_URL
  echo "Using Tor at: ${IP}"
}

title="             ircd"
section="=================================="
output=$(wait_for_tor && setup_tor_hostname && setup_tor_socks_proxy && setup_private_key && update_private_channels && update_contacts)
msg="ircd configured. Starting..."
echo "${title}\ns${section}\n${output}\n${msg}\n${section}"
exec ircd --external-addr "${EXTERNAL_ADDR}"
