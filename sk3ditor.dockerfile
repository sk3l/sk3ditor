FROM ubuntu:latest

MAINTAINER Admin <admin@skelton.onl>

##
# Parameterize the development account's info
ARG   dev_user=dev123
ARG   dev_groups=adm,sudo
ARG   dev_shell=/bin/bash

##
# Define image packages
ENV   packages="cmake               \
                build-essential     \
                coreutils           \
                git                 \
                golang              \
                npm                 \
                python3             \
                python3-pip         \
                python3-setuptools  \
                shellcheck          \
                sudo                \
                wget"

##
# Install package dependancies
RUN apt-get update && apt-get install -y --force-yes $packages

##
# Configure and install Neovim from nightly app image
ENV   nvim_install_path=/opt/nvim
ENV   nvim_exe_path=$nvim_install_path/squashfs-root/usr/bin/nvim
ENV   nvim_source_url=https://github.com/neovim/neovim/releases/download/nightly/nvim.appimage

RUN mkdir $nvim_install_path                        && \
    cd $nvim_install_path                           && \
    wget -O ./appImage $nvim_source_url             && \
    chmod +x $nvim_install_path/appImage            && \
    $nvim_install_path/appImage --appimage-extract  && \
    ln -s $nvim_exe_path /usr/local/sbin/nvim

##
# Setup the developer account
RUN useradd -G $dev_groups -m -s /bin/bash $dev_user
RUN echo "$dev_user   ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/sudo-$dev_user

USER $dev_user
RUN mkdir /home/$dev_user/code

##
# Install developer's shell resource files
# TODO - make plug-able by `RUN source <some_shell_script>`
ENV shell_rc_url=https://raw.githubusercontent.com/sk3l/sk3lshell/master/dot-files
RUN wget -O $HOME/.bashrc               $shell_rc_url/.bashrc
RUN wget -O $HOME/.bashrc_local_ubuntu  $shell_rc_url/.bashrc_local_ubuntu

RUN echo "export EDITOR=/usr/local/sbin/nvim" >> $HOME/.bashrc

##
# Install Neovim configuration
# TODO - make plug-able by `RUN source <some_shell_script>`
ENV editor_conf_dir=/home/$dev_user/.config/nvim
ENV editor_code_dir=$editor_conf_dir/lua
ENV editor_data_dir=/home/$dev_user/.local/share/nvim

COPY --chown=$dev_user:$dev_user nvim/conf/init.vim     $editor_conf_dir/init.vim
COPY --chown=$dev_user:$dev_user nvim/conf/ale.vim      $editor_conf_dir/ale.vim
COPY --chown=$dev_user:$dev_user nvim/conf/nerdtree.vim $editor_conf_dir/nerdtree.vim
COPY --chown=$dev_user:$dev_user nvim/code/plugins.lua  $editor_code_dir/plugins.lua

##
# Bootstrap Neovim's packages via packer.nvim
RUN nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'

RUN echo "colorscheme duskfox" > $editor_conf_dir/colors.vim

##
# Setup Bash-related development environment
RUN pip3 install --user bashate

##
# Setup Python-related development environment
ENV python_tools="python-lsp-server pylint flake8 jedi mypy black isort"
RUN pip3 install --user $python_tools

##
# Setup Go-related development environment
RUN go install golang.org/x/tools/gopls@latest

##
# Setup node.js version manager (NVM) and related node packages
SHELL ["/bin/bash", "-c"]
RUN wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
RUN source $HOME/.nvm/nvm.sh && nvm install node

##
# Replace regex patterns in any config files, e.g.
#RUN sed -i {s/\$\{db_host\}/$db_host/}          /svc/bitomb/$app_cfg_file

WORKDIR /home/$dev_user

##
# Uncomment below if running something aside from $SHELL
# ENTRYPOINT ["some_script"]

