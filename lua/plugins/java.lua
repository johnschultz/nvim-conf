-- Brazil Java workspaces: root jdtls at the workspace (where Bemol writes .bemol/), not the package,
-- and register every Bemol-generated source root as an LSP workspace folder.
local function bemol_root(path)
  return vim.fs.root(path, { ".bemol" })
end

local function bemol_folders(root)
  local list = root .. "/.bemol/ws_root_folders"
  if vim.fn.filereadable(list) == 0 then
    return {}
  end
  return vim.fn.readfile(list)
end

return {
  {
    "mfussenegger/nvim-jdtls",
    opts = function(_, opts)
      local default_root = opts.root_dir
      opts.root_dir = function(path)
        return bemol_root(path) or default_root(path)
      end

      opts.settings.java = vim.tbl_deep_extend("force", opts.settings.java or {}, {
        references = { includeDecompiledSources = true },
        eclipse = { downloadSources = true },
        maven = { downloadSources = true },
        sources = { organizeImports = { starThreshold = 9999, staticStarThreshold = 9999 } },
      })

      opts.on_attach = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        local root = client and client.root_dir and bemol_root(client.root_dir)
        if not root then
          return
        end
        local known = {}
        for _, wf in ipairs(client.workspace_folders or {}) do
          known[vim.uri_to_fname(wf.uri)] = true
        end
        for _, folder in ipairs(bemol_folders(root)) do
          if not known[folder] then
            vim.lsp.buf.add_workspace_folder(folder)
          end
        end
      end
    end,
  },
}
