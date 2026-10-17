# dotfiles

macOS の環境を [nix-darwin](https://github.com/nix-darwin/nix-darwin) と [home-manager](https://github.com/nix-community/home-manager) で管理しています。

## install
```sh
cd ~
git clone git@github.com:kobayashiyabako16g/dotfiles.git
cd ~/dotfiles
./install.sh
```

GitHub の access token を Nix に渡す場合は、Git 管理外の `/etc/nix/access-tokens.conf` に書きます。

```sh
echo 'access-tokens = github.com=<token>' | sudo tee /etc/nix/access-tokens.conf
sudo chmod 600 /etc/nix/access-tokens.conf
```

## 構成

| パス | 内容 |
| --- | --- |
| `flake.nix` | エントリポイント (`darwinConfigurations.macbook`) |
| `nix/darwin/` | macOS システム設定・Nix 設定・Homebrew |
| `nix/home/` | home-manager (パッケージ, zsh, git, tmux, ghostty, neovim など) |
| `config/` | Nix 化していない設定。home-manager から `~/.config` に symlink される (編集は即時反映) |
| `claude/` | Claude Code の scripts / skills (`~/.claude` に symlink) |

## 設定の反映

```sh
sudo darwin-rebuild switch --flake ~/dotfiles
```

## アップデート

```sh
nix flake update
sudo darwin-rebuild switch --flake ~/dotfiles
```
