FROM ubuntu:14.04.2
MAINTAINER Ronan Harmegnies

## apt update + additionnal ppas
RUN echo "debconf debconf/frontend select Teletype" | debconf-set-selections &&\
    echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections &&\
    apt-get update && \
    apt-get install -y apt-transport-https software-properties-common python-software-properties wget curl git unzip &&\
    add-apt-repository -y ppa:webupd8team/java && \
    add-apt-repository ppa:webupd8team/sublime-text-3 &&\
    add-apt-repository "deb https://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main" &&\
    wget --quiet -O - https://postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add - &&\
    apt-get update

RUN  apt-get install -y \
# basics
        openssh-client build-essential vim ctags man \
# dev (for golang)
        gcc g++ libc6-dev make \
# tmux deps
        libevent-dev ncurses-dev pkg-config automake \
# homesick deps
        ruby \
# zsh, openssh
        zsh \
        openssh-server \
# jdk8
        oracle-java8-installer \
# node.js
       nodejs-legacy npm \
# erlang deps
       libwxbase2.8-0 libwxgtk2.8-0 \
# elixir deps
       inotify-tools \
       postgresql-client-9.4

# Locale
RUN locale-gen en_US en_US.UTF-8 && dpkg-reconfigure locales &&\
    echo "\nLANGUAGE=en_US.UTF-8\nLANG=en_US.UTF-8\nLC_ALL=en_US.UTF-8" >> /etc/environment
ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

RUN \
# tmux plugins
    git clone https://github.com/tmux/tmux.git /usr/local/share/tmux &&\
    (cd /usr/local/share/tmux  && git checkout -b tags/2.1 && sh autogen.sh && ./configure && make && make install) &&\
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
    echo "AllowAgentForwarding yes" >> /etc/ssh/sshd_config

# Erlang
ENV ERLANG_VERSION 18.1-1
RUN wget --no-verbose http://packages.erlang-solutions.com/site/esl/esl-erlang/FLAVOUR_1_general/esl-erlang_$ERLANG_VERSION~ubuntu~trusty_amd64.deb &&\
    dpkg -i esl-erlang_$ERLANG_VERSION~ubuntu~trusty_amd64.deb

# Elixir/Phoenix
ENV ELIXIR_VERSION 1.1.1
ENV PHOENIX_VERSION 1.0.3
RUN wget --no-verbose https://github.com/elixir-lang/elixir/releases/download/v$ELIXIR_VERSION/Precompiled.zip &&\
    unzip Precompiled.zip -d /usr/local/elixir-$ELIXIR_VERSION &&\
    ln -s /usr/local/elixir-$ELIXIR_VERSION/bin/elixirc /usr/local/bin/ &&\
    ln -s /usr/local/elixir-$ELIXIR_VERSION/bin/elixir /usr/local/bin/ &&\
    ln -s /usr/local/elixir-$ELIXIR_VERSION/bin/mix /usr/local/bin/ &&\
    ln -s /usr/local/elixir-$ELIXIR_VERSION/bin/iex /usr/local/bin/ &&\
    /usr/local/bin/mix local.rebar --force &&\
    /usr/local/bin/mix local.hex --force &&\
    /usr/local/bin/mix hex.info &&\
    /usr/local/bin/mix archive.install https://github.com/phoenixframework/phoenix/releases/download/v$PHOENIX_VERSION/phoenix_new-$PHOENIX_VERSION.ez --force

# Golang
ENV GOLANG_VERSION 1.5.1
ENV GOLANG_DOWNLOAD_URL https://golang.org/dl/go$GOLANG_VERSION.linux-amd64.tar.gz
ENV GOLANG_DOWNLOAD_SHA1 46eecd290d8803887dec718c691cc243f2175fe0
ENV GOPATH /go

RUN curl -fsSL "$GOLANG_DOWNLOAD_URL" -o golang.tar.gz \
  && echo "$GOLANG_DOWNLOAD_SHA1 golang.tar.gz" | sha1sum -c - \
  && tar -C /usr/local -xzf golang.tar.gz \
  && rm golang.tar.gz \
  && mkdir -p "$GOPATH/bin" "$GOPATH/src" \
  && echo "\nPATH=$GOPATH/bin:/usr/local/go/bin:$PATH\nexport JAVA_HOME=/usr/lib/jvm/java-8-oracle" >> "/root/.zshrc"


## Sublime text
#RUN mkdir -p /usr/share/icons/hicolor/16x16/apps/ /usr/share/icons/hicolor/32x32/apps/ \
#             /usr/share/icons/hicolor/48x48/apps/ /usr/share/icons/hicolor/128x128/apps/ \
#             /usr/share/icons/hicolor/256x256/apps/
#RUN apt-get install -y sublime-text-installer libglib2.0-dev libx11-dev libgtk2.0-0 
#RUN mkdir -p '/root/.config/sublime-text-3/Packages' '/root/.config/sublime-text-3/Installed Packages' &&\
#    wget https://sublime.wbond.net/Package%20Control.sublime-package &&\
#    mv 'Package Control.sublime-package' '/root/.config/sublime-text-3/Installed Packages/'

# Cleanup
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/cache/oracle-jdk8-installer

#ADD https://github.com/zimbatm/direnv/releases/download/v2.6.0/direnv.linux-amd64 /usr/local/bin/direnv
RUN wget --no-verbose https://github.com/zimbatm/direnv/releases/download/v2.6.0/direnv.linux-amd64 -O /usr/local/bin/direnv && \
    chmod 755 /usr/local/bin/direnv

# share workspace directory
VOLUME ["/code"]
VOLUME ["/go"]

RUN echo "export GOPATH=\$PWD" > /go/.envrc && direnv allow /go

EXPOSE 22

ADD add_git_key.rb /root/add_git_key.rb
CMD /root/add_git_key.rb && /usr/sbin/sshd -D
