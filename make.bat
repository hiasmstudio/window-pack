@echo off
echo "make codegen dll for Delphi packed"
..\..\compiler\delphi\dcc32.exe -U..\..\compiler\delphi CodeGen.dpr
copy ..\FTCG\CodeGen.dpr FTCG_CodeGen.dpr
copy ..\FTCG\errors.pas errors.pas
..\..\compiler\delphi\dcc32.exe -U..\..\compiler\delphi FTCG_CodeGen.dpr
pause