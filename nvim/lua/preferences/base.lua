-- ---------------------------------------------------------------------------
--  BASE PREFERENCES
-- ---------------------------------------------------------------------------

local M = {}

local utils = require("utils")
local colour_util = require("utils.colour")

local g = vim.g
local o = vim.o
local fn = vim.fn
local opt = vim.opt
local api = vim.api
local keymap = vim.keymap

--
-- CONFIG: VIM
--
local function config_vim()
  --  define default file encoding and fileformat
  opt.encoding = "utf-8"
  opt.fileencoding = "utf-8"
  opt.ff = "unix"

  -- vim compatible
  opt.compatible = false

  opt.ignorecase = true
  -- vim language menu
  --  opt.langmenu = 'en_US'
end

--
-- CONFIG: DRAW
--
local function config_draw()
  opt.title = true
  opt.ruler = true
  opt.showcmd = true
  --  opt.wrap = false
  --
  -- キーボード再描画を遅らせる
  opt.lazyredraw = false
  --  opt.lazyredraw = true

  --  opt.completeopt = 'menuone,noinsert'
  opt.scrolloff = 5
  --  opt.inccommand = 'split'
  opt.cursorline = true

  --  use gui color preference on terminal
  vim.opt.termguicolors = true
  vim.o.termguicolors = true

  ---- alphablending (reference by telescope.nvim)
  ---- DEPRECATED: これをONにすると `nvim-notify` の背景透過が消える
  --vim.opt.winblend = colour_util.get_pumblend()
  --vim.o.winblend = colour_util.get_pumblend()

  --  show whitespace characters
  opt.list = true
  opt.listchars = {
    tab = "»-",
    trail = "-",
    eol = "↲",
    --extend = "»",
    --precede = "«",
    nbsp = "%",
  }

  --  Windows でもパスの区切り文字を / にする
  --  2023-12-22: 一時的に `shellslash` をオフにする 👉 telescope.nvim がいまいち対応していないため
  --opt.shellslash = true
  --opt.shellslash = false

  -- +++++++++++++++
  -- " display - line number

  --  display line number
  opt.number = true
  opt.signcolumn = "yes"

  --  display linespace(lineheight)
  opt.linespace = 2

  g.float_window_row = 10
  g.float_window_width = 30

  utils.window.resize_float_window_default()

  api.nvim_create_autocmd("VimResized", { callback = utils.window.resize_float_window_default })
  api.nvim_create_user_command("ResizeFloatWindow", utils.window.resize_float_window_default, {})
end

--
-- CONFIG: PATH
--
local function config_path()
  --  UndoFiles
  local home_tmp_dir = fn.expand("~/.cache/vim_tmp")
  local undofiles = fn.expand(home_tmp_dir .. "/undofiles")
  local bkupfiles = fn.expand(home_tmp_dir .. "/backupfiles")

  --  ~/tmp 以降のディレクトリがない場合は新規作成
  if fn.isdirectory(home_tmp_dir) ~= 1 then
    fn.execute("!mkdir -p " .. home_tmp_dir)
    fn.execute("!mkdir " .. undofiles)
    fn.execute("!mkdir " .. bkupfiles)
  end

  opt.undodir = undofiles
  opt.backupdir = bkupfiles

  --  ctags path
  opt.tags = "./tags;~"

  --  autochdir (auto change directory by buffer file path)
  opt.autochdir = true
end

--
-- CONFIG: WINDOW
--
local function config_wnd()
  --opt.wildmenu = true
  opt.wildmenu = false
  --  コマンドライン補完設定
  -- opt.wildmode = "list:full,full"
  opt.hidden = true
  --  編集中ファイルがあっても別画面に切り替え可能に
  vim.cmd("set noequalalways")
end

local function clipboard_config()
  --  use clipboard
  g.nopaste = true
  keymap.set("n", "<S-Insert>", "<C-R>+")
  opt.clipboard = "unnamedplus"

  require("preferences.config.env")
