#!/bin/bash

set -e

source $(dirname $0)/helpers.sh

it_can_get_empty_path() {
    _get "/get_empty_path" | \
        jq -e '.version.md5 == "8a80554c91d9fca8acb82f023de02f11"'
}

it_can_validate_type_string() {
    schema=$(jq -n -c '{properties: {foo: {type: "string" }}}')
    _credhub set -n /get_validate_string/schema -t json -v "${schema}"
    _credhub set -n /get_validate_string/foo -t value -v "bar"
    _get "/get_validate_string" | \
        jq -e '.version.md5 == "00b797cb94936cd9772d11c2ee5a4325"'
}

it_can_validate_type_integer() {
    schema=$(jq -n -c '{properties: {foo: {type: "integer" }}}')
    _credhub set -n /get_validate_integer/schema -t json -v "${schema}"
    _credhub set -n /get_validate_integer/foo -t value -v "42"
    _get "/get_validate_integer" | \
        jq -e '.version.md5 == "8cc31dd1b55544a8bc142a80dd8930a2"'
}

it_can_validate_type_object() {
    schema=$(jq -n -c '{properties: {foo: {type: "object", properties: {foo: {type: "string"}}}}}')
    _credhub set -n /get_validate_object/schema -t json -v "${schema}"
    _credhub set -n /get_validate_object/foo -t json -v '{"foo":"bar"}'
    _get "/get_validate_object" | \
        jq -e '.version.md5 == "4a06e28d2b58a94d241ec2c4065bdd11"'
}

it_can_default_type_string() {
    schema=$(jq -n -c '{properties: {foo: {type: "string", default: "bar"}}}')
    _credhub set -n /get_default_string/schema -t json -v "${schema}"
    _get "/get_default_string" | \
        jq -e '.version.md5 == "4831d745a0a6a73d6d699bc5a6483935"'
    _credhub get -n /get_default_string/foo -j | \
        jq -e '.value == "bar"'
}

it_can_default_type_object() {
    schema=$(jq -n -c '{properties: {foo: {type: "object", default: {foo: "bar"}}}}')
    _credhub set -n /get_default_object/schema -t json -v "${schema}"
    _get "/get_default_object" | \
        jq -e '.version.md5 == "70484c00ad70f3e861642579482514f0"'
    _credhub get -n /get_default_object/foo -j | \
        jq -e '.value.foo == "bar"'
}

it_validates_required_fields() {
    schema=$(jq -n -c '{properties: {foo: {type: "string"}}, required: ["foo"]}')
    _credhub set -n /get_required_string/schema -t json -v "${schema}"
    set +e
    out=$(_get "/get_required_string" 2>&1)
    set -e
    echo ${out} | grep 'required'
}

run it_can_get_empty_path
run it_can_validate_type_string
run it_can_validate_type_integer
run it_can_validate_type_object
run it_can_default_type_string
run it_can_default_type_object
run it_validates_required_fields
