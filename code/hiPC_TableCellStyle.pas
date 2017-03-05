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
    HList: PStrListEx;
    
    procedure ApplyTo(x,y:integer);
    procedure InitGraph; 
   public

    _prop_VisibleTableApply: boolean;
    _prop_VisibleTable:      boolean;
    _prop_AlphaBlendApply:   boolean;
    _prop_AlphaBlendValue:   byte; 

    _prop_HeadFontApply:     boolean;
    _prop_HeadFont:          TFontRec;

    _prop_TableApply:        boolean;
    _prop_TableBackColor:    integer;
    _prop_RowHeight:         integer;
    _prop_Spacing:           integer;
    _prop_TBorderColor:      integer;
    _prop_TBorderStyle:      byte;
    _prop_TBorderSize:       integer;
    _prop_TableTrans:        boolean;

    _prop_HeadApply:         boolean;
    _prop_Visible:           boolean;
    _prop_HeadBackColor:     integer;
    _prop_HeadAlign:         byte;
    _prop_HeadTrans:         boolean;

    _prop_Col:               integer;
    _prop_Row:               integer;
    
    _prop_FontApply:         boolean;
    _prop_Font:              TFontRec;
    _prop_BgApply:           boolean;
    _prop_Background:        TColor;
    _prop_Transparent:       boolean;
    _prop_BorderApply:       boolean;
    _prop_Color:             TColor;
    _prop_Style:             byte;
    _prop_Size:              integer;

    _data_Col:THI_Event;
    _data_Row:THI_Event;
    _data_Object:THI_Event;
    _event_onSetStyle:THI_Event;

    constructor Create;
    destructor Destroy; override;

    procedure _work_doSetStyle(var _Data:TData; Index:word);
    procedure _work_doFontApply(var _Data:TData; Index:word);
    procedure _work_doFont(var _Data:TData; Index:word);
    procedure _work_doBgApply(var _Data:TData; Index:word);
    procedure _work_doBackground(var _Data:TData; Index:word);
    procedure _work_doTransparent(var _Data:TData; Index:word);
    procedure _work_doBorderApply(var _Data:TData; Index:word);
    procedure _work_doColor(var _Data:TData; Index:word);
    procedure _work_doStyle(var _Data:TData; Index:word);
    procedure _work_doSize(var _Data:TData; Index:word);                      

    procedure _work_doHeadFontApply(var _Data:TData; Index:word);
    procedure _work_doHeadFont(var _Data:TData; Index:word);

    procedure _work_doTableApply(var _Data:TData; Index:word);
    procedure _work_doTableBackColor(var _Data:TData; Index:word);
    procedure _work_doRowHeight(var _Data:TData; Index:word);
    procedure _work_doSpacing(var _Data:TData; Index:word);
    procedure _work_doTBorderColor(var _Data:TData; Index:word);
    procedure _work_doTBorderStyle(var _Data:TData; Index:word);
    procedure _work_doTBorderSize(var _Data:TData; Index:word);
    procedure _work_doTableTrans(var _Data:TData; Index:word);

    procedure _work_doHeadApply(var _Data:TData; Index:word);
    procedure _work_doVisible(var _Data:TData; Index:word);
    procedure _work_doHeadBackColor(var _Data:TData; Index:word);
    procedure _work_doHeadAlign(var _Data:TData; Index:word);
    procedure _work_doHeadTrans(var _Data:TData; Index:word);

	procedure _work_doAlphaBlendApply(var _Data:TData; Index:word);
	procedure _work_doAlphaBlendValue(var _Data:TData; Index:word);

	procedure _work_doVisibleTableApply(var _Data:TData; Index:word);
	procedure _work_doVisibleTable(var _Data:TData; Index:word);

  end;

implementation

procedure THIPC_TableCellStyle.InitGraph;
begin
  if _prop_FontApply then
  begin
//    DeleteObject(FFont);
    FFont := CreateFontIndirect(CreateLogFont(_prop_Font));
    Hlist.AddObject('', FFont);    
  end;
  if _prop_BgApply then
  begin
