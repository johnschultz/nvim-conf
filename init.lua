-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- barium
local lspconfig = require("lspconfig")
local configs = require("lspconfig.configs")

-- Check if the config is already defined (useful when reloading this file)
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

lspconfig.barium.setup({})

-- -- bemol
-- -- Step 1: Copy the bemol() function.
-- function bemol()
--   local bemol_dir = vim.fs.find({ ".bemol" }, { upward = true, type = "directory" })[1]
--   local ws_folders_lsp = {}
--   if bemol_dir then
--     local file = io.open(bemol_dir .. "/ws_root_folders", "r")
--     if file then
--       for line in file:lines() do
--         table.insert(ws_folders_lsp, line)
--       end
--       file:close()
--     end
--   end
--
--   for _, line in ipairs(ws_folders_lsp) do
--     vim.lsp.buf.add_workspace_folder(line)
--   end
-- end
--
-- -- Step 2: Call bemol() from your on_attach() function.
-- local on_attach = function(_, bufnr)
--   vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = bufnr, desc = "[G]oto [D]efinition" })
--   -- your other keymaps and the rest of your configuration here.
--
--   bemol()
-- end
--
-- -- Step 3: Make sure you pass on_attach to lspconfig.
-- server_name = "jdtls" -- or whatever lsp you're using.
-- lspconfig[server_name].setup({
--   on_attach = on_attach,
-- })
