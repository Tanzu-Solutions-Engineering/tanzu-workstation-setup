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
cp /home/ubuntu/snap/docker/*/.docker/config.json ~/.docker/config.json
```

## Tanzu Kubernetes Grid Packages

https://www.vmware.com/go/get-tkg

Using my workstation and then used scp to copy them to the linux jumpbox
- tkg cli
  - Extract, copy tkg to /usr/local/bin renaming them to tkg
  - Copy carvel tools to /usr/local/bin and rename
- kubectl cli
  - Extract, add execute bit copy kubectl to /usr/local/bin
- tkg extensions

From your mac workstation...

```bash
export JUMPBOX_USER=dpfeffer
export JUMPBOX_IP=192.168.7.139
# Download from https://www.vmware.com/go/get-tkg
# - kubectl
# - tkg
# - tkg-extensions
# - velero
scp ~/Downloads/tkg-extensions-manifests-v1.3.0-vmware.1.tar.gz $JUMPBOX_USER@$JUMPBOX_IP:
scp ~/Downloads/kubectl-linux-v1.20.4-vmware.1.gz $JUMPBOX_USER@$JUMPBOX_IP:
scp ~/Downloads/tanzu-cli-bundle-linux-amd64.tar $JUMPBOX_USER@$JUMPBOX_IP:
scp ~/Downloads/velero-linux-v1.5.3_vmware.1.gz $JUMPBOX_USER@$JUMPBOX_IP:
```

From linux jumpbox...

```bash
gunzip kubectl-linux-v1.20.4-vmware.1.gz
chmod +x kubectl-linux-v1.20.4-vmware.1 && sudo mv kubectl-linux-v1.20.4-vmware.1 /usr/local/bin/kubectl

tar -xvf tanzu-cli-bundle-linux-amd64.tar
sudo install cli/core/v1.3.0/tanzu-core-linux_amd64 /usr/local/bin/tanzu
tanzu plugin clean
tanzu plugin install --local cli all
gunzip cli/imgpkg-linux-amd64-v0.2.0+vmware.1.gz
sudo mv cli/imgpkg-linux-amd64-v0.2.0+vmware.1 /usr/local/bin/imgpkg
gunzip cli/kapp-linux-amd64-v0.33.0+vmware.1.gz
sudo mv cli/kapp-linux-amd64-v0.33.0+vmware.1 /usr/local/bin/kapp
gunzip cli/kbld-linux-amd64-v0.24.0+vmware.1.gz
sudo mv cli/kbld-linux-amd64-v0.24.0+vmware.1 /usr/local/bin/kbld
gunzip cli/ytt-linux-amd64-v0.30.0+vmware.1.gz
sudo mv cli/ytt-linux-amd64-v0.30.0+vmware.1 /usr/local/bin/ytt

gunzip velero-linux-v1.5.3_vmware.1.gz
chmod +x velero-linux-v1.5.3_vmware.1
sudo mv velero-linux-v1.5.3_vmware.1 /usr/local/bin/velero
```

Create a directory in your home for various git projects.  This is one of them.
- Create ~/workspace
- git clone https://github.com/doddatpivotal/tanzu-workstation-setup.git

## Additional Apps & Utilities

```bash
# Install pivnet - https://github.com/pivotal-cf/pivnet-cli
curl -LO https://github.com/pivotal-cf/pivnet-cli/releases/download/v3.0.1/pivnet-linux-amd64-3.0.1
chmod +x ./pivnet-linux-amd64-3.0.1
sudo mv pivnet-linux-amd64-3.0.1 /usr/local/bin/pivnet
# Get your Pivnet API Token at the bottom of the [Pivnet Profile Page](https://network.pivotal.io/users/dashboard/edit-profile).  
pivnet login --api-token $PIVNET_API_TOKEN

# Install kp - https://docs.pivotal.io/build-service
pivnet download-product-files \
  --product-slug='build-service' \
  --release-version='1.1.4' \
  --product-file-id=883031
chmod +x kp-linux-0.2.0
sudo mv kp-linux-0.2.0 /usr/local/bin/kp

# Install jq - https://stedolan.github.io/jq/
sudo apt-get install jq

# Install k9s - https://github.com/derailed/k9s
sudo snap install k9s

# Install yq - per https://github.com/mikefarah/yq
sudo wget https://github.com/mikefarah/yq/releases/download/v4.7.0/yq_linux_amd64 -O /usr/bin/yq 
sudo chmod +x /usr/bin/yq

# Install helm
curl -LO https://get.helm.sh/helm-v3.5.1-linux-amd64.tar.gz
gunzip helm-v3.5.1-linux-amd64.tar.gz
tar -xvf helm-v3.5.1-linux-amd64.tar
sudo mv linux-amd64/helm /usr/local/bin/helm
rm helm*
rm -rf linux-amd64/

# Install kind
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.10.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

# Install kubectx/kubens
sudo git clone https://github.com/ahmetb/kubectx /opt/kubectx
sudo ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx
sudo ln -s /opt/kubectx/kubens /usr/local/bin/kubens

# Install tmc
curl -LO https://tmc-cli.s3-us-west-2.amazonaws.com/tmc/0.2.1-3baebdac/linux/x64/tmc
chmod +x ./tmc
sudo mv tmc /usr/local/bin/tmc

# Install pack
curl -LO https://github.com/buildpacks/pack/releases/download/v0.18.1/pack-v0.18.1-linux.tgz
gunzip pack-v0.18.1-linux.tgz
tar -xvf pack-v0.18.1-linux.tar
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

# Install HTTPie
sudo apt install httpie

# Install JDK
sudo apt install openjdk-11-jdk
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
