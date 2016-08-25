unit hiPrint_Table;

interface

uses Windows,Kol,Share,Debug,DrawControls,hiDocumentTemplate,Img_Draw;

type
  THIPrint_Table = class(TDocItem)
   private
	FPadding: TRect;
    
    procedure SetTableBackColor(Value:TColor);    
    procedure SetRowHeight(Value:integer);    
    procedure SetSpacing(Value:integer);
    procedure SetTBorderColor(Value:TColor);
    procedure SetTBorderStyle(Value:byte);
    procedure SetTBorderSize(Value:integer);
    procedure SetTableTrans(Value:boolean);

    procedure SetColumns(Value:string);
    procedure SetHeadFont(Value:TFontRec);
    procedure SetVisible(Value:boolean);
    procedure SetHeadBackColor(Value:TColor);
    procedure SetHeadAlign(Value:byte);
    procedure SetHeadTrans(Value:boolean);

    procedure SetCellFont(Value:TFontRec);
    procedure SetCells(Value:string);
    procedure SetCellBackColor(Value:TColor);
    procedure SetCBorderColor(Value:TColor);
    procedure SetCBorderStyle(Value:byte);
    procedure SetCBorderSize(Value:integer);	
    procedure SetCellTrans(Value:boolean);
    procedure SetLeft(Value:integer);
    procedure SetTop(Value:integer);
    procedure SetRight(Value:integer);
    procedure SetBottom(Value:integer);

    procedure SetAlphaBlend(Value:byte); 	    
   public
    FTable:TDrawTable;

	_prop_VisibleTable: boolean;

    constructor Create;
    destructor Destroy; override;
    procedure Draw(dc:HDC; x,y:integer; const Scale:TScale; alpha: boolean=false); override;    

    property _prop_TableBackColor:TColor write SetTableBackColor;    
    property _prop_RowHeight:integer write SetRowHeight;    
    property _prop_Spacing:integer write SetSpacing;
    property _prop_TBorderColor:TColor write SetTBorderColor;
    property _prop_TBorderStyle:byte write SetTBorderStyle;
    property _prop_TBorderSize:integer write SetTBorderSize;
    property _prop_TableTrans:boolean write SetTableTrans;
    
    property _prop_Columns:string write SetColumns;
    property _prop_HeadFont:TFontRec write SetHeadFont;
    property _prop_Visible:boolean write SetVisible;
    property _prop_HeadBackColor:TColor write SetHeadBackColor;
    property _prop_HeadAlign:byte write SetHeadAlign;
    property _prop_HeadTrans:boolean write SetHeadTrans;

    property _prop_CellFont:TFontRec write SetCellFont;
    property _prop_Cells:string write SetCells;
    property _prop_CellBackColor:TColor write SetCellBackColor;
    property _prop_CBorderColor:TColor write SetCBorderColor;
    property _prop_CBorderStyle:byte write SetCBorderStyle;
    property _prop_CBorderSize:integer write SetCBorderSize;	
    property _prop_CellTrans:boolean write SetCellTrans;
    property _prop_Left:integer write SetLeft;
    property _prop_Top:integer write SetTop;
    property _prop_Right:integer write SetRight;
    property _prop_Bottom:integer write SetBottom;			    

    property _prop_AlphaBlendValue:byte write SetAlphaBlend;
  end;

function CreateLogFont(const FFont:TFontRec):LOGFONT;

implementation

const
      HAl:array[0..2] of byte = (DT_LEFT,DT_CENTER,DT_RIGHT);

function CreateLogFont(const FFont:TFontRec):LOGFONT;
begin
   FillChar(Result, sizeof(Result), 0);

   Result.lfHeight := FFont.Size + 6;
   Result.lfWidth := FFont.Size div 2 + 1;
   if FFont.Style and 1 > 0 then Result.lfWeight := FW_BOLD else Result.lfWeight := fw_NORMAL;
   Result.lfItalic := byte(FFont.Style and 2);
   Result.lfUnderline := byte(FFont.Style and 4);
   Result.lfStrikeOut := byte(FFont.Style and 8);
   Result.lfCharSet := DEFAULT_CHARSET;
   StrCopy(Result.lfFaceName,PChar(FFont.name));
