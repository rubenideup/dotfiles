" .vimrc config file for C++ projects based on Google C++ Style Guide
" http://google-styleguide.googlecode.com/svn/trunk/cppguide.xml
" just copy this template into your project

set expandtab
set tabstop=2
set shiftwidth=2

" ignore this directories/files
set wildignore+=**/doc/**

" Generate new tags with command
"
" ctags -R --sort=yes --c++-kinds=+p --fields=+iaS --extra=+q --language-force=C++ -f qt4 /usr/include/qt4/
"
" include libraries tags
set tags+=~/.vim/tags/libxml2
set tags+=~/.vim/tags/mysql
set tags+=~/.vim/tags/cpp
set tags+=~/.vim/tags/boost_date_time
set tags+=~/.vim/tags/mysql
