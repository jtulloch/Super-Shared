function MyTabOrComplete()
	let col = col('.') - 1
	if !col || getline('.')[col - 1] !~ '\k'
		return "\<tab>"
	else
		return "\<C-N>"
	endif
endfunction

inoremap <Tab> <C-R>=MyTabOrComplete()<CR>

function MyPaste()
	return "\<S-INSERT>"
endfunction

map <F9> :set paste!<bar>set nopaste?<CR>
noremap <F7> :set ignorecase!<bar>set ignorecase?<CR>
nnoremap <C-I> >i{
nnoremap <C-N> <i{
nnoremap co I//XXX <ESC>

if exists('loaded_snippet')
	imap <C-H> <Plug>Jumper
endif

let Tlist_Ctags_Cmd = "/usr/bin/ctags"
let Tlist_Inc_Winwidth = 1
let Tlist_Exit_OnlyWindow = 1
let Tlist_File_Fold_Auto_Close = 1
let Tlist_Process_File_Always = 1
let Tlist_Enable_Fold_Column = 0
let tlist_php_settings = 'php;c:class;d:constant;f:function'

if exists('loaded_taglist')
    nmap <silent> <F8> :TlistToggle<CR>
endif

nmap <F5> [I:let nr = input("Which one: ") <Bar>exe "normal " . nr ."[\t"<CR>


" Load the akelos template snippets
au BufRead,BufNewFile *.tpl exec "so ${SHAREDPATH}/.vim/after/ftplugin/tpl_snippets.vim"

" jslint command
let jslintcommand = "/usr/bin/jslint/jslintfile.sh %"
let w3mdump = "w3m -T text/html -dump"
let diffCreator = "php ${SHAREDPATH}/scripts/parseLineProblems.php % "
let commandheight = "15"
set splitbelow
set splitright
map ,j :let fname = tempname()<CR>:exe "!".jslintcommand." \| ".w3mdump." \| ".diffCreator.fname<CR>:exe "vert diffsplit ".fname<CR>
"map ,j :let fname = tempname()<CR><C-W><C-O>:silent exe "!".jslintcommand." \| ".w3mdump." > " . fname<CR>:exe commandheight." split " . fname<CR><C-W>k<C-L>
" end jslint stuff
"
"map ,d :let fname = tempname()<CR>:silent exe "!psql wolverine -f % &> " . fname<CR>:exe commandheight." split " . fname<CR>:let g:output_buffer = bufnr("%")<C-W>k<C-L>
command! -nargs=0 -bar LoadDB call s:RunCommand("go")
nnoremap ,d :LoadDB<CR>

"set winheight=20
"set winminheight=20
nnoremap <C-W>. 10<C-W>>
nnoremap <C-W>, 10<C-W><
nnoremap <C-W>0 10<C-W>+
nnoremap <C-W>9 10<C-W>-
nnoremap <C-W>3 <C-W>_
nnoremap <C-W>1 z20<CR>
nnoremap <C-K> <C-W>k
nnoremap <C-J> <C-W>j
nnoremap <C-H> <C-W>h
nnoremap <C-L> <C-W>l
nnoremap <C-P> :mksession! ~/tmp/save.session<CR>:qa<CR>
nnoremap <C-D> :qa<CR>
nnoremap <C-A> :q<CR>
nnoremap <C-W>v :vsp 

helptags ~/.vim/doc

cabbr diff :VCSVimDiff

"set t_Co=256
"colors railscasts
"colorscheme BlackSea
set hlsearch


" , #perl # comments
map ,# :s/^/#/<CR>

" ,/ C/C++/C#/Java // comments
"map ,/ :s/^/\/\//<CR>
map ,/ :s/^/\/\/XXX/<CR>
map ,? :s/^\/\/X*//<CR>
map ,x A //XXX<ESC>

function! s:RunCommand(theCommand)
    if g:output_buffer > 0
        exe "bunload " . g:output_buffer
    endif

    let tempFileName = tempname()
    silent exe "!psql wolverine -f % &> " . tempFileName
    exe "15 split " . tempFileName
    let g:output_buffer = winbufnr(tempFileName)
endfunction

function! s:DoProj()
    let winnum = bufwinnr(g:proj_running)
    if winnum != -1
        hide
        return
    endif

    Project
endfunction
command! -nargs=0 -bar MyProjectToggle call s:DoProj()
nnoremap <silent> <F4> :MyProjectToggle<CR>
nnoremap <silent> <F6> :sp<CR>:MyProjectToggle<CR>

" Remap control U to search for function name
nnoremap <C-u> /function *&* *

exec "Project ~/.project_".$PROJECT
hide
