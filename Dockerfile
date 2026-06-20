FROM debian:bookworm-slim

ENV ANSIBLE_HOST_KEY_CHECKING=True \
    ANSIBLE_RETRY_FILES_ENABLED=False

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

RUN mkdir -p /ansible /terraform /tmp/ansible /tmp/terraform

WORKDIR /ansible

COPY ansible.cfg inventory.ini playbook.yml README.md /ansible/
COPY group_vars /ansible/group_vars
COPY templates /ansible/templates
COPY terraform /terraform
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]
CMD []
