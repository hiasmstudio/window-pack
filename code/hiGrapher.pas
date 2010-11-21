unit hiGrapher;

interface

{$I share.inc}

uses Windows,Share,Win,Kol;

type
  TRPoint = record
    x,y:real;
   end;
  THIGrapher = class(THIWin)
   private
    Bmp:PBitmap;
//    HB:HBRUSH;
    Values:array of TRPoint;
    FCount:integer;

    FGrid:integer;

    procedure _OnClick( Sender: PObj );
    procedure _OnSize( Sender: PObj );
    procedure _OnPaint( Sender: PControl; DC: HDC );
    procedure Clear;
    procedure DrawBmp;
    function graphMin:real;
    function graphMax:real;
    procedure SetGrid(Value:integer);
    
    procedure Add(val:real);
   public
    _prop_GridColor:TColor;
    _prop_BorderColor:TColor;
    _prop_AxisColor:TColor;
    _prop_Step:real;
    _prop_MinH:real;
    _prop_MaxH:real;
    _prop_MaxValues:integer;
    _prop_LeftMargin:integer;
    _prop_RightMargin:integer;
    _prop_TopMargin:integer;
    _prop_BottomMargin:integer;
    
    _prop_PenWidth:integer;
    _prop_PenColor:TColor;

    _data_Data:THI_Event;
    _data_ValueY:THI_Event;

    constructor Create(Parent:PControl);
    procedure Init; override;
    destructor Destroy; override;
    procedure _work_doAdd(var _Data:TData; Index:word);
    procedure _work_doClear(var _Data:TData; Index:word);
    procedure _work_doMaxValues(var _Data:TData; Index:word);
    procedure _work_doSaveToFile(var _Data:TData; Index:word);
    procedure _var_Min(var _Data:TData; Index:word);
    procedure _var_Max(var _Data:TData; Index:word);
    property _prop_Grid:integer write SetGrid;
  end;

implementation

constructor THIGrapher.Create;
begin
   inherited Create(Parent);
   Control := NewPaintbox(Parent);
   Bmp := NewBitmap(0,0);
end;

destructor THIGrapher.Destroy;
begin
   // "уходя, гасите свет"
   Bmp.free;
   inherited;
end;

procedure THIGrapher.Init;
begin
   inherited;
   with Control{$ifndef F_P}^{$endif} do
    begin
     OnClick := _OnClick;
     OnPaint := _OnPaint;
     OnResize := _OnSize;
    end;

   //Bmp.Width := Control.Width;
   //Bmp.Height := Control.Height;
   //Clear;
   //Control.Invalidate;
   _OnSize(Control);

end;

procedure THIGrapher._OnSize;
begin
   Bmp.Width := max(Control.Width,1);
   Bmp.Height := max(Control.Height,1);
   DrawBmp;
   Control.Invalidate;
end;

procedure THIGrapher.Add(val:real);
begin
   if(_prop_MaxValues > 0)and(FCount = _prop_MaxValues)then
    begin
     Move(Values[1],Values[0],sizeof(TRPoint)*(FCount-1));
    end
   else
    begin
     inc(FCount);
     SetLength(Values,FCount);
    end;

   with Values[FCount-1] do
    begin
     Y := val;
     if FCount = 1 then
      X := 0
     else X := Values[FCount-2].X + _prop_Step;
    end;
end;

procedure THIGrapher._work_doAdd;
var st:PStream;
   mx,my:integer;
   s:smallint;
begin
   if _IsStream(_Data) then
    begin
      Clear;
      mx := 0;
      my := 0;
      st := ReadStream(_Data, _data_ValueY);
      st.Position := 0;
      while st.position < st.size do
       begin
         st.read(s, sizeof(s));
         if s > mx then mx := s;
         if s < my then my := s;
         Add(s);
       end;
//      _prop_minH := my;
//      _prop_MaxH := mx;
//      add(my);  
//      _debug(mx);
//      _debug(my);
    end
   else Add(ReadReal(_Data,_data_ValueY,0));
   
   DrawBmp;
   Control.Invalidate;
end;

procedure THIGrapher._work_doMaxValues;
begin
   _prop_MaxValues := ToInteger(_Data);
end;

procedure THIGrapher._work_doSaveToFile;
begin
   Bmp.SaveToFile(ToString(_Data));
end;

procedure THIGrapher._work_doClear;
begin
   Clear;
   Control.Invalidate;
end;

procedure THIGrapher._OnClick;
begin

end;

procedure THIGrapher._OnPaint;
begin
   Bmp.Draw(DC,0,0);
end;

procedure THIGrapher.Clear;
begin
   FCount := 0;
   DrawBmp;
end;

procedure THIGrapher.SetGrid;
begin
   FGrid := max(1,Value);
