-- chezmoi.vim / chezmoi.nvim and the <leader>sz picker come from the util.chezmoi extra.
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      -- chezmoi.vim's regex syntax handles template files; treesitter would highlight the wrong language
      highlight = { disable = { "chezmoitmpl" } },
    },
  },
}
