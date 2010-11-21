unit hiCeDir;

interface

uses Windows,Kol,KOLRapi,Share,Debug;

type
  THICeDir = class(TDebug)
   private
    lpBufferPath: array[0..MAX_PATH - 1] of WideChar; //WideString;
    procedure ReadDirProc(var _Data:TData; const name:Integer);
   public

    procedure _var_WindowsDir(var _Data:TData; Index:word);
    procedure _var_ProgramsDir(var _Data:TData; Index:word);
    procedure _var_StartUpDir(var _Data:TData; Index:word);
    procedure _var_TempDir(var _Data:TData; Index:word);
    procedure _var_StartMenuDir(var _Data:TData; Index:word);
    procedure _var_DesktopDir(var _Data:TData; Index:word);
    procedure _var_FavoritesDir(var _Data:TData; Index:word);
    procedure _var_FontsDir(var _Data:TData; Index:word);
    procedure _var_MyDocumentDir(var _Data:TData; Index:word);
    procedure _var_ApplicationDataDir(var _Data:TData; Index:word);
  end;

implementation

procedure THICeDir.ReadDirProc;
var nBuffLen,nResLen: Integer;
begin
  nBuffLen := sizeof(lpBufferPath);
  nResLen := CeGetSpecialFolderPath(name,nBuffLen,@lpBufferPath);
  //CeGetSpecialFolderPath(name,MAX_PATH,lpBufferPath);
  if nResLen > 0 then
    dtString(_Data,LStrFromPWCharLen(@lpBufferPath,nResLen) + '\')
     else dtNull(_Data);
end;

procedure THICeDir._var_WindowsDir;
begin
   ReadDirProc(_Data,CSIDL_WINDOWS);
end;

procedure THICeDir._var_ProgramsDir;
begin
  ReadDirProc(_Data,CSIDL_PROGRAM_FILES);
end;

procedure THICeDir._var_StartUpDir;
begin
  ReadDirProc(_Data,CSIDL_STARTUP);
end;

procedure THICeDir._var_TempDir;
var nBuffLen,nResLen: Integer;
begin
  nBuffLen := sizeof(lpBufferPath);
  nResLen := CeGetTempPath(nBuffLen,@lpBufferPath);
  if nResLen > 0 then
    dtString(_Data,LStrFromPWCharLen(@lpBufferPath,nResLen))
     else dtNull(_Data);
end;

procedure THICeDir._var_StartMenuDir;
begin
  ReadDirProc(_Data,CSIDL_STARTMENU);
end;

procedure THICeDir._var_DesktopDir;
begin
  ReadDirProc(_Data,CSIDL_DESKTOP);
end;

procedure THICeDir._var_FavoritesDir;
begin
  ReadDirProc(_Data,CSIDL_FAVORITES);
end;

procedure THICeDir._var_FontsDir;
begin
  ReadDirProc(_Data,CSIDL_FONTS);
end;

procedure THICeDir._var_MyDocumentDir;
begin
  ReadDirProc(_Data,CSIDL_PERSONAL);
end;

procedure THICeDir._var_ApplicationDataDir;
begin
  ReadDirProc(_Data,CSIDL_APPDATA);
end;

end.
