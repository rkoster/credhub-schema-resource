#!/bin/bash

set -e

source $(dirname $0)/helpers.sh

it_can_check_empty_path() {
    _check "/empty_path" | \
        jq -e '.version.md5 == "8a80554c91d9fca8acb82f023de02f11"'
}

it_can_check_schema() {
    schema=$(jq -n -c '{properties: []}')
    _credhub set -n /check_schema/schema -t json -v "${schema}"
    _check "/check_schema" | \
        jq -e '.version.md5 == "6917b7c95f545d7faf1d7c8d54a15e69"'
}

run it_can_check_empty_path
run it_can_check_schema
