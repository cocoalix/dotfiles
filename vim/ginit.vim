" this init.vim is using utf-8
scriptencoding utf-8

call rpcnotify(1, 'Gui', 'Option', 'Tabline', 0)

" Migu 2M
" https://osdn.jp/projects/mix-mplus-ipa/downloads/63545/migu-2m-20150712.zip/
"
" Cica
" https://github.com/miiton/Cica
let s:fav_font_map = #{
      \   Migu2M: 'Migu 2M',
      \   Migu2MPL: 'Migu 2M for Powerline',
      \   Cica: 'Cica',
      \   Hack: 'Hack',
      \ }

let s:fontsize = 13
let s:min_fontsize = 7
function! AdjustFontSize(amount) abort
  let s:fontsize = s:fontsize + a:amount
  execute 'set guifont=' . s:fav_font_map['Cica'] . ':h' . s:fontsize
endfunction

let s:max_columns = 260

function! AutoAdjustFontSize() abort
  let l:diff = s:max_columns - &columns
  let l:unit = l:diff / 27
  " 27ずつ
  let s:fontsize = s:fontsize + l:unit
  if s:fontsize < s:min_fontsize
    s:fontsize = s:min_fontsize
  endif
  execute 'set guifont=' . s:fav_font_map['Cica'] . ':h' . s:fontsize
endfunction


noremap <C-ScrollWheelUp> :call AdjustFontSize(1)<CR>
noremap <C-ScrollWheelDown> :call AdjustFontSize(-1)<CR>
inoremap <C-ScrollWheelUp> <Esc>:call AdjustFontSize(1)<CR>a
inoremap <C-ScrollWheelDown> <Esc>:call AdjustFontSize(-1)<CR>a
