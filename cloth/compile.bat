@echo off
IF EXIST cloth.exp DEL /F cloth.exp
IF EXIST cloth.lib DEL /F cloth.lib
IF EXIST cloth.exe DEL /F cloth.exe
#nvcc -Xptxas -O3,-v -o cloth cloth.cu
nvcc -Xptxas -O3,-v -o cloth cloth.cu
cloth.exe
pause
IF EXIST cloth.exp DEL /F cloth.exp
IF EXIST cloth.lib DEL /F cloth.lib