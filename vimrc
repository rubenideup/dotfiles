set nocompatible
set number
set smartindent
set cindent
set autoindent
set expandtab
set tabstop=2
set shiftwidth=2
set noerrorbells
set foldmethod=syntax
set ignorecase
set visualbell t_vb=
set cursorline
syntax on


set t_Co=256
set background=dark
colorscheme wombat256

" set gui font
if has('gui_running')
  set guifont=Monaco\ 10
endif

set mouse=a
filetype indent on
filetype on
filetype plugin on

" mark the lines above 120 columns
highlight OverLength ctermbg=red ctermfg=white guibg=#592929
match OverLength /\%121v.\+/

" remove trailing spaces on save
autocmd BufWritePre *.php :%s/\s\+$//e

" SuperTab completion mode
let g:SuperTabDefaultCompletionType = "context"

" Taglist variables
" Display function name in status bar:
let g:ctags_statusline=1
" Automatically start script
let generate_tags=1
" Various Taglist diplay config:
let Tlist_Use_Right_Window = 1
let Tlist_Compact_Format = 1
let Tlist_Exit_OnlyWindow = 1
let Tlist_GainFocus_On_ToggleOpen = 1
let Tlist_File_Fold_Auto_Close = 1

" custom mappings
map <F1> :NERDTreeToggle<CR>
map <F2> :TlistToggle<CR>
let g:qb_hotkey = "<F3>"
map <F10> :Bclose<CR>
map <F11> :shell<CR>
