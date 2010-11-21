library MySLib;
{$mode objfpc}{$H+}
uses Windows,Kol;

//----------------============----------------
//       Remote DLL calling demo
//       Example for using with HiAsm
//       Must be compiled with FPC [arm]
//----------------============----------------

type
IRAPIStream = record
  f1: DWORD;
  f2: DWORD;
end;
pIRAPIStream = ^IRAPIStream;

function testme(cbInput: DWORD; pInput: Pointer; var pcbOutput: DWORD; var ppOutput: Pointer;
   mppIRAPIStream: pIRAPIStream): Integer; export; stdcall;
var str:String;
begin
  MessageBox(0, StringToOleStr(PChar(pInput)), 'Message from Example', 0);
  str := 'abs‡·‚';
  pcbOutput := length(str) + 1;
  ppOutput := PChar(str);
  Result := 555;
end;

exports testme;

begin
end.
