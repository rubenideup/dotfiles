#!/bin/bash

mkdir -p ~/.vim/tags && cd ~/.vim/tags
echo "Generating Qt4 tags ..."
ctags -R --sort=yes --c++-kinds=+p --fields=+iaS --extra=+q --language-force=C++ -f qt4 /usr/include/qt4

echo "Generating OpenGL tags ..."
ctags -R --sort=yes --c++-kinds=+p --fields=+iaS --extra=+q --language-force=C++ -f gl /usr/include/GL

echo "Generating MySQL C++ Connector tags ..."
ctags -R --sort=yes --c++-kinds=+p --fields=+iaS --extra=+q --language-force=C++ -f mysql /usr/include/mysql*

echo "Generating LibXml2 tags ..."
ctags -R --sort=yes --c++-kinds=+p --fields=+iaS --extra=+q --language-force=C++ -f libxml2 /usr/include/libxml2

echo "Generating Boost::date_time tags ..."
ctags -R --sort=yes --c++-kinds=+p --fields=+iaS --extra=+q --language-force=C++ -f boost_date_time /usr/include/boost/date_time*

echo "Generating C++ STL tags ..."
ctags -R --sort=yes --c++-kinds=+p --fields=+iaS --extra=+q --language-force=C++ -f cpp /usr/include/c++