//    DeleteObject(FBrush);
    if _prop_Transparent then
      FBrush := GetStockObject(NULL_BRUSH)
    else FBrush := CreateSolidBrush(Color2RGB(_prop_Background));
    Hlist.AddObject('', FBrush);
  end;
  if _prop_BorderApply then
  begin
//    DeleteObject(FPen);
    FPen := CreatePen(_prop_Style, _prop_Size, Color2RGB(_prop_Color));
    Hlist.AddObject('', FPen);
  end;   
end;

constructor THIPC_TableCellStyle.Create;
begin
  HList := NewStrListEx;
end;

destructor THIPC_TableCellStyle.Destroy;
var
  i: integer;
begin
  if HList.Count <> 0 then
    for i := 0 to HList.Count - 1 do
      DeleteObject(HList.Objects[i]);	
//  DeleteObject(FFont);
//  DeleteObject(FBrush);
//  DeleteObject(FPen);
  HList.free;  
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
    
//  InitGraph;

  col := ReadInteger(_Data, _data_Col, _prop_Col);
  row := ReadInteger(_Data, _data_Row, _prop_Row);
  InitItem(_Data);

  if _prop_TableApply then
  begin
    THIPrint_Table(FItem)._prop_TableBackColor := _prop_TableBackColor;
    THIPrint_Table(FItem)._prop_RowHeight      := _prop_RowHeight;
    THIPrint_Table(FItem)._prop_Spacing        := _prop_Spacing;
    THIPrint_Table(FItem)._prop_TBorderColor   := _prop_TBorderColor;
    THIPrint_Table(FItem)._prop_TBorderStyle   := _prop_TBorderStyle;
    THIPrint_Table(FItem)._prop_TBorderSize    := _prop_TBorderSize;
    THIPrint_Table(FItem)._prop_TableTrans     := _prop_TableTrans;
  end;  

  if _prop_HeadFontApply then
    THIPrint_Table(FItem)._prop_HeadFont := _prop_HeadFont;
  if _prop_HeadApply then
  begin
   THIPrint_Table(FItem)._prop_Visible       := _prop_Visible;
   THIPrint_Table(FItem)._prop_HeadBackColor := _prop_HeadBackColor;
   THIPrint_Table(FItem)._prop_HeadAlign     := _prop_HeadAlign;
   THIPrint_Table(FItem)._prop_HeadTrans     := _prop_HeadTrans; 
  end;  

  if _prop_VisibleTableApply then
    THIPrint_Table(FItem)._prop_VisibleTable := _prop_VisibleTable;
  if _prop_AlphaBlendApply then
    THIPrint_Table(FItem)._prop_AlphaBlendValue := _prop_AlphaBlendValue;

  if col = -1 then
    for i := 0 to THIPrint_Table(FItem).FTable.HeadCount-1 do
       ApplyTo(i, Row)
  else if row = -1 then
    for i := 0 to THIPrint_Table(FItem).FTable.Rows-1 do
       ApplyTo(Col, i)
  else ApplyTo(Col, Row);
  
  _hi_onEvent(_event_onSetStyle);  
end;

procedure THIPC_TableCellStyle._work_doFontApply;
begin
  _prop_FontApply := ReadBool(_Data);
end;

procedure THIPC_TableCellStyle._work_doFont;
begin
  if _IsFont(_Data) then
  begin
    with pfontrec(_Data.idata)^ do
    begin
      _prop_Font.Color := Color;
      _prop_Font.Style := Style;
      _prop_Font.Name :=  Name;
      _prop_Font.Size := Size;
      _prop_Font.Charset := CharSet;
    end;
  FInit := false;
//    if _prop_FontApply then
//    begin    
//      DeleteObject(FFont);
//      FFont := CreateFontIndirect(CreateLogFont(_prop_Font));
//    end;     
  end;
end;  

