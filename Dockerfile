FROM debian:bookworm-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ansible \
        ca-certificates \
        gnupg \
        openssh-client \
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

WORKDIR /ansible

COPY ansible.cfg inventory.ini playbook.yml README.md /ansible/
COPY group_vars /ansible/group_vars
COPY templates /ansible/templates
COPY terraform /terraform
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
COPY terraform.rc /etc/terraformrc

ENV TF_CLI_CONFIG_FILE=/etc/terraformrc

RUN TF_CLI_CONFIG_FILE=/dev/null terraform -chdir=/terraform init -backend=false -input=false -lockfile=readonly \
    && TF_CLI_CONFIG_FILE=/dev/null terraform -chdir=/terraform providers mirror /terraform-providers \
    && rm -rf /terraform/.terraform /root/.terraform.d

ENTRYPOINT ["docker-entrypoint.sh"]
CMD []
