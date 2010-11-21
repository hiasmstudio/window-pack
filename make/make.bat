@echo off
echo "make project maker dll for delphi packed"
..\..\..\compiler\delphi\dcc32.exe -U..\..\..\compiler\delphi make_exe.dpr
..\..\..\compiler\delphi\dcc32.exe -U..\..\..\compiler\delphi make_com.dpr
..\..\..\compiler\delphi\dcc32.exe -U..\..\..\compiler\delphi make_console.dpr
..\..\..\compiler\delphi\dcc32.exe -U..\..\..\compiler\delphi make_cpl.dpr
..\..\..\compiler\delphi\dcc32.exe -U..\..\..\compiler\delphi make_dll.dpr
..\..\..\compiler\delphi\dcc32.exe -U..\..\..\compiler\delphi make_hiasm.dpr
..\..\..\compiler\delphi\dcc32.exe -U..\..\..\compiler\delphi make_service.dpr
..\..\..\compiler\delphi\dcc32.exe -U..\..\..\compiler\delphi make_ntsvc.dpr

pause