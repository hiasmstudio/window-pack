unit hiLED; { Компонент Led (Светодиод) ver 2.60 }

interface

uses Windows,Kol,Share,Debug,Win;

type
   TShapeLed = (lsCircle,lsRectangle);

   THILED = class(THIWin)
   private
      FColors : array[0..2] of TColor;
      FValue : boolean;
      FShape : TShapeLed;
      FBlick : boolean;
      PenGray,PenWhite : HPen;
      FPen1  : HPen;
      FPen2  : HPen;
      FPen3  : HPen;
      //FPen4  : HPen;
      FPen5  : HPen;
      FBr1   : HBrush;
      FBr2   : HBrush;
      procedure _onPaint( Sender: PControl; DC: HDC );
      procedure _onResize(Obj:PObj);override;
      procedure _OnClick( Sender: PObj );
   public
      _event_onChange  : THI_Event;
      _event_onClick:THI_Event;

      property _prop_ColorOn    : TColor    write FColors[0];
      property _prop_ColorOff   : TColor    write FColors[1];
      property _prop_ColorBlick : TColor    write FColors[2];
      property _prop_Shape      : TShapeLed write FShape;
      property _prop_Blick      : boolean   write FBlick;
      property _prop_Value      : boolean   write FValue;

      procedure Init;override;
      destructor Destroy; override;
      procedure _work_doOn(var _Data:TData; Index:word);
      procedure _work_doOff(var _Data:TData; Index:word);
      procedure _work_doChangeValue(var _Data:TData; Index:word);
      procedure _work_doColorOn(var _Data:TData; Index:word);
      procedure _work_doColorOff(var _Data:TData; Index:word);
      procedure _work_doColorBlick(var _Data:TData; Index:word);            
      procedure _var_Value(var _Data:TData; Index:word);
   end;

implementation

procedure THILED.Init;
begin
   Control := NewPaintbox(FParent);
   inherited;
   PenGray  := CreatePen(ps_Solid,1,clGray);
   PenWhite := CreatePen(ps_Solid,1,clWhite);
   FBr1     := CreateSolidBrush(Color2RGB(FColors[0]));
   FBr2     := CreateSolidBrush(Color2RGB(FColors[1]));
   FPen1 := CreatePen(ps_Solid,1,Color2RGB(FColors[1]));
   FPen2 := CreatePen(ps_Solid,1,Color2RGB(FColors[2]));
   FPen3 := CreatePen(ps_Solid,2,clWhite);
   //FPen4 := CreatePen(ps_Solid,1,FColors[1]);
   FPen5 := CreatePen(ps_Solid,2,Color2RGB(FColors[0]));
   Control.onPaint := _onPaint;
   Control.OnClick := _OnClick;   
end;

procedure THILED._onResize;
begin
  Control.Invalidate;
  inherited;
end;

destructor THILED.Destroy;
begin
   DeleteObject(PenGray);
   DeleteObject(PenWhite);
   DeleteObject(FBr1);
   DeleteObject(FBr2);
   DeleteObject(FPen1);
   DeleteObject(FPen2);
   DeleteObject(FPen3);
   //DeleteObject(FPen4);
   DeleteObject(FPen5);
   inherited Destroy;
end;

procedure THILED._work_doOn;
begin
   if FValue then exit;
   FValue := true;
   Control.Invalidate;
   _hi_CreateEvent(_Data,@_event_onChange, byte(FValue));
end;

procedure THILED._work_doOff;
begin
   if not FValue then exit;
   FValue := false;
   Control.Invalidate;
   _hi_CreateEvent(_Data,@_event_onChange, byte(FValue));
end;

procedure THILED._work_doChangeValue;
begin
   FValue := not FValue;
   Control.Invalidate;
   _hi_CreateEvent(_Data,@_event_onChange, byte(FValue));
end;

procedure THILED._work_doColorOn;
begin
  FColors[0] := ToInteger(_Data);
  DeleteObject(FBr1);
  DeleteObject(FPen5);
  FBr1  := CreateSolidBrush(Color2RGB(FColors[0]));
  FPen5 := CreatePen(ps_Solid,2,Color2RGB(FColors[0]));
  InvalidateRect(Control.Handle, nil, false);          
end;

procedure THILED._work_doColorOff;
begin
  FColors[1] := ToInteger(_Data);
  DeleteObject(FBr2);
  DeleteObject(FPen1);
  FBr2  := CreateSolidBrush(Color2RGB(FColors[1]));
  FPen1 := CreatePen(ps_Solid,1,Color2RGB(FColors[1]));
  InvalidateRect(Control.Handle, nil, false);
end;

