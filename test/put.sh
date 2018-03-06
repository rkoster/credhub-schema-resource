#!/bin/bash

set -e

source $(dirname $0)/helpers.sh

it_can_put_yaml_schema() {
    echo "properties: ['foo']" > ${TMPDIR}/schema.yml
    schema=$(spruce json ${TMPDIR}/schema.yml)
    _put "/put_yaml_schema" "schema.yml" | jq -e --argjson schema "${schema}" '
    . == {
      version: "e828be2b9750848cfcd3f7599843aa27",
      metadata: { schema: $schema }
    }
    '
}

it_can_put_json_schema() {
    jq -n -c '{properties: ["bar"]}' > ${TMPDIR}/schema.json
    schema=$(cat ${TMPDIR}/schema.json)
    _put "/put_yaml_schema" "schema.json" | jq -e --argjson schema "${schema}" '
    . == {
      version: "e828be2b9750848cfcd3f7599843aa27",
      metadata: { schema: $schema }
    }
    '
}

run it_can_put_yaml_schema
run it_can_put_json_schema
