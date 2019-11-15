### Download and unpack specific Terraform version
```
(export TFVER=0.12.2; echo $TFVER; curl -sS https://releases.hashicorp.com/terraform/${TFVER}/terraform_${TFVER}_linux_amd64.zip > terraform.zip && unzip terraform.zip)  # specific Terraform
```

### Download and unpack latest Terraform
```
(export TFURL=$(curl -s https://www.terraform.io/downloads.html | grep -o -E "https://.+?_linux_amd64.zip"); echo "Fetching $TFURL"; curl -sSL "$TFURL" > terraform.zip && unzip terraform.zip)  # latest Terraform
```
### Download and unpack latest Serf (or any other Hashicorp utility)
```
(export APP=serf; export ZIP=${APP}.zip; export URL=$(curl -s https://www.${APP}.io/downloads.html | grep -o -E "https://.+?_linux_amd64.zip"); echo "Fetching $URL"; curl -sSL "$URL" > ${ZIP} && unzip ${ZIP} && rm ${ZIP})  # latest Serf
```

### Update `webhook` in `/usr/local/bin` to latest version
```
sudo sh -c "curl -L $(curl -s https://api.github.com/repos/adnanh/webhook/releases/latest | grep -o -E "https://.+?-linux-amd64.tar.gz") | tar -xzO > /usr/local/bin/webhook && chmod +x /usr/local/bin/webhook  # latest webhook
```
