# Harbor Setup in Linux Workstation

The following is a summary and simplification of the steps required to install Harbor in an Ubuntu jumpbox. 
The instructions are extracted from the Harbor 2 installation documentation: https://goharbor.io/docs/2.0.0/install-config/

Is it assumed you have provisioned an Ubuntu Linux jumpbox with Docker Server, for example using the steps found [here](/Linux.md).
It is also assumed that you have confirmed the Harbor pre-requirements: https://goharbor.io/docs/2.0.0/install-config/installation-prereqs/.

## Download the Harbor Installer

```bash
cd ~/downloads/
curl -JOL https://github.com/goharbor/harbor/releases/download/v2.5.3/harbor-offline-installer-v2.5.3.tgz
tar xzvf harbor-offline-installer-v2.5.3.tgz
```

## Prepare certs for HTTPS Access to Harbor

```bash
mkdir -p cd ~/data/
cd ~/data/
# Create CA cert: change subj values to meet your needs
openssl genrsa -out ca.key 4096
openssl req -x509 -new -nodes -sha512 -days 3650  -subj "/C=CN/ST=NewYork/L=NewYork/O=sandbox/OU=Personal/CN=vmware.com"  -key ca.key  -out ca.crt
# Create Harbor key: change file name to meet your needs (yourdomain.com.key)
openssl genrsa -out harbor.h2o-4-1056.h2o.vmware.com.key 4096
# Create Harbor CSR: change the subj values and file name to meet your needs (yourdomain.com.csr), with the CN that you wannt to use as Harbor FQDN
openssl req -sha512 -new  \
   -subj "/C=CN/ST=NewYork/L=NewYork/O=sandbox/OU=Personal/CN=harbor.h2o-4-1056.h2o.vmware.com" \
   -key harbor.h2o-4-1056.h2o.vmware.com.key \
   -out harbor.h2o-4-1056.h2o.vmware.com.csr
# Create extension file: change the DNS.1 value to meet your needs, with the Harbor FQDN
cat > v3.ext <<-EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names
[alt_names]
DNS.1=harbor.h2o-4-1056.h2o.vmware.com
EOF
# Create Harbor Certificate: change file name to meet your needs (yourdomain.com.crt)
openssl x509 -req -sha512 -days 3650 -extfile v3.ext -CA ca.crt -CAkey ca.key -CAcreateserial -in harbor.h2o-4-1056.h2o.vmware.com.csr -out harbor.h2o-4-1056.h2o.vmware.com.crt
# Convert crt to cert, for use by Docker
openssl x509 -inform PEM -in harbor.h2o-4-1056.h2o.vmware.com.crt -out harbor.h2o-4-1056.h2o.vmware.com.cert
# Copy the server certificate, key and CA files into the Docker certificates folder on the Harbor host. You must create the appropriate folders first
sudo mkdir -p /etc/docker/certs.d/harbor.h2o-4-1056.h2o.vmware.com/
sudo cp harbor.h2o-4-1056.h2o.vmware.com.* /etc/docker/certs.d/harbor.h2o-4-1056.h2o.vmware.com/
sudo cp ca.crt /etc/docker/certs.d/harbor.h2o-4-1056.h2o.vmware.com/
# Restart Docker Server
systemctl restart docker
```

## Prepare Harbor configuration

```bash
cd ~/downloads/harbor/
# Make a copy of the default Harbor config yaml
cp harbor.yml.tmpl harbor.yml
# Edit harbor.yml
vi harbor.yaml
# Make at least the following changes
#   -> hostname: use the fqdn you plan for Harbor (harbor.h2o-4-1056.h2o.vmware.com in this guide)
#   -> data_volume: the location on the target host in which to store Harbor's data
#   -> https.certificate: Location of the Harbor cert file (~/data/harbor.h2o-4-1056.h2o.vmware.com.cert in this guide)
#   -> https.key: Location of the Harbor key file (~/data/harbor.h2o-4-1056.h2o.vmware.com.key in this guide)
```

## Install Harbor

```bash
cd ~/downloads/harbor/
# Install Harbor with the script
sudo ./install.sh
# Use  --with-notary flag to enable Notary
```