#! /bin/bash

# copy vscode settings
mkdir -p $HOME/.config/Code/User
cp vscode/settings.json $HOME/.config/Code/User/settings.json

# copy .zshrc
cp .zshrc $HOME/.zshrc

echo "Changing shell to zsh for ${USER}..."
# Always want to use ZSH as my default shell (e.g. for SSH)
if ! grep -q "${USER}.*/bin/zsh" /etc/passwd
then
  sudo chsh -s /bin/zsh ${USER}
fi

# install nix
curl -L https://nixos.org/nix/install | sh -s -- --no-daemon

source /home/codespace/.nix-profile/etc/profile.d/nix.sh
nix-env -iA nixpkgs.glibcLocales
export LOCALE_ARCHIVE="$(nix-env --installed --no-name --out-path --query glibc-locales)/lib/locale/locale-archive"

if [ -n "$CODESPACES" ]; then
    WORKSPACE="/workspaces/$(echo $GITHUB_REPOSITORY | rev | cut -d/ -f1 | rev)"
    nix-env -if $WORKSPACE/codespace.nix
fi

if ! grep -q "codespace.*/bin/zsh" /etc/passwd; then
  sudo chsh -s /bin/zsh codespace
fi

export BUNDLE_RUBYGEMS__PKG__GITHUB__COM=$GITHUB_TOKEN
