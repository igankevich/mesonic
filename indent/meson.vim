" Meson build indent file
" Language: Meson build
" Author: Ivan Gankevich <igankevich@ya.ru>
" Based on pascal.vim
" http://psy.swansea.ac.uk/staff/Carter/Vim/vim_indent.htm

if exists("b:did_indent")
	finish
endif
let b:did_indent = 1

" trigger indentaion on each control flow keyword and brackets
setlocal indentkeys=0(,0),0[,0],o,O
setlocal indentkeys+==if,=endif,=else,=elif,=foreach,=endforeach
setlocal indentexpr=MesonIndent(v:lnum)

function! s:GetPreviousLineNumberIgnoringComments(lineno)

	if a:lineno == 0
		return -1
	endif

	let comment = '^\s*#'

	let nline = a:lineno
	while nline > 0
		let nline = prevnonblank(nline-1)
		if getline(nline) !~? comment
			break
		endif
	endwhile

	if nline == 0 && getline(nline) =~? comment
		let nline = -1
	endif

	return nline

endfunction

function! MesonIndent(lineno)

	let prev_lineno = s:GetPreviousLineNumberIgnoringComments(a:lineno)

	" do not indent the first line
	if prev_lineno == -1
		return 0
	endif

	let this_line = getline(a:lineno)
	let prev_line = getline(prev_lineno)
	let amount = indent(prev_lineno)

	" indent after keywords and brackets
	if prev_line =~ '\v^\s*(if|else|foreach)' ||
	 \ prev_line =~ '\v[\(\[]\s*$'
		let amount += &shiftwidth
	" unindent after keywords and brackets
	elseif this_line =~ '\v^\s*(endif|else|endforeach)' ||
	     \ this_line =~ '\v^\s*[\)\]],*\s*$'
		let amount -= &shiftwidth
	endif

	return amount

endfunction
