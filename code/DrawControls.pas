unit DrawControls;

interface

uses Windows,kol;

type
  TColumn = record
    Caption:string;
    Width:integer;
    Align:cardinal;
  end;
  PColumn = ^TColumn;
  TCellStyle = record
    BackColor:HBRUSH;
    Pen:HPEN;
    Font:HFONT;
    FontColor:TColor;
  end;
  PCellStyle = ^TCellStyle;
  TDrawTable = class
    private
      FTBorderPen:HPEN;
      FTBorderColor:TColor;
      FTBorderStyle:byte;
      FTBorderSize:integer;
      FTableBack:HBRUSH;
      FTableBackColor:TColor;
      FTableTrans:boolean;

      FHeadFont:HFONT;
      FHeadFont_orig:LOGFONT;
      FHeadBack:HBRUSH;
      FHeadBackColor:TColor;
      FHeadTrans:boolean;

      FCellBack:HBRUSH;
      FCellBackColor:TColor;
      FCellTrans:boolean;
      FCellBorderPen:HPEN;
      FCellBorderColor:TColor;
      FCellBorderStyle:byte;
      FCellBorderSize:integer;
      FCellFont:HFONT;
      FCellFont_orig:LOGFONT;

      FColumns:PList;

      FMatrix:PList;

      old_sx,old_sy:real;

      procedure InitTBorberPen;
      procedure SetTBorderColor(value:TColor);
      procedure SetTBorderStyle(value:byte);
      procedure SetTBorderSize(value:integer);
      procedure InitTableBackground;
      procedure SetTableBackColor(value:TColor);
      procedure SetTableTrans(value:boolean);

      procedure InitCellBorberPen;
      procedure SetCellBorderColor(value:TColor);
      procedure SetCellBorderStyle(value:byte);
      procedure SetCellBorderSize(value:integer);
      procedure InitCellBackground;
      procedure SetCellBackColor(value:TColor);
      procedure SetCellTrans(value:boolean);
      procedure SetCellFont(const value:LOGFONT);

      procedure InitHeadBackground;
      procedure SetHeadBackColor(value:TColor);
      procedure SetHeadTrans(value:boolean);
      procedure SetHeadFont(const value:LOGFONT);

      procedure SetColumns(const value:string);
      function GetColumns:string;
      procedure ClearColumns;
      procedure SetCells(const value:string);
      function GetCells:string;
      function GetHeaderItem(index:integer):PColumn;
      function GetHeadCount:integer;

      procedure SetCell(x,y:integer; const value:string);
      function GetCell(x,y:integer):string;
      function GetCellStyle(x,y:integer):PCellStyle;
      function GetRows:integer;
      procedure ClearMatrix;

      function GetCellRect(x,y:integer):TRect;
    public
      Width,Height:integer;
      CellPadding:TRect;
      CellSpacing:integer;
      RowHeight:integer;
      HeadColor:TColor;
      HeadAlign:integer;
      HeadVisible:boolean;
      CellColor:TColor;

      constructor Create;
      destructor Destroy; override;
      procedure Draw(dc:HDC; x,y:integer; sx,sy:real);

      function AddRow:integer;
      procedure RemoveRow(index:integer);

      procedure CellAtPos(x,y:integer; var col,row:integer);

      property Columns:string read GetColumns write SetColumns;
      property Cells:string read GetCells write SetCells;
      property TBorderColor:TColor write SetTBorderColor;
      property TBorderStyle:byte write SetTBorderStyle;
      property TBorderSize:integer write SetTBorderSize;
      property TableBackColor:TColor write SetTableBackColor;
      property TableTrans:boolean write SetTableTrans;

      property CellBorderColor:TColor write SetCellBorderColor;
      property CellBorderStyle:byte write SetCellBorderStyle;
      property CellBorderSize:integer write SetCellBorderSize;
      property CellBackColor:TColor write SetCellBackColor;
      property CellTrans:boolean write SetCellTrans;
      property CellFont:LOGFONT write SetCellFont;

      property HeadBackColor:TColor write SetHeadBackColor;
      property HeadTrans:boolean write SetHeadTrans;
      property HeadFont:LOGFONT write SetHeadFont;

      property Header[index:integer]:PColumn read GetHeaderItem;
      property HeadCount:integer read GetHeadCount;

      property Cell[x,y:integer]:string read GetCell write SetCell;
      property CellStyle[x,y:integer]:PCellStyle read GetCellStyle;
      property Rows:integer read GetRows;

      property CellRect[x,y:integer]:TRect read GetCellRect;
  end;

  TDrawImage = class
    private
      FFramePen:HPEN;
      FBack:HBRUSH;

      FBackColor:TColor;
      FBackStyle:boolean;

      FFrameColor:TColor;
      FFrameStyle:byte;
      FFrameSize:integer;

      _sx,_sy:real;

      procedure InitFramePen;
      procedure SetFrameColor(value:TColor);
      procedure SetFrameStyle(value:byte);
      procedure SetFrameSize(value:integer);

      procedure InitBackground;
      procedure SetBackColor(value:TColor);
      procedure SetBackStyle(value:boolean);

      procedure Fill(dc:hdc; x1,y1,x2,y2:integer);
      procedure Center(DC:HDC; r:TRect);
      procedure Stretch(DC:HDC; r:TRect);
      procedure Scale(DC:HDC; r:TRect; x:boolean);
      procedure ScaleMax(DC:HDC; const r:TRect);
      procedure ScaleMin(DC:HDC; const r:TRect);
      procedure Mosaic(DC:HDC; const r:TRect);
      procedure None(DC:HDC; r:TRect);
    public
      Width,Height:integer;
      Image:PBitmap;
      ViewStyle:byte;

      constructor Create;
      destructor Destroy; override;
      procedure Draw(dc:HDC; x,y:integer; sx,sy:real);

      property FrameColor:TColor write SetFrameColor;
      property FrameStyle:byte write SetFrameStyle;
      property FrameSize:integer write SetFrameSize;
      property BackColor:TColor write SetBackColor;
      property BackStyle:boolean write SetBackStyle;
  end;

