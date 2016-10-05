" Vim plugin for initialising Meson build directories
" Maintainer: Ivan Gankevich <igankevich@ya.ru>

" script guard
if exists("meson_loaded")
    finish
endif
let meson_loaded = 1

function! g:MesonProjectDir()

	let l:dir = getcwd()      " a starting directory to look for meson.build file
	let l:project_dir = l:dir " the top-most directory with meson.build file
	let l:nesting = 100       " maximal no. of subdirectories in a project

	" find top-most directory with readable meson.build file
	while fnamemodify(l:dir, ':p') !=# '/' && l:nesting > 0
		if filereadable(l:dir . '/' . 'meson.build')
			let l:project_dir = l:dir
		endif
		let l:dir = l:dir . '/..'
		let l:nesting = l:nesting - 1
	endwhile

	" why one needs to do it two times?
	let l:project_dir = fnamemodify(l:project_dir, ':p')
	let l:project_dir = fnamemodify(l:project_dir, ':p')
	return l:project_dir

endfunction

" the name of the Meson build directory (defaults to '$project_dir/build')
function! g:MesonBuildDir(project_dir)
	let l:meson_build_dir = 'build'
	if exists("b:meson_build_dir")
		let l:meson_build_dir = b:meson_build_dir
	elseif exists("g:meson_build_dir")
		let l:meson_build_dir = g:meson_build_dir
	endif
	return fnamemodify(a:project_dir . '/' . l:meson_build_dir, ':p:gs?/\+?/?')
endfunction

" Meson build executable (defaults to 'meson')
function! s:MesonCommand()
	let l:cmd = 'meson'
	if exists('b:meson_command')
		let l:cmd = b:meson_command
	elseif exists('g:meson_command')
		let l:cmd = g:meson_command
	endif
	return l:cmd
endfunction

" make build directory and init meson build system in it
function! g:MesonInit(...)
	if a:0 > 1
		echoerr 'Too many arguments to MesonInit function. Usage: MesonInit <build-dir>'
		return
	endif
	let l:project_dir = g:MesonProjectDir()
	if a:0 == 1
		let g:meson_build_dir = a:1
	endif
	let l:build_dir = g:MesonBuildDir(l:project_dir)
	if !filereadable(l:project_dir . '/meson.build')
		echoerr "Can not find meson.build file in the project directory"
		return
	endif
	if !isdirectory(l:build_dir)
		call mkdir(l:build_dir)
	endif
	let l:relative_build_dir = fnamemodify(l:build_dir, ':p:h:t')
	if !filereadable(l:build_dir . '/build.ninja')
		echo 'Initialising ' . l:relative_build_dir
		echo system(s:MesonCommand() . ' ' . l:project_dir . ' ' . l:build_dir)
	else
		echo 'Switching to ' . l:relative_build_dir
		let g:meson_build_dir = l:relative_build_dir
	endif
	compiler meson
endfunction

" quick access command
command! -nargs=? MesonInit call g:MesonInit(<args>)

" gf implementation
function! g:MesonGoToFile(filename,cmd)
	" determine dirname of the file being edited
	let dirname = fnamemodify(expand('%'), ':h')
	if dirname == '.'
		let dirname = ''
	else
		let dirname = dirname.'/'
	endif
	let name = a:filename
	if isdirectory(a:filename)
		" go directly to meson.build file instead of going
		" to corresponding directory
		let name = a:filename.'/meson.build'
	else
		" try to infer filename from the call to 'subdir'
		" with string literal as an argument
		let line = getline('.')
		let tmp = substitute(line, '\v^\s*subdir\('."'".'(.+)'."'".'\).*', '\1', '')
		if isdirectory(dirname.tmp)
			let name = tmp.'/meson.build'
		endif
	endif
	execute a:cmd.' '.dirname.name
endfunction

" go to meson.build in the parent directory (if any)
function! g:MesonGoToParentFile(cmd) 
	" determine dirname of the file being edited
	let dirname = fnamemodify(expand('%'), ':h')
	let filename = dirname.'/../meson.build'
	if filereadable(filename)
		execute a:cmd.' '.filename
	else
		echo 'No parent meson.build file.'
	endif
endfunction
