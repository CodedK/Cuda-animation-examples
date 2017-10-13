@echo off
IF EXIST julia_gpu.exp DEL /F julia_gpu.exp
IF EXIST julia_gpu.lib DEL /F julia_gpu.lib
IF EXIST julia_gpu.exe DEL /F julia_gpu.exe
nvcc -Xptxas -O3,-v -o julia_gpu julia_gpu.cu
julia_gpu.exe
pause
IF EXIST julia_gpu.exp DEL /F julia_gpu.exp
IF EXIST julia_gpu.lib DEL /F julia_gpu.lib