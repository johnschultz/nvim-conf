-- Amazon tooling only exists where the builder toolbox is installed.
local amazon = vim.fn.isdirectory(vim.fn.expand("~/.toolbox")) == 1

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        lua_ls = {
          settings = {
            Lua = {
              completion = { callSnippet = "Replace" },
              diagnostics = { disable = { "missing-fields" } },
            },
          },
        },
        -- Barium: LSP for Brazil Config files. Not in lspconfig, so the full config lives here.
        barium = amazon and {
          mason = false,
          cmd = { "barium" },
          filetypes = { "brazil-config" },
          root_markers = { ".git" },
        } or nil,
      },
    },
  },
  -- Filetype detection, syntax, and indent for Brazil Config / packageInfo / version set files
  {
    url = "ssh://git.amazon.com/pkg/VimBrazilConfig",
    name = "VimBrazilConfig",
    branch = "mainline",
    enabled = amazon,
    lazy = false,
    init = function()
      -- Detect via vim.filetype so the filetype is set before LSP setup runs; the plugin's own
      -- vimscript ftdetect fires too late for vim.lsp.enable to see the buffer on first open.
      vim.filetype.add({
        filename = {
          Config = "brazil-config",
          packageInfo = "brazil-config",
        },
      })
    end,
  },
}
