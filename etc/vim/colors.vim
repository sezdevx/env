set background=dark
hi clear
if exists("syntax_on")
	syntax reset
endif

hi Normal		  ctermfg=white ctermbg=black
hi ErrorMsg		ctermfg=white ctermbg=lightblue
hi Visual	   	ctermbg=fg cterm=reverse
hi VisualNOS	ctermbg=fg cterm=reverse,underline
hi Todo			  ctermbg=darkblue
hi Search		  ctermbg=darkblue cterm=underline term=underline
hi IncSearch	ctermbg=gray

hi SpecialKey		ctermfg=darkcyan
hi Directory		ctermfg=cyan
hi Title			ctermfg=magenta cterm=bold
hi WarningMsg		ctermfg=red
hi WildMenu			ctermfg=yellow ctermbg=black cterm=none term=none
hi ModeMsg			ctermfg=lightblue
hi MoreMsg			ctermfg=darkgreen	ctermfg=darkgreen
hi Question			ctermfg=green cterm=none
hi NonText			ctermfg=darkblue


hi StatusLine	ctermfg=white ctermbg=61 term=none cterm=none
hi StatusLineNC	ctermfg=black ctermbg=61 term=none cterm=none
hi VertSplit	ctermfg=black ctermbg=61 term=none cterm=none

hi Folded	ctermbg=black cterm=bold term=bold
hi FoldColumn	ctermbg=black cterm=bold term=bold
hi LineNr	cterm=none

hi DiffAdd	term=none cterm=none
hi DiffChange	ctermbg=magenta cterm=none
hi DiffDelete	ctermfg=blue ctermbg=cyan 
hi DiffText	cterm=bold ctermbg=red 

hi Cursor	ctermfg=black ctermbg=yellow
hi lCursor	ctermfg=black ctermbg=white


hi Comment	ctermfg=65
hi String   ctermfg=113
hi Function ctermfg=172
hi Constant	ctermfg=75 cterm=none
hi Special	ctermfg=146 cterm=none 
hi Identifier	ctermfg=221 cterm=none
hi Statement	ctermfg=172 cterm=none 
hi PreProc	ctermfg=214 cterm=none
hi type		ctermfg=81 cterm=none
hi Underlined	cterm=underline term=underline
hi Ignore	ctermfg=bg


