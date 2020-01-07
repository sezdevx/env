autocmd FileType javascript :iabbrev <buffer> iff if ()<left>
autocmd FileType html :iabbrev <buffer> bqc <blockquote><CR></blockquote><CR><UP><UP><TAB>
"iabbrev wiht with
augroup python
   autocmd!
   autocmd FileType python let python_highlight_all=1
   autocmd FileType python nnoremap <buffer> <leader>rp :w<cr>:!python3 %<cr>

   " abbreviations for python
   autocmd FileType python :iabbrev <buffer> iff if :<left>
augroup END
"map <leader>rp :w<cr>:!python3 %<cr>



