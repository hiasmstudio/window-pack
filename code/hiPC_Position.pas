unit hiPC_Position;

interface

uses Kol,Share,Debug,hiDocumentTemplate,PrintController;

type
  THIPC_Position = class(TPrintController)
   private
   public
    _prop_X: integer;
    _prop_Y: integer;    
    _data_Y:THI_Event;
    _data_X:THI_Event;
    _event_onPosition:THI_Event;

    procedure _work_doPosition(var _Data:TData; Index:word);
    procedure _var_CurrentX(var _Data:TData; Index:word);
    procedure _var_CurrentY(var _Data:TData; Index:word);
  end;

implementation

procedure THIPC_Position._work_doPosition;
var x,y:integer;
begin
  x := ReadInteger(_Data, _data_X, _prop_X);
  y := ReadInteger(_Data, _data_Y, _prop_Y);
  InitItem(_Data);
  TDocItem(FItem)._prop_X := x;
  TDocItem(FItem)._prop_Y := y;
  _hi_onEvent(_event_onPosition);
end;

procedure THIPC_Position._var_CurrentX;
begin
  InitItem(_Data);
  dtInteger(_Data, TDocItem(FItem)._prop_X);
end;

procedure THIPC_Position._var_CurrentY;
begin
  InitItem(_Data);
  dtInteger(_Data, TDocItem(FItem)._prop_Y);
end;

end.
