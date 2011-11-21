" init patogen system
call pathogen#runtime_append_all_bundles()
call pathogen#helptags()

set nocompatible
set ttyfast
set number
set smartindent
set cindent
set autoindent
set expandtab
set tabstop=2
set shiftwidth=2
set noerrorbells
set ignorecase
set cursorline
set textwidth=120
set nolazyredraw   " don't redraw screen while executing macros
set encoding=utf-8
set exrc           " enable per-directory .vimrc files
set secure         " disable unsafe commands in local .vimrc files
set incsearch      " find the next match as we type the search
set hlsearch       " hilight searches by default

if version >= 730
  set colorcolumn=+1 " mark the ideal max text width (vim 7.3 or greater)
endif


if version >= 730
  " persistent undo configuration (vim 7.3 or greater)
  set undodir=~/.vim/undodir
  set undofile
  set undolevels=1000  " maximum number of changes that can be undoed
  set undoreload=10000 " maximum number lines to save for undo on a buffer reload
endif

" basic ui options
"set visualbell t_vb=
set shm=atIWswxrnmlf " message formats
set ruler
set laststatus=2
set showcmd
set showmode
set mouse=a

" set git branch on statusline
function! GitBranch()
  let branch = system("git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* //'")
  if branch != ''
      return ' Git <' . substitute(branch, '\n', '', 'g') . '> '
  en
  return ''
endfunction

set statusline=%<\ %n:%f\ %m%r%y%=%{GitBranch()}%-35.(line:\ %l\ of\ %L,\ col:\ %c%V\ (%P)%)


set t_Co=256
set background=dark
colorscheme wombat256

" vim behaviour
command! W :w " for mistyping :w as :W

" folding options
set foldmethod=syntax
set foldlevel=1
set foldcolumn=3
let php_folding=1
let javaScript_fold=1
let xml_syntax_folding=1

" php options
let php_sql_query=1
let php_htmlInStrings=1

" directories for .swp files
set directory=~/.vim/swp//,/tmp//
" ignore symfony project data (doc, coverage, etc.)
set wildignore+=**/build/**,vendor/**,**/cache/**,**/tmp/** 
set wildignore+=*.o,*.phar,*.php~
set tags+=tags;/ " search recursively upwards for the tags file

syntax on
filetype on
filetype indent on
filetype plugin on

" mark the lines above 120 columns
highlight OverLength ctermbg=red ctermfg=white gui=undercurl guisp=red
match OverLength /\%121v.\+/

" mark the columns that are close to overlength limit
highlight LineProximity gui=undercurl guisp=orange
let w:m1=matchadd('LineProximity', '\%<121v.\%>115v', -1)


function! UpdateBundles()
  let cmd = "ruby ~/.dotfiles/vim/bin/vim-update-bundles.rb"
  echo "running: ".cmd." this could take a while ..."

  let tmpfile = tempname()
  let cmd = cmd." > ".tmpfile
  call system(cmd)

  let efm_bak = &efm
  set efm=%m
  execute "silent! cgetfile ".tmpfile
  let &efm = efm_bak
  botright copen

  call delete(tmpfile)
endfunction

command! -complete=file UpdateBundles call UpdateBundles()


"----------------------------------------------
" black magic section, handle it with caution
"-----------------------------------------------

" variable name refactoring for local and global scopes
" move te cursor to a variable name and pres gr o gR to apply the refactoring
nnoremap gr gd[{V%:s/<C-R>///gc<left><left><left>
nnoremap gR gD[{V%:s/<C-R>///gc<left><left><left>


"**************************************************************
"                      Bundle plugins                         *
"**************************************************************

" Snipmate
" Bundle: https://github.com/msanders/snipmate.vim.git


" NerdTree
" Bundle: https://github.com/scrooloose/nerdtree.git
map <F1> :NERDTreeToggle<CR>


" SuperTab
" Bundle: https://github.com/ervandew/supertab.git
let g:SuperTabDefaultCompletionType = "context" " SuperTab completion mode
let g:SuperTabContextDefaultCompletionType = "<c-x><c-o>"


" Vim surround
" Bundle: https://github.com/tpope/vim-surround.git


" PHP Syntax (updated to 5.3)
" Bundle: https://github.com/vim-scripts/php.vim--Nicholson.git


" PHP Check syntax
" Bundle: https://github.com/tomtom/checksyntax_vim.git


" Command-T
" Bundle: https://github.com/vim-scripts/Command-T.git
" BundleCommand: cd ruby/command-t; ruby extconf.rb; make
nmap <silent> ,t :CommandT<CR>
nmap <silent> ,b :CommandTBuffer<CR>
let g:CommandTCancelMap=['<ESC>','<C-c>'] " remap the close action to solve konsole terminal problems


" TagBar
" Bundle: git://github.com/majutsushi/tagbar
map <F2> :TagbarToggle<CR>


" Tabular
" Bundle: https://github.com/godlygeek/tabular.git


" Ack, a better grep 
" Bundle: https://github.com/mileszs/ack.vim
let g:ackprg="ack-grep -H --nocolor --nogroup --column"


" Match it
" Bundle: https://github.com/vim-scripts/matchit.zip.git


" Less annoying delimiters - DelimitMate
" Bundle: http://github.com/Raimondi/delimitMate.git
let delimitMate_smart_quotes = 1
let delimitMate_visual_leader = ","


" Lorem ipsum dummy text generator
" Bundle: https://github.com/vim-scripts/loremipsum.git


" Increment
" Bundle: https://github.com/vim-scripts/increment.vim.git


" Zen Coding
" Bundle: http://github.com/mattn/zencoding-vim.git
let g:user_zen_leader_key = '<c-z>'
let g:user_zen_settings = { 'indentation': '  ' }


" Gundo
" Bundle: http://github.com/sjl/gundo.vim.git
nnoremap <F3> :GundoToggle<CR>


"**************************************************************
"                Autocmds and keybindings                     *
"**************************************************************

source ~/.vimrc-keymaps

if has("autocmd")
  source ~/.vimrc-au
endif

