unit hiPC_TableSetCell;

interface

uses Kol,Share,Debug,hiDocumentTemplate,hiPrint_Table,PrintController;

type
  THIPC_TableSetCell = class(TPrintController)
   private
   public
    _prop_Col:integer;
    _prop_Row:integer;
    _prop_Text: string;

    _data_Object:THI_Event;
    _data_Row:THI_Event;
    _data_Col:THI_Event;
    _data_Text:THI_Event;
    _event_onText:THI_Event;

    procedure _work_doText(var _Data:TData; Index:word);
    procedure _var_CurrentText(var _Data:TData; Index:word);
    procedure _var_RowCount(var _Data:TData; Index:word);    
    procedure _var_ColCount(var _Data:TData; Index:word);    
  end;

implementation

procedure THIPC_TableSetCell._work_doText;
var t:string;
    x,y:integer;
begin
  t := ReadString(_Data, _data_Text, _prop_Text);
  x := ReadInteger(_Data, _data_Col, _prop_Col);
  y := ReadInteger(_Data, _data_Row, _prop_Row);
  InitItem(_Data);
  THIPrint_Table(FItem).FTable.Cell[x, y] := t;
  _hi_onEvent(_event_onText);
end;

procedure THIPC_TableSetCell._var_CurrentText;
var
    x,y:integer;
begin
  InitItem;
  x := ReadInteger(_Data, _data_Col, _prop_Col);
  y := ReadInteger(_Data, _data_Row, _prop_Row);
  dtString(_Data, THIPrint_Table(FItem).FTable.Cell[x, y]);
end;

procedure THIPC_TableSetCell._var_RowCount(var _Data:TData; Index:word);    
begin
  InitItem;
  dtInteger(_Data, THIPrint_Table(FItem).FTable.Rows);
end;

procedure THIPC_TableSetCell._var_ColCount(var _Data:TData; Index:word);
begin
  InitItem;
  dtInteger(_Data, THIPrint_Table(FItem).FTable.HeadCount);
end;

end.
