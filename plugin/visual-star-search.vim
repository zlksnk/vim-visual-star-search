" From http://got-ravings.blogspot.com/2008/07/vim-pr0n-visual-search-mappings.html

" makes * and # work on visual mode too.  global function so user mappings can call it.
" specifying 'raw' for the second argument prevents escaping the result for grep
" TODO: there's a bug with raw mode.  since we're using @/ to return an unescaped
" search string, vim's search highlight will be wrong.  Refactor plz.
function! VisualStarSearchSet(cmdtype,...)
  let temp = @"
  normal! gvy
  if !a:0 || a:1 != 'raw'
    let @" = escape(@", a:cmdtype.'\*')
  endif
  let @/ = substitute(@", '\n', '\\n', 'g')
  let @/ = substitute(@/, '\[', '\\[', 'g')
  let @/ = substitute(@/, '\~', '\\~', 'g')
  let @/ = substitute(@/, '\.', '\\.', 'g')
  let @" = temp
endfunction

function! s:correctescape(arg) abort
  let l:res = a:arg
  let l:res = substitute(l:res, '(', '\\\(', 'g')
  let l:res = substitute(l:res, ')', '\\\)', 'g')
  let l:res = substitute(l:res, '[', '\\\[', 'g')
  let l:res = substitute(l:res, ']', '\\\]', 'g')
  let l:res = substitute(l:res, '{', '\\\{', 'g')
  let l:res = substitute(l:res, '}', '\\\}', 'g')
  let l:res = shellescape(l:res)
  return l:res
endfunction


" replace vim's built-in visual * and # behavior
xnoremap * :<C-u>call VisualStarSearchSet('/')<CR>/<C-R>=@/<CR><CR>
xnoremap # :<C-u>call VisualStarSearchSet('?')<CR>?<C-R>=@/<CR><CR>

" recursively grep for word under cursor or selection
if maparg('<leader>*', 'n') == ''
  " there is `<cexpr>` too that will select `console.log` if cursor is on `log` of
  " `console.log("something")` instead of just selecting `log`
  " but a variable could be destructed at some point so it's better to keep `<cword>`
  nnoremap <silent><leader>* :execute 'noautocmd Grep ' . expand("<cword>")<CR>
endif
if maparg('<leader>*', 'v') == ''
  vnoremap <silent><leader>* :<C-u>call VisualStarSearchSet('/', 'raw')<CR>:execute 'noautocmd Grep ' . <sid>correctescape(@/)<CR>
endif

