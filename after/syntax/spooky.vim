if exists('b:current_syntax')
	let old_syntax = b:current_syntax
	unlet b:current_syntax
endif

syntax include @Lua syntax/lua.vim
unlet b:current_syntax

" Cannot use syntax region as the preamble must be matched as a whole
" (ending must present)
" syntax region spookyPreamble start=/\%^/ matchgroup=spookyTemplateStart end=/^\s*----*\s*$/me=s-1 contains=@Lua keepend
syntax match spookyPreamble /\%^\_.\{-}$\n\s*----*\s*$/ contains=@Lua keepend
syntax region spookyVariable matchgroup=spookyVariableBoundary start=/\${/ matchgroup=spookyVariableBoundary end=/}/ oneline

highlight link spookyVariableBoundary SpecialChar
highlight link spookyVariable Identifier

if exists('old_syntax')
  let b:current_syntax = old_syntax
endif

