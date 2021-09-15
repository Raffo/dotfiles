#! /bin/bash

mkdir -p $HOME/.config/Code/User
cp vscode/settings.json $HOME/.config/Code/User/settings.json
curl -L https://nixos.org/nix/install | sh -s -- --no-daemon