procedure THIPC_TableCellStyle._work_doBgApply;
begin
  _prop_BgApply := ReadBool(_Data);
end;

procedure THIPC_TableCellStyle._work_doBackground;
begin
  _prop_Background := ToInteger(_Data);
  FInit := false;  
end;

procedure THIPC_TableCellStyle._work_doTransparent;
begin
  _prop_Transparent := ReadBool(_Data);
end;

procedure THIPC_TableCellStyle._work_doBorderApply;
begin
  _prop_BorderApply := ReadBool(_Data);
end;

procedure THIPC_TableCellStyle._work_doColor;
begin
  _prop_Color := ToInteger(_Data);
  FInit := false;  
end;

procedure THIPC_TableCellStyle._work_doStyle;
begin
  _prop_Style := ToInteger(_Data);
  FInit := false;  
end;

procedure THIPC_TableCellStyle._work_doSize;                      
begin
  _prop_Size := ToInteger(_Data);
  FInit := false;  
end;

procedure THIPC_TableCellStyle._work_doAlphaBlendApply;
begin
  _prop_AlphaBlendApply := ReadBool(_Data);
end;

procedure THIPC_TableCellStyle._work_doAlphaBlendValue;
begin
  _prop_AlphaBlendValue := ToInteger(_Data);
end;

procedure THIPC_TableCellStyle._work_doVisibleTableApply;
begin
  _prop_VisibleTableApply := ReadBool(_Data);
end;

procedure THIPC_TableCellStyle._work_doVisibleTable;
begin
  _prop_VisibleTable := ReadBool(_Data);
end;

procedure THIPC_TableCellStyle._work_doHeadFontApply;
begin
  _prop_HeadFontApply := ReadBool(_Data);
end;

procedure THIPC_TableCellStyle._work_doHeadFont;
begin
  if _IsFont(_Data) then
  begin
    with pfontrec(_Data.idata)^ do
    begin
      _prop_HeadFont.Color := Color;
      _prop_HeadFont.Style := Style;
      _prop_HeadFont.Name :=  Name;
      _prop_HeadFont.Size := Size;
      _prop_HeadFont.Charset := CharSet;
    end;
  end;
end;

procedure THIPC_TableCellStyle._work_doHeadApply;
begin
  _prop_HeadApply := ReadBool(_Data);
end;

procedure THIPC_TableCellStyle._work_doVisible;
begin
  _prop_Visible := ReadBool(_Data);
end;

procedure THIPC_TableCellStyle._work_doHeadBackColor;
begin
  _prop_HeadBackColor := ToInteger(_Data);
end;

procedure THIPC_TableCellStyle._work_doHeadAlign;
begin
  _prop_HeadAlign := ToInteger(_Data);
end;

procedure THIPC_TableCellStyle._work_doHeadTrans;
begin
  _prop_HeadTrans := ReadBool(_Data);
end;

procedure THIPC_TableCellStyle._work_doTableApply;
begin
  _prop_TableApply := ReadBool(_Data);
end;

procedure THIPC_TableCellStyle._work_doTableBackColor;
begin
  _prop_TableBackColor := ToInteger(_Data);
end;

procedure THIPC_TableCellStyle._work_doRowHeight;
begin
  _prop_RowHeight := ToInteger(_Data);
end;

procedure THIPC_TableCellStyle._work_doSpacing;
begin
  _prop_Spacing := ToInteger(_Data);
end;

procedure THIPC_TableCellStyle._work_doTBorderColor;
begin
  _prop_TBorderColor := ToInteger(_Data);
end;

procedure THIPC_TableCellStyle._work_doTBorderStyle;
begin
  _prop_TBorderStyle := ToInteger(_Data);
end;

procedure THIPC_TableCellStyle._work_doTBorderSize;
begin
  _prop_TBorderSize := ToInteger(_Data);
end;

procedure THIPC_TableCellStyle._work_doTableTrans;
begin
  _prop_TableTrans := ReadBool(_Data);
end;



end.