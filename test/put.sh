#!/bin/bash

set -e

source $(dirname $0)/helpers.sh

it_can_put_yaml_schema() {
    echo "properties: ['foo']" > ${TMPDIR}/schema.yml
    schema=$(spruce json ${TMPDIR}/schema.yml)
    _put "/put_yaml_schema" "schema.yml" | \
        jq -e '.version.md5 == "52cecb3000840402451e5f92bf470f0f"'
}

it_can_put_json_schema() {
    jq -n -c '{properties: ["bar"]}' > ${TMPDIR}/schema.json
    schema=$(cat ${TMPDIR}/schema.json)
    _put "/put_yaml_schema" "schema.json" | \
        jq -e '.version.md5 == "28459155d37cb2c2e35337d95e61e226"'
}

run it_can_put_yaml_schema
run it_can_put_json_schema
