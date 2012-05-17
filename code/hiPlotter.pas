unit hiPlotter;

interface

{$I share.inc}

uses Windows,Share,Win,Kol;

type
  TRPoint = record
    x,y:real;
  end;
  
  THIPlotter = class;
  TSeries = class
    Parent:THIPlotter;
    Values:array of TRPoint;
    Count:integer;
    Size:integer;
    Color:TColor;
    MaxValues:integer;
    hide:bool;

//    onChangeSeries:TEvents;

    constructor Create;
    destructor Destroy; override;
    procedure Add(valY, valX:real); virtual;
    procedure Clear;
    procedure Show(val:bool);
    procedure Draw(Canvas:PCanvas; startX,startY,fX,fY:real; VSpace, HSpace:integer); virtual; abstract;
    function graphMinY:real; virtual;
    function graphMaxY:real; virtual;
    function graphMinX:real; virtual;
    function graphMaxX:real; virtual;
  end;
  THIPlotter = class(THIWin)
   private
    Bmp:PBitmap;
    FSeries:PList;
    FRgn:HRGN;

    FStartPos,FBPos:TPoint;
    FBeginMove:byte;

    procedure _OnClick( Sender: PObj );
    procedure _OnSize( Sender: PObj );
    procedure _OnPaint( Sender: PControl; DC: HDC );
    procedure DrawBmp;
    function graphMinY:real;
    function graphMaxY:real;
    function graphMinX:real;
    function graphMaxX:real;
    
    function GetSeries(index:integer):TSeries;
    function GetSeriesCount:integer;
   protected
     procedure _onMouseDown(Sender: PControl; var Mouse: TMouseEventData); override;
     procedure _onMouseMove(Sender: PControl; var Mouse: TMouseEventData); override;
     procedure _onMouseUp(Sender: PControl; var Mouse: TMouseEventData); override;
     procedure _onMouseWheel(Sender: PControl; var Mouse: TMouseEventData); override;
   public
    _prop_GridColor:TColor;
    _prop_BorderColor:TColor;
    _prop_AxisColor:TColor;
    _prop_Step:real;
    _prop_MinH:real;
    _prop_MaxH:real;
    _prop_MinW:real;
    _prop_MaxW:real;
    _prop_GridX:integer;
    _prop_GridY:integer;
    _prop_LeftMargin:integer;
    _prop_RightMargin:integer;
    _prop_TopMargin:integer;
    _prop_BottomMargin:integer;
    _prop_FileName:string;
    _prop_MouseControl:boolean;
    
    _data_FileName:THI_Event;
    
    onMouseDown:TEvents;
    onMouseUp:TEvents;
    onMouseMove:TEvents;

    constructor Create(Parent:PControl);
    procedure Init; override;
    destructor Destroy; override;
    procedure _work_doClear(var _Data:TData; Index:word);
    procedure _work_doSaveToFile(var _Data:TData; Index:word);
    procedure _var_MinX(var _Data:TData; Index:word);
    procedure _var_MaxX(var _Data:TData; Index:word);
    procedure _var_MinY(var _Data:TData; Index:word);
    procedure _var_MaxY(var _Data:TData; Index:word);
    
    function getInterfacePlotter:THIPlotter;
    
    procedure AddSeries(s:TSeries);
    procedure RemoveSeries(s:TSeries);
    procedure ReDraw;
    
    function AbsToGraphY(v:real):real;
    function AbsToGraphX(v:real):real;
    
    property Series[index:integer]:TSeries read GetSeries;
    property SeriesCount:integer read GetSeriesCount;    
  end;

implementation

constructor TSeries.Create;
begin
   inherited;
   hide := false;
//   onChangeSeries := TEvents.create;
end;

destructor TSeries.Destroy;
begin
//   onChangeSeries.Destroy;
   inherited;
end; 

procedure TSeries.Show;
begin
   hide := not val;
end; 

procedure TSeries.Add;
begin
   if(MaxValues > 0)and(Count = MaxValues)then
    begin
     Move(Values[1],Values[0],sizeof(TRPoint)*(Count-1));
    end
   else
    begin
     inc(Count);
     SetLength(Values,Count);
    end;

   with Values[Count-1] do
    begin
      Y := valY;
      X := valX;
    end;
