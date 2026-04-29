return {
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  -- Auto-install Mason packages (LSP servers, formatters, linters) so a
  -- fresh machine just works without remembering to run :MasonInstall.
  -- Server names below are Mason package names (different from lspconfig's
  -- names). Update both this list and configs/lspconfig.lua's `servers`
  -- table when adding a language.
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" },
    event = "VeryLazy",
    config = function()
      require("mason-tool-installer").setup({
        ensure_installed = {
          "pyright",
          "typescript-language-server",
          "lua-language-server",
          "gopls",
          "json-lsp",
          "yaml-language-server",
        },
        auto_update = false,
        run_on_start = true,
      })
    end,
  },

  -- test new blink
  -- { import = "nvchad.blink.lazyspec" },

  -- {
  -- 	"nvim-treesitter/nvim-treesitter",
  -- 	opts = {
  -- 		ensure_installed = {
  -- 			"vim", "lua", "vimdoc",
  --      "html", "css"
  -- 		},
  -- 	},
  -- },

  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles", "DiffviewFileHistory" },
    config = function()
      local actions = require("diffview.actions")
      -- Override <leader>e in every diffview context to toggle the file
      -- panel (collapse/expand) instead of just focusing it. The default
      -- <leader>b still toggles too; <leader>e is the muscle-memory key.
      require("diffview").setup({
        keymaps = {
          view = {
            { "n", "<leader>e", actions.toggle_files, { desc = "Toggle the file panel" } },
          },
          file_panel = {
            { "n", "<leader>e", actions.toggle_files, { desc = "Toggle the file panel" } },
          },
          file_history_panel = {
            { "n", "<leader>e", actions.toggle_files, { desc = "Toggle the file panel" } },
          },
        },
      })
    end,
  },

  -- Pick a Python virtualenv interactively and tell pyright (and other
  -- python LSPs) to use that interpreter. Auto-detects Poetry, uv, venv,
  -- conda, virtualenv, hatch, and pipenv environments.
  --
  -- Keys:
  --   <leader>vs  → open the venv picker
  --   <leader>vc  → see the active venv
  {
    "linux-cultist/venv-selector.nvim",
    branch = "regexp",
    dependencies = {
      "neovim/nvim-lspconfig",
      "nvim-telescope/telescope.nvim",
    },
    cmd = { "VenvSelect", "VenvSelectCached" },
    keys = {
      { "<leader>vs", "<cmd>VenvSelect<cr>", desc = "Select Python venv" },
      { "<leader>vc", "<cmd>VenvSelectCached<cr>", desc = "Active Python venv" },
    },
    opts = {
      settings = {
        options = {
          notify_user_on_venv_activation = true,
        },
      },
    },
  },

  {
    "pwntester/octo.nvim",
    cmd = "Octo",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      enable_builtin = true,
      default_merge_method = "squash",
      picker = "telescope",
    },
  },
}
