# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A personal [LazyVim](https://lazyvim.github.io) config for Neovim, with Amazon-specific tooling layered on
(Brazil `Config` files, Bemol-generated Java workspaces, internal git plugins). There is no build or test suite.
Verification is done by launching Neovim, headless or interactive.

## Commands

```bash
# Format Lua (2-space, 120 col, per stylua.toml). stylua is installed by mason, not on PATH.
~/.local/share/nvim/mason/bin/stylua lua/

# Install/update/clean plugins to match the specs, headless
nvim --headless "+Lazy! sync" +qa

# Health report to a file
nvim --headless "+checkhealth lazy mason vim.lsp nvim-treesitter" "+w! /tmp/health.txt" +qa

# Check which LSP clients attach to a file (replace the path and the wait in ms)
nvim --headless path/to/file "+lua vim.defer_fn(function()
  for _, c in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do print(c.name, c.root_dir) end
  vim.cmd('qa!') end, 5000)"
```

Inside Neovim: `:Lazy` (plugins), `:LazyExtras` (toggle LazyVim extras), `:Mason` (LSP/DAP binaries), `:LspInfo`.

## Load order and where things go

`init.lua` -> `lua/config/lazy.lua`, which bootstraps lazy.nvim with two spec sources:

1. `LazyVim/LazyVim` core plugins plus the extras listed in `lazyvim.json` (`dap.core`, `lang.java`,
   `lang.python`, `lang.scala`, `util.chezmoi`). Manage extras with `:LazyExtras`, not by importing them
   in `lazy.lua`.
2. `{ import = "plugins" }`: every file in `lua/plugins/` is a lazy.nvim spec that overrides or extends the
   extras above.

`lua/config/{options,keymaps,autocmds}.lua` are LazyVim's standard hooks. Options load before lazy.nvim,
keymaps and autocmds on `VeryLazy`.

Custom plugins default to `lazy = false` (set in `lazy.lua`), so add `event`/`ft`/`cmd` if one should lazy-load.
Override LazyVim LSP servers through `nvim-lspconfig` `opts.servers`, as in `lsp.lua`. LazyVim passes each
entry to `vim.lsp.config` and calls `vim.lsp.enable`, so a server that lspconfig does not know about needs
its full `cmd`/`filetypes`/`root_markers` in that table and `mason = false`.

## Amazon-specific pieces

`lua/plugins/lsp.lua` guards all of these with `amazon`, true when `~/.toolbox` exists. Off a work machine
they are skipped so plugin sync does not try to reach `git.amazon.com`.

- **VimBrazilConfig** is pulled over SSH from `git.amazon.com/pkg/VimBrazilConfig` and provides the
  `brazil-config` filetype, syntax, and indent. The spec also registers `Config` and `packageInfo` with
  `vim.filetype.add`. That is not redundant: the plugin's vimscript ftdetect runs after LazyVim's LSP setup
  on first open, so without the early registration barium never sees the buffer.
- **barium** is the Brazil Config LSP, defined inline in `opts.servers.barium`. The binary lives in
  `~/.toolbox/bin`.
- **Java** uses the `lang.java` extra (nvim-jdtls, mason jdtls, Lombok, DAP, test runner).
  `lua/plugins/java.lua` overrides it for Brazil workspaces: `root_dir` prefers the nearest `.bemol`
  directory, which is the workspace root, not the package. `on_attach` reads `.bemol/ws_root_folders` and
  adds each line as an LSP workspace folder. Workspace data ends up in `~/.cache/nvim/jdtls/<workspace>/`.
  Bemol must have been run in the workspace first; otherwise jdtls falls back to lspconfig's root markers
  and roots at the package.
- **Scala** uses the `lang.scala` extra. `lua/plugins/scala.lua` narrows metals to `scala`/`sbt` because
  the extra also attaches it to Java, where jdtls is the owner.
- **chezmoi** comes from the `util.chezmoi` extra (`<leader>sz` picker). `lua/plugins/chezmoi.lua` only
  disables treesitter highlighting for `chezmoitmpl` so the plugin's regex syntax handles templates.

## Git

Commits on this repo use the personal GitHub identity and are SSH-signed via 1Password. That is set in this
repo's `.git/config` because the chezmoi-managed gitconfig with the `includeIf` rules for `personalgithub`
remotes is not applied on every machine. Commit `lazy-lock.json` with plugin updates so versions are
reproducible across machines.
