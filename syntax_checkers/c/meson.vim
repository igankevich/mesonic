" Vim syntastic plugin
" Language:     C
"
" See for details on how to add an external Syntastic checker:
" https://github.com/scrooloose/syntastic/wiki/Syntax-Checker-Guide#external

if exists("g:loaded_syntastic_c_meson_checker")
    finish
endif

let g:loaded_syntastic_c_meson_checker = 1

" Force syntastic to call ninja without a specific file name
let g:syntastic_c_meson_fname = ""

let s:save_cpo = &cpo
set cpo&vim

function! SyntaxCheckers_c_meson_IsAvailable() dict
    return executable(self.getExec()) &&
        \ executable(g:MesonCommand()) &&
        \ filereadable('meson.build') &&
        \ syntastic#util#versionIsAtLeast(self.getVersion(), [0, 16, 0])
endfunction

function! SyntaxCheckers_c_meson_GetLocList() dict
    return SyntasticMake({
        \ 'makeprg': self.makeprgBuild({ 'args': '-C '.g:MesonBuildDir(g:MesonProjectDir()) }),
        \ 'errorformat':
        \     '%-G../%f:%s:,' .
        \     '%-G../%f:%l: %#error: %#(Each undeclared identifier is reported only%.%#,' .
        \     '%-G../%f:%l: %#error: %#for each function it appears%.%#,' .
        \     '%-GIn file included%.%#,' .
        \     '%-G %#from ../%f:%l\,,' .
        \     '../%f:%l:%c: %trror: %m,' .
        \     '../%f:%l:%c: %tarning: %m,' .
        \     '../%f:%l:%c: %m,' .
        \     '../%f:%l: %trror: %m,' .
        \     '../%f:%l: %tarning: %m,'.
        \     '../%f:%l: %m',
        \ })
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'c',
    \ 'name': 'meson',
    \ 'exec': g:NinjaCommand()
    \ })

let &cpo = s:save_cpo
unlet s:save_cpo
