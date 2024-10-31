# Nix Home Manager

This repo contains a configuration to replicate my computer installation using nix package manager. 

I'm still a rookie on unsing nix and this repo is mostly for learning how to do it, but I have to admit: the journey it is really fun. 

## Requirements
To use the repo on a MBP it is necessary to:
- (install nix)[https://nix.dev/manual/nix/2.18/installation/installing-binary#multi-user-installation]
- (install the module nix-darwin)[https://github.com/LnL7/nix-darwin]
- (install the module of home-manager)[https://nix-community.github.io/home-manager/index.xhtml#sec-install-nix-darwin-module]

## Links
- ()[https://davi.sh/til/nix/nix-macos-setup/]
- ()[https://nix-community.github.io/home-manager/options.xhtml]

# Notes
- nix run nix-darwin --extra-experimental-features nix-command --extra-experimental-features flakes -- switch --flake ~/.config/nix
