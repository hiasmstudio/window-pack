unit hiPC_TableRow;

interface

uses Kol,Share,Debug,hiDocumentTemplate,hiPrint_Table,PrintController;

type
  THIPC_TableRow = class(TPrintController)
   private
    FRow:integer; 
   public
    _data_Index:THI_Event;
    _data_Object:THI_Event;
    _event_onAddRow:THI_Event;

    procedure _work_doAddRow(var _Data:TData; Index:word);
    procedure _work_doRemoveRow(var _Data:TData; Index:word);
    procedure _var_Row(var _Data:TData; Index:word);
  end;

implementation

procedure THIPC_TableRow._work_doAddRow;
begin
  InitItem(_Data);
  FRow := THIPrint_Table(FItem).FTable.AddRow; 
  _hi_onEvent(_event_onAddRow, FRow);
end;

procedure THIPC_TableRow._work_doRemoveRow;
begin
  InitItem(_Data);
  THIPrint_Table(FItem).FTable.RemoveRow(ReadInteger(_Data, _data_Index));
end;

procedure THIPC_TableRow._var_Row;
begin
  dtInteger(_Data, FRow);
end;

end.
