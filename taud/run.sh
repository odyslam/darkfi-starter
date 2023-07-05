#!/usr/bin/env bash
set -e

WORKSPACES=""
wait_for_tor(){
  while [ ! -f /var/lib/tor/taud/hostname ] 
    do
      echo "Waiting for Tor to start..."
      sleep 5 # or less like 0.
  done
}

setup_tor_hostname() {
  EXTERNAL_ADDR="tor+tls://$(cat /var/lib/tor/taud/hostname):25551"
  export EXTERNAL_ADDR
  echo "Tor address for taud: ${EXTERNAL_ADDR}"
  echo "external_addrs = [\"${EXTERNAL_ADDR}\"]" >> /root/.config/darkfi/taud_config.toml
  
}

setup_tor_socks_proxy() {
  IP="socks5://$(getent hosts tor | cut -d' ' -f1):9050"
  DARKFI_TOR_SOCKS5_URL=${IP}
  export DARKFI_TOR_SOCKS5_URL
  echo "Using Tor at: ${IP}"
}

update_workspaces() {
  while IFS='=' read -r name key; do
    if [[ $name == 'WORKSPACE_'* ]]; then
      workspace="${name#WORKSPACE_}"
      echo "Adding workspace: ${workspace} : ${key}"
      WORKSPACES="\"${workspace}:${key}\","
    fi
  done < <(env)
  sed -i "1s/^/workspaces=[${WORKSPACES%?}]\n/" /root/.config/darkfi/taud_config.toml
}

update_nickname() {
  if [ -z "${NICK}" ]; then
    NICK="darkfi-$RANDOM"
    echo "No nickname set, using default: ${NICK}"
  fi
  echo "Using nickname: ${NICK}"
  sed -i "1s/^/nickname=\"${NICK}\"\n/" /root/.config/darkfi/taud_config.toml
}
title="             taud"
section="=================================="
output=$(wait_for_tor && setup_tor_hostname && setup_tor_socks_proxy && update_workspaces && update_nickname)
msg="taud configured. Starting..."
echo "${title}\ns${section}\n${outputotput}\n${msg}\n${section}"
exec taud 
