unit hiPC_Size;

interface

uses Kol,Share,Debug,hiDocumentTemplate,PrintController;

type
  THIPC_Size = class(TPrintController)
   private
   public
    _prop_Width:integer;
    _prop_Height:integer;

    _data_Height:THI_Event;
    _data_Width:THI_Event;
    _event_onSize:THI_Event;

    procedure _work_doSize(var _Data:TData; Index:word);
    procedure _var_CurrentWidth(var _Data:TData; Index:word);
    procedure _var_CurrentHeight(var _Data:TData; Index:word);
  end;

implementation

procedure THIPC_Size._work_doSize;
var w,h:integer;
begin
  w := ReadInteger(_Data, _data_Width, _prop_Width);
  h := ReadInteger(_Data, _data_Height, _prop_Height);
  InitItem(_Data);
  TDocItem(FItem)._prop_Width := w;
  TDocItem(FItem)._prop_Height := h;
  _hi_onEvent(_event_onSize);
end;

procedure THIPC_Size._var_CurrentWidth;
begin
  InitItem(_Data);
  dtInteger(_Data, TDocItem(FItem)._prop_Width);
end;

procedure THIPC_Size._var_CurrentHeight;
begin
  InitItem(_Data);
  dtInteger(_Data, TDocItem(FItem)._prop_Height);
end;

end.
