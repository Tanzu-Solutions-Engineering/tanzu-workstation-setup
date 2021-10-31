# expects $1 to be VMWUSER
# expects $2 to be VMWPASS

export VMWUSER=$1
export VMWPASS=$2

echo /home/ubuntu/home/ubuntu/home/ubuntu/home/ubuntu/home/ubuntu/home/ubuntu SETUP ENV

echo /home/ubuntu/home/ubuntu/home/ubuntu/home/ubuntu/home/ubuntu/home/ubuntu SYSTEM UPDATES
apt update
apt upgrade
echo /home/ubuntu/home/ubuntu/home/ubuntu/home/ubuntu/home/ubuntu/home/ubuntu INSTALL SYSTEM COMPONENTS
apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
apt-cache policy docker-ce
apt install -y docker-ce

usermod -aG docker ubuntu

echo /home/ubuntu/home/ubuntu/home/ubuntu/home/ubuntu/home/ubuntu/home/ubuntu INSTALL TANZU CLI

# Download TKG files
docker run -itd --name vmw -e VMWUSER=$VMWUSER -e VMWPASS=$VMWPASS -v ${PWD}:/files --entrypoint=sh apnex/vmw-cli
# view current files
docker exec -t vmw vmw-cli ls vmware_tanzu_kubernetes_grid
# download files
docker exec -t vmw vmw-cli cp tanzu-cli-bundle-linux-amd64.tar
docker exec -t vmw vmw-cli cp kubectl-linux-v1.21.2+vmware.1.gz
docker exec -t vmw vmw-cli cp crashd-linux-amd64-v0.3.3+vmware.1.tar.gz
docker exec -t vmw vmw-cli cp velero-linux-v1.6.2_vmware.1.gz
# stop vmw-cli container
docker rm -f vmw

gunzip kubectl-linux-v1.21.2+vmware.1.gz
chmod +x kubectl-linux-v1.21.2+vmware.1 && sudo mv kubectl-linux-v1.21.2+vmware.1 /usr/local/bin/kubectl

mkdir -p /home/ubuntu/tanzu-cli
chown -R ubuntu /home/ubuntu/tanzu-cli

tar -xvf tanzu-cli-bundle-linux-amd64.tar -C /home/ubuntu/tanzu-cli
sudo install /home/ubuntu/tanzu-cli/cli/core/v1.4.0/tanzu-core-linux_amd64 /usr/local/bin/tanzu
tanzu plugin install --local /home/ubuntu/tanzu-cli/cli all

echo "export TANZU_CLI_PINNIPED_AUTH_LOGIN_SKIP_BROWSER=true" >> /home/ubuntu/.bashrc

gunzip /home/ubuntu/tanzu-cli/cli/imgpkg-linux-amd64-v0.10.0+vmware.1.gz
chmod +x /home/ubuntu/tanzu-cli/cli/imgpkg-linux-amd64-v0.10.0+vmware.1 
sudo cp /home/ubuntu/tanzu-cli/cli/imgpkg-linux-amd64-v0.10.0+vmware.1 /usr/local/bin/imgpkg
gunzip /home/ubuntu/tanzu-cli/cli/kapp-linux-amd64-v0.37.0+vmware.1.gz
chmod +x /home/ubuntu/tanzu-cli/cli/kapp-linux-amd64-v0.37.0+vmware.1
sudo cp /home/ubuntu/tanzu-cli/cli/kapp-linux-amd64-v0.37.0+vmware.1 /usr/local/bin/kapp
gunzip /home/ubuntu/tanzu-cli/cli/kbld-linux-amd64-v0.30.0+vmware.1.gz
chmod +x /home/ubuntu/tanzu-cli/cli/kbld-linux-amd64-v0.30.0+vmware.1
sudo cp /home/ubuntu/tanzu-cli/cli/kbld-linux-amd64-v0.30.0+vmware.1 /usr/local/bin/kbld
gunzip /home/ubuntu/tanzu-cli/cli/ytt-linux-amd64-v0.34.0+vmware.1.gz
chmod +x /home/ubuntu/tanzu-cli/cli/ytt-linux-amd64-v0.34.0+vmware.1
sudo cp /home/ubuntu/tanzu-cli/cli/ytt-linux-amd64-v0.34.0+vmware.1 /usr/local/bin/ytt

gunzip velero-linux-v1.6.2_vmware.1.gz
chmod +x velero-linux-v1.6.2_vmware.1
sudo cp velero-linux-v1.6.2_vmware.1 /usr/local/bin/velero

gunzip crashd-linux-amd64-v0.3.3+vmware.1.tar.gz
mkdir -p /home/ubuntu/tanzu-crashd
tar -xvf crashd-linux-amd64-v0.3.3+vmware.1.tar -C /home/ubuntu/tanzu-crashd
# for some reason, the following version has +, while the others have -
sudo cp /home/ubuntu/tanzu-crashd/crashd/crashd-linux-amd64-v0.3.3+vmware.1 /usr/local/bin/crashd
chown -R ubuntu /home/ubuntu/tanzu-crashd

tanzu plugin list

exit 0