implementation

procedure ScaleRect(var r:TRect; sx, sy:real);
begin
  r.Left := Round(r.Left * sx);
  r.Right := Round(r.Right * sx);
  r.Top := Round(r.Top * sy);
  r.Bottom := Round(r.Bottom * sy);
end;

constructor TDrawTable.Create;
begin
   inherited;

   FTBorderSize := 1;
   InitTBorberPen;

   FColumns := NewList;

   FMatrix := NewList;
   old_sx := -1;
   old_sy := -1;
end;

destructor TDrawTable.Destroy;
begin
   DeleteObject(FTBorderPen);
   DeleteObject(FHeadBack);
   DeleteObject(FHeadFont);
   DeleteObject(FCellFont);

   ClearColumns;
   FColumns.Free;

   ClearMatrix;
   FMatrix.Free;
   inherited;
end;

procedure TDrawTable.InitTBorberPen;
begin
   DeleteObject(FTBorderPen);
   FTBorderPen := CreatePen(FTBorderStyle, FTBorderSize, Color2RGB(FTBorderColor));
end;

procedure TDrawTable.SetTBorderColor(value:TColor);
begin
   FTBorderColor := value;
   InitTBorberPen;
end;

procedure TDrawTable.SetTBorderStyle(value:byte);
begin
   FTBorderStyle := value;
   InitTBorberPen;
end;

procedure TDrawTable.SetTBorderSize(value:integer);
begin
   FTBorderSize := value;
   InitTBorberPen;
end;

procedure TDrawTable.InitTableBackground;
begin
  DeleteObject(FTableBack);
  if FTableTrans then
    FTableBack := GetStockObject(NULL_BRUSH)
  else FTableBack := CreateSolidBrush(Color2RGB(FTableBackColor));
