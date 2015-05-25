FROM ubuntu:14.04.2
MAINTAINER Ronan Harmegnies

ADD https://github.com/zimbatm/direnv/releases/download/v2.6.0/direnv.linux-amd64 /usr/local/bin/direnv
COPY add_git_key.rb /root/add_git_key.rb

# apt update + additionnal ppas
RUN echo "debconf debconf/frontend select Teletype" | debconf-set-selections &&\
    apt-get update && \
    apt-get -y install software-properties-common python-software-properties &&\
    add-apt-repository ppa:webupd8team/sublime-text-3 &&\
    apt-get update


RUN  apt-get install -y \
# basics
        openssh-client git build-essential vim ctags man curl \
# tmux deps
        libevent-dev ncurses-dev pkg-config automake \
# homesick deps
        ruby \
# zsh, openssh
        zsh \
        openssh-server
RUN \
# tmux plugins
    git clone https://github.com/ThomasAdam/tmux.git /usr/local/share/tmux &&\
    (cd /usr/local/share/tmux  && git checkout -b tags/2.0 && sh autogen.sh && ./configure && make && make install) &&\
# wemux
    git clone https://github.com/zolrath/wemux.git /usr/local/share/wemux &&\
    (cd /usr/local/share/wemux && git checkout -b tags/v3.2.0) &&\
    ln -s /usr/local/share/wemux/wemux /usr/local/bin/wemux &&\
    cp /usr/local/share/wemux/wemux.conf.example /usr/local/etc/wemux.conf &&\
    echo "host_list=(root)" >> /usr/local/etc/wemux.conf &&\
# Homesick, (used by zsh and vim)
    gem install homesick --no-rdoc --no-ri &&\
# Github Auth gem, used for authorizing users for SSH
    gem install github-auth --no-rdoc --no-ri &&\
# zsh
    homesick clone ronanh/zshfiles &&\
    homesick symlink zshfiles &&\
    chsh -s /usr/bin/zsh root &&\
# vim
    homesick clone ronanh/vimfiles &&\
    homesick symlink vimfiles &&\
    /root/.vim/bundle/neobundle.vim/bin/neoinstall &&\
# SSH
    mkdir /var/run/sshd &&\
    echo "AllowAgentForwarding yes" >> /etc/ssh/sshd_config &&\
# Direnv
    chmod 755 /usr/local/bin/direnv &&\
# Locale
    locale-gen en_US en_US.UTF-8 && dpkg-reconfigure locales &&\
    echo "\nLANGUAGE=en_US.UTF-8\nLANG=en_US.UTF-8\nLC_ALL=en_US.UTF-8" >> /etc/environment


# Sublime text
RUN mkdir -p /usr/share/icons/hicolor/16x16/apps/ /usr/share/icons/hicolor/32x32/apps/ \
             /usr/share/icons/hicolor/48x48/apps/ /usr/share/icons/hicolor/128x128/apps/ \
             /usr/share/icons/hicolor/256x256/apps/
RUN apt-get install -y sublime-text-installer libglib2.0-dev libx11-dev libgtk2.0-0 
RUN mkdir -p '/root/.config/sublime-text-3/Packages' '/root/.config/sublime-text-3/Installed Packages' &&\
    wget https://sublime.wbond.net/Package%20Control.sublime-package &&\
    mv 'Package Control.sublime-package' '/root/.config/sublime-text-3/Installed Packages/'


# Cleanup
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


# share workspace directory
VOLUME ["/src"]

EXPOSE 22 

CMD /root/add_git_key.rb && /usr/sbin/sshd -D
