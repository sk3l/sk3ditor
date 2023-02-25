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
# TODO - make plug-able by `RUN source <some_shell_script>`
ENV shell_rc_url=https://raw.githubusercontent.com/sk3l/sk3lshell/master/dot-files
RUN wget -O $HOME/.bashrc               $shell_rc_url/.bashrc
RUN wget -O $HOME/.bashrc_local_ubuntu  $shell_rc_url/.bashrc_local_ubuntu

RUN echo "export EDITOR=$editor_fqn" >> $HOME/.bashrc

##
# Install developer's editor conf
# TODO - make plug-able by `RUN source <some_shell_script>`
ENV editor_conf_url=https://raw.githubusercontent.com/sk3l/vim-conf/master/
ENV editor_plugin_url=https://github.com/wbthomason/packer.nvim

ENV editor_conf_dir=/home/$dev_user/.config/nvim
ENV editor_code_dir=/home/$dev_user/.config/nvim/lua
ENV editor_data_dir=/home/$dev_user/.local/share/nvim

RUN mkdir -p $editor_conf_dir
RUN mkdir -p $editor_code_dir
RUN mkdir -p $editor_data_dir

# TODO - shift the editor files out of this repo
COPY nvim_init_vim      /home/$dev_user/.config/nvim/init.vim
COPY nvim_plugins_lua   /home/$dev_user/.config/nvim/lua/plugins.lua

RUN git clone --depth 1 $editor_plugin_url $editor_data_dir/site/pack/packer/start/packer.nvim
RUN wget -O $HOME/.config/nvim/ale      $editor_conf_url/conf/vimrc_ale
RUN wget -O $HOME/.config/nvim/nerdtree $editor_conf_url/conf/vimrc_nerdtree

##
# Replace regex patterns in any config files, e.g.
#RUN sed -i {s/\$\{db_host\}/$db_host/}          /svc/bitomb/$app_cfg_file

WORKDIR /home/$dev_user

##
# Uncomment below if running something aside from $SHELL
# ENTRYPOINT ["some_script"]

