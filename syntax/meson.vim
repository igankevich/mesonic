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

" global builtin functions
syn keyword mesonBuiltin
	\ add_global_arguments
	\ add_global_link_arguments
	\ add_languages
	\ add_project_arguments
	\ add_project_link_arguments
	\ add_test_setup
	\ assert
	\ benchmark
	\ both_libraries
	\ build_target
	\ configuration_data
	\ configure_file
	\ custom_target
	\ declare_dependency
	\ dependency
	\ disabler
	\ environment
	\ error
	\ executable
	\ files
	\ find_library
	\ find_program
	\ generator
	\ get_option
	\ gettext
	\ get_variable
	\ import
	\ include_directories
	\ install_data
	\ install_headers
	\ install_man
	\ install_subdir
	\ is_variable
	\ jar
	\ join_paths
	\ library
	\ message
	\ option
	\ project
	\ run_command
	\ run_target
	\ set_variable
	\ shared_library
	\ shared_module
	\ static_library
	\ subdir
	\ subdir_done
	\ subproject
	\ test
	\ vcs_tag
	\ warning

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
