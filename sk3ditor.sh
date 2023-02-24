#!/bin/bash

# NOTE:
# We use --privileged along with --device to mount /dev/fuse (required for Neovim.appimage)
# This can be omitted if using a different editor or extracting appImage files
docker run --rm -i --tty --device /dev/fuse --privileged sk3ditor 
