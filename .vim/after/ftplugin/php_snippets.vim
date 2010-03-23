if !exists('loaded_snippet') || &cp
    finish
endif

let st = g:snip_start_tag
let et = g:snip_end_tag
let cd = g:snip_elem_delim

exec "so ${SHAREDPATH}/snippets/php_snippets.vim"

Snippet each foreach( $<{variable}> as $<{variable:substitute(@z,'^.*\-.\|s$','','g')}> ) {<CR><{}><CR>}<CR><{}>
Snippet eachkey foreach( $<{variable}> as $<{key}> => $<{variable:substitute(@z,'^.*\-.\|s$','','g')}> ) {<CR><{}><CR>}<CR><{}>
