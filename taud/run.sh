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
  EXTERNAL_ADDR="tor://$(cat /var/lib/tor/taud/hostname):25551"
  export EXTERNAL_ADDR
  echo "Tor address for taud: ${EXTERNAL_ADDR}"
}

setup_tor_socks_proxy() {
  IP="socks5://$(getent hosts tor | cut -d' ' -f1):9050"
  DARKFI_TOR_SOCKS5_URL=${IP}
  export DARKFI_TOR_SOCKS5_URL
  echo "Using Tor at: ${IP}"
}

update_workspaces() {
  env | while IFS='=' read -r name key ; do
    if [[ $name == 'WORKSPACE_'* ]]; then
      workspace="${name#WORKSPACE_}"
      echo "Adding workspace: ${workspace} : ${key}"
      WORKSPACES="${WORKSPACES} --workspaces ${workspace}:${key}"
    fi
  done
}

wait_for_tor
setup_tor_hostname
setup_tor_socks_proxy
update_workspaces
echo "Starting taud..."
exec taud --external-addr "${EXTERNAL_ADDR}"