//   onChangeSeries.Event(self); 
end;

procedure TSeries.Clear;
begin
   Count := 0;
   SetLength(Values,Count);
//   onChangeSeries.Event(self);
end;

function TSeries.graphMinY:real;
var i:integer;
begin
   if Count = 0 then
     Result := 0
   else
    begin
      Result := Values[0].Y;
      for i := 1 to Count-1 do
       if Values[i].Y < Result then
        Result := Values[i].y;
    end;
end;

function TSeries.graphMaxY:real;
var i:integer;
begin
   if Count = 0 then
     Result := 0
   else
    begin
      Result := Values[0].Y;
      for i := 1 to Count-1 do
       if Values[i].Y > Result then
        Result := Values[i].y;
    end;
end;

function TSeries.graphMinX:real;
var i:integer;
begin
   if Count = 0 then
     Result := 0
   else
    begin
      Result := Values[0].X;
      for i := 1 to Count-1 do
       if Values[i].X < Result then
        Result := Values[i].x;
    end;
end;

function TSeries.graphMaxX:real;
var i:integer;
begin
   if Count = 0 then
     Result := 0
   else
    begin
      Result := Values[0].X;
      for i := 1 to Count-1 do
       if Values[i].X > Result then
        Result := Values[i].x;
    end;
end;

//---------------------------- PLOTTER -----------------------------------------

constructor THIPlotter.Create;
begin
   inherited Create(Parent);
   Control := NewPaintbox(Parent);
   Bmp := NewBitmap(0,0);
   FSeries := NewList;
   _prop_MouseCapture := true;
   onMouseDown := TEvents.Create;
   onMouseUp := TEvents.Create;
   onMouseMove := TEvents.Create;
end;

destructor THIPlotter.Destroy;
var i:integer;
begin
   onMouseDown.Destroy;
   onMouseUp.Destroy;
   onMouseMove.Destroy;
   DeleteObject(FRgn);
   Bmp.free;
   for i := 0 to SeriesCount - 1 do
     Series[i].Parent := nil;
   FSeries.Free;
   inherited;
end;

procedure THIPlotter.Init;
begin
   inherited;
   with Control{$ifndef F_P}^{$endif} do
    begin
     OnClick := _OnClick;
     OnPaint := _OnPaint;
     OnResize := _OnSize;
    end;

   _OnSize(Control);
end;

function THIPlotter.getInterfacePlotter:THIPlotter;
begin
   Result := self;
end;

procedure THIPlotter._OnSize;
begin
   Bmp.Width := max(control.Width,1);
   Bmp.Height := max(Control.Height,1);
   DeleteObject(FRgn);
   FRgn := CreateRectRgn(0,0,Bmp.Width,Bmp.Height); 
   DrawBmp;
//   Control.Invalidate;
end;

function THIPlotter.GetSeries(index:integer):TSeries;
begin
   Result := TSeries(FSeries.Items[index]);
end;

function THIPlotter.GetSeriesCount:integer;
begin
   Result := FSeries.Count;
end;

procedure THIPlotter._onMouseDown;
begin
   inherited;
   FStartPos.x := Mouse.x;
   FStartPos.y := Mouse.y;
   FBPos := FStartPos;
   SetFocus(Control.handle);
   
   onMouseDown.event(@Mouse);
   
   if not _prop_MouseControl then exit;
   
   if Mouse.Button = mbMiddle then
     FBeginMove := 1
   else if(Mouse.Button = mbLeft)and(GetKeyState(VK_CONTROL) < 0) then
     FBeginMove := 2
   else FBeginMove := 0;  
   if(_prop_MaxH = 0)and(_prop_MinH = 0)then
     begin
        _prop_MaxH := graphMaxY;
        _prop_MinH := graphMinY;
     end; 
   if(_prop_MaxW = 0)and(_prop_MinW = 0)then
     begin
        _prop_MaxW := graphMaxX;
        _prop_MinW := graphMinX;
     end; 
end;

