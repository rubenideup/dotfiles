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
set nolazyredraw " don't redraw screen while executing macros
set encoding=utf-8

" basic ui options
set visualbell t_vb=
set shm=atIWswxrnmlf " message formats
set ruler
set statusline=%f
set showcmd
set showmode
set mouse=a

set t_Co=256
set background=dark
colorscheme wombat256

" set gui font
if has('gui_running')
  set guifont=Monaco\ 10
endif

" vim behaviour
command! W :w " for mistyping :w as :W

" folding options
set foldmethod=syntax
set foldlevel=1
set foldcolumn=3
let php_folding=1
let javaScript_fold=1
let xml_syntax_folding=1

" directories for .swp files
set directory=~/.vim/swp//,/tmp//
set wildignore+=app/build/**,vendor/**,app/cache/** " ignore symfony project data (doc, coverage, etc.)
set wildignore+=*.o,*.phar,*.php~

syntax on
filetype on
filetype indent on
filetype plugin on

" mark the lines above 120 columns
highlight OverLength ctermbg=red ctermfg=white guibg=#592929
match OverLength /\%121v.\+/

" hack to solve bug in SQL files in ubuntu
let g:omni_sql_no_default_maps = 1


"**************************************************************
"                      Bundle plugins                         *
"**************************************************************

" Snipmate
" --- BUNDLE: https://github.com/msanders/snipmate.vim.git


" NerdTree
" --- BUNDLE: https://github.com/scrooloose/nerdtree.git
map <F1> :NERDTreeToggle<CR>


" SuperTab
" --- BUNDLE: https://github.com/ervandew/supertab.git
let g:SuperTabDefaultCompletionType = "context" " SuperTab completion mode


" Vim surround
" --- BUNDLE: https://github.com/tpope/vim-surround.git


" PHP Syntax (updated to 5.3)
" --- BUNDLE: https://github.com/vim-scripts/php.vim--Nicholson.git


" PHP Check syntax
" --- BUNDLE: https://github.com/tomtom/checksyntax_vim.git


" Command-T
" --- BUNDLE: https://github.com/vim-scripts/Command-T.git
nmap <silent> ,t :CommandT<CR>
nmap <silent> ,b :CommandTBuffer<CR>
let g:CommandTCancelMap=['<ESC>','<C-c>'] " remap the close action to solve konsole terminal problems


" TagBar
" --- BUNDLE: git://github.com/majutsushi/tagbar
map <F2> :TagbarToggle<CR>


" Tabular
" --- BUNDLE: https://github.com/godlygeek/tabular.git


" Ack, a better grep 
" --- BUNDLE: https://github.com/mileszs/ack.vim
let g:ackprg="ack-grep -H --nocolor --nogroup --column"


" Match it
" --- BUNDLE: https://github.com/vim-scripts/matchit.zip.git


" Less annoying delimiters - DelimitMate
" --- BUNDLE: http://github.com/Raimondi/delimitMate.git
let delimitMate_smart_quotes = 1
let delimitMate_visual_leader = ","


"**************************************************************
"                Autocmds and keybindings                     *
"**************************************************************

source ~/.vimrc-keymaps

if has("autocmd")
  source ~/.vimrc-au
endif

