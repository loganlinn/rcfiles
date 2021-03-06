#!/usr/bin/env bash

# @file asdf-up.sh
# @brief Install and configure asdf version manager
# @description
#     This can be used to boostrap asdf on a clean machine.
#     Enables plugins to be configured via file.
#     Designed to be used as pre/post-up hook for [rcm](https://github.com/thoughtbot/rcm).
# @see https://asdf-vm.com

[[ ${TRACE-} ]] && set -x

set -euo pipefail

ASDF_DIR=${ASDF_DIR:-$HOME/.asdf}
ASDF_DEFAULT_TOOL_VERSIONS_FILENAME=${ASDF_DEFAULT_TOOL_VERSIONS_FILENAME:-$HOME/.tool-versions}

function print_section() {
  >&2 printf '\n\033[1m%s\033[m\n\n%s\n' "$1" "$(sed -e "s/^/    /" -)" 
}

function asdf-missing-plugins() {
	cut -d' ' -f1 "${1--}" | sort |
		comm -23 - <(asdf plugin list 2>/dev/null | sort) |
		join -a1 - <(asdf plugin list all 2>/dev/null)
}

function main() {
	if ! [[ -d $ASDF_DIR ]]; then
		git clone https://github.com/asdf-vm/asdf.git "$ASDF_DIR"
	fi

	# shellcheck source=/dev/null
	source "${ASDF_DIR}/asdf.sh"

	echo "asdf update"
	asdf update 2>/dev/null

	# setup tool plugins
	if [[ -f $ASDF_DEFAULT_TOOL_VERSIONS_FILENAME ]]; then
		while read -r plugin; do
			(
				echo "asdf plugin add $plugin"
				# shellcheck disable=SC2086
				asdf plugin add $plugin
			)
		done < <(asdf-missing-plugins "$ASDF_DEFAULT_TOOL_VERSIONS_FILENAME")
	fi

	asdf version 2>&1 | print_section "ASDF VERSION"
	env | grep '^ASDF_' | print_section "ASDF ENVIRONMENT VARIABLES"
	asdf plugin list --urls 2>&1 | print_section "ASDF PLUGINS"
  asdf current 2>&1 | print_section "ASDF CURRENT"
}

main
