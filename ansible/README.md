# Infrastructure stack

Minimal Terraform and Ansible stack for managing OVH DNS records, nginx sites,
static web roots, and Certbot certificates over SSH.

## Files

- `inventory.ini` defines the target host groups.
- `Dockerfile` installs Terraform and Ansible in a shared local image.
- `build.sh` builds the shared local Docker image.
- `ansible.sh` builds the image and passes all arguments through to
  `ansible-playbook playbook.yml`.
- `terraform.sh` builds the image, initializes Terraform with the remote state
  backend, and runs Terraform. With no arguments it runs `apply -auto-approve`.
- Terraform providers are mirrored into the image at build time and the runtime
  uses that local mirror instead of downloading providers on the fly.
- `terraform/` manages OVH DNS records for `below.black`,
  `below.industries`, `leo.surf`, and `yoko.cat`.
- `playbook.yml` installs nginx/certbot/git/nftables packages, installs the latest Docker Engine
  from Docker's upstream apt repository with the Compose plugin, creates the expected web roots,
  deploys static site content declared with `www_source`, builds git-backed
  Jinjapocalypse sites declared with `jinjapocalypse_git_source`,
  bootstraps missing certificates, installs the nftables firewall policy,
  installs nginx config files, enables Certbot renewal, recreates
  `/home/<owner>/www -> /usr/share/nginx/html`, and reloads nginx after
  `nginx -t` passes.
- `group_vars/all.yml` contains shared defaults. `group_vars/dev.yml` and
  `group_vars/prod.yml` are the environment-specific source of truth for
  websites, server blocks, certificate lineages, web roots, redirects, cache
  headers, proxy rules, and static content sources.
- `templates/site.conf.j2` renders final nginx site configs from the selected
  environment variables.
- `templates/acme-bootstrap.conf.j2` renders temporary HTTP-only nginx config for
  first-time ACME HTTP-01 certificate issuance.

## Apply

Apply DNS first when needed:

```bash
./terraform.sh
```

Then apply the server configuration:

```bash
./ansible.sh --ask-become-pass
```

`terraform.sh` requires OVH API credentials and OVH Object Storage state
credentials. Set `OVH_ENDPOINT` when you need an API endpoint other than the
default `ovh-eu`.

Required Terraform environment:

```bash
export OVH_APPLICATION_KEY=...
export OVH_APPLICATION_SECRET=...
export OVH_CONSUMER_KEY=...
export OVH_TF_STATE_BUCKET=...
export OVH_TF_STATE_REGION=...
export OVH_TF_STATE_ENDPOINT=https://s3.<region>.io.cloud.ovh.net
export OVH_TF_STATE_ACCESS_KEY=...
export OVH_TF_STATE_SECRET_KEY=...
```

`OVH_TF_STATE_KEY` is optional and defaults to
`infrastructure/terraform.tfstate`.

The container keeps Ansible files in `/ansible`, Terraform files in
`/terraform`, and scratch data under `/tmp/ansible` and `/tmp/terraform`.

The default target group is `dev`. Select another inventory group with:

```bash
./ansible.sh -e target_hosts=prod --ask-become-pass
```

The playbook can create certificates on a fresh host using Certbot webroot
validation. DNS for each configured domain must point at the server and inbound
port `80` must be reachable from the public Internet.

The firewall is managed by nftables and only allows inbound TCP ports `22`,
`80`, and `443`, plus established traffic and loopback.

Docker is configured to use the nftables firewall backend and the host enables
IP forwarding so Compose bridge networks can be created without Docker trying to
touch legacy iptables chains.

Set `certbot_email` in the relevant `group_vars/*.yml` file if you want Let's Encrypt expiry
notices. If it is empty, the playbook registers without an email address.

## Static Content

Local uploads are optional. Set `www_source` on an `nginx_sites` entry only when
you want Ansible to copy local content into that site's web root on the target
server:

```yaml
nginx_sites:
  - name: leo.surf
    www_source: leo.surf/build/
```

Sources are resolved relative to the workspace root by `ansible.sh`, or relative to
the parent of this directory when running `ansible-playbook` directly. The
default target is `{{ nginx_html_root }}/{{ name }}/`; set `www_dest` on a site
only when the server path differs.

Set `jinjapocalypse_git_source` on an `nginx_sites` entry to build the site on
the target server from a git repository:

```yaml
nginx_sites:
  - name: below.industries
    jinjapocalypse_git_source: https://github.com/beLow-Industries/below.industries.git
```

When at least one site uses `jinjapocalypse_git_source`, the playbook installs
Docker and git, clones `jinjapocalypse_repo_url` to `jinjapocalypse_checkout_dir`,
builds the local `jinjapocalypse_image_name` Docker image with `build.sh`,
installs `/usr/local/sbin/jinjapocalypse-build-<site>.sh`, runs it once, and
adds a root cron job. The default cron schedule is hourly:

```yaml
jinjapocalypse_cron:
  minute: "0"
  hour: "*"
  day: "*"
  month: "*"
  weekday: "*"
```

Override `jinjapocalypse_cron` globally or set the same mapping on an individual
site. The generated rebuild script runs Jinjapocalypse with
`--source-from-git-repo=<repo>`, then replaces the configured web root with the
new `build/` output.

## Check

```bash
./ansible.sh --check --diff --ask-become-pass
```

Run a Certbot renewal dry-run explicitly with:

```bash
./ansible.sh -e certbot_renewal_dry_run=true --ask-become-pass
```

`ansible.sh` mounts this directory and the workspace root into the container
read-only, mounts `~/.ssh` when present, and forwards `SSH_AUTH_SOCK` when an SSH
agent is available. `terraform.sh` mounts the Terraform directory read-only.
Override the shared image tag with
`INFRASTRUCTURE_IMAGE_NAME=custom-name ./ansible.sh ...` or
`INFRASTRUCTURE_IMAGE_NAME=custom-name ./terraform.sh ...`.
The default tag is `infrastructure:local`.

## DNS

Copy `terraform/dns.auto.tfvars.example` to `terraform/dns.auto.tfvars` and add
the managed A, AAAA, CNAME, and CAA records for each zone. Terraform intentionally
starts with empty record lists so it does not invent DNS targets.
