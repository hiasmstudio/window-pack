unit hiImg_Diagram;

interface

uses windows,Kol,Share,Debug,Img_Draw;

const
  bsManual = bsCross;

type
  THIImg_Diagram = class(THIImg)
   private
    FList:PStrList;
    GFont   : PGraphicTool;

    procedure SetNewFont(Value:TFontRec);
    procedure SetItems(const value:string);
   public
    _data_Data:THI_Event;
    _prop_TitleMask:string;
    _prop_BgColor:TColor;
    _prop_LegendShow:boolean;
    _prop_LegendSize:integer;
    _prop_BgColors:PStrListEx;
    _prop_ShowZero:boolean;
        
    destructor Destroy; override;
    procedure _work_doDraw(var _Data:TData; Index:word);
    procedure _work_doItems(var _Data:TData; Index:word);
    property _prop_Items:string write SetItems;
    property _prop_Font:TFontRec write SetNewFont;
  end;

implementation

destructor THIImg_Diagram.Destroy;
begin
  FList.Free; 
  inherited;
end;

procedure THIImg_Diagram.SetNewFont;
begin
   if Assigned(GFont) then GFont.free;
   GFont := NewFont;
   GFont.Color:= Value.Color;
   Share.SetFont(GFont,Value.Style);
   GFont.FontName:= Value.Name;
   GFont.FontHeight:= _hi_SizeFnt(Value.Size);
   GFont.FontCharset:= Value.CharSet;
end;

procedure THIImg_Diagram.SetItems(const value:string);
begin
  FList := NewStrList;
  FList.Text := value;
end;

procedure THIImg_Diagram._work_doItems;
begin
  SetItems(ToString(_Data));
end;

procedure THIImg_Diagram._work_doDraw(var _Data:TData; Index:word);
var
   dt,mt: TData;
   br, oldb: HBRUSH;
   pen: HPEN;
   i,rx,ry,fh:integer;
   sum,a,ra,per:real;
   items:array of real;
   x3,y3,x4,y4:integer;
   hOldFont: HFONT;
   SizeFont: TSize;
   s:string;
   BgColor:TRGB;
   _r,_g,_b:real;
begin
   dt := _Data;
   if not ImgGetDC(_Data) then exit;
   ReadXY(_Data);

   ImgNewSizeDC;

   mt := ReadMTData(_Data, _data_Data);
   pen := CreatePen(PS_SOLID, Round((fScale.x + fScale.y) * ReadInteger(_Data,_data_Size,_prop_Size)/2), Color2RGB(ReadInteger(_Data,_data_Color,_prop_Color)));
   
   SelectObject(pDC,Pen);
   
   fh := GFont.FontHeight;
   GFont.FontHeight := Round(GFont.FontHeight * fScale.y);
   hOldFont := SelectObject(pDC, GFont.Handle);   
      
   sum := 0;
   SetLength(items, FList.Count);
   for i := 0 to FList.Count-1 do
    begin
      Items[i] := ToReal(mt);
      if mt.ldata <> nil then
        mt := mt.ldata^;
        
      sum := sum + items[i];  
    end; 

   if _prop_LegendShow then
     dec(x2, Round(_prop_LegendSize * fScale.x));
   
   rx := (x2-x1) div 2;
   ry := (y2-y1) div 2;
   x3 := x2;
   y3 := y1 + ry;
   a := 0;
   
   BgColor := TRGB(Color2RGB(_prop_BgColor));
   _r := (BgColor.r - 40) / FList.Count;   
   _g := (BgColor.g - 40) / FList.Count;
   _b := (BgColor.b - 40) / FList.Count;
   for i := 0 to FList.Count-1 do
    begin
      if _prop_Style = bsSolid then
        br := CreateSolidBrush(RGB(Round(BgColor.r - _r*i), Round(BgColor.g - _g*i), Round(BgColor.b - _b*i)))
      else if _prop_Style = bsManual then
        br := CreateSolidBrush(Color2RGB(integer(_prop_BgColors.Objects[i])))
      else
        br := GetStockObject(NULL_BRUSH);
      
      oldb := SelectObject(pDC,br);
     
      if items[i] > 0 then
        begin 
         a := a + items[i]/sum*2*pi;
         x4 := x1 + rx + Round(rx*cos(a));
         y4 := y1 + ry + Round(-ry*sin(a));  
         Pie(pDC, x1, y1, x2, y2, x3, y3, x4, y4);
         x3 := x4;
         y3 := y4;
        end;
      if _prop_LegendShow then              
        Rectangle(pDC, x2 + Round(5 * fScale.x), Round((10 + i*24) * fScale.y), x2 + Round(25 * fScale.x), Round((30 + i*24) * fScale.y));
      SelectObject(pDC,oldb);
      DeleteObject(br);
    end;   

   a := 0;
   SetBkMode(pDC, TRANSPARENT);
   SetTextColor(pDC, Color2RGB(GFont.Color));   
   for i := 0 to FList.Count-1 do
    begin
      per := Round(items[i]/sum*1000)/10; 
      s := _prop_TitleMask;
      Replace(s, '%name%', FList.items[i]); 
      Replace(s, '%val%', double2str(items[i]));
      Replace(s, '%per%', double2str(per));

      GetTextExtentPoint32(pDC, PChar(s), Length(s), SizeFont);

      ra := items[i]/sum*2*pi;
      a := a + ra;
      x4 := x1 + rx + Round(rx/2*cos(a - ra/2)) - SizeFont.cx div 2;
      y4 := y1 + ry + Round(-ry/2*sin(a - ra/2)) - SizeFont.cy div 2;
      
      if x4 < 0 then x4 := 1
      else if x4 > x2 - SizeFont.cx then x4 := x2 - SizeFont.cx - 1;   
      if y4 < 0 then y4 := 1
      else if y4 > y2 - SizeFont.cy then y4 := y2 - SizeFont.cy - 1;
      if _prop_ShowZero or(per > 0)then 
        TextOut(pDC, x4, y4, PChar(s), Length(s));
      if _prop_LegendShow then
        TextOut(pDC, x2 + Round(30 * fScale.x), Round((12 + i*24) * fScale.y), PChar(FList.items[i]), Length(FList.items[i]));
    end;  
   SelectObject(pDC, hOldFont);
   GFont.FontHeight := fh;
   DeleteObject(Pen);
   ImgReleaseDC; 
   _hi_CreateEvent(_Data,@_event_onDraw,dt);
end;

end.
