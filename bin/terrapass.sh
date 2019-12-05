#!/usr/bin/bash

# Script for Terraform + pass (https://www.passwordstore.org/)
# sets environment variables for Terraform providers from keys
# in `pass` store (under `terraform/{provider}` dir).

PASTOR=$HOME/.password-store

[[ -a $PASTOR/terraform/digitalocean.gpg ]] && \
  DIGITALOCEAN_TOKEN=$(pass terraform/digitalocean) && \
  export DIGITALOCEAN_TOKEN && \
  echo "exported DIGITALOCEAN_TOKEN"

[[ -a $PASTOR/terraform/github.gpg ]] && \
  GITHUB_TOKEN=$(pass terraform/digitalocean) && \
  export GITHUB_TOKEN && \
  echo "exported GITHUB_TOKEN"

terraform "$@"
