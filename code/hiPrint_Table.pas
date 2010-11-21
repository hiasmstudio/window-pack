unit hiPrint_Table;

interface

uses Windows,Kol,Share,Debug,DrawControls,hiDocumentTemplate,Img_Draw;

type
  THIPrint_Table = class(TDocItem)
   private
    FInit:boolean; 
    procedure InitTable;
   public
    FTable:TDrawTable;
    {
    _prop_X:integer;
    _prop_Y:integer;
    _prop_Width:integer;
    _prop_Height:integer;
    }
    _prop_Columns:string;
    _prop_Cells:string;
    _prop_Visible:boolean;
    _prop_HeadFont:TFontRec;
    _prop_HeadBackColor:TColor;
    _prop_HeadAlign:byte;
    _prop_HeadTrans:boolean;

    _prop_Left:integer;
    _prop_Top:integer;
    _prop_Right:integer;
    _prop_Bottom:integer;

    _prop_CellFont:TFontRec;
    _prop_CellBackColor:TColor;
    _prop_CellAlign:byte;
    _prop_CellTrans:boolean;
    _prop_Spacing:integer;
    _prop_CBorderColor:TColor;
    _prop_CBorderStyle:byte;
    _prop_CBorderSize:integer;

    _prop_TableBackColor:TColor;
    _prop_TableTrans:boolean;
    _prop_RowHeight:integer;
    _prop_TBorderColor:TColor;
    _prop_TBorderStyle:byte;
    _prop_TBorderSize:integer;

    constructor Create;
    destructor Destroy; override;
    procedure Draw(dc:HDC; x,y:integer; const Scale:TScale); override;    
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
   FTable := TDrawTable.Create; 
end;

destructor THIPrint_Table.Destroy; 
begin      
   FTable.Destroy;
   inherited;
end;

procedure THIPrint_Table.InitTable;
begin           
   FTable.Columns := _prop_Columns;
   FTable.Cells := _prop_Cells;
   
   FTable.RowHeight := _prop_RowHeight;
   FTable.TBorderColor := _prop_TBorderColor;
   FTable.TBorderStyle := _prop_TBorderStyle;
   FTable.TBorderSize := _prop_TBorderSize;
   FTable.TableBackColor := _prop_TableBackColor;
   FTable.TableTrans := _prop_TableTrans;

   FTable.CellBorderColor := _prop_CBorderColor;
   FTable.CellBorderStyle := _prop_CBorderStyle;
   FTable.CellBorderSize := _prop_CBorderSize;
   FTable.CellPadding := MakeRect(_prop_Left, _prop_Top, _prop_Right, _prop_Bottom);
   FTable.CellSpacing := _prop_Spacing;
   FTable.CellBackColor := _prop_CellBackColor;
   FTable.CellTrans := _prop_CellTrans;
   FTable.CellColor := _prop_CellFont.Color;
   FTable.CellFont := CreateLogFont(_prop_CellFont);

   FTable.HeadBackColor := _prop_HeadBackColor;
   FTable.HeadTrans := _prop_HeadTrans;
   FTable.HeadColor := _prop_HeadFont.Color;
   FTable.HeadFont := CreateLogFont(_prop_HeadFont);
   FTable.HeadAlign := hal[_prop_HeadAlign];
   FTable.HeadVisible := _prop_Visible;
   
   FTable.Width := _prop_Width;
   FTable.Height := _prop_Height;
end;

procedure THIPrint_Table.Draw;
begin
    if not FInit then // тут надо все через property разводить...
     begin
       FInit := true;
       InitTable;
     end;
   FTable.Draw(dc, x + _prop_X, y + _prop_Y, Scale.X, Scale.Y);
end;

end.
