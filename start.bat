@echo off
nasm -fwin32 main.asm && ^
gcc -m32 main.obj -o main.exe && ^
main.exe

del *.obj