FROM ubuntu:latest

MAINTAINER Admin <admin@skelton.onl>

##
# Parameterize the development account's info
ARG   dev_user=dev123
ARG   dev_groups=adm,sudo
ARG   dev_shell=/bin/bash

##
# Parameterize the development account's editor
ARG   editor_name=nvim
ARG   editor_path=/usr/local/sbin
ARG   editor_fqn=$editor_path/$editor_name
ARG   editor_url=https://github.com/neovim/neovim/releases/download/nightly/nvim.appimage

##
# Define image packages
ENV   packages="cmake               \
                build-essential     \
                coreutils           \
                fuse                \
                git                 \
                golang              \
                npm                 \
                python3             \
                python3-pip         \
                python3-setuptools  \
                sudo                \
                wget"

##
# Install package dependancies
RUN apt-get update && apt-get install -y --force-yes $packages

##
# Install editor
RUN mkdir -p $editor_path           && \
    wget -O $editor_fqn $editor_url && \
    chmod +x $editor_fqn

##
# Setup the developer account
RUN useradd -G $dev_groups -m -s /bin/bash $dev_user
RUN echo "$dev_user   ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/sudo-$dev_user

USER $dev_user

##
# Install developer's shell resource files
ENV shell_rc_url=https://raw.githubusercontent.com/sk3l/sk3lshell/master/dot-files
RUN wget -O $HOME/.bashrc               $shell_rc_url/.bashrc
RUN wget -O $HOME/.bashrc_local_ubuntu  $shell_rc_url/.bashrc_local_ubuntu

RUN echo "export EDITOR=$editor_fqn" >> $HOME/.bashrc

# Copy over code and install blog app and dependancies.
# COPY code /svc/bitomb/

##
# replace conf server name & port with Docker build arg
#RUN sed -i {s/\$\{db_host\}/$db_host/}          /svc/bitomb/$app_cfg_file

WORKDIR /home/$dev_user
## Uncomment if running something aside from $SHELL
# ENTRYPOINT ["some_script"]

# Open up port for receiving downstream requests from nginx
#EXPOSE $server_port

