Script for better User eXperience on Linux. Clone repo and
link scripts that are needed to `$HOME/bin`.

For example, the command below will expand path to `terrapass.sh`
in current dir, and create a link to it in `$HOME/bin`. Now
`terrapass.sh` can be called from any place.

    $ ln -s $(realpath terrapass.sh) ~/bin/terrapass.sh

### List of scripts

 * `amend-pr.sh` - clone PR from GitHub, edit and push back
 * `aws.sh` - run AWS CLI v2 from container using project AWS config
 * `list-open-ports.sh` - lists open listening ports
 * `lxd-runin.sh` - mount current dir to LXD container and run command
 * `runin-podman.sh` - run container with current dir mounted in
 * `terrapass.sh` - runs Terraform with unlocked token from `pass`

