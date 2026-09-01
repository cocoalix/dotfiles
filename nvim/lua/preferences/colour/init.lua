-- ---------------------------------------------------------------------------
--  COLORSCHEME PREFERENCE
--  cterm colors => https://www.ditig.com/publications/256-colors-cheat-sheet
-- ---------------------------------------------------------------------------

--- @module colour
local _c = require("utils.colour")
local _io = require("utils.io")
local _try_catch = require("utils.try_catch")
local _env = require("utils.env")

local _COLOUR = require("const.colour")
local _COLOUR_AZURE = require("const.colour.azure")
local theme = _COLOUR.get_mytheme_color_table(_COLOUR_AZURE)

local notify = require("preferences.colour.sub.notify")

local background_transparent   = { bg = "None" }

local M = {}

---
--- ターミナル用の自分の好きな色の組み合わせを取得する
--- @return table
---
local function get_flavour_colour_for_terminal()
  return {
    _c.get_hl_table("Normal", background_transparent)
  , _c.get_hl_table("NonText", background_transparent)
  }
end

---
--- 共通の自分の好きな色の組み合わせを取得する
--- @return table
---
local function get_common_flavour_colour_override()
  return {
    _c.get_hl_table("LineNr", background_transparent)
  , _c.get_hl_table("CursorLineNr", theme.sub.g)
  , _c.get_hl_table("WinBar", background_transparent)
  , _c.get_hl_table("WinBarNC", background_transparent)

  ,

    _c.get_hl_table("RegistersWindow", theme.primary.g)
  , _c.get_hl_table("Pmenu", theme.primary.g)
  , _c.get_hl_table("PmenuSel", theme.accent_bg.g)
  , _c.get_hl_table("PmenuSbar", background_transparent)
  , _c.get_hl_table("PmenuThumb", theme.accent_bg.g)

  , _c.get_hl_table("NormalFloat", theme.primary.g)
  , _c.get_hl_table("FloatBorder", theme.primary.g)

  , _c.get_hl_table("FloatShadow", background_transparent)
  , _c.get_hl_table("FloatShadowThrough", background_transparent)
  }
end

M.get_my_colorscheme = function()
  _io.begin_debug("colour.get_my_colorscheme")
  local my_colorscheme = {}

  -- LineNumber
  table.insert(my_colorscheme, _c.get_hl_table("CursorLineNr", theme.sub.g))

  -- TransparentBG
  -- get my flavour colour for generally(commonly)
  -- 自分専用の好きな色の組み合わせを取得して上書きする
  local flavour_colour = get_common_flavour_colour_override()
  my_colorscheme = vim.tbl_deep_extend("force", my_colorscheme, flavour_colour)

  if not _env.is_neovide() then
    -- get additional flavour colour for using on terminal
    -- ターミナルの場合はさらに追加の組み合わせを取得して上書きする
    local on_terminal = get_flavour_colour_for_terminal()
    my_colorscheme = vim.tbl_deep_extend("force", my_colorscheme, on_terminal)
  end


  _io.end_debug("colour.get_my_colorscheme")
  return my_colorscheme
end


M.setup = function()
  _io.begin_debug("colour.setup")

  local colorscheme = "onehalfdark"

  _try_catch({
    try = function()
      vim.cmd("colorscheme " .. colorscheme)
    end,
    catch = function()
      --vim.cmd("colorscheme " .. "primary")
    end,
    finally = function()
      -- background color
      vim.opt.background = "dark"
    end,
  })

  --  hl cursor line
  vim.opt.cursorline = true

  --  define colorscheme load function for lazyload
  local my_colorscheme = M.get_my_colorscheme()
  local myhl_augroup_id = vim.api.nvim_create_augroup("Myhl", { clear = true })
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = myhl_augroup_id,
    callback = function() _c.set_highlight_by_table(my_colorscheme) end,
  })

  vim.api.nvim_create_autocmd("BufWinEnter", {
    group = myhl_augroup_id,
    callback = function(args)
      -- Get buftype for the buffer that triggered the event
      local filetype = vim.bo[args.buf].filetype
      local buftype = vim.bo[args.buf].buftype

      -- ファイルタイプとバッファタイプに応じてborderの背景色を変更する
      --    filetype: neo-tree (for neo-tree)
      if filetype == "neo-tree" then
        _c.set_highlight_by_table({
          _c.get_hl_table("NormalFloat", background_transparent),
        })
      --    buftype: prompt (for nui.input (e.g. neo-tree-popup))
      elseif buftype == "prompt" then
        _c.set_highlight_by_table({
          _c.get_hl_table("NormalFloat", background_transparent),
        })
      elseif buftype == "terminal" then
        if filetype == "snacks_terminal" then
          _c.set_highlight_by_table({
            _c.get_hl_table("Normal", background_transparent),
            _c.get_hl_table("NormalFloat", background_transparent),
          })
        end
      --    buftype: nofile
      elseif buftype == "nofile" then
        _c.set_highlight_by_table({
          _c.get_hl_table("NormalFloat", background_transparent),
        })
      else
        _c.set_highlight_by_table({
          _c.get_hl_table("NormalFloat", theme.primary.g),
        })
      end
    end,
  })
  vim.api.nvim_create_autocmd("FileType", {
    pattern = {
      "neo-tree",
    },
    callback = function()
      _c.set_highlight_by_table({
        _c.get_hl_table("NormalFloat", theme.primary.g)
      })
    end
  })

  _io.debug_echo("=== begin: default load ===")
  _c.set_highlight_by_table(my_colorscheme)
  _io.debug_echo("=== end: default load ===")

  --  modify color by colorscheme
  if colorscheme == "onehalfdark" then
    _io.debug_echo("overwrite terminal color")
  vim.g.terminal_color_0 = "#5A6A7C"
  vim.g.terminal_color_8 = "#8097B0"
  end

  notify.setup(my_colorscheme)

  _io.end_debug("colour.setup")
end

return M
