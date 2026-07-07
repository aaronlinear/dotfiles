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
-- Clear search highlight and close floating windows (e.g. the <leader>e diagnostic float) on <Esc>
vim.keymap.set("n", "<Esc>", function()
  vim.cmd("nohlsearch")
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_config(win).relative ~= "" then
      pcall(vim.api.nvim_win_close, win, false)
    end
  end
end, { silent = true, desc = "Clear highlight & close floating windows" })
-- Move between windows with Ctrl-h/j/k/l
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })
-- Jump to start/end of line with H/L
vim.keymap.set({ "n", "v" }, "H", "^", { desc = "Start of line (first non-blank)" })
vim.keymap.set({ "n", "v" }, "L", "$", { desc = "End of line" })
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.clipboard = "unnamedplus"
-- Keep 10 lines of context above/below the cursor so the view scrolls before
-- the cursor reaches the very edge of the window
vim.opt.scrolloff = 10

-- Auto-reload files changed outside of nvim; :checktime re-reads on focus/enter
-- if the buffer is unmodified. <leader>l force-reloads (discards local edits),
-- since plain :e refuses when there are unsaved changes.
vim.opt.autoread = true
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
  callback = function()
    if vim.fn.mode() == "n" then
      vim.cmd("checktime")
    end
  end,
})
vim.keymap.set("n", "<leader>l", "<cmd>edit!<CR>", { desc = "Reload buffer from disk" })

-- Copy the current buffer's path to the system clipboard. `modifier` is a
-- filename-modifier passed to expand() (":p" absolute, ":." relative, ":t" name)
local function copy_path(modifier)
  local path = vim.fn.expand("%" .. modifier)
  if path == "" then
    vim.notify("No file in current buffer", vim.log.levels.WARN)
    return
  end
  vim.fn.setreg("+", path)
  vim.notify("Copied: " .. path)
end
vim.keymap.set("n", "<leader>ya", function() copy_path(":p") end, { desc = "Copy absolute file path" })
vim.keymap.set("n", "<leader>yr", function() copy_path(":.") end, { desc = "Copy relative file path" })
vim.keymap.set("n", "<leader>yn", function() copy_path(":t") end, { desc = "Copy file name" })

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
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        on_attach = function(bufnr)
          local gs = require("gitsigns")
          local function map(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
          end

          -- Navigate hunks (respects diff mode). Uses ]h/[h to avoid clashing
          -- with treesitter's ]c/[c class-motion mappings.
          map("n", "]h", function()
            if vim.wo.diff then
              vim.cmd.normal({ "]c", bang = true })
            else
              gs.nav_hunk("next")
            end
          end, "Next git hunk")
          map("n", "[h", function()
            if vim.wo.diff then
              vim.cmd.normal({ "[c", bang = true })
            else
              gs.nav_hunk("prev")
            end
          end, "Previous git hunk")

          -- Hunk actions
          map("n", "<leader>gs", gs.stage_hunk, "Stage hunk")
          map("v", "<leader>gs", function()
            gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
          end, "Stage hunk")
          map("n", "<leader>gr", gs.reset_hunk, "Reset hunk")
          map("v", "<leader>gr", function()
            gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
          end, "Reset hunk")
          map("n", "<leader>gu", gs.undo_stage_hunk, "Undo stage hunk")
          map("n", "<leader>gp", gs.preview_hunk, "Preview hunk")
          map("n", "<leader>gb", function()
            gs.blame_line({ full = true })
          end, "Blame line")
          map("n", "<leader>gB", gs.toggle_current_line_blame, "Toggle inline blame")
        end,
      })
    end,
  },
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      -- Compiled C fuzzy sorter. Replaces telescope's in-process Lua matcher,
      -- which on huge repos (universe) is slow enough that the results list can
      -- fail to redraw on each keystroke until some event (e.g. arrow press)
      -- nudges it. `cond` guards machines without a compiler: fzf-native is
      -- skipped there and telescope falls back to the Lua sorter.
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        cond = function()
          return vim.fn.executable("make") == 1
        end,
      },
    },
    config = function()
      require("telescope").setup({
        defaults = {
          dynamic_preview_title = true,
          -- Show filename before its (dimmed) directory — far more legible than
          -- deep leading paths in a large monorepo.
          path_display = { "filename_first" },
          -- Use ripgrep to enumerate files (fast on huge monorepos, respects
          -- .gitignore). rg is already required for live_grep, so no extra
          -- system dependency — keeps this config portable across machines.
          find_command = { "rg", "--files", "--hidden", "--glob", "!.git/" },
          -- Prune generated/vendored dirs that otherwise flood results in
          -- large repos (e.g. universe's Bazel output).
          file_ignore_patterns = {
            "^bazel%-",
            "/bazel%-",
            "node_modules/",
            "/target/",
            "%.git/",
          },
        },
      })

      -- Activate fzf-native when it built (see cond guard above). pcall keeps
      -- startup clean on machines where the extension was skipped.
      pcall(require("telescope").load_extension, "fzf")

      local builtin = require("telescope.builtin")

      vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "Find files" })
      vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "Live grep" })
      vim.keymap.set("n", "<leader>sb", builtin.buffers, { desc = "Find buffers" })
      vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "Find help" })
      vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "Find keymaps" })
      vim.keymap.set("n", "<leader>w", builtin.grep_string, { desc = "Search word under cursor" })
    end,
  },
  {
    -- Surfaces LSP progress ($/progress) as a subtle spinner/toast. Gives
    -- feedback during slow requests — e.g. lsp_references or rust-analyzer's
    -- initial indexing in universe — that otherwise look like a hung editor.
    "j-hui/fidget.nvim",
    config = true,
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
      lspconfig.clangd.setup({})

      -- rust-analyzer can be launched from two places:
      --   * Mason's binary   — one generic prebuilt copy Mason downloads.
      --   * rustup's proxy    — ~/.cargo/bin/rust-analyzer, a forwarder that
      --     detects the toolchain the current project pins (rust-toolchain.toml)
      --     and dispatches to THAT toolchain's rust-analyzer.
      -- Prefer the proxy when rustup is present: matching the project's pinned
      -- toolchain avoids mismatches that break e.g. proc-macro/build-script
      -- expansion. Fall back to Mason's binary (kept in ensure_installed above)
      -- on machines without rustup — hence the executable() guard.
      -- Caveat: the guard only checks the proxy file exists, not that the
      -- toolchain has the rust-analyzer component. If rustup is present but the
      -- component is missing, the proxy is still chosen and errors at launch;
      -- run `rustup component add rust-analyzer` there if that happens.
      local rustup_ra = vim.fn.expand("~/.cargo/bin/rust-analyzer")
      local ra_opts = {}
      if vim.fn.executable(rustup_ra) == 1 then
        ra_opts.cmd = { rustup_ra }
      end
      lspconfig.rust_analyzer.setup(ra_opts)

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
          vim.keymap.set("n", "<leader>t", tb.lsp_type_definitions, vim.tbl_extend("force", opts, { desc = "Go to type definition" }))
          vim.keymap.set("n", "<leader>cr", vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "Rename symbol" }))
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "Code action" }))
          vim.keymap.set("n", "<leader>h", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "Hover docs" }))
          vim.keymap.set("n", "<leader>sd", tb.lsp_document_symbols, vim.tbl_extend("force", opts, { desc = "Document symbols" }))
          vim.keymap.set("n", "<leader>sw", tb.lsp_dynamic_workspace_symbols, vim.tbl_extend("force", opts, { desc = "Workspace symbols" }))
        end,
      })
    end,
  },
})
