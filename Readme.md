# Workstation Setup

Get Windows 10 ISO: https://www.microsoft.com/en-us/evalcenter/evaluate-windows-10-enterprise
Using the windows server jumpbox, upload the ISO to vCenter
Create new VM, Win 10 64-bit
  4 core, 16 GB RAM, 200 GB Disk
  Under CPU choose "Expose hardware assisted virtualization to the guest OS"
Bood VM from ISO disk and run through setup.  Use domain account.  cody / KeepItSimple1!
Install VM Tools
Set IP to address in static range
Enable remote access: https://networking.grok.lsu.edu/Article.aspx?articleid=18609

Now Remote Desktop to IP address

Chrome - 

Install Git => https://git-scm.com/download/win

Install VS Code => https://code.visualstudio.com/download
  Enable auto save (File->Auto Save)

Install Windows Subsystem for Linux 2 - https://docs.microsoft.com/en-us/windows/wsl/wsl2-kernel

Docker - https://docs.docker.com/docker-for-windows/install/

https://docs.microsoft.com/en-us/windows/wsl/wsl2-kernel

Filezilla - https://filezilla-project.org/download.php?platform=win64
7-zip - https://www.7-zip.org/

TKG - https://www.vmware.com/go/get-tkg
  tkg cli
    Extract using 7-zip and copy tkg and Carvel utilities to ~/bin renaming them to name.exe
  kubectl cli
    Extract using 7-zip and copy kubectl.exe to ~/bin
  ova's
  tkg extensions
  tkg connectivity api


Create %USERPROFILE%/bin directory
Add %USERPROFILE%/bin to path
    Enter env in search bar

Copy your .pivnetrc file to %USERPROFILE%/

Create %USERPROFILE%/workspace/workstation-setup directory
Open VS COde to that directory
Set Git Bash as default terminal

```bash
curl -L -o ~/bin/ytt.exe https://github.com/k14s/ytt/releases/download/v0.30.0/ytt-windows-amd64.exe
curl -L -o ~/bin/kapp.exe https://github.com/k14s/kapp/releases/download/v0.34.0/kapp-windows-amd64.exe
curl -L -o ~/bin/kbld.exe https://github.com/k14s/kbld/releases/download/v0.26.0/kbld-windows-amd64.exe
curl -L -o ~/bin/pivnet.exe https://github.com/pivotal-cf/pivnet-cli/releases/download/v2.0.1/pivnet-windows-amd64-2.0.1
curl -L -o ~/bin/yq.exe https://github.com/mikefarah/yq/releases/download/3.4.1/yq_windows_amd64.exe
curl -L -o ~/bin/tmc.exe https://vmware.bintray.com/tmc/0.2.0-b11584d8/windows/x64/tmc.exe
curl -L -o ~/bin/jq.exe https://github.com/stedolan/jq/releases/download/jq-1.6/jq-win64.exe

curl -LO https://get.helm.sh/helm-v3.4.0-rc.1-windows-amd64.zip
unzip helm-v3.4.0-rc.1-windows-amd64.zip 
mv windows-amd64/helm.exe ~/bin/helm.exe
rm helm*
rm -rf windows-amd64/

curl -LO https://github.com/vmware-tanzu/octant/releases/download/v0.16.1/octant_0.16.1_Windows-64bit.zip
unzip octant_0.16.1_Windows-64bit.zip
mv octant_0.16.1_Windows-64bit/octant.exe ~/bin/octant.exe
rm -rf octant_0.16.1_Windows-64bit
rm octant*

curl -LO https://github.com/buildpacks/pack/releases/download/v0.14.2/pack-v0.14.2-windows.zip
unzip pack-v0.14.2-windows.zip
mv pack.exe ~/bin/
rm pack*


pivnet download-product-files --product-slug='build-service' --release-version='1.0.2' --product-file-id=773507 --download-dir ~/bin
mv ~/bin/kp-windows-0.1.1.exe ~/bin/kp.exe
```

JDK - https://adoptopenjdk.net/releases.html
    JDK 11, Windows x86, msi
    In the installer choose to set JAVA_HOME variable