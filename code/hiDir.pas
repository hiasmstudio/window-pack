unit hiDir;

interface

uses Windows,Kol,Share,Debug;

type
  THIDir = class(TDebug)
   private
   public
    _data_Dir,
    _event_onError,
    _event_onEnd:THI_Event;

    procedure _work_doDir(var _Data:TData; Index:word);
    procedure _work_doCurrentDir(var _Data:TData; Index:word);
    procedure _var_CurrentDir(var _Data:TData; Index:word);
    procedure _var_WindowsDir(var _Data:TData; Index:word);
    procedure _var_TempDir(var _Data:TData; Index:word);
    procedure _var_ProgramsDir(var _Data:TData; Index:word);
    procedure _var_StartUpDir(var _Data:TData; Index:word);
    procedure _var_StartMenuDir(var _Data:TData; Index:word);
    procedure _var_DesktopDir(var _Data:TData; Index:word);
    procedure _var_FavoritesDir(var _Data:TData; Index:word);
    procedure _var_FontsDir(var _Data:TData; Index:word);
    procedure _var_HistoryDir(var _Data:TData; Index:word);
    procedure _var_MyDocumentDir(var _Data:TData; Index:word);
    procedure _var_SendToDir(var _Data:TData; Index:word);
  end;

implementation

procedure THIDir._work_doDir;
begin
   if ForceDirectories(ReadString(_Data, _data_Dir)) then
     _hi_CreateEvent(_Data,@_event_onEnd)
   else
     _hi_CreateEvent(_Data,@_event_onError);
end;

procedure THIDir._work_doCurrentDir;
begin
   SetCurrentDirectory(PChar(ReadString(_Data, _data_Dir)));
   _hi_CreateEvent(_Data,@_event_onEnd);
end;

procedure THIDir._var_CurrentDir;
begin
   dtString(_Data,GetStartDir);//_Data.sdata + '\';
end;

procedure THIDir._var_WindowsDir;
begin
   dtString(_Data,GetWindowsDir);
end;

procedure THIDir._var_TempDir;
begin
   dtString(_Data,GetTempDir);
end;

procedure ReadDirKey(var _Data:TData; const name:string);
var
  reg:HKey;
begin
  reg:=RegKeyOpenRead(HKEY_CURRENT_USER,'Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders');
  dtString(_Data,RegKeyGetStr(reg,Name) + '\');
  RegKeyClose(reg);
end;

procedure THIDir._var_ProgramsDir;
begin
  ReadDirKey(_Data,'Programs');
end;

procedure THIDir._var_StartUpDir;
begin
  ReadDirKey(_Data,'Startup');
end;

procedure THIDir._var_StartMenuDir;
begin
  ReadDirKey(_Data,'Start Menu');
end;

procedure THIDir._var_DesktopDir;
begin
  ReadDirKey(_Data,'Desktop');
end;

procedure THIDir._var_FavoritesDir;
begin
  ReadDirKey(_Data,'Favorites');
end;

procedure THIDir._var_FontsDir;
begin
  ReadDirKey(_Data,'Fonts');
end;

procedure THIDir._var_HistoryDir;
begin
  ReadDirKey(_Data,'History');
end;

procedure THIDir._var_MyDocumentDir;
begin
  ReadDirKey(_Data,'Personal');
end;

procedure THIDir._var_SendToDir;
begin
  ReadDirKey(_Data,'SendTo');
end;

end.
