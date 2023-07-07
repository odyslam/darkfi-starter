#!/usr/bin/env sh 
# Tor seems not to be able to reason about the docker-based dns networking
# so we need to get the ip of the ircd container and use that instead
IP=$(getent hosts ircd | cut -d' ' -f1)
read -r -d '' CONFIG << EOM
HiddenServiceDir /var/lib/tor/ircd/
HiddenServicePort 25551 ${IP}:25551
HiddenServiceDir /var/lib/tor/taud/
HiddenServicePort 25551 ${IP}:23331
SOCKSPort 0.0.0.0:9050
SOCKSPolicy accept ${IP}/16
EOM
echo "$CONFIG" > /etc/tor/torrc
exec tor
