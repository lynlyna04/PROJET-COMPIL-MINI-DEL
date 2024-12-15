flex lexy.l
bison -d synta.y
gcc lex.yy.c synta.tab.c -o pro.exe -lfl -ly