procedure THIPlotter._onMouseUp;
var dy,h:real;
begin
   inherited;
   case FBeginMove of
     2:
       begin
         Control.Canvas.Pen.PenMode := pmXor;
         Control.Canvas.Rectangle(FBPos.x, FBPos.y, FStartPos.x, FStartPos.y);
         
         dy := (_prop_MaxH - _prop_MinH)/(Control.Height - _prop_BottomMargin - _prop_TopMargin);
         h := _prop_MaxH - _prop_MinH;  
         if FBPos.y < FStartPos.y then
           begin  
             _prop_MaxH := _prop_MinH + h - (FBPos.y - _prop_TopMargin)*dy;
             _prop_MinH := _prop_MinH + h - (FStartPos.y - _prop_TopMargin)*dy;
           end
         else
           begin
             _prop_MaxH := 0;
             _prop_MinH := 0;
             _prop_MaxH := graphMaxY;
             _prop_MinH := graphMinY;
           end;
           
         dy := (_prop_MaxW - _prop_MinW)/(Control.Width - _prop_LeftMargin - _prop_RightMargin);
         if FBPos.x < FStartPos.x then
           begin  
             _prop_MaxW := _prop_MinW + (FStartPos.x - _prop_LeftMargin)*dy;
             _prop_MinW := _prop_MinW + (FBPos.x - _prop_LeftMargin)*dy;
           end
         else
           begin
             _prop_MaxW := 0;
             _prop_MinW := 0;
             _prop_MaxW := graphMaxX;
             _prop_MinW := graphMinX;
           end;
         ReDraw;
       end;
   end;
   FBeginMove := 0;
   onMouseUp.event(@Mouse);
end;

procedure THIPlotter._onMouseMove;
var dy:real;
begin
   inherited;
   case FBeginMove of
    1:
     begin 
       dy := (_prop_MaxH - _prop_MinH)/(Control.Height - _prop_BottomMargin - _prop_TopMargin);
       _prop_MaxH := _prop_MaxH + (Mouse.y - FStartPos.y)*dy;
       _prop_MinH := _prop_MinH + (Mouse.y - FStartPos.y)*dy;
       
       dy := (_prop_MaxW - _prop_MinW)/(Control.Width - _prop_LeftMargin - _prop_RightMargin);
       _prop_MaxW := _prop_MaxW - (Mouse.x - FStartPos.x)*dy;
       _prop_MinW := _prop_MinW - (Mouse.x - FStartPos.x)*dy;
       ReDraw;
     end;
    2:
     begin 
       Control.Canvas.Pen.PenMode := pmXor;
       Control.Canvas.Rectangle(FBPos.x, FBPos.y, FStartPos.x, FStartPos.y);
       Control.Canvas.Rectangle(FBPos.x, FBPos.y, Mouse.x, Mouse.y);
     end;
   end;
   FStartPos.x := Mouse.x;
   FStartPos.y := Mouse.y;
  
   onMouseMove.event(@Mouse);
end;

procedure THIPlotter._onMouseWheel;
var h:real;
    i:real;
begin
   inherited;
   if not _prop_MouseControl then exit;
   i := (integer(Mouse.Shift) / $1000)*0.0001;

   h := _prop_MaxH - (_prop_MaxH - _prop_MinH) * (FStartPos.y - _prop_TopMargin)/(Control.Height - _prop_TopMargin - _prop_BottomMargin); 
   _prop_MaxH := _prop_MaxH - i*(_prop_MaxH - h);
   _prop_MinH := _prop_MinH - i*(_prop_MinH - h);

   h := _prop_MinW + (_prop_MaxW - _prop_MinW) * (FStartPos.x - _prop_LeftMargin)/(Control.Width - _prop_LeftMargin - _prop_RightMargin); 
   _prop_MaxW := _prop_MaxW - i*(_prop_MaxW - h);
   _prop_MinW := _prop_MinW - i*(_prop_MinW - h);

   ReDraw;
end;

procedure THIPlotter.AddSeries;
begin
   s.Parent := self;
   FSeries.Add(s);
end;

procedure THIPlotter.RemoveSeries(s:TSeries);
begin
   FSeries.Delete(FSeries.IndexOf(s));
   s.Destroy;
end;

