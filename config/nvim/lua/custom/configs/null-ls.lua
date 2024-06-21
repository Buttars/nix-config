local present, null_ls = pcall(require, "null-ls")

if not present then
  return
end

local b = null_ls.builtins

local sources = {
  b.formatting.prettierd,

  b.code_actions.eslint_d,
  b.formatting.eslint_d,
  b.diagnostics.eslint_d,

  b.diagnostics.cspell.with {
    extra_args = {
      "--config",
      "~/.config/nvim/lua/custom/configs/cspell.json",
    },
  },
  b.code_actions.cspell,

  -- Lua
  b.formatting.stylua,

  -- cpp
  b.formatting.clang_format,

  -- latex
  b.formatting.latexindent
}

null_ls.setup {
  debug = true,
  sources = sources,
}

null_ls.disable "cspell"
