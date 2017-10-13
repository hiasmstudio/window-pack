unit hiODialog;

interface

uses Kol, Share, Debug;

type
  THIODialog = class(TDebug)
    private
      FOpenDialog: POpenSaveDialog;
    public
      _prop_StartDir: string;
      _prop_Filter: string;
      _prop_Title: string;
      _prop_FileName: string;
      _prop_Select: Byte;
      
      // By NetSpirit
      _prop_NoChangeDir: Byte;
      _prop_FileMustExists: Byte;
      
      _event_onExecute: THI_Event;
      _event_onCancel: THI_Event;
      _data_FileName: THI_Event;
      _data_StartDir: THI_Event;

      destructor Destroy; override;
      procedure _work_doExecute0(var _Data: TData; Index: Word);
      procedure _work_doExecute1(var _Data: TData; Index: Word);
      procedure _work_doStartDir(var _Data: TData; Index: Word);
      procedure _work_doFileName(var _Data: TData; Index: Word);
      procedure _work_doFilter(var _Data: TData; Index: Word);
  end;

implementation

destructor THIODialog.Destroy;
begin
  FOpenDialog.Free;
  inherited;
end;

procedure THIODialog._work_doExecute0;
var
  Opts: TOpenSaveOptions;
begin
  if not Assigned(FOpenDialog) then
  begin
    // By NetSpirit
    Opts := DefOpenSaveDlgOptions;
    if _prop_NoChangeDir = 1 then Opts := Opts + [OSNoChangedir];
    if _prop_FileMustExists = 0 then Opts := Opts - [OSFileMustExist];
    FOpenDialog := NewOpenSaveDialog(_prop_Title, _prop_StartDir, Opts);
    
    FOpenDialog.WndOwner := ReadHandle;
    FOpenDialog.Filter := _prop_Filter;
  end;

  FOpenDialog.Filename := ReadString(_Data, _data_FileName, _prop_FileName);
  if FOpenDialog.Execute then
    _hi_CreateEvent(_Data, @_event_onExecute, FOpenDialog.Filename)
  else
    _hi_CreateEvent(_Data, @_event_onCancel);
end;

procedure THIODialog._work_doExecute1;
var
  Lst: PStrList;
  I: Word;
  S: string;
  Opts: TOpenSaveOptions;
begin
  if not Assigned(FOpenDialog) then
  begin
    // By NetSpirit
    Opts := DefOpenSaveDlgOptions + [OSAllowMultiSelect];
    if _prop_NoChangeDir = 1 then Opts := Opts + [OSNoChangedir];
    if _prop_FileMustExists = 0 then Opts := Opts - [OSFileMustExist];
    FOpenDialog := NewOpenSaveDialog(_prop_Title, _prop_StartDir, Opts);
    
    FOpenDialog.WndOwner := ReadHandle;
    FOpenDialog.Filter := _prop_Filter;
  end;

  FOpenDialog.FileName := ReadString(_Data, _data_FileName, _prop_FileName);
  
  if FOpenDialog.Execute then
  begin
    Lst := NewStrList;
    Lst.Text := FOpenDialog.FileName;
    if Lst.Count > 0 then
      S := Lst.Items[0];
    if Lst.Count = 1 then
      _hi_CreateEvent(_Data, @_event_onExecute, S)
    else
    begin
      S := S + '\';
      for I := 1 to Lst.Count - 1 do
        _hi_OnEvent(_event_onExecute, S + Lst.Items[I]);
      FOpenDialog.FileName := '';
    end;
    Lst.Free;
  end
  else
    _hi_CreateEvent(_Data, @_event_onCancel);
end;

procedure THIODialog._work_doStartDir;
begin
  _prop_StartDir := ReadString(_Data, _data_StartDir, '');
  if Assigned(FOpenDialog) then FOpenDialog.InitialDir := _prop_StartDir;
end;

procedure THIODialog._work_doFileName;
begin
  _prop_FileName := ReadString(_Data, _data_FileName, '');
end;

procedure THIODialog._work_doFilter;
begin
  _prop_Filter := ToString(_Data);
end;

end.
