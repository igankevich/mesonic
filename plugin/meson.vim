" Vim plugin for initialising Meson build directories
" Maintainer: Ivan Gankevich <igankevich@ya.ru>

" script guard
if exists("meson_loaded")
    finish
endif
let meson_loaded = 1
let g:meson_error_format = []

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
function! g:MesonCommand()
    let l:cmd = 'meson'
    if exists('b:meson_command')
        let l:cmd = b:meson_command
    elseif exists('g:meson_command')
        let l:cmd = g:meson_command
    endif
    return l:cmd
endfunction

" Ninja build executable (defaults to 'ninja')
function! g:NinjaCommand()
    let l:cmd = 'ninja'
    if exists('b:meson_ninja_command')
        let l:cmd = b:meson_ninja_command
    elseif exists('g:meson_ninja_command')
        let l:cmd = g:meson_ninja_command
    endif
    return l:cmd
endfunction

" make build directory and init meson build system in it
function! g:MesonInit(directory, bang)
    let l:project_dir = g:MesonProjectDir()
    if len(a:directory) > 0
        let g:meson_build_dir = a:directory
    endif
    let l:build_dir = g:MesonBuildDir(l:project_dir)
    if !filereadable(l:project_dir . '/meson.build')
        echoerr "Can not find meson.build file in the project directory"
        return
    endif
    if !isdirectory(l:build_dir)
        call mkdir(l:build_dir, "p")
    endif
    if !filereadable(l:build_dir . '/build.ninja')
        let oldmakeprg = &l:makeprg
        let olderrorformat = &l:errorformat
        let &l:makeprg = g:MesonCommand() . ' setup ' . l:project_dir . ' ' . l:build_dir
        let &l:errorformat = '%f:%l:%c: %m'
        try
            make
        finally
            let &l:makeprg = oldmakeprg
            let &l:errorformat = olderrorformat
        endtry
    else
        let l:relative_build_dir = fnamemodify(l:build_dir, ':p:h:t')
        echo 'Switching to ' . l:relative_build_dir
        let g:meson_build_dir = l:relative_build_dir
    endif
    execute 'compiler' . a:bang . ' meson'
endfunction

" quick access command
command! -nargs=? -bang -complete=dir MesonInit
    \ call g:MesonInit('<args>', '<bang>')

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
    " try to remove dots in the path
    let modifiers = ':.'
    if filename[0] ==# '/'
        let modifiers = ':p'
    endif
    let filename = fnamemodify(filename, modifiers)
    if filereadable(filename)
        execute a:cmd.' '.filename
    else
        echo 'No parent meson.build file.'
    endif
endfunction

" filter matching elements
function! s:MesonFilter(keyword, list)
    " where to show args (menu/info/none)
    let l:meson_show_args = 'none'
    if exists("b:meson_show_args")
        let l:meson_show_args = b:meson_show_args
    elseif exists("g:meson_show_args")
        let l:meson_show_args = g:meson_show_args
    endif
    let result = []
    for elem in a:list
        if elem.word =~# '^'.a:keyword
            let new_elem = {'word': elem.word}
            if !empty(get(elem, 'menu', ''))
                if l:meson_show_args ==# 'menu'
                    let new_elem.menu = elem.menu
                elseif l:meson_show_args ==# 'info'
                    let new_elem.info = elem.menu
                endif
            endif
            call add(result, new_elem)
        endif
    endfor
    return result
endfunction