end;

procedure TDrawTable.SetTableBackColor;
begin
   FTableBackColor := value;
   InitTableBackground;
end;

procedure TDrawTable.SetTableTrans;
begin
   FTableTrans := value;
   InitTableBackground;
end;

procedure TDrawTable.InitCellBorberPen;
var p:HPEN;
    i,j:integer;
begin
   p := FCellBorderPen;
   DeleteObject(FCellBorderPen);
   FCellBorderPen := CreatePen(FCellBorderStyle, FCellBorderSize, Color2RGB(FCellBorderColor));
   for i := 0 to FColumns.Count-1 do
     for j := 0 to FMatrix.Count-1 do
       with CellStyle[i,j]^ do
         if Pen = p then Pen := FCellBorderPen
end;

procedure TDrawTable.SetCellBorderColor(value:TColor);
begin
   FCellBorderColor := value;
   InitCellBorberPen;
end;

procedure TDrawTable.SetCellBorderStyle(value:byte);
begin
   FCellBorderStyle := value;
   InitCellBorberPen;
end;

procedure TDrawTable.SetCellBorderSize(value:integer);
begin
   FCellBorderSize := value;
   InitCellBorberPen;
end;

procedure TDrawTable.InitCellBackground;
var b:HBRUSH;
    i,j:integer;
begin
   b := FCellBack;
   DeleteObject(FCellBack);
   if FCellTrans then
     FCellBack := GetStockObject(NULL_BRUSH)
   else FCellBack := CreateSolidBrush(Color2RGB(FCellBackColor));

   for i := 0 to FColumns.Count-1 do
     for j := 0 to FMatrix.Count-1 do
       with CellStyle[i,j]^ do
         if BackColor = b then BackColor := FCellBack
end;

procedure TDrawTable.SetCellBackColor;
begin
  FCellBackColor := value;
  InitCellBackground;
end;

procedure TDrawTable.SetCellTrans;
begin
   FCellTrans := value;
   InitCellBackground;
end;

procedure TDrawTable.SetCellFont;
var f:HFONT;
    i,j:integer;
begin
   f := FCellFont;
   DeleteObject(FCellFont);
   FCellFont := CreateFontIndirect(value);
   FCellFont_orig := value;
   for i := 0 to FColumns.Count-1 do
     for j := 0 to FMatrix.Count-1 do
       with CellStyle[i,j]^ do
         if Font = f then
           Font := FCellFont
end;

procedure TDrawTable.InitHeadBackground;
begin
  DeleteObject(FHeadBack);
  if FHeadTrans then
    FHeadBack := GetStockObject(NULL_BRUSH)
  else FHeadBack := CreateSolidBrush(Color2RGB(FHeadBackColor));
end;

procedure TDrawTable.SetHeadBackColor;
begin
  FHeadBackColor := value;
  InitHeadBackground;
end;

procedure TDrawTable.SetHeadTrans;
begin
   FHeadTrans := value;
   InitHeadBackground;
end;

procedure TDrawTable.SetHeadFont;
begin
   DeleteObject(FHeadFont);
   FHeadFont := CreateFontIndirect(value);
   FHeadFont_orig := value;
end;

const
  HAl:array[0..2] of byte = (DT_LEFT,DT_CENTER,DT_RIGHT);

procedure TDrawTable.SetColumns;
var lst:PStrList;
    i,t:integer;
    c:PColumn;
    s:string;
begin
   ClearColumns;

   lst := NewStrList;

   lst.Text := value;
   for i := 0 to lst.Count-1 do
    begin
       new(c);
       FillChar(c^, sizeof(TColumn), 0);
       s := lst.Items[i];
       t := pos('|', s);
       if t > 0 then
        begin
          c.Caption := copy(s, 1, t-1);
          delete(s, 1, t);
        end
       else
        begin
          c.Caption := s;
          s := '70';
        end;

       t := pos('|', s);
       if t > 0 then
        begin
          c.Width := str2int(copy(s, 1, t-1));
          delete(s, 1, t);
          c.Align := hal[str2int(s)];
        end
       else
        begin
          c.Width := str2int(s);
          c.Align := 0;
        end;

       FColumns.Add(c);
    end;

   lst.Free;
