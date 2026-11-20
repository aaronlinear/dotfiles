local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", "https://github.com/folke/lazy.nvim.git", lazypath })
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.clipboard = "unnamedplus"
vim.opt.termguicolors = false
vim.opt.scrolloff = 10
vim.opt.autoread = true

vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })
vim.keymap.set("n", "<Esc>", function()
  vim.cmd("nohlsearch")
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_config(win).relative ~= "" then
      pcall(vim.api.nvim_win_close, win, false)
    end
  end
end, { silent = true, desc = "Clear highlight & close floating windows" })
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })
vim.keymap.set({ "n", "v" }, "H", "^", { desc = "Start of line (first non-blank)" })
vim.keymap.set({ "n", "v" }, "L", "$", { desc = "End of line" })
vim.keymap.set("n", "<leader>l", "<cmd>edit!<CR>", { desc = "Reload buffer from disk" })
vim.keymap.set("n", "<leader>se", "<cmd>Explore<CR>", { desc = "Open file explorer (netrw)" })

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

vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
  callback = function()
    if vim.fn.mode() == "n" then
      vim.cmd("checktime")
    end
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  callback = function(args)
    pcall(vim.treesitter.start, args.buf)
  end,
})

require("lazy").setup({
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").install({ "lua", "python", "bash", "markdown", "cpp", "rust" })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("nvim-treesitter-textobjects").setup({
        select = { lookahead = true, include_surrounding_whitespace = true },
        move = { set_jumps = true },
      })

      local select = require("nvim-treesitter-textobjects.select")
      local function sel(lhs, query, desc)
        vim.keymap.set({ "x", "o" }, lhs, function()
          select.select_textobject(query, "textobjects")
        end, { desc = desc })
      end
      sel("af", "@function.outer", "Around function")
      sel("if", "@function.inner", "Inside function")
      sel("ac", "@class.outer", "Around class")
      sel("ic", "@class.inner", "Inside class")

      local move = require("nvim-treesitter-textobjects.move")
      local function mv(lhs, fn, query, desc)
        vim.keymap.set({ "n", "x", "o" }, lhs, function()
          move[fn](query, "textobjects")
        end, { desc = desc })
      end
      mv("]f", "goto_next_start", "@function.outer", "Next function start")
      mv("[f", "goto_previous_start", "@function.outer", "Previous function start")
      mv("]c", "goto_next_start", "@class.outer", "Next class start")
      mv("[c", "goto_previous_start", "@class.outer", "Previous class start")
    end,
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
          local function nav_hunk(direction, diff_key)
            return function()
              if vim.wo.diff then
                vim.cmd.normal({ diff_key, bang = true })
              else
                gs.nav_hunk(direction)
              end
            end
          end

          local function set_base(rev)
            gs.change_base(rev, true, vim.schedule_wrap(function()
              vim.notify("Diff base: " .. (rev or "index"))
            end))
          end

          map("n", "]h", nav_hunk("next", "]c"), "Next git hunk")
          map("n", "[h", nav_hunk("prev", "[c"), "Previous git hunk")
          map("n", "<leader>gs", gs.stage_hunk, "Stage hunk")
          map("v", "<leader>gs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Stage hunk")
          map("n", "<leader>gr", gs.reset_hunk, "Reset hunk")
          map("v", "<leader>gr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Reset hunk")
          map("n", "<leader>gu", gs.undo_stage_hunk, "Undo stage hunk")
          map("n", "<leader>gp", gs.preview_hunk, "Preview hunk")
          map("n", "<leader>gb", function() gs.blame_line({ full = true }) end, "Blame line")
          map("n", "<leader>gB", gs.toggle_current_line_blame, "Toggle inline blame")
          map("n", "<leader>gc", function()
            local actions = require("telescope.actions")
            require("telescope.builtin").git_commits({
              prompt_title = "Pick diff base",
              attach_mappings = function(prompt_bufnr)
                actions.select_default:replace(function()
                  local entry = require("telescope.actions.state").get_selected_entry()
                  actions.close(prompt_bufnr)
                  if entry then set_base(entry.value) end
                end)
                return true
              end,
            })
          end, "Pick commit as diff base")
          map("n", "<leader>g0", set_base, "Reset diff base")
          map("n", "<leader>gf", function()
            local base = require("gitsigns.config").config.base or "HEAD"
            local root = vim.b[bufnr].gitsigns_status_dict.root
            require("telescope.builtin").find_files({
              prompt_title = "Files changed since " .. base,
              cwd = root,
              find_command = { "git", "diff", "--name-only", "--diff-filter=d", base },
              previewer = require("telescope.previewers").new_termopen_previewer({
                get_command = function(entry)
                  return { "git", "-C", root, "--no-pager", "diff", base, "--", entry.value }
                end,
              }),
            })
          end, "Files changed since diff base")
        end,
      })
    end,
  },
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        cond = function() return vim.fn.executable("make") == 1 end,
      },
    },
    config = function()
      require("telescope").setup({
        defaults = {
          dynamic_preview_title = true,
          path_display = { "filename_first" },
          find_command = { "rg", "--files", "--hidden", "--glob", "!.git/" },
          file_ignore_patterns = { "^bazel%-", "/bazel%-", "node_modules/", "%.git/" },
        },
      })
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
  { "j-hui/fidget.nvim", config = true },
  { "mason-org/mason.nvim", config = true },
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = { "mason-org/mason.nvim", "neovim/nvim-lspconfig" },
    config = function()
      vim.lsp.config("basedpyright", {
        settings = { basedpyright = { analysis = { typeCheckingMode = "standard" } } },
      })

      local rustup_ra = vim.fn.expand("~/.cargo/bin/rust-analyzer")
      if vim.fn.executable(rustup_ra) == 1 then
        vim.lsp.config("rust_analyzer", { cmd = { rustup_ra } })
      end

      -- Must follow the vim.lsp.config() calls
      require("mason-lspconfig").setup({
        ensure_installed = { "basedpyright", "lua_ls", "rust_analyzer", "clangd" },
      })

      vim.diagnostic.config({ virtual_text = { severity = vim.diagnostic.severity.ERROR } })

      vim.keymap.set("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, { desc = "Previous diagnostic" })
      vim.keymap.set("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, { desc = "Next diagnostic" })
      vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic detail" })
      vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Diagnostics to loclist" })

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local tb = require("telescope.builtin")
          local function map(lhs, rhs, desc)
            vim.keymap.set("n", lhs, rhs, { buffer = args.buf, desc = desc })
          end
          map("<leader>d", tb.lsp_definitions, "Go to definition")
          map("<leader>r", tb.lsp_references, "Go to references")
          map("<leader>i", tb.lsp_implementations, "Go to implementations")
          map("<leader>t", tb.lsp_type_definitions, "Go to type definition")
          map("<leader>cr", vim.lsp.buf.rename, "Rename symbol")
          map("<leader>ca", vim.lsp.buf.code_action, "Code action")
          map("<leader>h", vim.lsp.buf.hover, "Hover docs")
          map("<leader>sd", tb.lsp_document_symbols, "Document symbols")
          map("<leader>sw", tb.lsp_dynamic_workspace_symbols, "Workspace symbols")
        end,
      })
    end,
  },
})
