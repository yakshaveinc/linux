### Installing and Downloading Tools
Download and unpack **specific Terraform** version
```
(export TFVER=0.12.2; echo $TFVER; curl -sS https://releases.hashicorp.com/terraform/${TFVER}/terraform_${TFVER}_linux_amd64.zip > terraform.zip && unzip terraform.zip)  # specific Terraform
```
Download and unpack **latest Terraform**
```
(export TFURL=$(curl -s https://www.terraform.io/downloads.html | grep -o -E "https://.+?_linux_amd64.zip"); echo "Fetching $TFURL"; curl -sSL "$TFURL" > terraform.zip && unzip terraform.zip)  # latest Terraform
```
Download and unpack **latest Serf (or any other Hashicorp utility)**
```
(export APP=serf; export ZIP=${APP}.zip; export URL=$(curl -s https://www.${APP}.io/downloads.html | grep -o -E "https://.+?_linux_amd64.zip"); echo "Fetching $URL"; curl -sSL "$URL" > ${ZIP} && unzip ${ZIP} && rm ${ZIP})  # latest Serf
```

**Update `webhook` in `/usr/local/bin` to latest version**
```
sudo sh -c "curl -L $(curl -s https://api.github.com/repos/adnanh/webhook/releases/latest | grep -o -E "https://.+?-linux-amd64.tar.gz") | tar -xzO > /usr/local/bin/webhook && chmod +x /usr/local/bin/webhook  # latest webhook
```

**Unpack `dive` v0.9.1 to `/tmp`**
```
(export GH=wagoodman/dive; export TAG=v0.9.1; curl -sSL "$(curl -s https://api.github.com/repos/$GH/releases/tags/$TAG | grep -o -E "https://.+?linux_amd64.+?.gz")") | tar xvz -C /tmp
```

**Unpdate `pack` in `/usr/local/bin` to latest version**
```
(export GH=buildpacks/pack; export LATEST=$(curl -s https://api.github.com/repos/$GH/releases/latest | grep -o -E "https://.+?-linux.tgz"); echo "$LATEST"; curl -sSL "$LATEST" | sudo tar -C /usr/local/bin/ --no-same-owner -xzv $(basename $GH))
```

---

### CI Integration setup

**Adding snap build to Travis**

Generate SNAP_TOKEN for uploads.
```
podman run -it --rm yakshaveinc/snapcraft:core18 snapcraft export-login --snaps=yakshaveinc --acls=package_upload --channels stable -
```
