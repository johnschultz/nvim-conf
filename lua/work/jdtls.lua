-- File that identifies a brazil workplace (like looking for ".git/" when searching for the root of a git repo).
local PACKAGE_ROOT_FILE = "packageInfo"

local function get_workspace_folders_from_bemol(root_dir)
  local ws_root_folders = root_dir .. "/.bemol/ws_root_folders"
  if vim.fn.glob(ws_root_folders) ~= "" then
    local workspace_folders = {}
    for line in io.lines(ws_root_folders) do
      table.insert(workspace_folders, "file://" .. line)
    end
    return workspace_folders
  else
    print("WARNING: Bemol file is missing")
    return nil
  end
end

return {
  {
    "mfussenegger/nvim-jdtls",
    opts = function(_, lazyvim_opts)
      -- Use workplace as root rather than package (i.e. "~/workplace/XX/" rather than "~/workplace/XX/src/YY/")
      lazyvim_opts.root_dir = function(fname)
        return require("jdtls.setup").find_root({ PACKAGE_ROOT_FILE }, fname)
      end

      -- Add Lombok support
      vim.list_extend(lazyvim_opts.cmd, {
        "--jvm-arg=-javaagent:" .. require("mason-registry").get_package("jdtls"):get_install_path() .. "/lombok.jar",
      })

      -- TODO: Figure out a way to have this run on LspAttach so it doesn't "lock" onto the first project opened
      lazyvim_opts.jdtls = {
        init_options = {
          workspaceFolders = get_workspace_folders_from_bemol(lazyvim_opts.root_dir()),
          -- ["settings.java.configuration.runtimes"] = {
          --   -- Our Java version is still 1.8 :')
          --   { name = "JavaSE-1.8", path = "/usr/lib/jvm/java-1.8.0/", default = true },
          -- },
        },
      }
    end,
  },
}
