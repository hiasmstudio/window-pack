unit hiSDialog;

interface

uses Kol,Share,Debug;

type
  THISDialog = class(TDebug)
   private
    FSaveDialog:POpenSaveDialog;
   public
    _prop_StartDir:string;
    _prop_Filter:string;
    _prop_Title:string;
    _prop_FileName:string;
    _event_onExecute:THI_Event;
    _event_onCancel:THI_Event;
    _data_FileName:THI_Event;
    _data_StartDir:THI_Event;

    destructor Destroy; override;
    procedure _work_doExecute(var _Data:TData; Index:word);
    procedure _work_doStartDir(var _Data:TData; Index:word);
    procedure _work_doFileName(var _Data:TData; Index:word);
    procedure _work_doFilter(var _Data:TData; Index:word);    
  end;

implementation

destructor THISDialog.Destroy;
begin
  FSaveDialog.Free;
  inherited;
end;

procedure THISDialog._work_doExecute;
begin
  if not Assigned(FSaveDialog) then
   begin
    FSaveDialog := NewOpenSaveDialog(_prop_Title,_prop_StartDir,[]);
    FSaveDialog.Filter := _prop_Filter;
    FSaveDialog.OpenDialog := false;
    FSaveDialog.WndOwner := ReadHandle;
   end;

  FSaveDialog.Filename := ReadString(_Data,_data_FileName,_prop_FileName);
  if FSaveDialog.Execute then
    _hi_CreateEvent(_Data,@_event_onExecute,FSaveDialog.filename)
  else _hi_CreateEvent(_Data,@_event_onCancel);
end;

procedure THISDialog._work_doStartDir;
begin
  _prop_StartDir := ReadString(_Data,_data_StartDir,'');
  if Assigned(FSaveDialog) then FSaveDialog.InitialDir := _prop_StartDir;
end;

procedure THISDialog._work_doFileName;
begin
  _prop_FileName := ReadString(_Data,_data_FileName,'');
end;

procedure THISDialog._work_doFilter;
begin
  _prop_Filter := ToString(_Data);
end;

end.
