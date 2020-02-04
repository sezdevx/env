autocmd FileType javascript :iabbrev <buffer> iff if ()<left>
autocmd FileType html :iabbrev <buffer> bqc <blockquote><CR></blockquote><CR><UP><UP><TAB>
"iabbrev wiht with
augroup python
   autocmd!
   autocmd FileType python let python_highlight_all=1
   autocmd FileType python nnoremap <buffer> <leader>rp :w<cr>:!python3 %<cr>

   autocmd FileType python set textwidth=79

   " abbreviations for python
   autocmd FileType python :iabbrev <buffer> iff if :<left>

   autocmd FileType python vnoremap <buffer> <silent> # :s/^/#/<cr>:noh<cr>
   autocmd FileType python vnoremap <buffer> <silent> -# :s/^#//<cr>:noh<cr>

   autocmd FileType python set tabstop=4 
   autocmd FileType python set softtabstop=4 
   autocmd FileType python set shiftwidth=4
   autocmd FileType python set textwidth=79
   autocmd FileType python set expandtab 
   autocmd FileType python set autoindent
   autocmd FileType python set fileformat=unix

augroup END
"map <leader>rp :w<cr>:!python3 %<cr>



