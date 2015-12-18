# docker-dev

Basic docker based development environment

## Build

checkout and cd to the docker-dev directory and build the container

```bash
docker build --no-cache -t docker-dev .
```

## Run a container

When running the container you must specify all of the allowed GitHub usernames using `AUTHORIZED_GIT_USERS` environment variable. 

ex:
```bash
docker run -d -e AUTHORIZED_GIT_USERS="ronanh" -p 0.0.0.0:2222:22 docker-dev
```


## ssh to a running container

simply ssh to the host running the container using the exposed port (2222 in the previous example)

To facilitate things it is posssible to configure the `~/.ssh/config` file:

```
Host devbox
  HostName <IP>
  Port <MAPPED PORT>
  User root
  ForwardAgent true
  ForwardX11 true
  StrictHostKeyChecking no
  UserKnownHostsFile=/dev/null
```

with these settings logging in is as simple as:

```bash
ssh devbox
```

## Notes for initial MacBook setup


* Install [VMWARE Fusion 7](http://www.vmware.com/fr/products/fusion) License: see email EGH
* Install [Virtual Box](https://www.virtualbox.org/)
* Install [Vagrant](https://www.vagrantup.com/)
* Install [Docker](http://boot2docker.io/)
* Install [iTerm2](https://www.iterm2.com/)
* Install [source-code-pro font](https://github.com/adobe-fonts/source-code-pro) and configure iTerm (font size 14)
* Other scriptable installs:


First, set `http_proxy`, `https_proxy` ENV if needed. ex:

```bash
echo "export PROXY_HOST=HOST" >> ~/.profile
echo "export PROXY_PORT=PORT" >> ~/.profile

echo "source ~/.profile" >> ~/.zprofile
source ~/.profile

export http_proxy=http://USER:PASSWORD@$PROXY_HOST:$PROXY_PORT
export https_proxy=$http_proxy
```

then

```bash
# Install homebrew
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
# update brew packages
brew update

# Reattach-to-user-namespace (used by tmux)
brew install reattach-to-user-namespace

# Install homesick https://github.com/technicalpickles/homesick
gem install homesick --no-rdoc --no-ri

# Recover my dotfiles
homesick clone ronanh/zshfiles
homesick symlink zshfiles
homesick clone ronanh/vimfiles
homesick symlink vimfiles

# Install vim bundles
~/.vim/bundle/neobundle.vim/bin/neoinstall

# Retrieve or generate new ssh Key 
# ssh-keygen -t rsa  -b 4096 -C "EMAIL"

# Github Auth gem, used for authorizing users for SSH
gem install github-auth --no-rdoc --no-ri

# Install tmux
brew install tmux

# vim
homesick clone ronanh/vimfiles
homesick symlink vimfiles

# zsh
homesick clone ronanh/zshfiles
homesick symlink zshfiles
brew install zsh

# direnv
brew install direnv

# Install [Docker machine](https://docs.docker.com/machine) 
# check version...
curl -L https://github.com/docker/machine/releases/download/v0.2.0/docker-machine_darwin-amd64 > /usr/local/bin/docker-machine
chmod +x /usr/local/bin/docker-machine

# Install [Docker Compose](https://docs.docker.com/compose/)
# check version
curl -L https://github.com/docker/compose/releases/download/1.2.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
```


