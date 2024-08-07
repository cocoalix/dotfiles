local utils = require("utils")

local g = vim.g
local o = vim.o
local v = vim.v
local fn = vim.fn
local opt = vim.opt
local api = vim.api
local keymap = vim.keymap

return {
  {
    -- Lazy load firenvim
    -- Explanation: https://github.com/folke/lazy.nvim/discussions/463#discussioncomment-4819297
    lazy = not g.started_by_firenvim,
    "glacambre/firenvim",
    module = false,
    cond = not not vim.g.started_by_firenvim,
    --cond = not not vim.g.started_by_firenvim,
    build = function()
      require("lazy").load({ plugins = "firenvim", wait = true })
      utils.io.echo("shell: " .. o.shell)
      vim.fn["firenvim#install"](0)
    end,
    config = function()
      --if g.started_by_firenvim == true then
      --  o.laststatus = 0
      --else
      --  o.laststatus = 2
      --end
      api.nvim_create_autocmd({ "UIEnter" }, {
        callback = function(event)
          local client = api.nvim_get_chan_info(v.event.chan).client
          if client ~= nil and client.name == "Firenvim" then
            o.laststatus = 0
          end
        end,
      })

      local enableFireNvim = {
        cmdline = "neovim",
        selector = "textarea",
        takeover = "always",
        content = "text",
        priority = 100,
      }

      g.firenvim_config = {
        globalSettings = {
          alt = "all",
        },
        localSettings = {
          [".*"] = {
            selector = "",
            priority = 0,
          },
          ["github\\.com"] = enableFireNvim,
          ["developer\\.mozilla\\.org"] = enableFireNvim,
          ["ap-northeast-1.console.aws.amazon.com"] = enableFireNvim,
        },
      }
    end,
  },
  --{
  --  -- RESTapi testing tool
  --  lazy = true,
  --  'rest-nvim/rest.nvim',
  --  dependencies = {
  --    'nvim-lua/plenary.nvim',
  --    "nvim-neotest/nvim-nio",
  --  },
  --  event = { 'VeryLazy' },
  --  cmd = {
  --    'RestNvim',         -- can be use with <Plug>RestNvim
  --    'RestNvimPreview',  -- can be use with <Plug>RestNvimPreview
  --    'RestNvimLast',
  --    'RestLog',
  --    'RestSelectEnv',
  --  },
  --  config = function()
  --    require("rest-nvim").setup({
  --      -- Open request results in a horizontal split
  --      result_split_horizontal = false,
  --      -- Keep the http file buffer above|left when split horizontal|vertical
  --      result_split_in_place = false,
  --      -- stay in current windows (.http file) or change to results window (default)
  --      stay_in_current_window_after_split = false,
  --      -- Skip SSL verification, useful for unknown certificates
  --      skip_ssl_verification = false,
  --      -- Encode URL before making request
  --      encode_url = true,
  --      -- Highlight request on run
  --      highlight = {
  --        enabled = true,
  --        timeout = 150,
  --      },
  --      result = {
  --        -- toggle showing URL, HTTP info, headers at top the of result window
  --        show_url = true,
  --        -- show the generated curl command in case you want to launch
  --        -- the same request via the terminal (can be verbose)
  --        show_curl_command = false,
  --        show_http_info = true,
  --        show_headers = true,
  --        -- table of curl `--write-out` variables or false if disabled
  --        -- for more granular control see Statistics Spec
  --        show_statistics = false,
  --        -- executables or functions for formatting response body [optional]
  --        -- set them to false if you want to disable them
  --        formatters = {
  --          json = "jq",
  --          html = function(body)
  --            return vim.fn.system({"tidy", "-i", "-q", "-"}, body)
  --          end
  --        },
  --      },
  --      -- Jump to request line on run
  --      jump_to_request = false,
  --      env_file = '.env',
  --      custom_dynamic_variables = {},
  --      yank_dry_run = true,
  --      search_back = true,

  --      -- Tree-Sitter parser
  --      ensure_installed = { "http", "json" },
  --    })
  --  end
  --},
  {
    lazy = true,
    event = { "VeryLazy" },
    "eiji03aero/quick-notes",
    dependencies = {
      'junegunn/fzf',
      'tpope/vim-fugitive',
    },
    cmd = {
      "QuickNotesNew",
      "QuickNotesDiary",
      "QuickNotesNewGitBranch",
      "QuickNotesLsNotes",
      "QuickNotesLsDiary",
      "QuickNotesFzf",
    },
    config = function()
      vim.g.quick_notes_directory = vim.g.my_home_cache_path .. "/quick-notes/"
      vim.g.quick_notes_suffix = 'md'
    end,
  }
}
