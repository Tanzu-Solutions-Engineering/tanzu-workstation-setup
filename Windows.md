# Windows Tanzu Workstation Setup

The following cheatsheet supports applications and utilities helpful for developer and operations (might I say devops) team members working with Tanzu.

The apps listed collected and used form a completely fresh Windows workstation.  See notes on creating the Windows 10 VM at the bottom.

## Applications and Utilities

Chrome - https://www.google.com/chrome

Install Git - https://git-scm.com/download/win

Install VS Code - https://code.visualstudio.com/download
- Enable auto save (File->Auto Save)
- Add the Kubernetes extension from Microsoft
- Add the vscode-base64 extension
- Add the SFTP extension from Natizyskunk
- Set Git Bash as default terminal (control-shift-p: terminal select default profile, select git bash)


Install Windows Subsystem for Linux 2 - https://docs.microsoft.com/en-us/windows/wsl/install-manual
- Steps 1-5

Install Docker - https://docs.docker.com/docker-for-windows/install/

(optional) Manually Download Tanzu Kubernetes Grid Packages - https://www.vmware.com/go/get-tkg (or you could download using cli as below)
- tanzu cli
- kubectl cli
- velero cli

Create single directory to put command line utilities into your path
- Create %USERPROFILE%\bin directory
- Add %USERPROFILE%\bin to path
  - Enter env in search bar, to launch the windows System Environment Variables dialog

Create a directory in your home for various git projects.  This is one of them.
- Create %USERPROFILE%\workspace
- git clone https://github.com/doddatpivotal/windows-tanzu-workstation.git
- Open VS Code to that directory

The following should be executed using Git BASH...

```bash

# Workaround for Docker for Windows in Git Bash. https://github.com/docker-archive/toolbox/issues/673
echo 'docker() { (export MSYS_NO_PATHCONV=1; "docker.exe" "$@") }' >> ~/.bash_profile

export VMWUSER='<your-vmw-customer-connect-user>'
export VMWPASS='<your-vmw-customer-connect-password>'

# Download TKG files
docker run -itd --name vmw -e VMWUSER=$VMWUSER -e VMWPASS=$VMWPASS -v ${PWD}:/files --entrypoint=sh apnex/vmw-cli
# view current files
docker exec -t vmw vmw-cli ls vmware_tanzu_kubernetes_grid
# download files
docker exec -t vmw vmw-cli cp tanzu-cli-bundle-windows-amd64.zip
docker exec -t vmw vmw-cli cp kubectl-windows-v1.23.8+vmware.2.exe.gz
docker exec -t vmw vmw-cli cp velero-windows64-v1.8.1+vmware.1.gz
# stop vmw-cli container
docker rm -f vmw

# unzip and move to your bin directory
gunzip kubectl-windows-v1.23.8+vmware.2.exe.gz
mv kubectl-windows-v1.23.8+vmware.2.exe ~/bin/kubectl.exe

# install tanzu cli
mkdir ~/tanzu-cli
unzip tanzu-cli-bundle-windows-amd64.zip -d ~/tanzu-cli
rm tanzu-cli-bundle-windows-amd64.zip

cp ~/tanzu-cli/cli/core/v0.11.6/tanzu-core-windows_amd64.exe ~/bin/tanzu.exe
tanzu plugin sync
tanzu plugin list

# unzip and copy Carvel tools to your bin directory
gunzip ~/tanzu-cli/cli/imgpkg-windows-amd64-v0.29.0+vmware.1.gz
cp ~/tanzu-cli/cli/imgpkg-windows-amd64-v0.29.0+vmware.1 ~/bin/imgpkg.exe
imgpkg version
gunzip ~/tanzu-cli/cli/kapp-windows-amd64-v0.49.0+vmware.1.gz
cp ~/tanzu-cli/cli/kapp-windows-amd64-v0.49.0+vmware.1 ~/bin/kapp.exe
kapp version
gunzip ~/tanzu-cli/cli/kbld-windows-amd64-v0.34.0+vmware.1.gz
cp ~/tanzu-cli/cli/kbld-windows-amd64-v0.34.0+vmware.1 ~/bin/kbld.exe
kbld version
gunzip ~/tanzu-cli/cli/vendir-windows-amd64-v0.27.0+vmware.1.gz
cp ~/tanzu-cli/cli/vendir-windows-amd64-v0.27.0+vmware.1 ~/bin/vendir.exe
vendir version
gunzip ~/tanzu-cli/cli/ytt-windows-amd64-v0.41.1+vmware.1.gz
cp ~/tanzu-cli/cli/ytt-windows-amd64-v0.41.1+vmware.1 ~/bin/ytt.exe
ytt version

# unzip and copy velero cli to bin directory
gunzip velero-windows64-v1.8.1+vmware.1.gz
mv velero-windows64-v1.8.1+vmware.1 ~/bin/velero.exe
velero version

# download pivnet cli to bin directory
curl -L -o ~/bin/pivnet.exe https://github.com/pivotal-cf/pivnet-cli/releases/download/v3.0.1/pivnet-windows-amd64-3.0.1
pivnet -v

# download yq to bin directory
curl -L -o ~/bin/yq.exe https://github.com/mikefarah/yq/releases/download/v4.25.1/yq_windows_amd64.exe
yq -V

# download tmc cli to bin directory
curl -L -o ~/bin/tmc.exe https://tmc-cli.s3-us-west-2.amazonaws.com/tmc/0.4.3-7e23d4d8/windows/x64/tmc.exe
tmc version

# download jq cli to bin directory
curl -L -o ~/bin/jq.exe https://github.com/stedolan/jq/releases/download/jq-1.6/jq-win64.exe
jq --help

# download kind to bin directory
curl -L -o ~/bin/kind.exe https://kind.sigs.k8s.io/dl/v0.11.1/kind-windows-amd64
kind version

# download helm to bin directory
curl -LO https://get.helm.sh/helm-v3.8.0-windows-amd64.zip
unzip helm-v3.8.0-windows-amd64.zip 
mv windows-amd64/helm.exe ~/bin/helm.exe
rm helm*
rm -rf windows-amd64/
helm version

curl -LO https://github.com/buildpacks/pack/releases/download/v0.26.0/pack-v0.26.0-windows.zip
unzip pack-v0.26.0-windows.zip
mv pack.exe ~/bin/
rm pack*
pack version

curl -LO https://github.com/vmware/govmomi/releases/download/v0.28.0/govc_Windows_x86_64.zip
unzip govc_Windows_x86_64.zip 
mv govc.exe ~/bin/govc.exe
rm govc_win*  LICENSE.txt CHANGELOG.md 
govc version

curl -LO https://github.com/concourse/concourse/releases/download/v6.7.5/fly-6.7.5-windows-amd64.zip
unzip fly-6.7.5-windows-amd64.zip
mv fly.exe ~/bin/fly.exe
rm fly-6.7.5*

# Go to https://network.tanzu.vmware.com and register for an account if you have not done so already.  Then grab the legacy api token for your profile and use that to login with the command below
pivnet login

pivnet download-product-files --product-slug='build-service' --release-version='1.6.1' --product-file-id=1241252 --download-dir ~/bin
mv ~/bin/kp-windows-0.6.0.exe ~/bin/kp.exe

# Install K9s.  Your favorite friend
mkdir k9s
cd k9s
curl -L0 https://github.com/derailed/k9s/releases/download/v0.25.18/k9s_Windows_x86_64.tar.gz --output k9s_Windows_x86_64.tar.gz
gunzip k9s_Windows_x86_64.tar.gz
tar -xvf k9s_Windows_x86_64.tar
mv k9s.exe ~/bin/k9s.exe
cd ..
rm -rf k9s

# Helpful Alias
echo "alias k=kubectl" >> ~/.bash_profile
source ~/.bash_profile

# Nice prompt
cd ~/workspace
git clone https://github.com/jonmosco/kube-ps1
echo "source ~/workspace/kube-ps1/kube-ps1.sh" >> ~/.bash_profile
echo PS1=\'[\`date +%X\) \\w]\\n \$\(kube_ps1\)] \\$ \' >> ~/.bash_profile

source ~/.bash_profile
cd ~


```