end;

constructor THIPrint_Table.Create;
begin
   inherited;
   _NameType := _TABLE; 
   FTable := TDrawTable.Create;
   ZeroMemory(@FPadding, sizeof(FPadding));
end;

destructor THIPrint_Table.Destroy; 
begin      
   FTable.Destroy;
   inherited;
end;

procedure THIPrint_Table.SetTableBackColor;    
begin
   FTable.TableBackColor := Value;
end;

procedure THIPrint_Table.SetRowHeight;    
begin
   FTable.RowHeight := Value;
end;

procedure THIPrint_Table.SetSpacing;
begin
   FTable.CellSpacing := Value;
end;

procedure THIPrint_Table.SetTBorderColor;
begin
   FTable.TBorderColor := Value;
end;

procedure THIPrint_Table.SetTBorderStyle;
begin
   FTable.TBorderStyle := Value;
end;

procedure THIPrint_Table.SetTBorderSize;
begin
   FTable.TBorderSize := Value;
end;

procedure THIPrint_Table.SetTableTrans;
begin
   FTable.TableTrans := Value;
end;

procedure THIPrint_Table.SetColumns;
begin
   FTable.Columns := Value;
end;

procedure THIPrint_Table.SetHeadFont;
begin
  FTable.HeadFont := CreateLogFont(Value);
  FTable.HeadColor := Value.Color;  
end;

procedure THIPrint_Table.SetVisible;
begin
   FTable.HeadVisible := Value;
end;

procedure THIPrint_Table.SetHeadBackColor;
begin
   FTable.HeadBackColor := Value;
end;

procedure THIPrint_Table.SetHeadAlign;
begin
   FTable.HeadAlign := hal[Value];
end;

procedure THIPrint_Table.SetHeadTrans;
begin
   FTable.HeadTrans := Value;
end;

procedure THIPrint_Table.SetCellFont;
begin
   FTable.CellFont := CreateLogFont(Value);
   FTable.CellColor := Value.Color;
end;

procedure THIPrint_Table.SetCells;
begin
   FTable.Cells := Value;
end;

procedure THIPrint_Table.SetCellBackColor;
begin
   FTable.CellBackColor := Value;
end;

procedure THIPrint_Table.SetCBorderColor;
begin
   FTable.CellBorderColor := Value;
end;

procedure THIPrint_Table.SetCBorderStyle;
begin
   FTable.CellBorderStyle := Value;
end;

procedure THIPrint_Table.SetCBorderSize;	
begin
   FTable.CellBorderSize := Value;
end;

procedure THIPrint_Table.SetCellTrans;
begin
   FTable.CellTrans := Value;
end;

procedure THIPrint_Table.SetLeft;
begin
   FPadding.Left := Value;
   FTable.CellPadding := FPadding;
end;

procedure THIPrint_Table.SetTop;
begin
   FPadding.Top := Value;
   FTable.CellPadding := FPadding;
end;

procedure THIPrint_Table.SetRight;
begin
   FPadding.Right := Value;
   FTable.CellPadding := FPadding;
end;

procedure THIPrint_Table.SetBottom;
begin
   FPadding.Bottom := Value;
   FTable.CellPadding := FPadding;
end;

procedure THIPrint_Table.SetAlphaBlend;
begin
   FTable.AlphaBlendValue := Value;
end;

procedure THIPrint_Table.Draw;
begin
   if not _prop_VisibleTable then exit;
   FTable.Width := _prop_Width;
   FTable.Height := _prop_Height;
   FTable.Draw(dc, x + _prop_X, y + _prop_Y, Scale.X, Scale.Y, alpha);
end;

end.
