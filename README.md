# Mesonic: A Vim plugin for Meson build system

Mesonic is a plugin that uses Vim compiler infrastructure to integrate
[Meson build system](https://mesonbuild.com/) into an editor with special
handling of out-of-source builds. It sets 'makeprg', 'errorformat' options and
provides syntax highlighting for ``meson.build`` files.

## Usage

Use ``:MesonInit`` to initialise build directory for the first time. After that
you can issue ``:make`` command as usual, which produces correct quickfix list
no matter what current directory is. All commands work as expected from any
subdirectory of your project.

You can customise meson and ninja commands with the following variables, which
can be either global or buffer local. Defaults are listed below.

```vim
let b:meson_command = 'meson'
let b:meson_ninja_command = 'ninja'        " ninja-build on Fedora
```

If you want to switch between build directories, issue ``:MesonInit`` command
with an argument. For example, to switch to ``build-debug`` directory, issue

```vim
:MesonInit build-debug         " switch for the current buffer
:MesonInit! build-debug        " switch for the current and new buffers
:bufdo MesonInit! build-debug  " switch for all existing and new buffers
```

The directory will be initialised if it does not exist or does not contain
``build.ninja`` file. As of the current version Meson options can be added only
via ``b:meson_command`` variable.

Meson options can be changed via ``:MesonConfigure`` command:

```vim
" change install prefix to $HOME/.local
:MesonConfigure -Dprefix=$HOME/.local

" debug build with address sanitizer
:MesonConfigure -Dbuildtype=debug -Db_sanitize=address -Dcpp_args=""

" fully optimised build
:MesonConfigure -Dbuildtype=release -Db_sanitize=none -Dcpp_args="-march=native"

" show current configuration
:MesonConfigure
```

The plugin completes partially written arguments and current argument values,
just hit <kbd>TAB</kbd> at any point in the command line.

The usual file navigation commands, namely <kbd>g</kbd><kbd>f</kbd>,
<kbd>Ctrl</kbd>+<kbd>w</kbd><kbd>f</kbd>, and
<kbd>Ctrl</kbd>+<kbd>w</kbd><kbd>g</kbd><kbd>f</kbd>, work for `subdir()`
constructs. To go to ``meson.build`` file in the parent directory simply use
<kbd>g</kbd><kbd>b</kbd> or <kbd>Backspace</kbd>. Also Mesonic does completion
for member functions of all global objects (`meson` and `*_machine`). Type
object name, dot and <kbd>Ctrl</kbd>+<kbd>x</kbd>+<kbd>o</kbd> to trigger
function name completion.  Further customisations are documented in the
help file: ``:help mesonic``.

### Syntastic integration

Mesonic provides a Syntastic syntax checker for the C language. In order to use
it, put the following (or similar) into your ``.vimrc``.

```vim
" If there's a `meson.build` file, use meson for linting.
autocmd FileType c call ConsiderMesonForLinting()
function ConsiderMesonForLinting()
    if filereadable('meson.build')
        let g:syntastic_c_checkers = ['meson']
    endif
endfunction
```

## Limitations

Mesonic assumes that build directory is a subdirectory of top-level directory of
your project, i.e. build directory is located in the same directory where your
main ``meson.build`` file is. In all other cases it may produce wrong file paths
in quickfix list.

## Contributing

This plugin was created as a result of my passion for Vim and C++
programming, and as a consequence of reading
["Learn Vimscript the Hard Way"](http://learnvimscriptthehardway.stevelosh.com/)
by Steve Losh. Feel free to contribute or post a bug at GitHub project page
(here).

## License

Mesonic is GPL licensed.
