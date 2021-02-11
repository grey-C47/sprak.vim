" Vim indent file
" Language:    SPRAK scripting language used in else Heart.Break()
" Maintainer:  Grey Cat <grey_cat@tuta.io>
" Created:     2021 Feb 11
" Last Change: 2021 Feb 11

if exists("b:did_indent")
	finish
endif
let b:did_indent = 1

setlocal indentexpr=GetSprakIndent(v:lnum)
setlocal indentkeys&
setlocal indentkeys+==end,=else

if exists("*GetSprakIndent")
	finish
endif

let s:LABEL = '[a-zA-Z_@?][a-zA-Z_@?0-9]'
let s:SPRAK_TYPE = 'void\|number\|string\|var\|array\|bool'
let s:SPRAK_COND_START = 'if\|else'
let s:SPRAK_COND_END = 'else\|end'
let s:SPRAK_LOOP = 'loop'
let s:SPRAK_COMMENT = '^\s*\#'

function! s:GetPrevNonCommentLineNum( lnum )
	" Skip lines starting with a comment
	let lnum = a:lnum
	while lnum > 0
		let lnum = prevnonblank(lnum - 1)
		if getline(lnum) !~? s:SPRAK_COMMENT
			break
		endif
	endwhile
	return lnum
endfunction

function! GetSprakIndent(line_num)
	" Line 0 always goes at column 0
	if a:line_num == 0
		return 0
	endif

	let this_line = getline(a:line_num)
	let prev_line_num = s:GetPrevNonCommentLineNum(a:line_num)
	let prev_line = getline(prev_line_num)
	let prev_ind = indent(prev_line_num)

	" KEEP INDENT

	"" comments
	if this_line =~ s:SPRAK_COMMENT
		return indent(a:line_num)
	endif

	" INCREASE INDENT

	"" functions
	" If the previous line is a function definition, add indent
	if prev_line =~ '^\s*\(' . s:SPRAK_TYPE . '\)\s\+' . s:LABEL . '\+\s*('
		return prev_ind + shiftwidth()
	endif

	"" conditionals
	" If the previous line is a condition start, add indent
	if prev_line =~ '^\s*\(' . s:SPRAK_COND_START . '\)'
		return prev_ind + shiftwidth()
	endif

	"" loops
	" If the previous line is a loop, add indent
	if prev_line =~ '^\s*\(' . s:SPRAK_LOOP . '\)'
		return prev_ind + shiftwidth()
	endif

	" DECREASE INDENT

	"" conditionals end
	" If the current line is a condition end, sub indent
	if this_line =~ '^\s*\(' . s:SPRAK_COND_END . '\)'
		return prev_ind - shiftwidth()
	endif

	" Otherwise, return same indent.
	return prev_ind
endfunction
