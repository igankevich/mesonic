" Vim syntax file
" Language: Meson build options
" Maintainer: Ivan Gankevich <igankevich@ya.ru>
" Based on conf.vim by Bram Moolenaar

if exists("b:current_syntax")
	finish
endif

syn region mesonString start=+'+ skip=+\\\\\|\\'+ end=+'+ oneline
syn keyword mesonCond true false
syn keyword mesonBuiltin option

hi link mesonString String
hi link mesonBuiltin Function
hi link mesonCond Statement

let b:current_syntax = "mesonopt"
