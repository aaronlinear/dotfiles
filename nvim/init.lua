-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)
vim.g.mapleader = " "
-- Stop <Space> from moving the cursor; only act as the leader key
vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })
-- Clear search highlight on <Esc>
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { silent = true })
-- Move between windows with Ctrl-h/j/k/l
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.clipboard = "unnamedplus"

vim.api.nvim_create_autocmd("FileType", {
  callback = function(args)
    pcall(vim.treesitter.start, args.buf)
  end,
})

require("lazy").setup({
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "lua", "python", "bash", "markdown", "cpp", "rust" },
        highlight = { enable = true },
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            include_surrounding_whitespace = true,
            keymaps = {
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
              ["ac"] = "@class.outer",
              ["ic"] = "@class.inner",
            },
          },
          move = {
            enable = true,
            set_jumps = true,
            goto_next_start = {
              ["]f"] = "@function.outer",
              ["]c"] = "@class.outer",
            },
            goto_previous_start = {
              ["[f"] = "@function.outer",
              ["[c"] = "@class.outer",
            },
          },
        },
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "master",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
  },
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").setup({
        defaults = {
          dynamic_preview_title = true,
        },
      })

      local builtin = require("telescope.builtin")

      vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "Find files" })
      vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "Live grep" })
      vim.keymap.set("n", "<leader>sb", builtin.buffers, { desc = "Find buffers" })
      vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "Find help" })
      vim.keymap.set("n", "<leader>w", builtin.grep_string, { desc = "Search word under cursor" })
    end,
  },
  {
    "williamboman/mason.nvim",
    version = "^1.0.0", -- 1.x is the last line supporting nvim 0.10
    config = true,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    version = "^1.0.0", -- pair with mason 1.x; 2.x requires nvim 0.11+
    dependencies = {
      "williamboman/mason.nvim",
      { "neovim/nvim-lspconfig", version = "^1.0.0" }, -- 2.x deprecates nvim 0.10
    },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "basedpyright", "lua_ls", "rust_analyzer", "clangd" },
      })

      local lspconfig = require("lspconfig")
      lspconfig.basedpyright.setup({})
      lspconfig.lua_ls.setup({})
      lspconfig.rust_analyzer.setup({})
      lspconfig.clangd.setup({})

      -- Inline diagnostics (on by default in 0.10, off by default in 0.11+)
      vim.diagnostic.config({ virtual_text = true })

      vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
      vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
      vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic detail" })
      vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Diagnostics to loclist" })

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local tb = require("telescope.builtin")
          local opts = { buffer = args.buf }
          vim.keymap.set("n", "<leader>d", tb.lsp_definitions, vim.tbl_extend("force", opts, { desc = "Go to definition" }))
          vim.keymap.set("n", "<leader>r", tb.lsp_references, vim.tbl_extend("force", opts, { desc = "Go to references" }))
          vim.keymap.set("n", "<leader>i", tb.lsp_implementations, vim.tbl_extend("force", opts, { desc = "Go to implementations" }))
          vim.keymap.set("n", "<leader>gn", vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "Rename symbol" }))
          vim.keymap.set("n", "<leader>gc", vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "Code action" }))
          vim.keymap.set("n", "<leader>h", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "Hover docs" }))
          vim.keymap.set("n", "<leader>sd", tb.lsp_document_symbols, vim.tbl_extend("force", opts, { desc = "Document symbols" }))
          vim.keymap.set("n", "<leader>sw", tb.lsp_dynamic_workspace_symbols, vim.tbl_extend("force", opts, { desc = "Workspace symbols" }))
        end,
      })
    end,
  },
})
