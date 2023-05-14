#!/usr/bin/env bash
# Create the default config file

_is_sourced() {
	# https://unix.stackexchange.com/a/215279
	[ "${#FUNCNAME[@]}" -ge 2 ] \
		&& [ "${FUNCNAME[0]}" = '_is_sourced' ] \
		&& [ "${FUNCNAME[1]}" = 'source' ]
}

_main() {
  /usr/local/bin/ircd
  echo "Get shell access into the container with: docker exec -it <container> /bin/bash to edit the config file"
  echo "\$ vi '~/config/darkfi/ircd_config.toml'"
  /usr/local/bin/ircd
}

if ! _is_sourced; then
	_main "$@"
fi

