" init patogen system
call pathogen#runtime_append_all_bundles()
call pathogen#helptags()

set nocompatible
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
set nolazyredraw " don't redraw screen while executing macros

" basic ui options
set visualbell t_vb=
set shm=atIWswxrnmlf " message formats
set ruler
set statusline=%f
set showcmd
set showmode

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

" view special characters
autocmd filetype xhtml,html,xml,php,yaml,htmltwig set list

" apply special syntax colors
autocmd BufRead *.twig set filetype=htmltwig

autocmd filetype xhtml,html,xml set listchars=tab:▸\ 
autocmd filetype php,yaml,htmltwig set listchars=tab:▸\ ,eol:¬

" directories for .swp files
set directory=~/.vim/swp//,/tmp//

" set gui font
if has('gui_running')
  set guifont=Monaco\ 10
endif

set mouse=a
syntax on
filetype on
filetype indent on
filetype plugin on

" mark the lines above 120 columns
highlight OverLength ctermbg=red ctermfg=white guibg=#592929
match OverLength /\%121v.\+/

" remove trailing spaces on save
autocmd BufWritePre *.php,*.sql,*.xml,*.twig,*.c,*.cpp,*.h,*.hpp :%s/\s\+$//e

" SuperTab completion mode
let g:SuperTabDefaultCompletionType = "context"

" hack to solve bug in SQL files in ubuntu
let g:omni_sql_no_default_maps = 1

" ack plugin configuration
let g:ackprg="ack-grep -H --nocolor --nogroup --column"

" custom mappings
map <F1> :NERDTreeToggle<CR>
map <F2> :TagbarToggle<CR>
map <F10> :Bclose<CR>
map <F11> :shell<CR>
map <C-Left> <ESC>:bprev!<CR>
map <C-Right> <ESC>:bnext!<CR>

nmap <silent> ,t :CommandT<CR>
nmap <silent> ,b :CommandTBuffer<CR>
let g:CommandTCancelMap=['<ESC>','<C-c>'] " remap the close action to solve konsole terminal problems
