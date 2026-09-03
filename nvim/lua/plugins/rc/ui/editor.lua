local g = vim.g
local fn = vim.fn
local api = vim.api
local opt = vim.opt
local keymap = vim.keymap

local _COLOUR = require("const.colour")

return {
  --{
  --  -- start page
  --  "goolord/alpha-nvim",
  --  dependencies = { "nvim-tree/nvim-web-devicons" },
  --  config = function()
  --    require("alpha").setup(require("alpha.themes.dashboard").config)
  --  end,
  --},
  {
    -- word highlighting on cursor
    lazy = true,
    "RRethy/vim-illuminate",
    event = { "BufReadPost", "FileReadPost" },
    config = function()
      require("illuminate").configure({
        -- providers: provider used to get references in the buffer, ordered by priority
        providers = {
          "lsp",
          "regex",
        },
        -- delay: delay in milliseconds
        delay = 100,
        -- filetype_overrides: filetype specific overrides.
        -- The keys are strings to represent the filetype while the values are tables that
        -- supports the same keys passed to .configure except for filetypes_denylist and filetypes_allowlist
        filetype_overrides = {},
        -- filetypes_denylist: filetypes to not illuminate, this overrides filetypes_allowlist
        filetypes_denylist = {
          "dirvish",
          "fugitive",
        },
        -- filetypes_allowlist: filetypes to illuminate, this is overriden by filetypes_denylist
        filetypes_allowlist = {},
        -- modes_denylist: modes to not illuminate, this overrides modes_allowlist
        -- See `:help mode()` for possible values
        modes_denylist = {},
        -- modes_allowlist: modes to illuminate, this is overriden by modes_denylist
        -- See `:help mode()` for possible values
        modes_allowlist = {},
        -- providers_regex_syntax_denylist: syntax to not illuminate, this overrides providers_regex_syntax_allowlist
        -- Only applies to the 'regex' provider
        -- Use :echom synIDattr(synIDtrans(synID(line('.'), col('.'), 1)), 'name')
        providers_regex_syntax_denylist = {},
        -- providers_regex_syntax_allowlist: syntax to illuminate, this is overriden by providers_regex_syntax_denylist
        -- Only applies to the 'regex' provider
        -- Use :echom synIDattr(synIDtrans(synID(line('.'), col('.'), 1)), 'name')
        providers_regex_syntax_allowlist = {},
        -- under_cursor: whether or not to illuminate under the cursor
        under_cursor = true,
        -- large_file_cutoff: number of lines at which to use large_file_config
        -- The `under_cursor` option is disabled when this cutoff is hit
        large_file_cutoff = nil,
        -- large_file_config: config to use for large files (based on large_file_cutoff).
        -- Supports the same keys passed to .configure
        -- If nil, vim-illuminate will be disabled for large files.
        large_file_overrides = nil,
        -- min_count_to_highlight: minimum number of matches required to perform highlighting
        min_count_to_highlight = 1,
      })
    end,
  },
  {
    -- html color chart previewer
    lazy = true,
    "norcalli/nvim-colorizer.lua",
    event = { "BufReadPost", "FileReadPost" },
    config = function()
      require("colorizer").setup({
        -- css
        "css", "scss", "sass", "less",
        -- web frontend frameworks
        "html", "typescriptreact", "javascriptreact", "vue", "svelte",
        -- web frontend scripts
        "javascript", "typescript",
        -- vim/neovim preferences
        "lua", "vim", "conf", "toml",
      })
    end,
  },
  {
    -- scroll bar
    lazy = true,
    "petertriho/nvim-scrollbar",
    dependencies = {
      "kevinhwang91/nvim-hlslens",
      "lewis6991/gitsigns.nvim",
    },
    event = {
      "FileReadPost",
    },
    config = function()
      require("gitsigns").setup()
      require("scrollbar.handlers.gitsigns").setup()
      require("scrollbar").setup({
        show = true,
        show_in_active_only = true,
        set_highlights = true,
        folds = 1000, -- handle folds, set to number to disable folds if no. of lines in buffer exceeds this
        max_lines = false, -- disables if no. of lines in buffer exceeds this
        hide_if_all_visible = false, -- Hides everything if all lines are visible
        throttle_ms = 100,
        excluded_buftypes = {
          "terminal",
          "nofile",
        },
        excluded_filetypes = {
          "noice",
          "prompt",
          "TelescopePrompt",
          "NvimTree",
          "toggleterm",
        },
        handle = {
          text = " ",
          color = _COLOUR.azure.g.sub2.bg,
          color_nr = nil, -- cterm
          highlight = "CursorColumn",
          hide_if_all_visible = true, -- Hides handle if all lines are visible
        },
        marks = {
          Cursor = {
            text = "•",
            priority = 0,
            gui = nil,
            color = nil,
            cterm = nil,
            color_nr = nil, -- cterm
            highlight = "Normal",
          },
          Search = {
            text = { "-", "=" },
            priority = 1,
            gui = nil,
            color = nil,
            cterm = nil,
            color_nr = nil, -- cterm
            highlight = "Search",
          },
          Error = {
            text = { "#", "=" },
            priority = 2,
            gui = nil,
            color = nil,
            cterm = nil,
            color_nr = nil, -- cterm
            highlight = "DiagnosticVirtualTextError",
          },
          Warn = {
            text = { "!", "=" },
            priority = 3,
            gui = nil,
            color = nil,
            cterm = nil,
            color_nr = nil, -- cterm
            highlight = "DiagnosticVirtualTextWarn",
          },
          Info = {
            text = { "i", "=" },
            priority = 4,
            gui = nil,
            color = nil,
            cterm = nil,
            color_nr = nil, -- cterm
            highlight = "DiagnosticVirtualTextInfo",
          },
          Hint = {
            text = { "?", "=" },
            priority = 5,
            gui = nil,
            color = nil,
            cterm = nil,
            color_nr = nil, -- cterm
            highlight = "DiagnosticVirtualTextHint",
          },
          Misc = {
            text = { "-", "=" },
            priority = 6,
            gui = nil,
            color = nil,
            cterm = nil,
            color_nr = nil, -- cterm
            highlight = "Normal",
          },
          GitAdd = {
            text = "┆",
            priority = 7,
            gui = nil,
            color = nil,
            cterm = nil,
            color_nr = nil, -- cterm
            highlight = "GitSignsAdd",
          },
          GitChange = {
            text = "┆",
            priority = 7,
            gui = nil,
            color = nil,
            cterm = nil,
            color_nr = nil, -- cterm
            highlight = "GitSignsChange",
          },
          GitDelete = {
            text = "▁",
            priority = 7,
            gui = nil,
            color = nil,
            cterm = nil,
            color_nr = nil, -- cterm
            highlight = "GitSignsDelete",
          },
        },
        autocmd = {
          render = {
            "BufWinEnter",
            "TabEnter",
            "TermEnter",
            "WinEnter",
            "CmdwinLeave",
            "TextChanged",
            "VimResized",
            "WinScrolled",
          },
          clear = {
            "BufWinLeave",
            "TabLeave",
            "TermLeave",
            "WinLeave",
          },
        },
        handlers = {
          cursor = true,
          diagnostic = true,
          gitsigns = true, -- Requires gitsigns
          handle = true,
          search = true, -- Requires hlslens
          ale = false, -- Requires ALE
        },
      })
      require("scrollbar.handlers").register("my_marks", function(bufnr)
        return {
          { line = 0 },
          { line = 1, type = "Warn", text = "x" },
          { line = 2, type = "Error" },
        }
      end)
    end,
  },
  {
    -- show find highlight number
    "kevinhwang91/nvim-hlslens",
    lazy = true,
    event = { "BufReadPost", "FileReadPost" },
    config = function()
      require("hlslens").setup()
      local kopts = { noremap = true, silent = true }

      vim.api.nvim_set_keymap(
        "n",
        "n",
        [[<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>]],
        kopts
      )
      vim.api.nvim_set_keymap(
        "n",
        "N",
        [[<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>]],
        kopts
      )
      vim.api.nvim_set_keymap("n", "*", [[*<Cmd>lua require('hlslens').start()<CR>]], kopts)
      vim.api.nvim_set_keymap("n", "#", [[#<Cmd>lua require('hlslens').start()<CR>]], kopts)
      vim.api.nvim_set_keymap("n", "g*", [[g*<Cmd>lua require('hlslens').start()<CR>]], kopts)
      vim.api.nvim_set_keymap("n", "g#", [[g#<Cmd>lua require('hlslens').start()<CR>]], kopts)

      vim.api.nvim_set_keymap("n", "<Leader>l", "<Cmd>noh<CR>", kopts)
    end,
  },
  {
    lazy = true,
    "unblevable/quick-scope",
    event = { "BufReadPost", "BufAdd", "BufNewFile" },
    keys = { "f", "F", "t", "T" },
  },
  {
    -- scope visible by lines
    "shellRaining/hlchunk.nvim",
    event = { "UIEnter" },
    config = function()
      require("hlchunk").setup({
        indent = {
          chars = { "│", "¦", "┆", "┊" }, -- more code can be found in https://unicodeplus.com/
          style = {
            "#8B00FF",
          },
        },
        blank = {
          enable = false,
        },
      })
    end,
  },
  {
    -- cursor jump shortcut
    lazy = true,
    "skanehira/jumpcursor.vim",
    event = { "FileReadPost", "BufRead" },
    keys = {
      { "<leader>j", "<Plug>(jumpcursor-jump)", mode = "n" },
    },
  },
  {
    lazy = true,
    "yutkat/wb-only-current-line.nvim",
    event = {
      "VeryLazy",
      "FileReadPost",
      "InsertEnter",
    },
  },
  {
    lazy = true,
    "kwkarlwang/bufresize.nvim",
    event = {
      "VeryLazy",
      "FileReadPost",
      "InsertEnter",
    },
    config = function()
      local bufresize = require("bufresize")
      bufresize.setup()
    end,
  },
  {
    lazy = true,
    "Rasukarusan/nvim-popup-message",
    -- event = { 'VimEnter' },
    cmd = { "PopMess" },
    config = function()
      local function pop_mess(opts)
        vim.fn["popup_message#open"]("execute('messages')")
      end
      vim.api.nvim_create_user_command("PopMess", pop_mess, {})
    end,
  },
}
