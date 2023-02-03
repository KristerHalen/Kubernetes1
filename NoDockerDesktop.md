https://dev.to/bowmanjd/install-docker-on-windows-wsl-without-docker-desktop-34m9

## Setting up WSL:
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
wsl --set-default-version 2
wsl -l -o
Om man vill ha en egen instans av Linux att leka med...:
wsl.exe --install -d Ubuntu-22.04
wsl -l -v
wsl
sudo apt update && sudo apt upgrade

## Installera Docker på WSL:
sudo apt install --no-install-recommends apt-transport-https ca-certificates curl gnupg2
. /etc/os-release
curl -fsSL https://download.docker.com/linux/${ID}/gpg | sudo tee /etc/apt/trusted.gpg.d/docker.asc
echo "deb [arch=amd64] https://download.docker.com/linux/${ID} ${VERSION_CODENAME} stable" | sudo tee /etc/apt/sources.list.d/docker.list
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io
sudo usermod -aG docker $USER
getent group | cut -d: -f3 | grep -E '^[0-9]{4}' | sort -g
getent group | grep 1337 || echo "Yes, that ID is free"
sudo sed -i -e 's/^\(docker:x\):[^:]\+/\1:1337/' /etc/group
(eller sudo groupmod -g 1337 docker)
DOCKER_DIR=/mnt/wsl/shared-docker
mkdir -pm o=,ug=rwx "$DOCKER_DIR"
chgrp docker "$DOCKER_DIR"
sudo mk,dir /etc/docker/
sudo touch /etc/docker/daemon.json
sudo nano /etc/docker/daemon.json
```
{
  "hosts": ["unix:///mnt/wsl/shared-docker/docker.sock"]
}
```

sudo dockerd

Ny terminal:
export DOCKER_HOST="unix:///mnt/wsl/shared-docker/docker.sock"
docker run --rm hello-world

Ny terminal:
sudo nano ~/.bashrc
```
DOCKER_DISTRO="Debian"
DOCKER_DIR=/mnt/wsl/shared-docker
DOCKER_SOCK="$DOCKER_DIR/docker.sock"
export DOCKER_HOST="unix://$DOCKER_SOCK"
if [ ! -S "$DOCKER_SOCK" ]; then
    mkdir -pm o=,ug=rwx "$DOCKER_DIR"
    chgrp docker "$DOCKER_DIR"
    /mnt/c/Windows/System32/wsl.exe -d $DOCKER_DISTRO sh -c "nohup sudo -b dockerd < /dev/null > $DOCKER_DIR/dockerd.log 2>&1"
fi
```

sudo visudo
```
%docker ALL=(ALL)  NOPASSWD: /usr/bin/dockerd
```
Avsluta terminal:
Installera Rancher Desktop (Skapar \\wsl.localhost\rancher-desktop, \\wsl.localhost\rancher-desktop-data)
choco install -force docker-cli (Mappar en windowsklient av docker.exe som fungerar fullt ut mot WSL)
docker run -d -p 5000:5000 --restart=always --name registry registry:2

Textfiles:
touch /path/filnamn
sudo nano /path/filnamn

Avinstallera:
sudo apt remove docker docker-engine docker.io containerd runc

wsl wslpath -a .
Usage:
    -a    force result to absolute path format
    -u    translate from a Windows path to a WSL path (default)
    -w    translate from a WSL path to a Windows path
    -m    translate from a WSL path to a Windows path, with '/' instead of '\'