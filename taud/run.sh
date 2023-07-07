#!/usr/bin/env bash
set -e

TAUD_WORKSPACES=""
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
    if [[ $name == 'TAUD_WORKSPACE_'* ]]; then
      workspace="${name#TAUD_WORKSPACE_}"
      echo "Adding workspace: ${workspace} : ${key}"
      TAUD_WORKSPACES="\"${workspace}:${key}\","
    fi
  done < <(env)
  sed -i "1s/^/workspaces=[${TAUD_WORKSPACES%?}]\n/" /root/.config/darkfi/taud_config.toml
}

update_nickname() {
  if [ -z "${TAUD_NICKNAME}" ]; then
    TAUD_NICKNAME="darkfi-$RANDOM"
    echo "No nickname set, using default: ${TAUD_NICKNAME}"
  fi
  echo "Using nickname: ${TAUD_NICKNAME}"
  sed -i "1s/^/nickname=\"${TAUD_NICKNAME}\"\n/" /root/.config/darkfi/taud_config.toml
}
title="             taud"
section="=================================="
output=$(wait_for_tor && setup_tor_hostname && setup_tor_socks_proxy && update_workspaces && update_nickname)

msg="taud configured. Starting..."
printf "%s\n%s\n%s\n%s\n%s\n" "${title}" "${section}" "${output}" "${msg}" "${section}"
exec taud 
