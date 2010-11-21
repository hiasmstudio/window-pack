unit hiShortcut;

interface

uses Windows,Kol,Share,Debug,shortcut;

type
  THIShortCut = class(TDebug)
   private
     Name,
     workdir,
     descr,
     Args,
     IcoPath: string;
     IcoIND: integer;
   public
    _prop_FileName:string;
    _prop_ShortcutName:string;
    _prop_WorkingDirectory:string;
    _prop_Description:string;
    _prop_Icon:string;
    _prop_Arguments:string;

    _event_onCreate:THI_Event;
    _event_onRead:THI_Event;

    _data_FileName:THI_Event;
    _data_ShortcutName:THI_Event;
    _data_WorkingDirectory:THI_Event;
    _data_Description:THI_Event;
    _data_Icon:THI_Event;
    _data_Arguments:THI_Event;

    procedure _work_doCreate(var _Data:TData; Index:word);
    procedure _work_doRead(var _Data:TData; Index:word);

    procedure _var_RFileName(var _Data:TData; Index:word);
    procedure _var_RWorkingDirectory(var _Data:TData; Index:word);
    procedure _var_RDescription(var _Data:TData; Index:word);
    procedure _var_RIcon(var _Data:TData; Index:word);
    procedure _var_RArguments(var _Data:TData; Index:word);
    procedure _var_RIconID(var _Data:TData; Index:word);    
  end;

implementation

procedure THIShortCut._work_doCreate;
begin
  CreateLink( PChar(ReadString(_Data,_data_FileName,_prop_FileName)),
              PChar(ReadString(_Data,_data_ShortcutName,_prop_ShortcutName)),
              PChar(ReadString(_Data,_data_WorkingDirectory,_prop_WorkingDirectory)),
              PChar(ReadString(_Data,_data_Description,_prop_Description)),
              PChar(ReadString(_Data,_data_Arguments,_prop_Arguments)),
              PChar(ReadString(_Data,_data_Icon,_prop_Icon)));
  _hi_onEvent(_event_onCreate);
end;

procedure THIShortCut._work_doRead;
var
  fn: string;
  dn, dw, dd, da, dp, di: TData;
begin
  fn := ReadString(_Data,_data_ShortcutName,_prop_ShortcutName);
  Name := '';
  workdir := '';
  descr := '';
  args := '';
  IcoPath := '';
  IcoIND := 0;
  dtNull(dn);
  if FileExists(fn) and (ExtractFileExt(fn) = '.lnk') then
  begin 
    ReadLink(fn, Name, workdir, descr, args, IcoPath, IcoIND);
    dtString(dn, Name);
    dtString(dw, workdir);
    dtString(dd, descr);
    dtString(da, args);
    dtString(dp, IcoPath);
    dtInteger(di, IcoIND);
    dn.ldata := @dw;
    dw.ldata := @dd;
    dd.ldata := @da;
    da.ldata := @dp;
    dp.ldata := @di;
  end;  
  _hi_onEvent_(_event_onRead, dn);
end;  

procedure THIShortCut._var_RFileName;
begin
  dtString(_Data, Name);
end;

procedure THIShortCut._var_RWorkingDirectory;
begin
  dtString(_Data, workdir);
end;

procedure THIShortCut._var_RDescription;
begin
  dtString(_Data, descr);
end;

procedure THIShortCut._var_RIcon;
begin
  dtString(_Data, IcoPath);
end;

procedure THIShortCut._var_RArguments;
begin
  dtString(_Data, Args);
end;

procedure THIShortCut._var_RIconID;
begin
  dtInteger(_Data, IcoIND);
end;

end.
