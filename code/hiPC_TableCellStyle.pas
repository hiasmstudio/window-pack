unit hiPC_TableCellStyle;

interface

uses Windows,Kol,Share,Debug,hiDocumentTemplate,hiPrint_Table,PrintController;

type
  THIPC_TableCellStyle = class(TPrintController)
   private
    FFont:HFont;
    FBrush:HBRUSH;
    FPen:HPEN;
    FInit:boolean;
    
    procedure ApplyTo(x,y:integer);
    procedure InitGraph; 
   public
    _prop_Col:integer;
    _prop_Row:integer;
    
    _prop_FontApply:boolean;
    _prop_Font:TFontRec;
    _prop_BgApply:boolean;
    _prop_Background:TColor;
    _prop_Transparent:boolean;
    _prop_BorderApply:boolean;
    _prop_Color:TColor;
    _prop_Style:byte;
    _prop_Size:integer;

    _data_Col:THI_Event;
    _data_Row:THI_Event;
    _data_Object:THI_Event;
    _event_onSetStyle:THI_Event;

    destructor Destroy; override;
    procedure _work_doSetStyle(var _Data:TData; Index:word);
  end;

implementation

procedure THIPC_TableCellStyle.InitGraph;
begin
    if _prop_FontApply then
      begin
         DeleteObject(FFont);
         FFont := CreateFontIndirect(CreateLogFont(_prop_Font));
      end;
    if _prop_BgApply then
      begin
         DeleteObject(FBrush);
         if _prop_Transparent then
            FBrush := GetStockObject(NULL_BRUSH)
         else FBrush := CreateSolidBrush(Color2RGB(_prop_Background));
      end;
    if _prop_BorderApply then
      begin
         DeleteObject(FPen);
         FPen := CreatePen(_prop_Style, _prop_Size, Color2RGB(_prop_Color));
      end;   
end;

destructor THIPC_TableCellStyle.Destroy;
begin
  DeleteObject(FFont);
  DeleteObject(FBrush);
  DeleteObject(FPen);
  inherited;
end;

procedure THIPC_TableCellStyle.ApplyTo;
begin
  with THIPrint_Table(FItem).FTable.CellStyle[x,y]^ do
   begin
     if _prop_FontApply then
       begin      
          Font := FFont;
          FontColor := _prop_Font.Color;
       end; 
     if _prop_BgApply then
        BackColor := FBrush;
     if _prop_BorderApply then
        Pen := FPen;
   end;
end;

procedure THIPC_TableCellStyle._work_doSetStyle;
var col,row,i:integer;
begin
  if FInit = false then begin InitGraph; FInit := true; end;
    
  col := ReadInteger(_Data, _data_Col, _prop_Col);
  row := ReadInteger(_Data, _data_Row, _prop_Row);
  InitItem(_Data);
  if col = -1 then
    for i := 0 to THIPrint_Table(FItem).FTable.HeadCount-1 do
       ApplyTo(i, Row)
  else if row = -1 then
    for i := 0 to THIPrint_Table(FItem).FTable.Rows-1 do
       ApplyTo(Col, i)
  else ApplyTo(Col, Row);
  
  _hi_onEvent(_event_onSetStyle);  
end;

end.
