return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      {
        "folke/lazydev.nvim",
        ft = "lua", -- only load on lua files
        opts = {
          library = {
            -- Load luvit types when the `vim.uv` word is found
            { path = "luvit-meta/library", words = { "vim%.uv" } },
          },
        },
      },
      -- optional `vim.uv` typings for lazydev
      { "Bilal2453/luvit-meta", lazy = true },
      "mfussenegger/nvim-jdtls",
      -- Barium LSP for Brzil Config files
      {
        url = "schultjo@git.amazon.com:pkg/NinjaHooks",
        branch = "mainline",
        lazy = false,
        config = function(plugin)
          vim.opt.rtp:prepend(plugin.dir .. "/configuration/vim/amazon/brazil-config")

          -- Use a custom filetype for Brazil Config files
          vim.filetype.add({
            filename = {
              ['Config'] = function()
                vim.b.brazil_package_Config = 1
                return 'brazil-config'
              end,
            },
          })
        end,
      },
    },
    opts = {
      servers = {
        jdtls = {},
        tsserver = {},
        barium = {
        },
        lua_ls = {
          settings = {
            Lua = {
              completion = {
                callSnippet = "Replace",
              },
              diagnostics = {
                disable = {
                  "missing-fields"
                }
              },
            },
          },
        },
      },
      -- you can do any additional lsp server setup here
      -- return true if you don't want this server to be setup with lspconfig
      setup = {
        -- example to setup with typescript.nvim
        -- tsserver = function(_, opts)
        --   require("typescript").setup({ server = opts })
        --   return true
        -- end,

        jdtls = function() return true end,

        -- barium needs to be configured here instead of under 
        -- `servers` because it is a custom server 
        barium = function()
          local lspconfig = require 'lspconfig'
          local configs = require 'lspconfig.configs'
          if not configs.barium then
            configs.barium = {
              default_config = {
                cmd = {'barium'};
                filetypes = {'brazil-config'};
                root_dir = function(fname)
                    return lspconfig.util.find_git_ancestor(fname)
                end;
                settings = {};
              };
            };
          end
        end

        -- Specify * to use this function as a fallback for any server
        -- ["*"] = function(server, opts) end,
      },
    },
  },
  {
    "williamboman/mason.nvim",
    opts = {
      -- ensure the following LSP are installed. stylua and shfmt come by default with LazyVIM
      ensure_installed = {
        "jdtls",
        -- "stylua",
        -- "shfmt",
      },
    },
  }
}
