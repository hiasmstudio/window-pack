unit hiODialog;

interface

uses Kol,Share,Debug;

type
  THIODialog = class(TDebug)
   private
    FOpenDialog:POpenSaveDialog;
   public
    _prop_StartDir:string;
    _prop_Filter:string;
    _prop_Title:string;
    _prop_FileName:string;
    _prop_Select:byte;
    _event_onExecute:THI_Event;
    _event_onCancel:THI_Event;
    _data_FileName:THI_Event;
    _data_StartDir:THI_Event;

    destructor Destroy; override;
    procedure _work_doExecute0(var _Data:TData; Index:word);
    procedure _work_doExecute1(var _Data:TData; Index:word);
    procedure _work_doStartDir(var _Data:TData; Index:word);
    procedure _work_doFileName(var _Data:TData; Index:word);
  end;

implementation

destructor THIODialog.Destroy;
begin
  FOpenDialog.Free;
  inherited;
end;

procedure THIODialog._work_doExecute0;
begin
  if not Assigned(FOpenDialog) then
   begin
    FOpenDialog := NewOpenSaveDialog(_prop_Title,_prop_StartDir,[OSNoValidate]);
    FOpenDialog.WndOwner := ReadHandle;
    FOpenDialog.Filter := _prop_Filter;
   end;

  FOpenDialog.Filename := ReadString(_Data,_data_FileName,_prop_FileName);
  if FOpenDialog.Execute then
    _hi_CreateEvent(_Data,@_event_onExecute,FOpenDialog.Filename)
  else _hi_CreateEvent(_Data,@_event_onCancel);
end;

procedure THIODialog._work_doExecute1;
var
  lst:PStrList;
  i:word;
  s:string;
begin
  if not Assigned(FOpenDialog) then
    begin
      FOpenDialog := NewOpenSaveDialog(_prop_Title,_prop_StartDir,[OSAllowMultiSelect,OSNoValidate]);
      FOpenDialog.WndOwner := ReadHandle;
      FOpenDialog.Filter := _prop_Filter;
    end;

  FOpenDialog.Filename := ReadString(_Data,_data_FileName,_prop_FileName);
  if FOpenDialog.Execute then
   begin
    lst := NewStrList;
    lst.Text := FOpenDialog.filename;
    if lst.Count > 0 then
      s := lst.items[0];
    if lst.Count = 1 then
      _hi_CreateEvent(_Data,@_event_onExecute,s)
    else
     begin
      s := s + '\';
      for i := 1 to lst.Count-1 do
        _hi_OnEvent(_event_onExecute, s + lst.items[i]);
      FOpenDialog.Filename := '';
     end;
    lst.Free;
   end
  else _hi_CreateEvent(_Data,@_event_onCancel);
end;

procedure THIODialog._work_doStartDir;
begin
  _prop_StartDir := ReadString(_Data,_data_StartDir,'');
  if Assigned(FOpenDialog) then FOpenDialog.InitialDir := _prop_StartDir;
end;

procedure THIODialog._work_doFileName;
begin
  _prop_FileName := ReadString(_Data,_data_FileName,'');
end;

end.
