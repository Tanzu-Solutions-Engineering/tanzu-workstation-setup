# Linux Tanzu Workstation Setup

The following cheatsheet supports applications and utilities helpful for developer and operations (might I say devops) team members working with Tanzu.

The apps listed collected and used form a completely fresh Ubuntu Linux jumpbox.  See notes on creating the Ubuntu Linux VM at the bottom.

Recommended size is cpu 2, ram 6GB, disk 30GB​. Or cpu 4, ram 8GB disk 160GB if you're installing Harbor

The following steps expects internet connectivity for ths jumpbox, either directly or via proxy settings.


## VMware Tanzu Accounts

- `my.vmware.com` - This is for downloading TKG. If you don't already have an account, register [here](https://my.vmware.com/web/vmware/registration).
- `Tanzu Net` - This is for downloading Tanzu Build Service. If you don't already have an account, register [here](https://account.run.pivotal.io/z/uaa/sign-up).

## Pre-installed

Git - Installed out of the box

Docker - Follow [these instructions](https://docs.docker.com/engine/install/ubuntu/) to setup Docker in your VM. See script below.

- I faced an permission issue with docker and needed to follow [these steps](https://docs.docker.com/engine/install/linux-postinstall/).
- Note: If running with HTTP_PROXY follow these [additional instructions](https://docs.docker.com/config/daemon/systemd/#httphttps-proxy).
- Note: The carvel tools need the `config.json` to be at `~/.docker/config.json` or else it won't be able to read the auth information that stored there.

```bash
# Cleanup
sudo apt-get remove docker docker-engine docker.io containerd runc
# Install Packages
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg lsb-release
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin docker-compose
# Post install permissions
sudo usermod -aG docker $USER
newgrp docker
sudo reboot now
# copy the config file to where carvel tools expect it
mkdir ~/.docker
# cp /var/snap/docker/current/config/daemon.json ~/.docker/config.json # if you find issue with kube proxy starting up, may need to run this command.  Found it just recently - UPDATE only seemed needed in the snap versions of docker
sudo sysctl net/netfilter/nf_conntrack_max=131072
```

## Jumpbox Setup

Create a directory in your home for various git projects.  This is one of them.

```bash
mkdir ~/workspace
cd ~/workspace
git clone https://github.com/Tanzu-Solutions-Engineering/tanzu-workstation-setup

# create location for install packages
mkdir ~/downloads
```

## Install Tanzu CLI and its plugins

Install independent CLI v1.1.0 with apt-get
```bash
sudo apt-get update
sudo apt-get install -y ca-certificates curl gpg
curl -fsSL https://packages.vmware.com/tools/keys/VMWARE-PACKAGING-GPG-RSA-KEY.pub | sudo gpg --dearmor -o /etc/apt/keyrings/tanzu-archive-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/tanzu-archive-keyring.gpg] https://storage.googleapis.com/tanzu-cli-os-packages/apt tanzu-cli-jessie main" | sudo tee /etc/apt/sources.list.d/tanzu.list
sudo apt-get update
sudo apt-get install tanzu-cli=1.1.0
echo "export TANZU_CLI_PINNIPED_AUTH_LOGIN_SKIP_BROWSER=true" >> ~/.bashrc
source ~/.bashrc

tanzu version
# version: v1.1.0

which tanzu
# /usr/bin/tanzu
```

Install plugins
```bash
tanzu plugin install --group vmware-tkg/default:v2.5.1 # Agree to terms in the prompt
tanzu plugin list
#  NAME                DESCRIPTION                                                        TARGET      VERSION  STATUS
#  isolated-cluster    Prepopulating images/bundle for internet-restricted environments   global      v0.32.2  installed
#  management-cluster  Kubernetes management cluster operations                           kubernetes  v0.32.2  installed
#  package             tanzu package management                                           kubernetes  v0.32.1  installed
#  pinniped-auth       Pinniped authentication operations (usually not directly invoked)  global      v0.32.2  installed
#  secret              Tanzu secret management                                            kubernetes  v0.32.0  installed
#  telemetry           configure cluster-wide settings for vmware tanzu telemetry         global      v1.1.0   installed
#  telemetry           configure cluster-wide settings for vmware tanzu telemetry         kubernetes  v0.32.2  installed
```

## Install Additional Tanzu Kubernetes Grid Tools

All other TKG required cli's are avilable at [Tanzu Kubernetes Grid 2. downloads](https://support.broadcom.com/group/ecx/productfiles?displayGroup=VMware%20Tanzu%20Kubernetes%20Grid%20-%20Standard&release=2.x&os=&servicePk=202475&language=EN&groupId=204074).

Make sure you download the following artifacts in the `~/downloads` fodlder:
- kubectl-linux-v1.28.7+vmware.1.gz
- crashd-linux-amd64-v0.3.7+vmware.8.tar.gz
- velero-linux-v1.12.1+vmware.1.gz
- tkg-carvel-tools-linux-amd64.tar.gz

Optionally, also download these OVAs
- ubuntu-2204-kube-v1.28.7+vmware.1-tkg.3-ce5a5137e5d37570ca3aca44843423a0.ova
- photon-5-kube-v1.28.7+vmware.1-tkg.3-50fb7614ebf10b4a98fbb31220ac0fb1.ova
- ubuntu-2004-kube-v1.27.11+vmware.1-tkg.3-a3639eb6364827cd45898ad984e77d88.ova

Run these commands to install the CLIs/tools:
```
gunzip ~/downloads/kubectl-linux-v1.28.7+vmware.1.gz
chmod +x ~/downloads/kubectl-linux-v1.28.7+vmware.1 && sudo mv ~/downloads/kubectl-linux-v1.28.7+vmware.1 /usr/local/bin/kubectl

gunzip ~/downloads/tkg-carvel-tools-linux-amd64.tar.gz
mkdir ~/downloads/tkg-carvel
tar -xvf ~/downloads/tkg-carvel-tools-linux-amd64.tar -C ~/downloads/tkg-carvel

gunzip ~/downloads/tkg-carvel/cli/imgpkg-linux-amd64-v0.36.0+vmware.2.gz
chmod +x ~/downloads/tkg-carvel/cli/imgpkg-linux-amd64-v0.36.0+vmware.2
sudo cp ~/downloads/tkg-carvel/cli/imgpkg-linux-amd64-v0.36.0+vmware.2 /usr/local/bin/imgpkg

gunzip ~/downloads/tkg-carvel/cli/kapp-linux-amd64-v0.55.0+vmware.2.gz
chmod +x ~/downloads/tkg-carvel/cli/kapp-linux-amd64-v0.55.0+vmware.2
sudo cp ~/downloads/tkg-carvel/cli/kapp-linux-amd64-v0.55.0+vmware.2 /usr/local/bin/kapp

gunzip ~/downloads/tkg-carvel/cli/kbld-linux-amd64-v0.37.0+vmware.2.gz
chmod +x ~/downloads/tkg-carvel/cli/kbld-linux-amd64-v0.37.0+vmware.2
sudo cp ~/downloads/tkg-carvel/cli/kbld-linux-amd64-v0.37.0+vmware.2 /usr/local/bin/kbld

gunzip ~/downloads/tkg-carvel/cli/ytt-linux-amd64-v0.45.0+vmware.2.gz
chmod +x ~/downloads/tkg-carvel/cli/ytt-linux-amd64-v0.45.0+vmware.2
sudo cp ~/downloads/tkg-carvel/cli/ytt-linux-amd64-v0.45.0+vmware.2 /usr/local/bin/ytt

gunzip ~/downloads/velero-linux-v1.12.1+vmware.1.gz
chmod +x ~/downloads/velero-linux-v1.12.1+vmware.1
sudo cp ~/downloads/velero-linux-v1.12.1+vmware.1 /usr/local/bin/velero

gunzip ~/downloads/crashd-linux-amd64-v0.3.7+vmware.8.tar.gz
mkdir ~/tanzu-crashd
tar -xvf ~/downloads/crashd-linux-amd64-v0.3.7+vmware.8.tar -C ~/tanzu-crashd
# for some reason, the following version has +, while the others have -
sudo cp ~/tanzu-crashd/crashd/crashd-linux-amd64-v0.3.7+vmware.8 /usr/local/bin/crashd
```

## Additional Apps & Utilities

```bash
# Install kind
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.22.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

# Helpful Alias
echo "alias k=kubectl" >> ~/.bashrc
source ~/.bashrc

# Install krew
(
  set -x; cd "$(mktemp -d)" &&
  OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
  ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
  KREW="krew-${OS}_${ARCH}" &&
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
  tar zxvf "${KREW}.tar.gz" &&
  ./"${KREW}" install krew
)
echo 'export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# Install kubectx/kubens
sudo git clone https://github.com/ahmetb/kubectx /opt/kubectx
sudo ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx
sudo ln -s /opt/kubectx/kubens /usr/local/bin/kubens

# Install fzf (for fuzy finder kubectx)
kubectl krew update
kubectl krew install fuzzy

# Install k9s - https://github.com/derailed/k9s
mkdir k9s
cd k9s
curl -L0 https://github.com/derailed/k9s/releases/download/v0.32.0/k9s_Linux_amd64.tar.gz --output k9s_Linux_amd64.tar.gz
gunzip k9s_Linux_amd64.tar
tar -xvf k9s_Linux_amd64.tar
sudo mv k9s /usr/local/bin/k9s
cd ..
rm -rf k9s

# Install yq - per https://github.com/mikefarah/yq
sudo wget https://github.com/mikefarah/yq/releases/download/v4.42.1/yq_linux_amd64 -O /usr/bin/yq
sudo chmod +x /usr/bin/yq

cd ~/workspace
git clone https://github.com/jonmosco/kube-ps1
echo "source ~/workspace/kube-ps1/kube-ps1.sh" >> ~/.bashrc
echo PS1=\'[\$\(date +\"%X %Y\"\) \\u@\\h \\W\\n \$\(kube_ps1\)]\\$ \' >> ~/.bashrc

source ~/.bashrc
cd ~

# Install helm
curl -LO https://get.helm.sh/helm-v3.14.2-linux-amd64.tar.gz
gunzip helm-v3.14.2-linux-amd64.tar.gz
tar -xvf helm-v3.14.2-linux-amd64.tar
sudo mv linux-amd64/helm /usr/local/bin/helm
rm helm*
rm -rf linux-amd64/


# Install pivnet - https://github.com/pivotal-cf/pivnet-cli
curl -LO https://github.com/pivotal-cf/pivnet-cli/releases/download/v4.1.1/pivnet-linux-amd64-4.1.1
chmod +x ./pivnet-linux-amd64-4.1.1
sudo mv pivnet-linux-amd64-4.1.1 /usr/local/bin/pivnet
# Get your Pivnet API Token at the bottom of the [Pivnet Profile Page](https://network.pivotal.io/users/dashboard/edit-profile).  
pivnet login --api-token $PIVNET_API_TOKEN

# Install jq - https://stedolan.github.io/jq/
sudo apt-get install jq

# Install HTTPie
sudo apt install httpie

# Install kp - https://network.tanzu.vmware.com/products/build-service/
pivnet download-product-files \
  --product-slug='build-service' \
  --release-version='1.13.0' \
  --product-file-id=1746630
chmod +x kp-linux-amd64-0.13.0
sudo mv kp-linux-amd64-0.13.0 /usr/local/bin/kp

# Install pack
PACK_VERSION=v0.33.2
curl -LO https://github.com/buildpacks/pack/releases/download/$PACK_VERSION/pack-$PACK_VERSION-linux.tgz
gunzip pack-$PACK_VERSION-linux.tgz
tar -xvf pack-$PACK_VERSION-linux.tar
chmod +x pack
sudo mv pack /usr/local/bin/
rm pack*

# Install JDK
sudo apt install openjdk-17-jdk

# Install govc tool - https://github.com/vmware/govmomi/blob/master/govc/README.md#binaries
curl -LO "https://github.com/vmware/govmomi/releases/latest/download/govc_$(uname -s)_$(uname -m).tar.gz"
tar -xvzf govc_$(uname -s)_$(uname -m).tar.gz
sudo mv govc /usr/local/bin
rm govc_Linux_x86_64.tar.gz README.md LICENSE.txt CHANGELOG.md
```

## Create Ubuntu Linux Virtual Machine (Optional)

- Download Server install image from https://releases.ubuntu.com/20.04/
- Upload iso to data store
- Create new VM
  - name it linux-jumpbox, place it in Datacenter
  - put it on Cluster1
  - Guest OS: choose Linux - Ubuntu Linux x64
  - Customize Hardware:
    - cpu 2, ram 6GB, disk 100GB
    - VM Network
    - Add a second CD Drive and choose ISO
- Power on jumpbox
- Choose web console while boot up
  - Accept all defaults
  - Your name, linux-jumpbox, your username, your password
  - Install SSH server, but don't import keys
  - Leave Unchecked the `SNAPS: Docker` option
- Now Get the IP address and ssh into it.  I did `ssh dpfeffer@192.168.7.77`