end

--
-- CONFIG: IO
--
local function config_io()
  clipboard_config()

  -- ---------------------------------------------------------------------------
  -- " input (key)

  -- +++++++++++++++
  --  define mapleader character
  --  (`mapleader` is preference of combination prefix character
  g.mapleader = ","

  -- +++++++++++++++
  --  tab and tabstop

  --  disable use tabcharacter and define tabstop
  opt.tabstop = 4
  opt.smartindent = true
  opt.autoindent = true
  opt.softtabstop = -1  -- reference shiftwidth
  opt.shiftwidth = 0    -- reference tabstop
  opt.expandtab = true
  opt.backspace = "indent,eol,start"

  vim.api.nvim_create_autocmd("FileType", {
    pattern = "php",
    callback = function()
      vim.opt_local.autoindent = true
      -- PHPではcindentよりindentexprを優先する
      vim.opt_local.cindent = false
      vim.opt_local.indentexpr = "GetPhpIndent()" -- 標準スクリプトを使用
    end,
  })

  --  日本語入力に関する設定:
  if fn.has("multi_byte_ime") or fn.has("xim") then
    -- IME ON時のカーソルの色を設定(設定例:紫)
    vim.cmd("highlight CursorIM guibg=Purple guifg=NONE")
    -- 挿入モード・検索モードでのデフォルトのIME状態設定
    opt.iminsert = 0
    opt.imsearch = 0
    --keymap.set("i", "<ESC>", "<ESC>:set iminsert=0<CR>")
    --if fn.has("xim") and fn.has("GUI_GTK") then
    --  -- XIMの入力開始キーを設定:
    --  -- 下記の s-space はShift+Spaceの意味でkinput2+canna用設定
    --  -- opt.imactivatekey=s-space
    --end
    -- 挿入モードでのIME状態を記憶させない場合、次行のコメントを解除
    -- inoremap <silent> <ESC> <ESC>:opt.iminsert=0<CR>
  end

  -- ---------------------------------------------------------------------------
  -- " input (mouse)
  --
  -- " 解説:
  --  mousefocusは幾つか問題(一例:ウィンドウを分割しているラインにカーソルがあっ
  --  ている時の挙動)があるのでデフォルトでは設定しない。Windowsではmousehide
  --  が、マウスカーソルをVimのタイトルバーに置き日本語を入力するとチラチラする
  --  という問題を引き起す。
  --
  --  どのモードでもマウスを使えるようにする
  opt.mouse = "a"
  --  マウスの移動でフォーカスを自動的に切替えない
  --  (mousefocu切替る/nomousefocu切り替えない)
  g.nomousefocus = true
  --  入力時にマウスポインタを隠す (nomousehide:隠さない)
  opt.mousehide = true
  --  ビジュアル選択(D&D他)を自動的にクリップボードへ (:help guioptions_a)
  -- opt.guioptions+=a
end

--
-- CONFIG: SOUND
--
local function config_sound()
  --  enable mute
  --api.nvim_set_option("t_vb", "")
  api.nvim_set_option("visualbell", true)
  g.visualbell = true
  g.noerrorbells = true
end

--
-- CONFIG: TERMINAL
--
local function config_term()
  if fn.has("win32") and fn.has("wsl") == 0 then
    o.shell = "pwsh"
    opt.shell = "pwsh"
    opt.shellcmdflag = "-c"
    opt.shellquote = '"'
    opt.shellxquote = ""
  end

  api.nvim_create_augroup("Terminal", { clear = true })
  -- auto insert mode
  --  api.nvim_create_autocmd('TermOpen', {
  --    pattern = '*',
  --    callback = function()
  --      -- do something
  --      vim.cmd.startinsert()
  --    end
  --  })
end

M.setup = function()
  config_vim()
  config_draw()
  config_path()
  config_wnd()
  config_io()
  config_sound()
  config_term()
end

return M
