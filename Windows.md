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

Download Tanzu Kubernetes Grid Packages - https://www.vmware.com/go/get-tkg
- tanzu cli
  - Extract using 7-zip and copy tkg and Carvel utilities to ~/bin renaming them to name.exe
- kubectl cli
  - Extract using 7-zip and copy kubectl.exe to ~/bin
- ova's

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
echo docker() { (export MSYS_NO_PATHCONV=1; "docker.exe" "$@") } >> ~/.bash_profile


# Download TKG files
docker run -itd --name vmw -e VMWUSER=$VMWUSER -e VMWPASS=$VMWPASS -v ${PWD}:/files --entrypoint=sh apnex/vmw-cli
# view current files
docker exec -t vmw vmw-cli ls vmware_tanzu_kubernetes_grid
# download files
docker exec -t vmw vmw-cli cp tanzu-cli-bundle-windows-amd64.tar
docker exec -t vmw vmw-cli cp kubectl-windows-v1.21.2+vmware.1.exe.gz 
docker exec -t vmw vmw-cli cp velero-windows64-v1.6.2_vmware.1.gz
# stop vmw-cli container
docker rm -f vmw


gunzip kubectl-windows-v1.21.2+vmware.1.exe.gz
mv kubectl-windows-v1.21.2+vmware.1.exe ~/bin/kubectl.exe

mkdir ~/tanzu-cli
tar -xvf tanzu-cli-bundle-windows-amd64.tar -C ~/tanzu-cli


cp ~/tanzu-cli/cli/core/v1.4.0/tanzu-core-windows_amd64.exe ~/bin/tanzu.exe
tanzu plugin clean
tanzu plugin install --local ~/tanzu-cli/cli all