procedure THIPlotter.ReDraw;
begin
//   DrawBmp;
   Control.Invalidate;
end;

procedure THIPlotter._work_doSaveToFile;
begin
   DrawBmp;
   Bmp.SaveToFile(ReadString(_Data, _data_FileName, _prop_FileName));
end;

procedure THIPlotter._work_doClear;
var i:integer;
begin
   for i := 0 to SeriesCount - 1 do
     Series[i].Clear;
   Control.Invalidate;
end;

procedure THIPlotter._OnClick;
begin

end;

procedure THIPlotter._OnPaint;
begin
   DrawBmp;
   Bmp.Draw(DC,0,0);
end;

function THIPlotter.graphMinY:real;
var i:integer; 
    r:real;
begin
   if SeriesCount = 0 then
     Result := 0
   else
     if _prop_MinH <> 0 Then Result := _prop_MinH Else
        begin
          Result := $FFFFFF;
          for i := 0 to SeriesCount-1 do
            if Series[i].Count > 0 then 
              begin
                r := Series[i].graphMinY;
                if r < Result then
                  Result := r;
              end;
          if Result = $FFFFFF then
            Result := 0;    
        end;
end;

function THIPlotter.graphMaxY:real;
var i:integer;
    r:real;
begin
   if SeriesCount = 0 then
     Result := 0
   else
     if _prop_MaxH <> 0 Then Result := _prop_MaxH Else
        begin
          Result := -$FFFFFF;
          for i := 0 to SeriesCount-1 do
            if Series[i].Count > 0 then 
              begin
                r := Series[i].graphMaxY;
                if r > Result then
                  Result := r;
              end;
          if Result = -$FFFFFF then
            Result := 0; 
        end;
end;

function THIPlotter.graphMinX:real;
var i:integer; 
    r:real;
begin
   if SeriesCount = 0 then
     Result := 0
   else
     if _prop_MinW <> 0 Then Result := _prop_MinW Else
        begin
          Result := $FFFFFF;
          for i := 0 to SeriesCount-1 do
            if Series[i].Count > 0 then 
              begin
                r := Series[i].graphMinX;
                if r < Result then
                  Result := r;
              end;
          if Result = $FFFFFF then
            Result := 0; 
        end;
end;

function THIPlotter.graphMaxX:real;
var i:integer;
    r:real;
begin
   if SeriesCount = 0 then
     Result := 0
   else
     if _prop_MaxW <> 0 Then Result := _prop_MaxW Else
        begin
          Result := -$FFFFFF;
          for i := 0 to SeriesCount-1 do
            if Series[i].Count > 0 then 
              begin
                r := Series[i].graphMaxX;
                if r > Result then
                  Result := r;
              end;
          if Result = -$FFFFFF then
            Result := 0; 
        end;
end;

function Max(r1,r2:real):real;
begin
   if r1 > r2 then
    Result := r1
   else Result := r2;
end;

procedure THIPlotter.DrawBmp;
var t:integer;
    x,dx:real;
    _Grid,ix:real;
    FY,FX:real;
    fstartY,fstartX:real;
    VSpace,HSpace:integer;
    r:TRect;
    s:string;
    rg:HRGN;