## Helpful Additions

Install WinSCP - https://winscp.net/eng/download.php

Install 7-zip - https://www.7-zip.org/

Windows Terminal - Install from Microsoft Store
- Search and then install
- Edit settings to add Git Bash as option: {"name": "Git Bash","commandline": "C:\\Program Files\\Git\\bin\\bash.exe","hidden": false}

>Note: If you don't have (and can't add Microstoft Store Extension) this site can be used to obtain direct link to the software: https://store.rg-adguard.net/

Install Python - Install from Microsoft Store
- Search and then install
- Note: Only seems to work in powershell

Install HTTPie
- Depends on Python
```bash
# From powershell window
pip install --upgrade pip setuptools
pip install --upgrade httpie
```
- Output of the above will suggest that you add a directory to your PATH variable.  After you so, you will be able to use HTTPie from powershell and GitBash


Install JDK - https://adoptopenjdk.net/releases.html
    JDK 11, Windows x86, msi
    In the installer choose to set JAVA_HOME variable

## Create Windows 10 Virtual Machine (Optional)

- Get Windows 10 ISO: https://www.microsoft.com/en-us/software-download/windows10ISO
- Upload the ISO to vCenter DataStore
- Create new VM, Win 10 64-bit
  - 4 core, 16 GB RAM, 200 GB Disk
  - Under CPU choose "Expose hardware assisted virtualization to the guest OS"
- Boot VM from ISO disk and run through setup.
  - Choose Windows 10 Pro
  - Custom Install
  - Choose to create offline account.  Could have used live account to connect to work, but since this is a lab, just choose offline account.
- Install VM Tools
- Enable remote access: https://networking.grok.lsu.edu/Article.aspx?articleid=18609
- May also need to edit Group Policy to get copy paste to work: https://nishantrana.me/2019/02/09/fixed-copy-paste-not-working-in-remote-desktop-connection-windows-10/
- Now Remote Desktop to IP address
