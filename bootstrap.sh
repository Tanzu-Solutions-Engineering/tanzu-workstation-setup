#!/bin/bash -e

if [ ! $# -eq 2 ]; then
  echo "Must supply customer connect username and password as args"
  exit 1
fi

export VMWUSER=$1
export VMWPASS=$2

mkdir -p /home/ubuntu/workspace
export HOME=/home/ubuntu

echo ~~~~~~~~ SETUP ENV

echo ~~~~~~~~ SYSTEM UPDATES
sudo apt-get update
sudo apt-get upgrade
echo ~~~~~~~~ INSTALL SYSTEM COMPONENTS
sudo apt-get install ca-certificates curl gnupg lsb-release
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin docker-compose

usermod -aG docker ubuntu

echo ~~~~~~~~ INSTALL TANZU CLI

# Download TKG files
docker run -itd --name vmw -e VMWUSER=$VMWUSER -e VMWPASS=$VMWPASS -v ${PWD}:/files --entrypoint=sh apnex/vmw-cli
# view current files
docker exec -t vmw vmw-cli ls vmware_tanzu_kubernetes_grid
# download files
docker exec -t vmw vmw-cli cp tanzu-cli-bundle-linux-amd64.tar.gz
docker exec -t vmw vmw-cli cp kubectl-linux-v1.24.10+vmware.1.gz
docker exec -t vmw vmw-cli cp crashd-linux-amd64-v0.3.7+vmware.5-4-g59b239d.tar.gz
docker exec -t vmw vmw-cli cp velero-linux-v1.9.5+vmware.1.gz
# stop vmw-cli container
docker rm -f vmw

gunzip kubectl-linux-v1.24.10+vmware.1.gz
chmod +x kubectl-linux-v1.24.10+vmware.1 && sudo mv kubectl-linux-v1.24.10+vmware.1 /usr/local/bin/kubectl

mkdir -p /home/ubuntu/tanzu-cli

gunzip tanzu-cli-bundle-linux-amd64.tar.gz
tar -xvf tanzu-cli-bundle-linux-amd64.tar -C /home/ubuntu/tanzu-cli
sudo install /home/ubuntu/tanzu-cli/cli/core/v0.28.1/tanzu-core-linux_amd64 /usr/local/bin/tanzu
tanzu plugin sync


echo "export TANZU_CLI_PINNIPED_AUTH_LOGIN_SKIP_BROWSER=true" >> /home/ubuntu/.bashrc

gunzip /home/ubuntu/tanzu-cli/cli/imgpkg-linux-amd64-v0.31.1+vmware.1.gz
chmod +x /home/ubuntu/tanzu-cli/cli/imgpkg-linux-amd64-v0.31.1+vmware.1
sudo cp /home/ubuntu/tanzu-cli/cli/imgpkg-linux-amd64-v0.31.1+vmware.1 /usr/local/bin/imgpkg
gunzip /home/ubuntu/tanzu-cli/cli/kapp-linux-amd64-v0.53.2+vmware.1.gz
chmod +x /home/ubuntu/tanzu-cli/cli/kapp-linux-amd64-v0.53.2+vmware.1
sudo cp /home/ubuntu/tanzu-cli/cli/kapp-linux-amd64-v0.53.2+vmware.1 /usr/local/bin/kapp
gunzip /home/ubuntu/tanzu-cli/cli/kbld-linux-amd64-v0.35.1+vmware.1.gz
chmod +x /home/ubuntu/tanzu-cli/cli/kbld-linux-amd64-v0.35.1+vmware.1
sudo cp /home/ubuntu/tanzu-cli/cli/kbld-linux-amd64-v0.35.1+vmware.1 /usr/local/bin/kbld
gunzip /home/ubuntu/tanzu-cli/cli/ytt-linux-amd64-v0.43.1+vmware.1.gz
chmod +x /home/ubuntu/tanzu-cli/cli/ytt-linux-amd64-v0.43.1+vmware.1
sudo cp /home/ubuntu/tanzu-cli/cli/ytt-linux-amd64-v0.43.1+vmware.1 /usr/local/bin/ytt

gunzip /home/ubuntu/downloads/velero-linux-v1.9.5+vmware.1.gz
chmod +x /home/ubuntu/downloads/velero-linux-v1.9.5+vmware.1
sudo cp /home/ubuntu/downloads/velero-linux-v1.9.5+vmware.1 /usr/local/bin/velero

gunzip /home/ubuntu/downloads/crashd-linux-amd64-v0.3.7+vmware.5-4-g59b239d.tar.gz
mkdir /home/ubuntu/tanzu-crashd
tar -xvf /home/ubuntu/downloads/crashd-linux-amd64-v0.3.7+vmware.5-4-g59b239d.tar -C /home/ubuntu/tanzu-crashd
# for some reason, the following version has +, while the others have -
sudo cp /home/ubuntu/tanzu-crashd/crashd/crashd-linux-amd64-v0.3.7+vmware.5-4-g59b239d /usr/local/bin/crashd

tanzu plugin list

# Install kind
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.17.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

# Helpful Alias
echo "alias k=kubectl" >> /home/ubuntu/.bashrc

# Install kubectx/kubens
sudo git clone https://github.com/ahmetb/kubectx /opt/kubectx
sudo ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx
sudo ln -s /opt/kubectx/kubens /usr/local/bin/kubens

# Install fzf (for fuzy finder kubectx)
sudo apt-get update
sudo apt-get -y install fzf

# Install k9s - https://github.com/derailed/k9s
mkdir k9s
cd k9s
curl -L0 https://github.com/derailed/k9s/releases/download/v0.27.2/k9s_Linux_amd64.tar.gz --output k9s_Linux_x86_64.tar.gz
gunzip k9s_Linux_x86_64.tar.gz
tar -xvf k9s_Linux_x86_64.tar
sudo mv k9s /usr/local/bin/k9s
cd ..
rm -rf k9s

# Install yq - per https://github.com/mikefarah/yq
sudo wget https://github.com/mikefarah/yq/releases/download/v4.30.8/yq_linux_amd64 -O /usr/bin/yq
sudo chmod +x /usr/bin/yq

cd /home/ubuntu/workspace
git clone https://github.com/jonmosco/kube-ps1
echo "source /home/ubuntu/workspace/kube-ps1/kube-ps1.sh" >> /home/ubuntu/.bashrc
echo PS1=\'[\$\(date +\"%X %Y\"\) \\u@\\h \\W\\n \$\(kube_ps1\)]\\$ \' >> /home/ubuntu/.bashrc

cd /home/ubuntu

# Install helm
curl -LO https://get.helm.sh/helm-v3.11.0-linux-amd64.tar.gz
gunzip helm-v3.11.0-linux-amd64.tar.gz
tar -xvf helm-v3.11.0-linux-amd64.tar
sudo mv linux-amd64/helm /usr/local/bin/helm
rm helm*
rm -rf linux-amd64/

# Install jq - https://stedolan.github.io/jq/
sudo apt-get -y install jq

# Install HTTPie
sudo apt -y install httpie

# Install tmc 
curl -LO https://tmc-cli.s3-us-west-2.amazonaws.com/tmc/0.5.3-bdf68514/linux/x64/tmc 
chmod +x ./tmc
sudo mv tmc /usr/local/bin/tmc


chown -R ubuntu /home/ubuntu
exit 0