return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        lua_ls = {
          settings = {
            Lua = {
              completion = {
                callSnippet = "Replace",
              },
              diagnostics = {
                disable = { "missing-fields" },
              },
            },
          },
        },
        -- Barium LSP for Brazil Config files
        barium = {},
      },
      setup = {
        barium = function()
          local lspconfig = require("lspconfig")
          local configs = require("lspconfig.configs")
          if not configs.barium then
            configs.barium = {
              default_config = {
                cmd = { "barium" },
                filetypes = { "brazil-config" },
                root_dir = function(fname)
                  return lspconfig.util.find_git_ancestor(fname)
                end,
                settings = {},
              },
            }
          end
        end,
      },
    },
  },
  -- NinjaHooks for Brazil Config support
  {
    url = "schultjo@git.amazon.com:pkg/NinjaHooks",
    branch = "mainline",
    lazy = false,
    config = function(plugin)
      vim.opt.rtp:prepend(plugin.dir .. "/configuration/vim/amazon/brazil-config")
      vim.filetype.add({
        filename = {
          ["Config"] = function()
            vim.b.brazil_package_Config = 1
            return "brazil-config"
          end,
        },
      })
    end,
  },
}
