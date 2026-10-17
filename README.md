# dotfiles

## Prerequisites

- Xcode Command Line Tools (for `git`)

```sh
xcode-select --install
```

`install.sh` installs Nix and Homebrew if they are missing.

## Setup

```sh
./install.sh
```

To pass a GitHub access token to Nix, write it to `/etc/nix/access-tokens.conf` (outside of Git).

```sh
echo 'access-tokens = github.com=<token>' | sudo tee /etc/nix/access-tokens.conf
sudo chmod 600 /etc/nix/access-tokens.conf
# nix commands read it with user permissions, so make yourself the owner
sudo chown "$USER" /etc/nix/access-tokens.conf
```

## Apply configuration

```sh
sudo darwin-rebuild switch --flake ~/dotfiles
```

## Update

```sh
nix flake update
sudo darwin-rebuild switch --flake ~/dotfiles
```
