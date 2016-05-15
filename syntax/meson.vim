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

" global Meson object
syn keyword mesonObject meson host_machine target_machine

" control flow
syn keyword mesonCond if else endif elif true false and or not
syn keyword mesonCond foreach endforeach

" global builtin functions
syn keyword mesonBuiltin add_global_arguments
syn keyword mesonBuiltin add_languages
syn keyword mesonBuiltin benchmark
syn keyword mesonBuiltin build_target
syn keyword mesonBuiltin configuration_data
syn keyword mesonBuiltin configure_file
syn keyword mesonBuiltin custom_target
syn keyword mesonBuiltin declare_dependency
syn keyword mesonBuiltin dependency
syn keyword mesonBuiltin error
syn keyword mesonBuiltin executable
syn keyword mesonBuiltin find_program
syn keyword mesonBuiltin find_library
syn keyword mesonBuiltin files
syn keyword mesonBuiltin generator
syn keyword mesonBuiltin get_option
syn keyword mesonBuiltin get_variable
syn keyword mesonBuiltin gettext
syn keyword mesonBuiltin import
syn keyword mesonBuiltin include_directories
syn keyword mesonBuiltin install_data
syn keyword mesonBuiltin install_headers
syn keyword mesonBuiltin install_man
syn keyword mesonBuiltin install_subdir
syn keyword mesonBuiltin is_subproject
syn keyword mesonBuiltin is_variable
syn keyword mesonBuiltin jar
syn keyword mesonBuiltin library
syn keyword mesonBuiltin message
syn keyword mesonBuiltin project
syn keyword mesonBuiltin run_command
syn keyword mesonBuiltin run_target
syn keyword mesonBuiltin set_variable
syn keyword mesonBuiltin shared_library
syn keyword mesonBuiltin static_library
syn keyword mesonBuiltin subdir
syn keyword mesonBuiltin subproject
syn keyword mesonBuiltin test
syn keyword mesonBuiltin vcs_tag

" meson object methods
syn keyword mesonBuiltin add_install_script
syn keyword mesonBuiltin add_postconf_script
syn keyword mesonBuiltin build_root
syn keyword mesonBuiltin current_build_dir
syn keyword mesonBuiltin current_source_dir
syn keyword mesonBuiltin get_compiler
syn keyword mesonBuiltin has_exe_wrapper
syn keyword mesonBuiltin is_cross_build
syn keyword mesonBuiltin is_unity
syn keyword mesonBuiltin project_version
syn keyword mesonBuiltin source_root

" compiler object methods
syn keyword mesonBuiltin alignment
syn keyword mesonBuiltin compiles
syn keyword mesonBuiltin get_id
syn keyword mesonBuiltin has_function
syn keyword mesonBuiltin has_header
syn keyword mesonBuiltin has_member
syn keyword mesonBuiltin has_type
syn keyword mesonBuiltin run
syn keyword mesonBuiltin sizeof
syn keyword mesonBuiltin version

"host_machine / target_machine methods
syn keyword mesonBuiltin system cpu_family cpu endian

hi link mesonComment Comment
hi link mesonTodo Todo
hi link mesonString String
hi link mesonBuiltin Function
hi link mesonObject Identifier
hi link mesonCond Statement

let b:current_syntax = "meson"
