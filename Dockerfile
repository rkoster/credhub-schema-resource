FROM ubuntu

RUN apt-get update && \
    apt-get install -yy wget curl

RUN wget -q -O - https://raw.githubusercontent.com/starkandwayne/homebrew-cf/master/public.key | apt-key add - \
    && echo "deb http://apt.starkandwayne.com stable main" | tee /etc/apt/sources.list.d/starkandwayne.list \
    && apt-get update && apt-get install -y \
       jq \
       credhub-cli

RUN curl -sL https://deb.nodesource.com/setup_9.x | bash - && \
    apt-get install -y nodejs

RUN npm install -g ajv-cli

COPY assets/check     /opt/resource/check
COPY assets/in        /opt/resource/in
COPY assets/out       /opt/resource/out
COPY assets/common.sh /opt/resource/common.sh
