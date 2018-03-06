#!/bin/bash

set -e

source $(dirname $0)/helpers.sh

it_can_check_empty_path() {
    check_path "/empty_path" | jq -e '
    . == {
      version: "8a80554c91d9fca8acb82f023de02f11",
      metadata: { schema: {} }
    }
  '
}

it_can_check_schema() {
    schema=$(jq -n -c '{properties: []}')
    _credhub set -n /check_schema/schema -t json -v "${schema}"
    check_path "/check_schema" | jq -e --argjson schema "${schema}" '
    . == {
      version: "2fbda529df636fb72e8bb8e288cf9b8a",
      metadata: { schema: $schema }
    }
    '
}

run it_can_check_empty_path
run it_can_check_schema
