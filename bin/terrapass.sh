#!/usr/bin/bash

# Script for Terraform + pass (https://www.passwordstore.org/)
# sets environment variables for Terraform providers from keys
# in `pass` store (under `terraform/{provider}` dir).

PASTOR=$HOME/.password-store

[[ -a $PASTOR/terraform/digitalocean.gpg ]] && \
  export DIGITALOCEAN_TOKEN=$(pass terraform/digitalocean) && \
  echo "exported DIGITALOCEAN_TOKEN"

[[ -a $PASTOR/terraform/github.gpg ]] && \
  export GITHUB_TOKEN=$(pass terraform/digitalocean) && \
  echo "exported GITHUB_TOKEN"

terraform "$@"