" complete global object member names
function! g:MesonOmniComplete(findstart, base)
    if a:findstart
        " locate the start of the member name
        let line = getline('.')
        let start = col('.') - 1
        while start > 0 && line[start - 1] !=# '.'
            let start -= 1
            if line[start] !~# '[a-zA-Z0-9_]'
                return -3
            endif
        endwhile
        return start
    else
        let members = {
            \ 'meson': [
                \ {'word': 'add_dist_script', 'menu': 'script_name, arg1, arg2, ...'},
                \ {'word': 'add_install_script', 'menu': 'script_name, arg1, arg2, ...'},
                \ {'word': 'add_postconf_script', 'menu': 'script_name, arg1, arg2, ...'},
                \ {'word': 'backend'},
                \ {'word': 'build_root'},
                \ {'word': 'can_run_host_binaries'},
                \ {'word': 'current_build_dir'},
                \ {'word': 'current_source_dir'},
                \ {'word': 'get_compiler', 'menu': 'language'},
                \ {'word': 'get_cross_property', 'menu': 'propname, fallback_value'},
                \ {'word': 'get_external_property', 'menu': 'propname, fallback_value, native'},
                \ {'word': 'has_exe_wrapper'},
                \ {'word': 'install_dependency_manifest', 'menu': 'output_name'},
                \ {'word': 'is_cross_build'},
                \ {'word': 'is_subproject'},
                \ {'word': 'is_unity'},
                \ {'word': 'override_dependency', 'menu': 'name, dep_object'},
                \ {'word': 'override_find_program', 'menu': 'progname, program'},
                \ {'word': 'project_build_root'},
                \ {'word': 'project_license'},
                \ {'word': 'project_name'},
                \ {'word': 'project_source_root'},
                \ {'word': 'project_version'},
                \ {'word': 'source_root'},
                \ {'word': 'version'},
            \ ],
            \ 'machine': [
                \ {'word': 'system'},
                \ {'word': 'cpu_family'},
                \ {'word': 'cpu'},
                \ {'word': 'endian'},
                \ ]
        \ }
        " find the dot
        let line = getline('.')
        let start = col('.') - 1
        while start > 0 && line[start - 1] !=# '.'
            let start -= 1
        endwhile
        let start -= 1
        let name_end = start-1
        " find the object name
        while start > 0 && line[start-1] =~# '[a-zA-Z0-9_]'
            let start -= 1
        endwhile
        let object_name = line[start:name_end]
        let result = []
        if object_name ==# 'meson'
            let result = members['meson']
        elseif object_name =~# '\v(build|host|target)_machine'
            let result = members['machine']
        endif
        return s:MesonFilter(a:base, result)
    endif
endfunction

" meson configure wrapper
function! MesonConfigure(arguments)
    if len(a:arguments) == 0
        let options = MesonIntrospect('--buildoptions')
        " sanitise
        for opt in options
            if opt.type ==# 'boolean'
                if opt.value == v:true
                    let opt.value = 'true'
                endif
                if opt.value == v:false
                    let opt.value = 'false'
                endif
            endif
        endfor
        " calculate column width
        let width = [0,0]
        for opt in options
            let w = [len(opt.name), len(string(opt.value))]
            for i in [0,1]
                if w[i] > width[i]
                    let width[i] = w[i]
                endif
            endfor
        endfor
        let format = '%' . width[0] . 's  %-' . width[1] . 's  %s'
        " print options
        for opt in options
            echo printf(format, opt.name, opt.value, opt.description)
        endfor
    else
        let cmd = MesonCommand() . ' configure ' . a:arguments . ' ' . MesonBuildDir(MesonProjectDir())
        let output = system(cmd)
        if v:shell_error
            echo output
        else
            echo 'MesonConfigure: OK'
        endif
    endif
endfunction

" ninja wrapper
function! NinjaRun(arguments)
    let oldmakeprg = &l:makeprg
    let &l:makeprg = NinjaCommand() . ' -C ' . MesonBuildDir(MesonProjectDir()) . ' ' . a:arguments
    try
        make
    finally
        let &l:makeprg = oldmakeprg
    endtry
endfunction

" meson run wrapper
function! MesonRun(arguments)
    let options = MesonIntrospect('--targets')
    if len(a:arguments) == 0
        " calculate column width
        let width = [0,0]
        for opt in options
            let w = [len(opt.name), len(string(opt.filename[0]))]
            for i in [0,1]
                if w[i] > width[i]
                    let width[i] = w[i]
                endif
            endfor
        endfor
        let format = '%' . width[0] . 's  %-' . width[1] . 's  %s'
        " print options
        for opt in options
            echo printf(format, opt.name, opt.filename[0], opt.type)
        endfor
    else
        let cmd = a:arguments
        let cmd_opts = []
        let target_found = 0
        let type = ''
        for arg in split(a:arguments)
            if ! target_found
                for opt in options
                    if opt.name == arg
                        let cmd = opt.filename[0]
                        let target_found = 1
                        let type = opt.type
                        break
                    endif
                endfor
                if !target_found
                    call add(cmd_opts, arg)
                endif
            else
                call add(cmd_opts, arg)
            endif
        endfor
        if type ==# 'executable'
            let error = 0
            let output = ""
            if !filereadable(cmd)
                call NinjaRun(split(a:arguments)[0])
            endif
            if filereadable(cmd)
                let output = system(cmd . ' '. join(cmd_opts) )
                let error = v:shell_error
            else
                let output = 'target filename do not exists. was :make executed?'
            endif
            if error
                echo 'MesonRun: ERROR'
            else
                echo 'MesonRun: OK'
            endif
            echo output
        else
            call NinjaRun(a:arguments)
        endif
    endif
