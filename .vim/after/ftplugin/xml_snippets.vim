
if !exists('loaded_snippet') || &cp
    finish
endif

let st = g:snip_start_tag
let et = g:snip_end_tag
let cd = g:snip_elem_delim

exec "Snippet xml <".st."xmlname".et.">".st.et."</".st."xmlname".et.">".st.et
exec "Snippet xmla <".st."xmlname".et." ".st.et.">".st.et."</".st."xmlname".et.">".st.et


"CLAIM CONFIG SPECIFIC
exec "Snippet config <".st."name".et."><CR><TAB><path>".st.et."</path><CR><method>".st.et."</method><CR><BS></".st."name".et.">".st.et
exec "Snippet seg <".st."name".et." segment='true' segmentId='".st.et."'><CR>".st.et."</".st."name".et.">".st.et
exec "Snippet val <value>".st.et."</value>".st.et
exec "Snippet min <min_length>".st.et."</min_length>".st.et
exec "Snippet max <max_length>".st.et."</max_length>".st.et


