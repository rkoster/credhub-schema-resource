#!/bin/bash

set -e

. "$(dirname "$0")/helpers.sh"

it_has_installed_ajv() {
    test -x /usr/bin/ajv
}

it_has_installed_spruce() {
    test -x /usr/bin/spruce
}

run it_has_installed_ajv
run it_has_installed_spruce