endfunction

" meson introspect wrapper
function! MesonIntrospect(argument)
    let cmd = MesonCommand() . ' introspect ' . a:argument . ' ' . MesonBuildDir(MesonProjectDir())
    silent let output = system(cmd)
    if v:shell_error
        return []
    endif
    return json_decode(output)
endfunction

" auto-complete meson configure arguments
function! MesonConfigureComplete(ArgLead, CmdLine, CursorPos)
    let result = []
    let options = MesonIntrospect('--buildoptions')
    let key = ''
    let val = ''
    let branch = 0
    let keyval = split(a:ArgLead, '=')
    if len(keyval) > 0
        let key = keyval[0]
        if key =~# '^-D'
            let key = key[2:-1] 
        endif
    endif
    if a:ArgLead =~# '=$'
        let branch = 1
    elseif len(keyval) > 1
        let val = keyval[1]
        let branch = 1
    endif
    for opt in options
        if branch == 0
            if opt.name =~# key
                call add(result, '-D' . opt.name . '=')
            endif
        else
            if opt.name ==# key
                let choices = []
                if opt.type ==# 'boolean'
                    let choices = ['false', 'true']
                elseif opt.type ==# 'combo'
                    let choices = opt.choices
                elseif opt.type ==# 'string'
                    let choices = [opt.value]
                elseif opt.type ==# 'array'
                    let choices = ['"' . join(opt.value, ' ') . '"']
                endif
                if len(choices) > 0
                    for choice in choices
                        if val ==# '' || choice =~# val
                            call add(result, '-D' . key . '=' . choice)
                        endif
                    endfor
                endif
                break
            endif
        endif
    endfor
    return result
endfunction

" auto-complete meson run arguments
function! MesonRunComplete(ArgLead, CmdLine, CursorPos)
    let result = []
    let options = MesonIntrospect('--targets')
    let key = a:ArgLead
    for opt in options
        if opt.name =~# key
            call add(result, opt.name)
        endif
    endfor
    return result
endfunction

" meson test wrapper
function! MesonTest(arguments)
    let oldmakeprg = &l:makeprg
    let &l:makeprg = MesonCommand() . ' test -C ' . MesonBuildDir(MesonProjectDir()) . ' ' . a:arguments
    try
        make
    finally
        let &l:makeprg = oldmakeprg
    endtry
endfunction

" auto-complete meson test arguments
function! s:MesonTestCompleteImpl(ArgLead, CmdLine, CursorPos, type)
    let result = []
    let key = a:ArgLead
    let allArgs = split(a:CmdLine)
    let type = a:type
    if index(allArgs, '--benchmark') != -1
        let type = '--benchmarks'
    endif
    let args = split(a:CmdLine[:a:CursorPos])
    let prevArg = ''
    if len(args) != 0
        if a:CmdLine[a:CursorPos-1] ==# ' '
            let prevArg = args[len(args)-1]
        else
            let prevArg = args[len(args)-2]
        endif
    endif
    let options = MesonIntrospect(type)
    if prevArg ==# '--suite' || prevArg ==# '--no-suite'
        let candidates = uniq(sort(flatten(map(options, {key, value -> value.suite}))))
    else
        let candidates = sort(map(options, {key, value -> value.name}))
    endif
    for c in candidates
        if c =~# key
            call add(result, c)
        endif
    endfor
    return result
endfunction

function! MesonTestComplete(ArgLead, CmdLine, CursorPos)
    return s:MesonTestCompleteImpl(a:ArgLead, a:CmdLine, a:CursorPos, '--tests')
endfunction

function! MesonBenchmark(arguments)
    call MesonTest('--benchmark ' . a:arguments)
endfunction

function! MesonBenchmarkComplete(ArgLead, CmdLine, CursorPos)
    return s:MesonTestCompleteImpl(a:ArgLead, a:CmdLine, a:CursorPos, '--benchmarks')
endfunction

" quick access command
command! -nargs=* -complete=customlist,MesonConfigureComplete MesonConfigure
    \ call MesonConfigure('<args>')
command! -nargs=* -complete=customlist,MesonRunComplete MesonRun
    \ call MesonRun('<args>')
command! -nargs=* -complete=customlist,MesonTestComplete MesonTest
    \ call MesonTest('<args>')
command! -nargs=* -complete=customlist,MesonBenchmarkComplete MesonBenchmark
    \ call MesonBenchmark('<args>')