# Abovce will likely fail.  So Due to [Running Tanzu commands on Windows fails with a certificate error] (https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.3.1/rn/VMware-Tanzu-Kubernetes-Grid-131-Release-Notes.html#knownissues), add following to ~/.config/tanzu/tkg/config.yaml
TKG_CUSTOM_IMAGE_REPOSITORY_CA_CERTIFICATE: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tDQpNSUlNUERDQ0N5U2dBd0lCQWdJUUZPc0JjK1YzWk4wYVZQd0VEang2MHpBTkJna3Foa2lHOXcwQkFRc0ZBRENCDQp1akVMTUFrR0ExVUVCaE1DVlZNeEZqQVVCZ05WQkFvVERVVnVkSEoxYzNRc0lFbHVZeTR4S0RBbUJnTlZCQXNUDQpIMU5sWlNCM2QzY3VaVzUwY25WemRDNXVaWFF2YkdWbllXd3RkR1Z5YlhNeE9UQTNCZ05WQkFzVE1DaGpLU0F5DQpNREV5SUVWdWRISjFjM1FzSUVsdVl5NGdMU0JtYjNJZ1lYVjBhRzl5YVhwbFpDQjFjMlVnYjI1c2VURXVNQ3dHDQpBMVVFQXhNbFJXNTBjblZ6ZENCRFpYSjBhV1pwWTJGMGFXOXVJRUYxZEdodmNtbDBlU0F0SUV3eFN6QWVGdzB5DQpNVEEyTURreE9ETXlOVFphRncweU1qQXhNalF4T0RNeU5USmFNSHd4Q3pBSkJnTlZCQVlUQWxWVE1STXdFUVlEDQpWUVFJRXdwRFlXeHBabTl5Ym1saE1SSXdFQVlEVlFRSEV3bFFZV3h2SUVGc2RHOHhGREFTQmdOVkJBb1RDMVpODQpkMkZ5WlN3Z1NXNWpNUXN3Q1FZRFZRUUxFd0pKVkRFaE1COEdBMVVFQXhNWVkyOXVjMjlzWlM1amJHOTFaQzUyDQpiWGRoY21VdVkyOXRNSUlCSWpBTkJna3Foa2lHOXcwQkFRRUZBQU9DQVE4QU1JSUJDZ0tDQVFFQXhUYklmQU5ODQozMTA2ZlBYcWxDWGtNeEVJc1k4RTNhNHhXMHMyZzQxM2VnbkloV2MwVXZJRmlWSlZsR3BQWkJZdzBDYnhPQTA4DQpJeG42NkpyZjdyK2N5eEdrU2JyQlRYSlhLSW4vTHNwUzJ4UHhGdlJqS01OekFUV3k0dzJTaFJmSDB0b3dFV1J0DQpFcTRqZnVMNktJR0dFRE0rNkYwTG82RzdrQzZvYmpCeGVGU0g5V3RHWU96b21SR0NNb0N4dXU3SjRZQys5SStNDQphc2hOTFdwL3lzeUJVaHpkc1kzQ0kvUXF0aHlTOVZnOUQ1aWRnYzF2WDVaTEdkYUVhbUxxMWo2bmZpcGIyb3lkDQpSbmh2MjlnUlFzMDlEQjBlay80VWsySlVFQVAzdERDeDhLbWs0MjZrSi9ONE1vTkNUV2V0YW9ZRlRmWkxtbVJIDQpEcmIyYUtRRjdNbVRQUUlEQVFBQm80SUllVENDQ0hVd0RBWURWUjBUQVFIL0JBSXdBREFkQmdOVkhRNEVGZ1FVDQoyS3gvdlU2OU5ZVVR3QUUrRXJrRVpSM29CZUF3SHdZRFZSMGpCQmd3Rm9BVWdxSndkTjI4VXovUGU5VDN6WCtuDQpZTVlLVEw4d2FBWUlLd1lCQlFVSEFRRUVYREJhTUNNR0NDc0dBUVVGQnpBQmhoZG9kSFJ3T2k4dmIyTnpjQzVsDQpiblJ5ZFhOMExtNWxkREF6QmdnckJnRUZCUWN3QW9ZbmFIUjBjRG92TDJGcFlTNWxiblJ5ZFhOMExtNWxkQzlzDQpNV3N0WTJoaGFXNHlOVFl1WTJWeU1ETUdBMVVkSHdRc01Db3dLS0Ftb0NTR0ltaDBkSEE2THk5amNtd3VaVzUwDQpjblZ6ZEM1dVpYUXZiR1YyWld3eGF5NWpjbXd3Z2dXRUJnTlZIUkVFZ2dWN01JSUZkNElZWTI5dWMyOXNaUzVqDQpiRzkxWkM1MmJYZGhjbVV1WTI5dGdnMWtaWFp2Y0hOc2IyOXdMbWx2Z2lKelpXRnJMblJ2WjJWMGFHVnlkMlZwDQpibTV2ZG1GMFpTNTJiWGRoY21VdVkyOXRnaUJwYmk1MGIyZGxkR2hsY25kbGFXNXViM1poZEdVdWRtMTNZWEpsDQpMbU52YllJZWFIUnRiQzFwYm1SbGVDNXlaWEJ2TG5OaGJIUndjbTlxWldOMExtbHZnaVpvZEcxc0xXbHVaR1Y0DQpMbUZ5WTJocGRtVXVjbVZ3Ynk1ellXeDBjSEp2YW1WamRDNXBiNElnWldGeWJIa3RZV05qWlhOekxuSmxjRzh1DQpjMkZzZEhCeWIycGxZM1F1YVcrQ0ZYZDNkeTUyYlhkaGNtVnpkRzl5YVdWekxtTnZiWUlWZDNkM0xuWm1iM0oxDQpiUzUyYlhkaGNtVXVZMjl0Z2hGM2QzY3VkbVZzYjJOc2IzVmtMbU52YllJZWQzZDNMbTE1Wm5WMGRYSmxjbVZoDQpaSGwzYjNKcmMzQmhZMlV1WTI5dGdnNTNkM2N1WjJWMGQzTXhMbU52YllJWWQzZDNMbU5zYjNWa1kzSmxaR2xpDQphV3hwZEhrdVkyOXRnaEYzZDNjdVlYQndZMjl1Wm1sbkxtOXlaNElZZDJSamIzSnBaeTVwZEdOdVlTNTJiWGRoDQpjbVV1WTI5dGdoRjJiWGRoY21WemRHOXlhV1Z6TG1OdmJZSUxkbWxoTG5adGR5NWpiMjJDRVhabWIzSjFiUzUyDQpiWGRoY21VdVkyOXRnZzF6Y0hKcGJtZHNhWFpsTG1sdmdobHpaWEoyYVdObGN5NXBkR051WVM1MmJYZGhjbVV1DQpZMjl0Z2gxelpYSjJhV05sY3kxemRHY3VhWFJqYm1FdWRtMTNZWEpsTG1OdmJZSWVjMlZ5ZG1salpYTXRZM04wDQpaeTVwZEdOdVlTNTJiWGRoY21VdVkyOXRnaHB6WlhKMmFXTmxaR1Z6YXk1bGJtY3VkbTEzWVhKbExtTnZiWUlaDQpjMk5rWTI5eWFXY3VhWFJqYm1FdWRtMTNZWEpsTG1OdmJZSVVjbVZ3YjNKMGJtOTNMblp0ZDJGeVpTNWpiMjJDDQpISEJ5YjJwbFkzUnpMbkpsWjJsemRISjVMblp0ZDJGeVpTNWpiMjJDSUhCaGMzTndiM0owTG5kdmNtdHpjR0ZqDQpaV0ZwY2k1MmJYZGhjbVV1WTI5dGdocHRlV1oxZEhWeVpYSmxZV1I1ZDI5eWEzTndZV05sTG1OdmJZSWZhbWx5DQpZV2x1ZEdWbmNtRjBhVzl1Y3k1bGJtY3VkbTEzWVhKbExtTnZiWUlUYW1seVlTNWxibWN1ZG0xM1lYSmxMbU52DQpiWUlYYW1seVlTMWxkV011Wlc1bkxuWnRkMkZ5WlM1amIyMkNDbWRsZEhkek1TNWpiMjJDRjJOemNDMXFhWEpoDQpMbVZ1Wnk1MmJYZGhjbVV1WTI5dGdodGpiMjV6YjJ4bExYQm5MbU5zYjNWa0xuWnRkMkZ5WlM1amIyMkNIR052DQpibk52YkdVdFpUSmxMbU5zYjNWa0xuWnRkMkZ5WlM1amIyMkNHMk52Ym01bFkzUXVkbU5vY3kxcGJuUXVkbTEzDQpZWEpsTG1OdmJZSVdZMjl1Ym1WamRDNW9ZM2d1ZG0xM1lYSmxMbU52YllJWlkyOXVabXgxWlc1alpTNWxibWN1DQpkbTEzWVhKbExtTnZiWUlVWTJ4dmRXUmpjbVZrYVdKcGJHbDBlUzVqYjIyQ0VHTnNiM1ZrTG5adGQyRnlaUzVqDQpiMjJDSFdOc2IzVmtMWFZ6TFRJdWFHOXlhWHB2Ymk1MmJYZGhjbVV1WTI5dGdoMWpiRzkxWkMxbGRTMHlMbWh2DQpjbWw2YjI0dWRtMTNZWEpsTG1OdmJZSWRZMnh2ZFdRdFlYQXRNaTVvYjNKcGVtOXVMblp0ZDJGeVpTNWpiMjJDDQpHbU5sZEMxaGNHa3RaMkYwWlhkaGVTNTJiWGRoY21VdVkyOXRnaEpqWWk1amIyUmxMblp0ZDJGeVpTNWpiMjJDDQpEV0Z3Y0dOdmJtWnBaeTV2Y21lQ0VtRndhUzUyWkhBdWRtMTNZWEpsTG1OdmJZSWdZMjR1ZEc5blpYUm9aWEozDQpaV2x1Ym05MllYUmxMblp0ZDJGeVpTNWpiMjJDSUdwd0xuUnZaMlYwYUdWeWQyVnBibTV2ZG1GMFpTNTJiWGRoDQpjbVV1WTI5dGdoTnlaWEJ2TG5OaGJIUndjbTlxWldOMExtbHZnaHRoY21Ob2FYWmxMbkpsY0c4dWMyRnNkSEJ5DQpiMnBsWTNRdWFXK0NHR0p2YjNSemRISmhjQzV6WVd4MGNISnZhbVZqZEM1cGI0SWJkMmx1WW05dmRITjBjbUZ3DQpMbk5oYkhSd2NtOXFaV04wTG1sdmdodHpkR0ZuYVc1bkxuSmxjRzh1YzJGc2RIQnliMnBsWTNRdWFXOHdEZ1lEDQpWUjBQQVFIL0JBUURBZ1dnTUIwR0ExVWRKUVFXTUJRR0NDc0dBUVVGQndNQkJnZ3JCZ0VGQlFjREFqQk1CZ05WDQpIU0FFUlRCRE1EY0dDbUNHU0FHRyttd0tBUVV3S1RBbkJnZ3JCZ0VGQlFjQ0FSWWJhSFIwY0hNNkx5OTNkM2N1DQpaVzUwY25WemRDNXVaWFF2Y25CaE1BZ0dCbWVCREFFQ0FqQ0NBWDhHQ2lzR0FRUUIxbmtDQkFJRWdnRnZCSUlCDQphd0ZwQUhZQTM2VmVxMmlDVHg5c3JlNjRYMDQrV3VyTm9oS2thbDZPT3hMQUlFUmNLbk1BQUFGNThneUVmUUFBDQpCQU1BUnpCRkFpQmpKcUJ4d0U4d2VQaUY1Zlc2S1pweUJLVUlRVUNJZFVTUWkzVUtMdXpGUndJaEFJUnQwUXlYDQpETzA5MlZ6cWdGZGRicWcxNVg5TG5KTHM4R3o2K05yZGtIaVZBSGNBVmhRR21pL1h3dXpUOWVHOVJMSSt4MFoyDQp1YnlaRVZ6QTc1U1lWZGFKME4wQUFBRjU4Z3lFOFFBQUJBTUFTREJHQWlFQTlrdWlOaGhUVWRlYTZCMERNR0ZuDQpzY2xMRVZFM01kc1NXOUhXNGVvUGZ5VUNJUUNLVHZSQ3VUaHhKcnZDTTdUMHpieFB3cUNpcDU3cmdnYXo4UzBkDQpVWCtIbkFCMkFFYWxWZXQxK3BFZ01MV2lpV24wODMwUkxFRjB2djFKdUlXcjh2eHcvbTFIQUFBQmVmSU1oajRBDQpBQVFEQUVjd1JRSWhBS2xlQWxzR1VBcnpFTVg0S044Y2NKQUZobHA1eVFwQlA2OVBHaHN6ODh5ZEFpQXhjR2pmDQphVkQxazFhUlhMYVYvSFQwRUtDVE4vMFJ2RVd1bGh0WGpoTWc0ekFOQmdrcWhraUc5dzBCQVFzRkFBT0NBUUVBDQpuWGxjUisrRnFHWERLcWQ5akVRZnVVaFpYb2Z3WmJSRGZmMDRSRUlkVzQ5c2pteEp5L1BMRE9qTCsySkt5bG5BDQpBWW1OOG1hQzRLMnM3YmNHTFhISHdWbWdSVDFSeDdzL0JTTDlNR0ZTeXpteW1NTVN5TWoyRTMzVDcvLzNnSXFpDQpxS2J2RDRnWTVaRkt4Q2RRQlZ1dkVDd0F0bkFJVGRKKzFDN1JOdmVWWGZnL0tKUEZMUEJZdHE3S3hyTGJrR2JpDQo3UnhGdlE1WThMZU9NaUt0TjFYdVFPS1BYNTJUbm9NNmVmUkEwcFhkMGxSYW4wRjVYSnl3NHZsK1hyeEVCdSsyDQpVYUtORmJ5QVVhN2g0SFBUR0Y4cmhaQU5IRmJKcTZiNHZzMWJxSFZlc29CL2daWDN2V0xtVW5qSU5pWkZmZFg0DQowS3k2NFkrZnk3N1lHcFFRcFNpVGtRPT0NCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0NCg== >> ~/.bashrc