end;

function TDrawTable.GetColumns;
var i:integer;
  function toAlign(v:integer):integer;
  var t:integer;
  begin
     Result := 0;
     for t := 0 to 2 do if hal[t] = v then result := t;
  end;
begin
   Result := '';
   for i := 0 to FColumns.Count-1 do
     with Header[i]^ do
      Result := Result + Caption + '|' + int2str(Width) + '|' + int2str(toAlign(Align)) + #13#10;
end;

procedure TDrawTable.ClearColumns;
var i:integer;
begin
   for i := 0 to FColumns.Count-1 do
     dispose(PColumn(FColumns.Items[i]));
   FColumns.Clear;
end;

procedure TDrawTable.SetCells;
var lst:PStrList;
    i,j,r,p:integer;
    s:string;
begin
   ClearMatrix;
   lst := NewStrList;
   lst.Text := value;
   for i := 0 to lst.Count-1 do
     begin
       s := lst.Items[i] + '|';
       p := pos('|', s);
       j := 0;
       r := AddRow;
       while(j < HeadCount)and(p > 0)do
        begin
          Cell[j, r] := copy(s, 1, p-1);
          delete(s, 1, p);
          p := pos('|', s);
          inc(j);
        end;
     end;
   lst.Free;
end;

function TDrawTable.GetCells;
var i,j:integer;
begin
   Result := '';
   for j := 0 to FMatrix.Count-1 do
     begin
      for i := 0 to FColumns.Count-1 do
       Result := Result + Cell[i,j] + '|';
      Result[Length(Result)] := #13;
      Result := Result + #10; 
     end;
end;

function TDrawTable.GetHeaderItem;
begin
   Result := PColumn(FColumns.Items[index]);
end;

function TDrawTable.GetHeadCount;
begin
   Result := FColumns.Count;
end;

procedure TDrawTable.SetCell;
begin
  if(y < Rows)and(x < FColumns.Count)then
    PStrList(FMatrix.Items[y]).Items[x] := value;
end;

function TDrawTable.GetCell;
begin
  if(y < Rows)and(x < FColumns.Count)then
    Result := PStrListEx(FMatrix.Items[y]).Items[x];
end;

function TDrawTable.GetCellStyle;
begin
  if(y < Rows)and(x < FColumns.Count)then
    Result := PCellStyle(PStrListEx(FMatrix.Items[y]).Objects[x]);
end;

function TDrawTable.GetCellRect;
var i:integer;
begin
   Result.Top := min(FTBorderSize + y*(CellSpacing + RowHeight), Height);
   Result.Bottom := min(Result.Top + RowHeight, Height - FTBorderSize);
   Result.Left := FTBorderSize;
   for i := 0 to x-1 do
     inc(Result.Left, Header[i].Width + CellSpacing);
   if Result.Left > Width then Result.Left := Width;
   if x = FColumns.Count-1 then
     Result.Right := Width - FTBorderSize
   else
     Result.Right := min(Result.Left + Header[x].Width, Width - FTBorderSize);

   if HeadVisible then
     OffsetRect(Result, 0, CellSpacing + RowHeight);
end;

procedure TDrawTable.CellAtPos;
var i,j:integer;
    p:TPoint;
begin
   p.X := x;
   p.Y := y;
   for i := 0 to FColumns.Count-1 do
    for j := 0 to FMatrix.Count-1 do
      if PointInRect(p, CellRect[i,j]) then
       begin
         row := j;
         col := i;
         exit;
       end;
   row := -1;
   col := -1;    
end;

function TDrawTable.GetRows;
begin
   Result := FMatrix.Count;
