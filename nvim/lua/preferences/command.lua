local command = {}

local utils = require('utils')

local opt = vim.opt
local fn = vim.fn
local api = vim.api
local g = vim.g

command.setup = function()
  utils.begin_debug(fn["expand"]('%/h'))

  --  -- +++++++++++++++
  --  --  define command
  --
  --  --  jq command
  --  --  if cannot use
  --  --    windows       : > pwsh -command "Start-Process -verb runas pwsh" "'-command winget install stedolan.jq'"
  --  --    brew on macOS : % brew install jq
  --  --    linux (debian): $ sudo apt -y update
  --  --                    $ sudo apt -y install jq
  --  --    linux (RHEL)  : $ sudo yum -y install epel-release
  --  --                    $ sudo yum -y install jq
  --  fn.command("Jqf", "!j+ '.'")
  --  fn.command("Jq",  "!j+ '%:p'")
  --
  --  --  preference file open mapping
  local ginitvim_filepath = g.my_initvim_path .. '/ginit.lua'
  local initvim_filepath  = g.my_initvim_path .. '/init.lua'

  --  init.vim reload
  local function reload_preference()
    if fn.has("gui_running") then
      fn["execute"]("source " .. ginitvim_filepath)
    end
      fn["execute"]("source " .. initvim_filepath)
  end

  local function reload_all()
    reload_preference()
  end

  api.nvim_create_user_command("ReloadPreference", reload_preference, {})
  api.nvim_create_user_command("Rer", reload_preference, {})
  api.nvim_create_user_command("ReloadAll", reload_all, {})
  api.nvim_create_user_command("Rea", reload_all, {})

  utils.end_debug(fn["expand"]('%/h'))
end

return command

