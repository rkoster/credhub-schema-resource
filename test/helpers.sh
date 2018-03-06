#!/bin/bash

set -e -u

set -o pipefail

export TMPDIR_ROOT=$(mktemp -d /tmp/credhub-schema-tests.XXXXXX)
trap "rm -rf $TMPDIR_ROOT" EXIT

if [ -d /opt/resource ]; then
    resource_dir=/opt/resource
else
    resource_dir=$(cd $(dirname $0)/../assets && pwd)
fi

credhub_url="${CREDHUB_URL:-https://localhost:9000}"

ca_cert() {
    if [ -d /credhub ]; then
        cat /credhub/src/test/resources/{server_ca_cert.pem,ca/dev_uaa.pem}
    else
        echo | openssl s_client -connect localhost:9000 2>&1 | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p'
        cat ${resource_dir}/../test/credhub/src/src/test/resources/ca/dev_uaa.pem
    fi
}

_credhub() {
    export HOME=$(mktemp -d)
    export CREDHUB_SERVER=${credhub_url}
    export CREDHUB_CA_CERT=$(ca_cert)
    credhub login -u credhub -p password > /dev/null
    credhub "$@" > /dev/null
}

config() {
    jq -n -c \
       --arg path "$1" \
       --arg url "${credhub_url}" \
       --arg ca "$(ca_cert)"  \
    '{
      username: "credhub",
      password: "password",
      server: $url,
      ca_cert: $ca,
      path: $path
    } | { source: . }'
}

run() {
    export TMPDIR=$(mktemp -d ${TMPDIR_ROOT}/credhub-schema-tests.XXXXXX)

    echo -e 'running \e[33m'"$@"$'\e[0m...'
    eval "$@" 2>&1 | sed -e 's/^/  /g'
    echo ""
}

check_path() {
    config $1 | ${resource_dir}/check | tee /dev/stderr
}