end;

procedure TDrawTable.ClearMatrix;
var i:integer;
begin
   for i := 0 to FMatrix.Count-1 do
     RemoveRow(0);
   FMatrix.Clear;
end;

function TDrawTable.AddRow;
var l:PStrListEx;
    cs:PCellStyle;
    i:integer;
begin
   l := NewStrListEx;
   FMatrix.Add(l);
   for i := 0 to FColumns.Count-1 do
     begin
       new(cs);
       cs.BackColor := FCellBack;
       cs.Pen := FCellBorderPen;
       cs.Font := FCellFont;
       cs.FontColor := CellColor;  
       l.AddObject('', cardinal(cs));
     end;
   Result := FMatrix.Count-1;
end;

procedure TDrawTable.RemoveRow;
var i:integer;
    l:PStrListEx;
begin
  if index = -1 then
    ClearMatrix
  else
   begin
      l := PStrListEx(FMatrix.Items[index]);
      for i := 0 to l.Count-1 do
        dispose(PCellStyle(l.Objects[i]));
      l.Free;
      FMatrix.Delete(index);
   end;
end;

procedure TDrawTable.Draw;
var i,j:integer;
    cr,r:TRect;

    function DrawCell(col:integer; const Caption:string; Align:integer):boolean;
    //var f:cardinal;
    begin
      cr.Right := cr.Left + Header[col].Width;
      if(col = FColumns.Count-1)or(cr.Right > x + self.Width - 1) then
        cr.Right := x + self.Width - 1;

      r := cr;
      ScaleRect(r, sx, sy);
      Rectangle(dc, r.Left, r.Top, r.Right, r.Bottom);

      r := cr;
      inc(r.Left, CellPadding.Left);
      inc(r.Top, CellPadding.Top);
      dec(r.Right, CellPadding.Right);
      dec(r.Bottom, CellPadding.Bottom);
      ScaleRect(r, sx, sy);
      DrawText(dc, PChar(Caption), length(caption), r, DT_SINGLELINE or Align or DT_VCENTER);
      cr.Left := cr.Right + CellSpacing;
      Result := cr.Left > x + self.Width - CellSpacing - 1;
    end;
    procedure ReInitFont(var f:HFONT; var lf:LOGFONT);
    var
       oldh,oldw:integer;
    begin
      DeleteObject(f);
      oldh := lf.lfHeight;
      oldw := lf.lfWidth;
      lf.lfHeight := Round(lf.lfHeight * sy);
      lf.lfWidth := Round(lf.lfWidth * sx);
      if F = FCellFont then
        SetCellFont(lf)
      else F := CreateFontIndirect(lf);
      lf.lfWidth := oldw;
      lf.lfHeight := oldh;
    end;
