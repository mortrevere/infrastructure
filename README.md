# Infrastructure

Terraform and Ansible stacks for the servers I manage.

## Choices

- Only prerequisite is `docker`: one image provides both Terraform and Ansible, so I'm not dependant on the local setup 
- As automated as possible: covers everything, no manual intervention, idempotency
- Should work on slow/unstable connections: remote server does the work
- Ansible uses SSH agent forwarding and `~/.ssh`, and the default target group is `prod`.

## Ansible

```bash
./ansible.sh
./ansible.sh --check --diff --ask-become-pass
./ansible.sh -e target_hosts=prod --ask-become-pass
```

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

