{ config, pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    plugins = with pkgs.vimPlugins; [
      # color
      catppuccin-nvim

      # ui
      bufferline-nvim
      nvim-web-devicons
      toggleterm-nvim
      which-key-nvim
      render-markdown-nvim

      # libs
      plenary-nvim
      nui-nvim

      # fzf
      telescope-nvim

      # lsp
      nvim-lspconfig
      lazydev-nvim
      blink-cmp

      # treesitter
      (nvim-treesitter.withPlugins (p: with p; [
        lua
        vim
        vimdoc
        javascript
        typescript
        python
        rust
        go
        gomod
        gowork
        gotmpl
        html
        css
        json
        yaml
        markdown
        markdown_inline
        bash
      ]))
      nvim-treesitter-textobjects
      nvim-treesitter-context

      # コマンド実行時に packadd する (lua/config/lazy.lua)
      { plugin = neo-tree-nvim; optional = true; }
      {
        # checkInputs の blink.cmp v2 は blink.lib 無しで require チェックに失敗するため除外する
        plugin = codecompanion-nvim.overrideAttrs (old: {
          nvimSkipModules = (old.nvimSkipModules or [ ]) ++ [ "codecompanion.providers.completion.blink.setup" ];
        });
        optional = true;
      }
    ];

    extraPackages = with pkgs; [
      gopls
      typescript
      typescript-language-server
      biome
    ];

    initLua = ''
      require("config")
    '';
  };

  # Lua 設定は dotfiles を直接参照し、rebuild なしで編集を反映する
  xdg.configFile."nvim/lua".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/config/nvim/lua";
}
