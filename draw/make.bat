@echo off
echo "make project maker dll for delphi packed"
..\..\..\compiler\delphi\dcc32.exe -U..\..\..\compiler\delphi LedLadder.dpr
..\..\..\compiler\delphi\dcc32.exe -U..\..\..\compiler\delphi LedNumber.dpr
..\..\..\compiler\delphi\dcc32.exe -U..\..\..\compiler\delphi GProgressBar.dpr
..\..\..\compiler\delphi\dcc32.exe -U..\..\..\compiler\delphi Grapher.dpr
..\..\..\compiler\delphi\dcc32.exe -U..\..\..\compiler\delphi ImgBtn.dpr
..\..\..\compiler\delphi\dcc32.exe -U..\..\..\compiler\delphi LED.dpr
..\..\..\compiler\delphi\dcc32.exe -U..\..\..\compiler\delphi VisualShape.dpr
..\..\..\compiler\delphi\dcc32.exe -U..\..\..\compiler\delphi LayoutSpacer.dpr
pause