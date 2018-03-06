export TMPDIR=${TMPDIR:-/tmp}

payload=$(mktemp $TMPDIR/credhub-schema-resource-request.XXXXXX)
schema=$(mktemp $TMPDIR/credhub-schema-resource-schema.XXXXXX)
doc=$(mktemp $TMPDIR/credhub-schema-resource-doc.XXXXXX)
changes=$(mktemp $TMPDIR/credhub-schema-resource-changes.XXXXXX)
errors=$(mktemp $TMPDIR/credhub-schema-resource-errors.XXXXXX)

configure_credhub() {
    export CREDHUB_SERVER=$(jq -r '.source.server // ""' < $payload)
    export CREDHUB_CLIENT=$(jq -r '.source.client_name // ""' < $payload)
    export CREDHUB_SECRET=$(jq -r '.source.client_secret // ""' < $payload)

    ca_cert=$(jq -r '.source.ca_cert // ""' < $payload)
    if [[ "${ca_cert}" != "" ]]; then
        export CREDHUB_CA_CERT="${ca_cert}"
    fi

    username=$(jq -r '.source.username // ""' < $payload)
    password=$(jq -r '.source.password // ""' < $payload)

    if [[ "${username}" != "" ]]; then
      credhub login -u ${username} -p ${password} > /dev/null
    fi
}

# get json schema for given path from credhub
# which is expected to be stored in credhub under path/schema
# also sort the keys for schema versioning
credhub_get_schema() {
    if credhub find -p "$(credhub_path)" 2>&1| grep -q $(schema_path); then
        credhub get --name $(schema_path) -j | jq -S -c '.value'
    else
        echo '{}'
    fi
}

credhub_path() {
    local credhub_path=$(jq -r '.source.path // "/"' < $payload)
    echo "${credhub_path%/}"
}

schema_path() {
    echo "$(credhub_path)/schema"
}

version() {
    jq --arg version $(md5sum ${schema} | cut -d' ' -f1) \
       -c -n '{ version: { md5: $version } }'
}
