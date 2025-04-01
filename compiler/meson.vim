" Compiler plugin for Meson build system
" Maintainer: Ivan Gankevich <igankevich@ya.ru>

if exists('current_compiler')
    finish
endif

let current_compiler = 'meson'

function! s:GetCwdRelativeToProjectDirectory(project_dir)
    let l:project_dir = a:project_dir
    let l:dir = getcwd()
    let l:nesting = 100
    let l:relative_dir = ''
    while l:nesting > 0
        if fnamemodify(l:dir, ':p') ==# fnamemodify(l:project_dir, ':p')
            break
        endif
        let l:relative_dir = fnamemodify(l:dir, ':t') . '/' . l:relative_dir
        let l:dir = fnamemodify(l:dir, ':h')
        let l:nesting = l:nesting - 1
    endwhile
    return l:relative_dir
endfunction

function! s:IsLocalOption()
    let l:local = 1
    let l:old_g_errorformat = &g:errorformat
    let l:old_l_errorformat = &l:errorformat
    CompilerSet errorformat=meson
    if &g:errorformat ==# 'meson'
        let &g:errorformat = l:old_g_errorformat
        let l:local = 0
    else
        let &l:errorformat = l:old_l_errorformat
    endif
    return l:local
endfunction

function! s:SetMakeProgramme(project_dir, local)
    let l:prg = g:NinjaCommand() . ' -C ' . g:MesonBuildDir(a:project_dir)
    if a:local
        let &l:makeprg = l:prg
    else
        let &makeprg = l:prg
    endif
endfunction

" Split error format on commas taking into account edge cases.
function! s:ToList(fmt)
    return split(a:fmt, '\([^\\]\)\@<=,\(%Z\)\@!')
endfunction

function! s:SetErrorFormat(project_dir, local)

    " remove meson error format lines that were added
    " by the previos call to SetErrorFormat
    let l:old_error_format = s:ToList(&errorformat)
    for line in g:meson_error_format
        let i = index(l:old_error_format, line)
        if i != -1
        "   echo 'remove ' . line . ' i=' . i
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
    \   '%EMeson encountered an error in file ' . l:project_subdir . '%f\, line %l\, column %c:,%Z%m',
    \   '%Dninja: Entering directory `%f''',
    \   '%f:%l.%c-%[%^:]%#: %t%[%^:]%#: %m'
    \   ] + l:rel_error_format
    let l:fmt = join(g:meson_error_format + l:old_error_format, ',')

    if a:local
        let &l:errorformat = l:fmt
    else
        let &errorformat = l:fmt
    endif
endfunction

let s:local = s:IsLocalOption()
let s:project_dir = g:MesonProjectDir()
call s:SetMakeProgramme(s:project_dir, s:local)
call s:SetErrorFormat(s:project_dir, s:local)
