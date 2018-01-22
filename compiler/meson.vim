" Compiler plugin for Meson build system
" Maintainer: Ivan Gankevich <igankevich@ya.ru>

if exists('current_compiler')
    finish
endif

let current_compiler = 'meson'

function! s:GetCwdRelativeToProjectDirectory(project_dir)
	return substitute(getcwd().'/', fnameescape(a:project_dir), '', 'g')
endfunction

" Ninja build executable (defaults to 'ninja')
function! s:NinjaCommand()
	let l:cmd = 'ninja'
	if exists('b:meson_ninja_command')
		let l:cmd = b:meson_ninja_command
	elseif exists('g:meson_ninja_command')
		let l:cmd = g:meson_ninja_command
	endif
	return l:cmd
endfunction

function! s:SetMakeProgramme(project_dir)
	let l:build_dir = g:MesonBuildDir(a:project_dir)
	let &l:makeprg =  s:NinjaCommand() . ' -C ' . l:build_dir
endfunction

" Split error format on commas taking into account edge cases.
function! s:ToList(fmt)
	return split(a:fmt, '\([^\\]\)\@<=,\(%Z\)\@!')
endfunction

function! s:SetErrorFormat(project_dir)

	" remove meson error format lines that were added
	" by the previos call to SetErrorFormat
	let l:old_error_format = s:ToList(&errorformat)
	for line in g:meson_error_format
		let i = index(l:old_error_format, line)
		if i != -1
		"	echo 'remove ' . line . ' i=' . i
			call remove(l:old_error_format, i)
		endif
	endfor

	" relativise filenames for meson.build syntax errors
	" for building from a subdirectory
	let l:project_subdir = s:GetCwdRelativeToProjectDirectory(a:project_dir)
	let l:project_subdir_relative_to_build_dir = '../' . l:project_subdir
	let l:subst = l:project_subdir_relative_to_build_dir . '%f'
	let l:rel_error_format = []
	for line in l:old_error_format
		if match(line, '%f') >= 0
			call add(l:rel_error_format, substitute(line, '%f', l:subst, 'g'))
		endif
	endfor

	" generate new error format lines
	let g:meson_error_format = [
	\	'%EMeson encountered an error in file ' . l:project_subdir . '%f\, line %l\, column %c:,%Z%m',
	\   '%Dninja: Entering directory `%f''',
	\   '%f:%l.%c-%[%^:]%#: %t%[%^:]%#: %m'
	\	] + l:rel_error_format
	let &l:errorformat = join(g:meson_error_format + l:old_error_format, ',')

endfunction

let s:project_dir = g:MesonProjectDir()
call s:SetMakeProgramme(s:project_dir)
call s:SetErrorFormat(s:project_dir)