procedure THILED._work_doColorBlick;
begin
  FColors[2] := ToInteger(_Data);
  DeleteObject(FPen2);
  FPen2 := CreatePen(ps_Solid,1,Color2RGB(FColors[2]));
  InvalidateRect(Control.Handle, nil, false);  
end;

procedure THILED._var_Value;
begin
   dtInteger(_Data,byte(FValue));
end;

procedure THILED._onPaint;
var   dX,dY : integer;
      R0: TRect;
      Pen2,Pen3: HPen;
      FRgn : HRgn;
begin
   R0 := Sender.ClientRect;
   Sender.PaintBackGround(DC,@R0);
   case FShape of
      lsCircle: FRgn := CreateEllipticRgnIndirect(R0);
      else      FRgn := CreateRectRgn(R0.Left,R0.Top,R0.Right,R0.Bottom);
   end;
   if FRgn <> 0 then begin
      if FValue then FillRgn(DC,FRgn,FBr1)
      else FillRgn(DC,FRgn,FBr2);
      DeleteObject(FRgn);
   end;
   if FBlick then begin
      SelectObject(DC,PenGray);
      if FValue then begin
         Pen2 := FPen2; Pen3 := FPen3;
      end else begin
         Pen2 := FPen1{FPen4}; Pen3 := FPen5;
      end;
      case FShape of
         lsCircle : begin
            dX := (R0.Right - R0.Left) div 8;
            dY := (R0.Bottom - R0.Top) div 8;
            Arc(DC,R0.Left,R0.Top,R0.Right,R0.Bottom,
                R0.Right,R0.Top,R0.Left,R0.Bottom);
            SelectObject(DC,PenWhite);
            Arc(DC,R0.Left,R0.Top,R0.Right,R0.Bottom,
                R0.Left,R0.Bottom,R0.Right,R0.Top);
            if FValue then begin
               SelectObject(DC,FPen1);
               Arc(DC,R0.Left+1,R0.Top+1,R0.Right-1,R0.Bottom-1,
                   R0.Left+dX-1,R0.Bottom-1,R0.Right-1,R0.Top+dY-1);
            end;
            R0.Left := R0.Right div 5; R0.Right := R0.Right - R0.Left;
            R0.Top := R0.Bottom div 5; R0.Bottom := R0.Bottom - R0.Top;
            SelectObject(DC,Pen2);
            dX := Round((R0.Right - R0.Left) * 0.52);
            dY := Round((R0.Bottom - R0.Top) * 0.52);
            Arc(DC,R0.Left,R0.Top,R0.Right,R0.Bottom,
                R0.Left + dX,R0.Top,R0.Left,R0.Top + dY);
            SelectObject(DC,Pen3);
            dX := Round((R0.Right - R0.Left) * 0.24);
            dY := Round((R0.Bottom - R0.Top) * 0.24);
            Arc(DC,R0.Left,R0.Top,R0.Right,R0.Bottom,
                R0.Left+dX,R0.Top,R0.Left,R0.Top+dY);
         end;
         lsRectangle : begin
            MoveToEx(DC,R0.Left,R0.Bottom,nil);
            LineTo(DC,R0.Left,R0.Top);
            LineTo(DC,R0.Right,R0.Top);
            SelectObject(DC,PenWhite);
            MoveToEx(DC,R0.Right-1,R0.Top,nil);
            LineTo(DC,R0.Right-1,R0.Bottom-1);
            LineTo(DC,R0.Left,R0.Bottom-1);
            if FValue then begin
               SelectObject(DC,FPen1);
               MoveToEx(DC,R0.Right-2,R0.Top+1,nil);
               LineTo(DC,R0.Right-2,R0.Bottom-2);
               LineTo(DC,R0.Left,R0.Bottom-2);
            end;
            R0.Left := R0.Right div 12; R0.Right := R0.Right - R0.Left;
            R0.Top := R0.Bottom div 8; R0.Bottom := R0.Bottom - R0.Top;
            SelectObject(DC,Pen2);
            MoveToEx(DC,R0.Left+1,R0.Bottom-2,nil);
            LineTo(DC,R0.Left+1,R0.Top+1);
            LineTo(DC,R0.Left+((R0.Right-R0.Left) div 3),R0.Top+1);
            SelectObject(DC,Pen3);
            MoveToEx(DC,R0.Left+1,R0.Top+2,nil);
            LineTo(DC,R0.Left+1,R0.Top+1);
            LineTo(DC,R0.Left+2,R0.Top+1);
            LineTo(DC,R0.Left+1,R0.Top+2);
         end;
      end;
   end;
end;

procedure THILED._OnClick;
begin
  _hi_OnEvent(_event_onClick);
end;

end.
