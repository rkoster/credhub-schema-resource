#!/bin/bash

if [ ! -f config.json ]; then
  vars=$(bucc vars)
  get_var() {
      printf "\"$(bosh int <(echo -e "${vars}") --path /${1})\""
  }


  jq -n ".source = {
    server: $(get_var credhub_url),
    client_name: $(get_var credhub_username),
    client_secret: $(get_var credhub_password),
    ca_cert: $(get_var bosh_ca_cert),
    path: \"/ci/test/\"
  }" > config.json
fi

docker build . -t credhub-schema-resource:dev > /dev/null

cat config.json | docker run -i credhub-schema-resource:dev /opt/resource/in /tmp/foo
