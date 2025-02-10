local work_jdtls_exists, _ = pcall(require, "work.jdtls")
local work_metals_exists, _ = pcall(require, "work.metals")

return {
  { import = "lazyvim.plugins.extras.lang.java" },
  work_jdtls_exists and { import = "work.jdtls" } or nil,
  work_metals_exists and { import = "work.metals" } or nil,
}
