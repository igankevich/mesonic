" Vim syntax file
" Language: Meson build
" Maintainer: Ivan Gankevich <igankevich@ya.ru>
" Based on conf.vim by Bram Moolenaar

if exists("b:current_syntax")
    finish
endif

syn keyword mesonTodo contained TODO FIXME XXX
syn match mesonComment "^#.*" contains=mesonTodo
syn match mesonComment "\s#.*"ms=s+1 contains=mesonTodo
syn region mesonString start=+'+ skip=+\\\\\|\\'+ end=+'+ oneline
syn region mesonStringM start=+'''+ skip=+\\\\\|\\'+ end=+'''+

" global objects
syn keyword mesonGlobal meson host_machine target_machine build_machine

" control flow
syn keyword mesonBool true false
syn keyword mesonCond if else endif elif and or not
syn keyword mesonRepeat foreach endforeach

" global functions
syn match mesonBuiltin "\(^\|[^\.]\)\zs\<\h\w*\>\ze\(\s\|\n\)*("

hi link mesonComment Comment
hi link mesonTodo Todo
hi link mesonString String
hi link mesonStringM String
hi link mesonBuiltin Function
hi link mesonGlobal Keyword
hi link mesonCond Conditional
hi link mesonBool Boolean
hi link mesonRepeat Repeat

let b:current_syntax = "meson"
