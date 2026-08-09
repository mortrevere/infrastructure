FROM debian:bookworm-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ansible \
        ca-certificates \
        gnupg \
        openssh-client \
        rsync \
        wget \
    && wget -O- https://apt.releases.hashicorp.com/gpg \
        | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com bookworm main" \
        > /etc/apt/sources.list.d/hashicorp.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        terraform \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /ansible /terraform /terraform-providers /tmp/ansible /tmp/terraform

COPY terraform/provider.tf /terraform/provider.tf

RUN mkdir -p /tmp/terraform-mirror \
    && cp /terraform/provider.tf /tmp/terraform-mirror/provider.tf \
    && TF_CLI_CONFIG_FILE=/dev/null terraform -chdir=/tmp/terraform-mirror init -backend=false -input=false \
    && TF_CLI_CONFIG_FILE=/dev/null terraform -chdir=/tmp/terraform-mirror providers mirror /terraform-providers \
    && rm -rf /tmp/terraform-mirror /root/.terraform.d

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
COPY terraform.rc /etc/terraformrc
COPY terraform /terraform
COPY ansible /ansible

WORKDIR /ansible

ENV TF_CLI_CONFIG_FILE=/etc/terraformrc

ENTRYPOINT ["docker-entrypoint.sh"]
CMD []
