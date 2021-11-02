# Linux Tanzu Workstation Setup

The following cheatsheet supports applications and utilities helpful for developer and operations (might I say devops) team members working with Tanzu.

The apps listed collected and used form a completely fresh Ubuntu Linux jumpbox.  See notes on creating the Ubuntu Linux VM at the bottom.

Recommended size is cpu 2, ram 6GB, disk 30GB​.

## VMware Tanzu Accounts

- `my.vmware.com` - This is for downloading TKG. If you don't already have an account, register [here](https://my.vmware.com/web/vmware/registration).
- `Tanzu Net` - This is for downloading Tanzu Build Service. If you don't already have an account, register [here](https://account.run.pivotal.io/z/uaa/sign-up).

## Pre-installed

Git - Installed out of the box

Docker - Installed through initial VM setup via Snap

- If not done at setup, you can run `sudo snap install docker --classic`.  See script below.
- I faced an permission issue with docker and needed to follow [these steps](https://docs.docker.com/engine/install/linux-postinstall/).
- Note: If running with HTTP_PROXY follow these [additional instructions](https://docs.docker.com/config/daemon/systemd/#httphttps-proxy).
- Note: For some reason the snap version puts the config.json for docker in an unusual location.  The carvel tools need this file to be at ~/.docker/config.json or else it won't be able to read the auth information that stored there.  Once you do logins or modify this file, copy it to the expected location.  Each time you do an action that would edit the config, you need to re-copy.

```bash
sudo snap install docker --classic
sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker
sudo reboot now
# copy the config file from where snap puts it to where carvel tools expect it
mkdir ~/.docker
cp /var/snap/docker/current/config/daemon.json ~/.docker/config.json # if you find issue with kube proxy starting up, may need to run this command.  Found it just recently
sudo sysctl net/netfilter/nf_conntrack_max=131072
```

## Jumpbox Setup

Create a directory in your home for various git projects.  This is one of them.

```bash
mkdir ~/workspace
cd ~/workspace
git clone https://github.com/doddatpivotal/tanzu-workstation-setup.git

# create location for install packages
mkdir ~/downloads
```

## Tanzu Kubernetes Grid Packages

All TKG cli's are avilable at https://www.vmware.com/go/get-tkg.  We will use the [vmw-cli OSS container](https://github.com/apnex/vmw-cli) to retrieve them.  You will need a VMware Customer Connect username and password.

From linux jumpbox...

```bash
export VMWARE_CUSTOMER_CONNECT_USER=<your username>
export VMWARE_CUSTOMER_CONNECT_PASSWORD=<your password>

cd ~/downloads

docker run -itd --name vmw -e VMWUSER=$VMWARE_CUSTOMER_CONNECT_USER -e VMWPASS=$VMWARE_CUSTOMER_CONNECT_PASSWORD -v ${PWD}:/files --entrypoint=sh apnex/vmw-cli

# view current files
docker exec -t vmw vmw-cli ls vmware_tanzu_kubernetes_grid

# download files
docker exec -t vmw vmw-cli cp tanzu-cli-bundle-linux-amd64.tar
docker exec -t vmw vmw-cli cp kubectl-linux-v1.21.2+vmware.1.gz
docker exec -t vmw vmw-cli cp crashd-linux-amd64-v0.3.3+vmware.1.tar.gz
docker exec -t vmw vmw-cli cp velero-linux-v1.6.2_vmware.1.gz

# stop vmw-cli container
docker rm -f vmw

gunzip ~/downloads/kubectl-linux-v1.21.2+vmware.1.gz
chmod +x ~/downloads/kubectl-linux-v1.21.2+vmware.1 && sudo mv ~/downloads/kubectl-linux-v1.21.2+vmware.1 /usr/local/bin/kubectl

mkdir ~/tanzu-cli
tar -xvf ~/downloads/tanzu-cli-bundle-linux-amd64.tar -C ~/tanzu-cli
sudo install ~/tanzu-cli/cli/core/v1.4.0/tanzu-core-linux_amd64 /usr/local/bin/tanzu
tanzu plugin clean
tanzu plugin install --local ~/tanzu-cli/cli all

echo "export TANZU_CLI_PINNIPED_AUTH_LOGIN_SKIP_BROWSER=true" >> ~/.bashrc
source ~/.bashrc

gunzip ~/tanzu-cli/cli/imgpkg-linux-amd64-v0.10.0+vmware.1.gz
chmod +x ~/tanzu-cli/cli/imgpkg-linux-amd64-v0.10.0+vmware.1
sudo cp ~/tanzu-cli/cli/imgpkg-linux-amd64-v0.10.0+vmware.1 /usr/local/bin/imgpkg
gunzip ~/tanzu-cli/cli/kapp-linux-amd64-v0.37.0+vmware.1.gz
chmod +x ~/tanzu-cli/cli/kapp-linux-amd64-v0.37.0+vmware.1
sudo cp ~/tanzu-cli/cli/kapp-linux-amd64-v0.37.0+vmware.1 /usr/local/bin/kapp
gunzip ~/tanzu-cli/cli/kbld-linux-amd64-v0.30.0+vmware.1.gz
chmod +x ~/tanzu-cli/cli/kbld-linux-amd64-v0.30.0+vmware.1
sudo cp ~/tanzu-cli/cli/kbld-linux-amd64-v0.30.0+vmware.1 /usr/local/bin/kbld
gunzip ~/tanzu-cli/cli/ytt-linux-amd64-v0.34.0+vmware.1.gz
chmod +x ~/tanzu-cli/cli/ytt-linux-amd64-v0.34.0+vmware.1
sudo cp ~/tanzu-cli/cli/ytt-linux-amd64-v0.34.0+vmware.1 /usr/local/bin/ytt

gunzip ~/downloads/velero-linux-v1.6.2_vmware.1.gz
chmod +x ~/downloads/velero-linux-v1.6.2_vmware.1
sudo cp ~/downloads/velero-linux-v1.6.2_vmware.1 /usr/local/bin/velero

gunzip ~/downloads/crashd-linux-amd64-v0.3.3+vmware.1.tar.gz
mkdir ~/tanzu-crashd
tar -xvf ~/downloads/crashd-linux-amd64-v0.3.3+vmware.1.tar -C ~/tanzu-crashd
# for some reason, the following version has +, while the others have -
sudo cp ~/tanzu-crashd/crashd/crashd-linux-amd64-v0.3.3+vmware.1 /usr/local/bin/crashd

```

## Additional Apps & Utilities

```bash
# Install kind
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.11.1/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

# Helpful Alias
echo "alias k=kubectl" >> ~/.bashrc
source ~/.bashrc

# Install kubectx/kubens
sudo git clone https://github.com/ahmetb/kubectx /opt/kubectx
sudo ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx
sudo ln -s /opt/kubectx/kubens /usr/local/bin/kubens

# Install fzf (for fuzy finder kubectx)
sudo apt-get update
sudo apt-get install fzf

# Install k9s - https://github.com/derailed/k9s
mkdir k9s
cd k9s
curl -L0 https://github.com/derailed/k9s/releases/download/v0.24.14/k9s_Linux_x86_64.tar.gz --output k9s_Linux_x86_64.tar.gz
gunzip k9s_Linux_x86_64.tar.gz
tar -xvf k9s_Linux_x86_64.tar
sudo mv k9s /usr/local/bin/k9s
cd ..
rm -rf k9s

# Install yq - per https://github.com/mikefarah/yq
sudo wget https://github.com/mikefarah/yq/releases/download/v4.13.0/yq_linux_amd64 -O /usr/bin/yq
sudo chmod +x /usr/bin/yq

cd ~/workspace
git clone https://github.com/jonmosco/kube-ps1
echo "source ~/workspace/kube-ps1/kube-ps1.sh" >> ~/.bashrc
echo PS1=\'[\$\(date +\"%X %Y\"\) \\u@\\h \\W\\n \$\(kube_ps1\)]\\$ \' >> ~/.bashrc

source ~/.bashrc
cd ~

# Install helm
curl -LO https://get.helm.sh/helm-v3.6.3-linux-amd64.tar.gz
gunzip helm-v3.6.3-linux-amd64.tar.gz
tar -xvf helm-v3.6.3-linux-amd64.tar
sudo mv linux-amd64/helm /usr/local/bin/helm
rm helm*
rm -rf linux-amd64/


# Install pivnet - https://github.com/pivotal-cf/pivnet-cli
curl -LO https://github.com/pivotal-cf/pivnet-cli/releases/download/v3.0.1/pivnet-linux-amd64-3.0.1
chmod +x ./pivnet-linux-amd64-3.0.1
sudo mv pivnet-linux-amd64-3.0.1 /usr/local/bin/pivnet
# Get your Pivnet API Token at the bottom of the [Pivnet Profile Page](https://network.pivotal.io/users/dashboard/edit-profile).  
pivnet login --api-token $PIVNET_API_TOKEN

# Install jq - https://stedolan.github.io/jq/
sudo apt-get install jq

# Install HTTPie
sudo apt install httpie

# Install kp - https://docs.pivotal.io/build-service
pivnet download-product-files \
  --product-slug='build-service' \
  --release-version='1.1.4' \
  --product-file-id=883031
chmod +x kp-linux-0.2.0
sudo mv kp-linux-0.2.0 /usr/local/bin/kp

# Install tmc
curl -LO https://tmc-cli.s3-us-west-2.amazonaws.com/tmc/0.2.1-170959eb/linux/x64/tmc
chmod +x ./tmc
sudo mv tmc /usr/local/bin/tmc

# Install pack
PACK_VERSION=v0.20.0
curl -LO https://github.com/buildpacks/pack/releases/download/$PACK_VERSION/pack-$PACK_VERSION-linux.tgz
gunzip pack-$PACK_VERSION-linux.tgz
tar -xvf pack-$PACK_VERSION-linux.tar
chmod +x pack
sudo mv pack /usr/local/bin/
rm pack*

# Install fly
curl -LO https://github.com/concourse/concourse/releases/download/v6.7.5/fly-6.7.5-linux-amd64.tgz
gunzip fly-6.7.5-linux-amd64.tgz
tar -xvf fly-6.7.5-linux-amd64.tar
chmod +x fly
sudo mv fly /usr/local/bin/
rm fly*

# Install JDK
sudo apt install openjdk-11-jdk

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
    - cpu 2, ram 6GB, disk 30GB
    - VM Network
    - Add a second CD Drive and choose ISO
- Power on jumpbox
- Choose web console while boot up
  - Accept all defaults
  - Your name, linux-jumpbox, your username, your password
  - Install SSH server, but don't import keys
  - SNAPS: Docker
- Now Get the IP address and ssh into it.  I did `ssh dpfeffer@192.168.7.77`
