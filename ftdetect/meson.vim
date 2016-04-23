autocmd BufRead,BufNewFile meson.build setfiletype meson
autocmd BufRead,BufNewFile * if (!exists("b:current_compiler") || b:current_compiler!=#"meson") && filereadable("meson.build") | compiler meson | endif
