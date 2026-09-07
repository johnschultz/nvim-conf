-- The scala extra also attaches metals to Java buffers; jdtls owns Java here.
return {
  {
    "scalameta/nvim-metals",
    ft = { "scala", "sbt" },
  },
}
