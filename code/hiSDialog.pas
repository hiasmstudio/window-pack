unit hiSDialog;

interface

uses Kol, Share, Debug;

type
  THISDialog = class(TDebug)
    private
      FSaveDialog: POpenSaveDialog;
    public
      _prop_StartDir: string;
      _prop_Filter: string;
      _prop_Title: string;
      _prop_FileName: string;
      
      // By NetSpirit
      _prop_NoChangeDir: Byte;
      _prop_PathMustExists: Byte;
      _prop_OverwritePrompt: Byte;
      
      _event_onExecute: THI_Event;
      _event_onCancel: THI_Event;
      _data_FileName: THI_Event;
      _data_StartDir: THI_Event;

      destructor Destroy; override;
      procedure _work_doExecute(var _Data: TData; Index: Word);
      procedure _work_doStartDir(var _Data: TData; Index: Word);
      procedure _work_doFileName(var _Data: TData; Index: Word);
      procedure _work_doFilter(var _Data: TData; Index: Word);    
  end;

implementation

destructor THISDialog.Destroy;
begin
  FSaveDialog.Free;
  inherited;
end;

procedure THISDialog._work_doExecute;
var
  Opts: TOpenSaveOptions;
begin
  if not Assigned(FSaveDialog) then
  begin
    // By NetSpirit
    Opts := DefOpenSaveDlgOptions;
    if _prop_NoChangeDir = 1 then Opts:= Opts + [OSNoChangedir];
    if _prop_PathMustExists = 0 then Opts := Opts - [OSPathMustExist, OSFileMustExist];
    if _prop_OverwritePrompt = 0 then Opts := Opts - [OSOverwritePrompt];
    FSaveDialog := NewOpenSaveDialog(_prop_Title,_prop_StartDir, Opts);
    
    FSaveDialog.Filter := _prop_Filter;
    FSaveDialog.OpenDialog := False;
    FSaveDialog.WndOwner := ReadHandle;
  end;

  FSaveDialog.FileName := ReadString(_Data, _data_FileName, _prop_FileName);
  if FSaveDialog.Execute then
    _hi_CreateEvent(_Data, @_event_onExecute, FSaveDialog.FileName)
  else
    _hi_CreateEvent(_Data, @_event_onCancel);
end;

procedure THISDialog._work_doStartDir;
begin
  _prop_StartDir := ReadString(_Data, _data_StartDir, '');
  if Assigned(FSaveDialog) then FSaveDialog.InitialDir := _prop_StartDir;
end;

procedure THISDialog._work_doFileName;
begin
  _prop_FileName := ReadString(_Data, _data_FileName, '');
end;

procedure THISDialog._work_doFilter;
begin
  _prop_Filter := ToString(_Data);
end;

end.
