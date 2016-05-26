" Vim plugin for Meson build files
" Author: Ivan Gankevich <igankevich@ya.ru>

" A workaround to prevent netrw opening directories under cursor.
nnoremap <buffer> gf :call MesonGoToFile(expand('<cfile>'),'edit')<cr>
nnoremap <buffer> <c-w>f :call MesonGoToFile(expand('<cfile>'),'split')<cr>
nnoremap <buffer> <c-w>gf :call MesonGoToFile(expand('<cfile>'),'tabnew')<cr>