end;

function THIGrapher.graphMin:real;
var i:integer;
begin
   if FCount = 0 then
     Result := 0
   else
    if _prop_MaxH > 0 Then Result := _prop_MinH Else
    begin
      Result := Values[0].Y;
      for i := 1 to FCount-1 do
       if Values[i].Y < Result then
        Result := Values[i].y;
    end;
end;

function THIGrapher.graphMax:real;
var i:integer;
begin
   if FCount = 0 then
     Result := 0
   else
    if _prop_MaxH > 0 Then Result := _prop_MaxH Else
    begin
      Result := Values[0].Y;
      for i := 1 to FCount-1 do
       if Values[i].Y > Result then
        Result := Values[i].y;
    end;
end;

function Max(r1,r2:real):real;
begin
   if r1 > r2 then
    Result := r1
   else Result := r2;
end;

procedure THIGrapher.DrawBmp;
var i:integer;
    x,dx:real;
    _Grid,ix:real;
    FY,FX:real;
    fstartY,fstartX:real;
    VSpace,HSpace:integer;
begin
   {$ifdef F_P}
   with Bmp,Canvas do
   {$else}
   with Bmp^,Canvas^ do
   {$endif}
    begin
      Font.FontHeight := 8;
      Brush.Color := Control.Color;
      Bmp.Canvas.FillRect(Control.ClientRect);

      Pen.Color := _prop_BorderColor;
      Pen.PenStyle := psSolid;
      Pen.PenWidth := 1;
      Rectangle(_prop_LeftMargin,_prop_TopMargin,Width - _prop_RightMargin,Height - _prop_BottomMargin);

      VSpace := Width - _prop_LeftMargin - _prop_RightMargin;
      HSpace := Height - _prop_TopMargin - _prop_BottomMargin;

      _Grid := max(1,VSpace/FGrid);
      Pen.Color := _prop_GridColor;
      Font.Color := _prop_AxisColor;
      //Pen.PenStyle := psDot;

      fstartY := graphMin;
      FY := graphMax - fstartY;
      if FCount > 0 then
       fstartX := Round(Values[0].X*100)/100
      else fstartX := 0;

      if FCount > 1 then
       begin
        FX := Values[FCount-1].X - Values[0].X;
        dx := FX/FGrid;
       end
      else
       begin
        dx := 0;
        FX := 1;
       end;
      if FY = 0 then FY := 1; /// else FY := 10;
      x := 0;
      if _Grid > 10 then
       TextOut(_prop_LeftMargin-2,Height - _prop_BottomMargin + 1,Double2Str(Round(x*100)/100 + fstartX));
      ix := _prop_LeftMargin + _Grid;;
      while ix < Width - _prop_RightMargin + 1 do
       begin
         MoveTo(Round(ix),_prop_TopMargin);
         LineTo(Round(ix),Height - _prop_BottomMargin);
         x := x + dx;
         if _Grid > 10 then
          TextOut(Round(ix)-2,Height - _prop_BottomMargin + 1,Double2Str(Round(x*100)/100 + fstartX));
         ix := ix + _Grid;
       end;

      if FCount > 0 then
        dx := FY / FGrid
      else dx := 0;
      _Grid := max(1,HSpace/FGrid);
      x := fstartY;
      if _Grid > 12 then
       TextOut(2,Height - _prop_BottomMargin - 4,Double2Str(Round(x*100)/100));
      ix := Height - _prop_BottomMargin - _Grid;
      while ix > _prop_TopMargin-1 do
       begin
         MoveTo(_prop_LeftMargin,Round(ix));
         LineTo(Width - _prop_RightMargin,Round(ix));
         x := x + dx;
         if _Grid > 12 then
          TextOut(2,Round(ix)-4,Double2Str(Round(x*100)/100));
         ix := ix - _Grid;
       end;

      Pen.Color := _prop_PenColor;
      Pen.PenStyle := psSolid;
      Pen.PenWidth := _prop_PenWidth;
      if FCount > 0 then
       MoveTo(_prop_LeftMargin + Round(VSpace*(Values[0].x - fstartX)/FX),
              _prop_TopMargin + Round(HSpace - HSpace*(Values[0].y - fstartY)/FY));
      for i := 1 to FCount-1 do
       with Values[i] do
        if x > FX + fstartX then break
        else LineTo(_prop_LeftMargin + Round(VSpace*(x - fstartX)/FX),
               _prop_TopMargin + Round(HSpace - HSpace*(y-fstartY)/FY));
    end;
end;

procedure THIGrapher._var_Min;
begin
  dtReal(_Data,graphMin);
end;

procedure THIGrapher._var_Max;
begin
  dtReal(_Data,graphMax);
end;

end.
