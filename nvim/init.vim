if &compatible
    set nocompatible
endif

" reset augroup
augroup MyAutoCmd
  autocmd!
augroup END


scriptencoding utf-8
set encoding=utf-8
set fileencoding=utf-8

"---------------------------------------------------------------------------
"" UndoFiles
if has('win32')
	set undodir=$HOME/undofiles
	set backupdir=$HOME/backupfiles
elseif has('unix')
	set undodir=$HOME/tmp/undofiles
	set backupdir=$HOME/tmp/backupfiles
elseif has('mac')
	set undodir=$HOME/tmp/undofiles
	set backupdir=$HOME/tmp/backupfiles
endif


"---------------------------------------------------------------------------
"" Input

"+++++++++++++++
"" tab
set tabstop=4
set smartindent
set shiftwidth=4
set expandtab

"+++++++++++++++
"" tab
set backspace=indent,eol,start

"---------------------------------------------------------------------------
"" mouse
"
"" 解説:
" mousefocusは幾つか問題(一例:ウィンドウを分割しているラインにカーソルがあっ
" ている時の挙動)があるのでデフォルトでは設定しない。Windowsではmousehide
" が、マウスカーソルをVimのタイトルバーに置き日本語を入力するとチラチラする
" という問題を引き起す。
"
" どのモードでもマウスを使えるようにする
set mouse=a
" マウスの移動でフォーカスを自動的に切替えない
" (mousefocus:切替る/nomousefocus:切り替えない)
set nomousefocus
" 入力時にマウスポインタを隠す (nomousehide:隠さない)
set mousehide
" ビジュアル選択(D&D他)を自動的にクリップボードへ (:help guioptions_a)
"set guioptions+=a

"---------------------------------------------------------------------------
" Use Default Shell
if has('win32')
    "set shell=PowerShell
    set shell=bash
elseif has('mac')
    "  set guifont=Osaka－等幅:h14
elseif has('xfontset')
    " UNIX用 (xfontsetを使用)
endif

"+++++++++++++++
" python設定
if has('win32')
  let g:python3_host_prog = 'C:\Users\akakura\AppData\Local\Programs\Python\Python39\python.exe'
elseif has('mac')
  let g:python_host_prog = $PYENV_ROOT.'/versions/neovim2/bin/python'
  let g:python3_host_prog = $PYENV_ROOT.'/versions/neovim3/bin/python'
endif

set number

"+++++++++++++++
" 行番号色変更
autocmd ColorScheme * hi LineNr ctermbg=46 ctermfg=0
autocmd ColorScheme * hi CursorLineNr ctermbg=239 ctermfg=46
set cursorline

"+++++++++++++++
" 空白文字、タブ文字を表示
set list listchars=tab:»-,trail:-,eol:↲,extends:»,precedes:«,nbsp:%

"+++++++++++++++
" ctags検索
set tags=tags;$HOME

" tagsファイルが存在する場所に対してctagsを毎回生成するようにする
function! s:execute_ctags() abort
    " 探すタグファイル名
    let tag_name = 'tags'
    " ディレクトリを遡り、タグファイルを探し、パス取得
    let tags_path = findfile(tag_name, '.;')
    " タグファイルパスが見つからなかった場合
    if tags_path ==# ''
        return
    endif

    " タグファイルのディレクトリパスを取得
    " `:p:h`の部分は、:h filename-modifiersで確認
    let tags_dirpath = fnamemodify(tags_path, ':p:h')
    " 見つかったタグファイルのディレクトリに移動して、ctagsをバックグラウンド実行（エラー出力破棄）
    execute 'silent !cd' tags_dirpath '&& ctags -R -f' tag_name '2> /dev/null &'
endfunction

" 自動実行
augroup ctags
    autocmd!
    autocmd BufWritePost * call s:execute_ctags()
augroup END

"+++++++++++++++
" font:
if has('win32')
    " Windows用
    " Migu 2M こそ至高フォント。
    "
    " https://osdn.jp/projects/mix-mplus-ipa/downloads/63545/migu-2m-20150712.zip/
    "set guifont=Migu\ 2M:h10
    "set guifont=MS_Mincho:h12:cSHIFTJIS
    " 行間隔の設定
    set linespace=1
    " 一部のUCS文字の幅を自動計測して決める
    if has('kaoriya')
        set ambiwidth=auto
    endif
