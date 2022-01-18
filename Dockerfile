FROM ubuntu:20.04

# Non-interactive mode
ENV contianer docker
ENV LC_ALL C
ARG DEBIAN_FRONTEND=noninteractive
ENV DEBIAN_FRONTEND noninteractive
ENV TZ=US/Pacific

# Shell string
ENV PS1 "\e[1;33m\u \e[1;34m\$PWD \e[0;0m$ "

# Sources
RUN sed -i 's/# deb/deb/g' /etc/apt/sources.list

# Install base system
RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get -y install \
    sudo apt bash curl git \
    wget build-essential gpg \
    lsb-release libc6 htop \
    neofetch tzdata apt-utils \
    aptitude ubuntu-server nano \
    gnupg

# Set shell
SHELL [ "/bin/bash", "-c" ]

# Install Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_17.x | bash -
RUN apt-get -y install nodejs && \
    node -v && \
    npm install --global npm@latest && \
    npm -v

# Install Yarn
RUN curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | tee /usr/share/keyrings/yarnkey.gpg >/dev/null
RUN echo "deb [signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update && \
    apt-get -y install yarn && \
    yarn -v

# Install MongoDB
RUN wget -qO - https://www.mongodb.org/static/pgp/server-5.0.asc | apt-key add -
RUN echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/5.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-5.0.list
RUN apt-get update && \
    apt-get install -y mongodb-org

# Clean up apt
RUN apt-get clean && \
    apt-get autoremove -y && \
    rm -rf /var/cache/apt/* && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/* /var/tmp/* && \
    rm -f /lib/systemd/system/multi-user.target.wants/* \
    /etc/systemd/system/*.wants/* \
    /lib/systemd/system/local-fs.target.wants/* \
    /lib/systemd/system/sockets.target.wants/*udev* \
    /lib/systemd/system/sockets.target.wants/*initctl* \
    /lib/systemd/system/basic.target.wants/* \
    /lib/systemd/system/anaconda.target.wants/* \
    /lib/systemd/system/plymouth* \
    /lib/systemd/system/systemd-update-utmp*

# Add the opendocs user
RUN adduser --disabled-password --gecos '' opendocs && \
    adduser opendocs sudo && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Permissions
RUN chmod -R a+rwx /home/opendocs

# User
USER opendocs

# Ports
EXPOSE 4500

# ENV
ENV SHELL=/bin/bash
ENV GOPATH=/home/opendocs
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

# Labels
LABEL name="OpenDocs Docker Image"
LABEL version="Alpha / 0.1.0"
LABEL description="\
OpenDocs in a Docker image. \
https://git.nosadnile.net/opendocs/opendocs \
"

# Set up shell string
RUN export PS1="\e[1;33m\u \e[1;34m\\\$PWD \e[0;0m$ "
RUN echo "export PS1=\"\e[1;33m\u \e[1;34m\\\$PWD \e[0;0m$ \"" | sudo tee -a /etc/environment
RUN echo "export PS1=\"\e[1;33m\u \e[1;34m\\\$PWD \e[0;0m$ \"" | tee -a /home/opendocs/.bashrc

# Clone
RUN cd /home/opendocs && \
    git clone -n https://github.com/opendocs-editor/server.git opendocs && \
    cd opendocs && \
    git reset --hard 51f4fcf2880a0ce43938f5b6263da5c8eebb5e42

# Workdir
WORKDIR /home/opendocs/opendocs

# Install packages
RUN yarn install

# Start command
RUN echo "#!/bin/bash" > /home/opendocs/run.sh && \
    echo "/usr/bin/mongod --config /etc/mongod.conf &" >> /home/opendocs/run.sh && \
    echo "cd /home/opendocs/opendocs" >> /home/opendocs/run.sh && \
    echo "/usr/bin/yarn test" >> /home/opendocs/run.sh

# Start
CMD [ "bash", "/home/opendocs/run.sh" ]