# now try again
tanzu plugin install --local ~/tanzu-cli/cli all
tanzu plugin list

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


curl -L -o ~/bin/pivnet.exe https://github.com/pivotal-cf/pivnet-cli/releases/download/v3.0.0/pivnet-windows-amd64-3.0.0
curl -L -o ~/bin/yq.exe https://github.com/mikefarah/yq/releases/download/4.6.1/yq_windows_amd64.exe
curl -L -o ~/bin/tmc.exe https://tmc-cli.s3-us-west-2.amazonaws.com/tmc/0.2.1-ded34d75/windows/x64/tmc.exe
curl -L -o ~/bin/jq.exe https://github.com/stedolan/jq/releases/download/jq-1.6/jq-win64.exe
curl -L -o ~/bin/kind.exe https://kind.sigs.k8s.io/dl/v0.9.0/kind-windows-amd64

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

curl -LO https://github.com/buildpacks/pack/releases/download/v0.15.1/pack-v0.15.1-windows.zip
unzip pack-v0.15.1-windows.zip
mv pack.exe ~/bin/
rm pack*

curl -LO https://github.com/vmware/govmomi/releases/download/v0.23.0/govc_windows_amd64.exe.zip
unzip govc_windows_amd64.exe.zip
mv govc_windows_amd64.exe ~/bin/govc.exe
rm govc_win*