begin
   if(sx <> old_sx)or(sy <> old_sy)then
     begin
       old_sx := sx;
       old_sy := sy;
       ReInitFont(FHeadFont, FHeadFont_orig);
       ReInitFont(FCellFont, FCellFont_orig);
     end;

   SelectObject(dc, FTableBack);
   SelectObject(dc, FTBorderPen);
   cr.Left := x;
   cr.Top := y;
   cr.Right := x + Width;
   cr.Bottom := y + Height;
   ScaleRect(cr, sx, sy);
   Rectangle(dc, cr.Left, cr.Top, cr.Right, cr.Bottom);

   SetBkMode(dc, TRANSPARENT);
   SelectObject(dc, FCellBorderPen);

   cr.Left := x + 1;
   cr.Top := y + 1;

   if HeadVisible then
    begin
     cr.Bottom := cr.Top + RowHeight;
     if cr.Bottom > y + Height then
       cr.Bottom := y + Height;

     SelectObject(dc, FHeadBack);
     SelectObject(dc, FHeadFont);
     SetTextColor(dc, HeadColor);
     for i := 0 to FColumns.Count-1 do
      with PColumn(FColumns.Items[i])^ do
        if DrawCell(i, Caption, HeadAlign) then break;

     cr.Top := cr.Bottom + CellSpacing;
    end;


   if FMatrix.Count > 0 then
    for j := 0 to FMatrix.Count-1 do
     begin
        cr.Left := x + 1;
        cr.Bottom := cr.Top + RowHeight;
        if cr.Bottom > y + Height - 1 then
          break;

        for i := 0 to FColumns.Count-1 do
          begin
            with CellStyle[i,j]^ do
              begin
                SetTextColor(dc, FontColor);
                SelectObject(dc, BackColor);
                SelectObject(dc, Pen);
                SelectObject(dc, Font);
              end;
            with PColumn(FColumns.Items[i])^ do
              if DrawCell(i, Cell[i,j], Align) then break;
          end;
        cr.Top := cr.Bottom + CellSpacing;
     end
   else
    while cr.Top < y + Height do
     begin
        SelectObject(dc, FCellBack);
        SelectObject(dc, FCellFont);
        SetTextColor(dc, CellColor);

        cr.Left := x + 1;
        cr.Bottom := cr.Top + RowHeight;
        if cr.Bottom > y + Height - 1 then
        break;

        for i := 0 to FColumns.Count-1 do
          with PColumn(FColumns.Items[i])^ do
            if DrawCell(i, Caption, Align) then break;
        cr.Top := cr.Bottom + CellSpacing;
     end;
end;

//-------------------------------------------------------------------------------------------------

constructor TDrawImage.Create;
begin
   inherited;
   Image := NewBitmap(0,0);
end;

destructor TDrawImage.Destroy;
begin
   DeleteObject(FFramePen);
   DeleteObject(FBack);
   Image.Free;
   inherited;
end;

procedure TDrawImage.InitFramePen;
begin
   DeleteObject(FFramePen);
   FFramePen := CreatePen(FFrameStyle, FFrameSize, Color2RGB(FFrameColor));
end;

procedure TDrawImage.SetFrameColor;
begin
   FFrameColor := value;
   InitFramePen;
end;

procedure TDrawImage.SetFrameStyle;
begin
   FFrameStyle := value;
   InitFramePen;
end;

procedure TDrawImage.SetFrameSize;
begin
   FFrameSize := value;
   InitFramePen;
end;

procedure TDrawImage.InitBackground;
begin
  DeleteObject(FBack);
  if FBackStyle then
    FBack := GetStockObject(NULL_BRUSH)
  else FBack := CreateSolidBrush(Color2RGB(FBackColor));
end;

procedure TDrawImage.SetBackColor;
begin
   FBackColor := value;
   InitBackground;
end;

procedure TDrawImage.SetBackStyle;
begin
   FBackStyle := value;
   InitBackground;
end;

procedure TDrawImage.Center;
var x,y,b:integer;
begin
  x := max(r.Left + (Width-Image.Width)div 2, r.Left);
  y := max(r.Top + (Height-Image.Height)div 2, r.Top);

  b := min(y + Image.Height, r.Bottom);

  Fill(dc, r.Left, r.Top, r.Right, y); //up
  Fill(dc, r.Left, b, r.Right, r.Bottom); //down
  Fill(dc, r.Left, y, x, b);  // left
  Fill(dc, min(x + Image.Width, r.Right), y, r.Right, b); //right

  r.Left := x;
  r.Top := y;
  r.Right := min(x + Image.Width, r.Right);
  r.Bottom := b;

  ScaleRect(r, _sx, _sy);
  Image.StretchDraw(DC, r);
end;

procedure TDrawImage.Stretch;
begin
  SetStretchBltMode(DC, HALFTONE);
  ScaleRect(r, _sx, _sy);
  Image.StretchDraw(DC, r);
end;

procedure  TDrawImage.Mosaic;
var i,j,sw,sh:integer;
    rc:TRect;
