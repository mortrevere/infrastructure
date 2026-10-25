# Infrastructure

Terraform and Ansible stacks for the servers I manage.

## Choices

- Only prerequisite is `docker`: one image provides both Terraform and Ansible, so I'm not dependant on the local setup 
- As automated as possible: covers everything, no manual intervention, idempotency
- Should work on slow/unstable connections: remote server does the work
- Ansible mounts the SSH agent and `~/.ssh`; all tasks default to the `prod` group.

## Ansible

```bash
./ansible.sh
./ansible.sh --check --diff --ask-become-pass
./ansible.sh -e target_hosts=prod --ask-become-pass
```

Apply host hardening without rebuilding websites or upgrading Docker:

```bash
./ansible.sh --tags web
./ansible.sh --tags hardening
./ansible.sh --tags umami
./ansible.sh -e target_hosts=house --tags node-exporter
```

`security` and `firewall` can also be applied separately. Firewall reloads replace
only the host policy and preserve Docker's tables. Public SSH requires keys;
WireGuard peer routing and VPN-only metrics remain available.

Each entry in `ansible/group_vars/prod.yml` declares one website. `www` aliases
(default: enabled), HTTPS redirects, certificate domains, and web roots are derived
from its name. Set `www: false` for hosts such as `stats.leo.surf`. A site has a
local `www_source`, a `jinjapocalypse_git_source`, or a proxy `upstream`.
Local directory sources use `www_deploy_strategy: rsync_checksum`; single files
use the default copy behavior. Generated sites still rebuild hourly.

`--tags web` deploys content and nginx/certificates on a provisioned host without
upgrading Docker. A missing certificate enables HTTP challenges for that site;
existing sites retain HTTPS. Apply DNS before requesting a new certificate.
Static sites allow browser reads from `https://leo.surf`; Umami supplies its own
CORS headers so analytics works across the hosted websites. SSH host key checking
is disabled in `ansible.cfg`, including synchronization through `use_ssh_args`.
`--check` previews directory synchronization on provisioned hosts with staging
already present; it does not issue certificates or rebuild generated sites.

Umami uses `/etc/umami/compose.yml`, with pinned images and root-only persistent
secrets in `/etc/umami/secrets.json` and `/etc/umami/umami.env`. It requires the
existing `umami_umami-db-data` volume and never creates a replacement database.
Use the managed Compose file rather than `/opt/umami/docker-compose.yml`.
Back up the database before changing the pinned image: application upgrades can
run schema migrations. Changing the application secret invalidates existing sessions.

## Terraform

Only manages OVH DNS zones for now. TF state is in a S3 bucket. 

Set the OVH credentials and state backend variables first:

```bash
export OVH_APPLICATION_KEY=...
export OVH_APPLICATION_SECRET=...
export OVH_CONSUMER_KEY=...
export OVH_TF_STATE_BUCKET=...
export OVH_TF_STATE_REGION=...
export OVH_TF_STATE_ENDPOINT=...
export OVH_TF_STATE_ACCESS_KEY=...
export OVH_TF_STATE_SECRET_KEY=...
```

Then run Terraform:

```bash
./terraform.sh plan
./terraform.sh
```

## TL;DR

```bash
./terraform.sh && ./ansible.sh
```