begin
   {$ifdef F_P}
   with Bmp,Canvas do
   {$else}
   with Bmp^,Canvas^ do
   {$endif}
    begin
      Font.FontHeight := 8;
      Brush.Color := Control.Color;
      Brush.BrushStyle := bsSolid;
      r.left := 0;
      r.top := 0;
      r.right := Width;
      r.bottom := Height; 
      FillRect(r);
      VSpace := Width - _prop_LeftMargin - _prop_RightMargin;
      HSpace := Height - _prop_TopMargin - _prop_BottomMargin;

      Pen.Color := _prop_GridColor;
      Font.Color := _prop_AxisColor;
      Pen.PenStyle := psDot;

      fstartY := graphMinY;
      FY := graphMaxY - fstartY;
      if FY = 0 then FY := 1;
      fstartX := graphMinX;
      FX := graphMaxX - fstartX;
      if FX = 0 then FX := 1;
      
      //---------------------------- X Axis ------------------------------------
      dx := FX/max(1,_prop_GridX);
      _Grid := max(1,VSpace/max(1,_prop_GridX));
      x := fstartX;
      if _Grid > 10 then
       TextOut(_prop_LeftMargin-2,Height - _prop_BottomMargin + 1,Double2Str(Round(x*100)/100));
      ix := _prop_LeftMargin + _Grid;;
      while ix < Width - _prop_RightMargin + 1 do
       begin
         MoveTo(Round(ix),_prop_TopMargin);
         LineTo(Round(ix),Height - _prop_BottomMargin);
         x := x + dx;
         if _Grid > 10 then
           begin
             s := Double2Str(Round(x*100)/100); 
             r.left := Round(ix);
             r.top := Height - _prop_BottomMargin + 1;
             r.bottom := r.top + 20;
             r.right := 0;  
             DrawText(s,r,DT_CALCRECT);
             t := (r.right - r.left) shr 1;
             dec(r.left, t);
             dec(r.right, t); 
             DrawText(s,r,0);
           end;
         ix := ix + _Grid;
       end;

      //---------------------------- Y Axis ------------------------------------
      dx := FY/max(1,_prop_GridY);
      _Grid := max(1,HSpace/max(1,_prop_GridY));
      x := fstartY;
      ix := Height - _prop_BottomMargin;
      while ix > _prop_TopMargin-1 do
       begin
         if x <> fstartY then
           begin
             MoveTo(_prop_LeftMargin,Round(ix));
             LineTo(Width - _prop_RightMargin,Round(ix));
           end;
         if _Grid > 12 then
           begin
             s := Double2Str(Round(x*100)/100); 
             r.left := 2;
             r.top := Round(ix);
             r.bottom := 0;
             r.right := 0;  
             DrawText(s,r,DT_CALCRECT);
             t := r.right - r.left;
             r.right := _prop_LeftMargin - 4; 
             r.left := r.right - t;
             t := (r.bottom - r.top) shr 1;
             dec(r.top, t);
             dec(r.bottom, t);
             DrawText(s,r,0);
           end;
         x := x + dx;
         ix := ix - _Grid;
       end;

      //---------------------------- Series ------------------------------------
      rg := CreateRectRgn(_prop_LeftMargin,_prop_TopMargin,_prop_LeftMargin + VSpace,_prop_TopMargin + HSpace);
      SelectObject(Handle, rg);
      for t := 0 to SeriesCount-1 do
        if not Series[t].hide then Series[t].Draw(Canvas, fstartX, fstartY, FX, FY, VSpace, HSpace);
      SelectObject(Handle, FRgn);  
      DeleteObject(rg);      
        
      Pen.Color := _prop_BorderColor;
      Pen.PenStyle := psSolid;
      Pen.PenWidth := 1;
      Brush.BrushStyle := bsClear;
      Rectangle(_prop_LeftMargin,_prop_TopMargin,Width - _prop_RightMargin,Height - _prop_BottomMargin);
    end;
end;

function THIPlotter.AbsToGraphY(v:real):real;
var FY,fstartY:real;
    HSpace:integer;
begin
  fstartY := graphMinY;
  FY := graphMaxY - fstartY;
  HSpace := Bmp.Height - _prop_TopMargin - _prop_BottomMargin;
  Result := (HSpace + _prop_TopMargin - v)*FY/HSpace + fstartY;  
end;

function THIPlotter.AbsToGraphX(v:real):real;
var FX,fstartX:real;
    VSpace:integer;
begin
  fstartX := graphMinX;
  FX := graphMaxX - fstartX;
  VSpace := Bmp.Width - _prop_LeftMargin - _prop_RightMargin;
  Result := FX - ((VSpace + _prop_LeftMargin - v)*FX/VSpace - fstartX);
end;

procedure THIPlotter._var_MinY;
begin
  dtReal(_Data,graphMinY);
end;

procedure THIPlotter._var_MaxY;
begin
  dtReal(_Data,graphMaxY);
end;

procedure THIPlotter._var_MinX;
begin
  dtReal(_Data,graphMinX);
end;

procedure THIPlotter._var_MaxX;
begin
  dtReal(_Data,graphMaxX);
end;

end.