curl -LO https://github.com/concourse/concourse/releases/download/v6.7.5/fly-6.7.5-windows-amd64.zip
unzip fly-6.7.5-windows-amd64.zip
mv fly.exe ~/bin/fly.exe
rm fly-6.7.5*

# Goto https://network.pivotal.io and register for an account if you have not done so already.  Then grab the legacy api token for your profile and use that to login with the command below
pivnet login
pivnet download-product-files --product-slug='build-service' --release-version='1.1.1' --product-file-id=883033 --download-dir ~/bin
mv ~/bin/kp-windows-0.2.0.exe ~/bin/kp.exe

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

- Get Windows 10 ISO: https://www.microsoft.com/en-us/evalcenter/evaluate-windows-10-enterprise
- Using the windows server jumpbox, upload the ISO to vCenter
- Create new VM, Win 10 64-bit
  - 4 core, 16 GB RAM, 200 GB Disk
  - Under CPU choose "Expose hardware assisted virtualization to the guest OS"
- Boot VM from ISO disk and run through setup.  Use domain account.  USERNAME / PASSWORD
- Install VM Tools
- Set IP to address in static range
- Enable remote access: https://networking.grok.lsu.edu/Article.aspx?articleid=18609
- May also need to edit Group Policy to get copy paste to work: https://nishantrana.me/2019/02/09/fixed-copy-paste-not-working-in-remote-desktop-connection-windows-10/
- Now Remote Desktop to IP address