begin
  for i := 0 to Width div Image.Width do
    for j := 0 to Height div Image.Height do
      begin
        //Image.Draw(DC, r.Left + i*Image.Width, r.Top + j*Image.Height);
        rc.Left := min(r.Left + i*Image.Width, r.right);
        rc.Top := min(r.Top + j*Image.Height, r.Bottom);
        rc.Right := min(rc.Left + Image.Width, r.Right);
        rc.Bottom := min(rc.Top + Image.Height, r.Bottom);
        sw := rc.Right - rc.Left;
        sh := rc.Bottom - rc.Top;
        ScaleRect(rc, _sx, _sy);
        StretchBlt(dc, rc.Left, rc.Top, rc.Right - rc.Left, rc.Bottom - rc.Top, Image.Canvas.Handle, 0, 0, sw, sh, SRCCOPY);
      end;
end;

procedure TDrawImage.ScaleMax;
begin
  Scale(DC, r, true);
end;

procedure TDrawImage.ScaleMin;
begin
  Scale(DC, r, false);
end;

procedure TDrawImage.Fill;
var r:TRect;
begin
   r.Left := x1;
   r.Top := y1;
   r.Right := x2;
   r.Bottom := y2;
   ScaleRect(r, _sx, _sy);
   FillRect(dc, r, FBack);
end;

procedure TDrawImage.Scale;
var
    k:real;
    a,b,c:integer;
begin
  k := Image.Height/Image.Width;
  if (Height < Width*k) = x then
   begin
    c := Round((Height - Width*k)/2);
    a := r.Top + c;
    b := r.Bottom - c;
    Fill(dc,r.Left,r.Top,r.Right,a);
    Fill(dc,r.Left,b,r.Right,r.Bottom);
    r.Top := a;
    r.Bottom := b;
   end
  else
   begin
    c := Round((Width - Height/k)/2);
    a := r.Left + c;
    b := r.Right - c;
    Fill(dc,r.Left,r.Top,a,r.Bottom);
    Fill(dc,b,r.Top,r.Right,r.Bottom);
    r.Left := a;
    r.Right := b;
   end;
  SetStretchBltMode(DC, HALFTONE);
  ScaleRect(r, _sx, _sy);
  Image.StretchDraw(DC,r);
end;

procedure TDrawImage.None;
var sw,sh:integer;
begin
  Fill(dc,r.Left + Image.Width,r.Top,r.Right,r.Bottom);
  Fill(dc,r.Left,r.Top + Image.Height,r.Left + Image.Width,r.Bottom);
  r.Right := min(r.Left + Image.Width, r.Right);
  r.Bottom := min(r.Top + Image.Height, r.Bottom);
  sw := r.Right - r.Left;
  sh := r.Bottom - r.Top;
  ScaleRect(r, _sx, _sy);
  StretchBlt(dc, r.Left, r.Top, r.Right - r.Left, r.Bottom - r.Top, Image.Canvas.handle,0,0,sw,sh,SRCCOPY);
  //Image.Draw(DC,r.Left,r.Top);
end;

procedure TDrawImage.Draw;
var cr,r:TRect;
begin
   SelectObject(dc, FFramePen);
   SelectObject(dc, FBack);
   cr.Left := x;
   cr.Top := y;
   cr.Right := x + Width;
   cr.Bottom := y + Height;
   r := cr;
   ScaleRect(r, sx, sy);
   Rectangle(dc, r.Left, r.Top, r.Right, r.Bottom);

   _sx := sx;
   _sy := sy;

   inc(cr.Left, FFrameSize);
   inc(cr.Top, FFrameSize);
   dec(cr.Right, FFrameSize);
   dec(cr.Bottom, FFrameSize);
   if not Image.Empty then
    case ViewStyle of
     0: Center(dc, cr);
     1: Stretch(dc, cr);
     2: ScaleMin(dc, cr);
     3: Mosaic(dc, cr);
     4: None(dc, cr);
     5: ScaleMax(dc, cr);
    end;
end;

end.