elseif has('mac')
    set guifont=Migu\ 2M:h10
elseif has('xfontset')
    " UNIX用 (xfontsetを使用)
    set guifontset=a14,r14,k14
endif

"---------------------------------------------------------------------------
" 日本語入力に関する設定:
"
if has('multi_byte_ime') || has('xim')
    " IME ON時のカーソルの色を設定(設定例:紫)
    highlight CursorIM guibg=Purple guifg=NONE
    " 挿入モード・検索モードでのデフォルトのIME状態設定
    set iminsert=0 imsearch=0
    if has('xim') && has('GUI_GTK')
        " XIMの入力開始キーを設定:
        " 下記の s-space はShift+Spaceの意味でkinput2+canna用設定
        "set imactivatekey=s-space
    endif
    " 挿入モードでのIME状態を記憶させない場合、次行のコメントを解除
    "inoremap <silent> <ESC> <ESC>:set iminsert=0<CR>
endif

"---------------------------------------------------------------------------
" Window
set wildmenu
" コマンドライン補完設定
set wildmode=list:full,full
set hidden
" 編集中ファイルがあっても別画面に切り替え可能に
set noequalalways

"---------------------------------------------------------------------------
" Mapping
nnoremap ; :

" tag jump
nnoremap <C-J> <C-]>

" must install:
" Shougo/Unite.vim
cnoremap :db Denite buffer
cnoremap ;db Denite buffer

" must install:
" Shougo/Unite.vim
cnoremap :ub Unite buffer
cnoremap ;ub Unite buffer

" must install:
" Shougo/Unite.vim
cnoremap :uf Unite file
cnoremap ;uf Unite file

" must install:
" Shougo/vimfiler.vim
cnoremap :nt NERDTree
cnoremap ;nt NERDTree

" today date and time
nmap <F6> <ESC>i<C-R>=strftime("%Y/%m/%d")<CR><CR>
nmap <F7> <ESC>i<C-R>=strftime("%H:%M")<CR><CR>

" use clipboard ------------------------------------------------------------------
set nopaste
noremap! <S-Insert> <C-R>+
set clipboard=unnamed

" Dein ---------------------------------------------------------------------------
" dein.vimのディレクトリ
let s:dein_dir = expand('~/.cache/dein')
let s:dein_repo_dir = s:dein_dir . '/repos/github.com/Shougo/dein.vim'

let s:initvim_path = fnamemodify(expand('<sfile>'), ':h')

" なければgit clone
if !isdirectory(s:dein_repo_dir)
    execute '!git clone https://github.com/Shougo/dein.vim' s:dein_repo_dir
endif
execute 'set runtimepath+=' . s:dein_repo_dir

if dein#load_state(s:dein_dir)
    call dein#begin(s:dein_dir)

    " 管理するプラグインを記述したファイル
    let s:toml = s:initvim_path . '/dein.toml'
    let s:lazy_toml = s:initvim_path . '/dein_lazy.toml'
    call dein#load_toml(s:toml, {'lazy': 0})
    call dein#load_toml(s:lazy_toml, {'lazy': 1})

    call dein#end()
    call dein#save_state()
endif
" プラグインの追加・削除やtomlファイルの設定を変更した後は
" 適宜 call dein#update や call dein#clear_state を呼んでください。
" そもそもキャッシュしなくて良いならload_state/save_stateを呼ばないようにしてください。

" その他インストールしていないものはこちらに入れる
if dein#check_install()
    call dein#install()
endif

" use colorschema
set termguicolors
colorscheme lucius
LuciusDark

" deoplete
let g:deoplete#enable_at_startup = 1

let s:removed_plugins = dein#check_clean()
if len(s:removed_plugins) > 0
    call map(s:removed_plugins, "delete(v:val, 'rf')")
    call dein#recache_runtimepath()
endif

filetype plugin indent on
syntax enable