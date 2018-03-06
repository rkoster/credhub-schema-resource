#!/bin/bash

echo "Starting Credhub"
cd /credhub
nohup ./gradlew --no-daemon bootRun \
                 -Djava.security.egd=file:/dev/urandom \
                 -Djdk.tls.ephemeralDHKeySize=2048 \
                 -Djdk.tls.namedGroups="secp384r1" \
                 -Djavax.net.ssl.trustStore=/credhub/src/test/resources/auth_server_trust_store.jks \
                 -Djavax.net.ssl.trustStorePassword=changeit &

credhub_url="${CREDHUB_URL:-https://localhost:9000}"

credhub_running() {
    output=$(curl -k --retry 5 --max-time 5 --connect-timeout 2 -k --silent ${credhub_url}/health || echo "{}")
    echo ${output} | jq -e '.status == "UP"' > /dev/null
}
while ! credhub_running; do sleep 1; done

echo -e "Credhub is Running\n\n"
