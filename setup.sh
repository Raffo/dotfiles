#! /bin/bash

# copy vscode settings
mkdir -p $HOME/.config/Code/User
cp vscode/settings.json $HOME/.config/Code/User/settings.json

# copy .zshrc
cp .zshrc $HOME/.zshrc

# install nix
curl -L https://nixos.org/nix/install | sh -s -- --no-daemon

source /home/codespace/.nix-profile/etc/profile.d/nix.sh

if [ -f "$CODESPACE_VSCODE_FOLDER/codespace.nix"]; then
    nix-env -if $CODESPACE_VSCODE_FOLDER/codespace.nix
fi

bash keepalive.sh &