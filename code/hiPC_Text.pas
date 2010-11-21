unit hiPC_Text;

interface

uses Kol,Share,Debug,hiDocumentTemplate,hiPrint_Text,PrintController;

type
  THIPC_Text = class(TPrintController)
   private
   public
    _data_Text:THI_Event;
    _event_onText:THI_Event;

    procedure _work_doText(var _Data:TData; Index:word);
    procedure _var_CurrentText(var _Data:TData; Index:word);
  end;

implementation

procedure THIPC_Text._work_doText;
var s:string;
begin
  s := ReadString(_Data, _data_Text);
  InitItem(_Data);
  THIPrint_Text(FItem)._prop_Text := s;
  _hi_onEvent(_event_onText);
end;

procedure THIPC_Text._var_CurrentText;
begin
  InitItem;
  dtString(_Data, THIPrint_Text(FItem)._prop_Text);
end;

end.
