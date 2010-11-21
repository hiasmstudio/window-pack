unit hiLedLadder; { Светодиодный индикатор ver 2.60 }

interface

uses Windows,Messages,Kol,Share,Win;

////////////////////////////////////////////////////////////////////////////
//               Переопределяем типы и функцию GradientFill               //
////////////////////////////////////////////////////////////////////////////
type
  COLOR16 = $0000..$FF00; //Этот тип в Windows.pas определен неправильно

  // Переопределяем  TTriVertex с правильным типом. Эта структура описывает
  // точку-вершину (Vertex)
  TTriVertex = packed record
    x, y: DWORD; // Координаты вершины
    Red, Green, Blue, Alpha: COLOR16; //Каналы цветов
  end;
  // GradientFill определена в Windows.pas, но мы ее переобъявляем  для
  // правильного типа TTriVertex. Не для Win95 и WinNT.
function GradientFill(DC: HDC; Vertex: Pointer; NumVertex: Cardinal;
                      Mesh: Pointer; NumMesh, Mode: DWORD): BOOL; stdcall;
                      external 'msimg32.dll' name 'GradientFill';
/////////////////////////////////////////////////////////////////////////////

type
  TOrientation = (orVertical, orHorizontal); //Направления заливки

type
  TTrackBarOrientation = (trHorizontal, trVertical);

type
 ThiLedLadder = class(THIWin)

  private
    fOrientation : TTrackbarOrientation;
    fLEDCount : Integer;
    fLEDPosition : Integer;
    fSpacing : Integer;
    fMinMid : Integer;
    fMidMax : Integer;
    fMax : Integer;
    fPosition : Integer;
    fFonColor: TColor;
    fSegColorMin: TColor;
    fNoSegColorMin: TColor;
    fSegColorMid: TColor;
    fNoSegColorMid: TColor;
    fSegColorMax: TColor;
    fNoSegColorMax: TColor;
    fGradient: boolean;
    procedure _OnClick( Sender: PObj );
//    procedure _OnPaint( Sender: PControl; DC: HDC ); override;
    procedure _OnPaint( Sender: PControl; DC: HDC );
  public
    _event_OnClick : THI_Event;
    _prop_Kind : Byte;

    property _prop_Gradient: boolean     write fGradient;
    property _prop_Count: Integer        write fLEDCount;
    property _prop_Spacing: Integer      write fSpacing;
    property _prop_MinMid: Integer       write fMinMid;
    property _prop_MidMax: Integer       write fMidMax;    
    property _prop_Max: Integer          write fMax;
    property _prop_FonColor: TColor      write fFonColor;
    property _prop_SegColorMin: TColor   write fSegColorMin;
    property _prop_NoSegColorMin: TColor write fNoSegColorMin;
    property _prop_SegColorMid: TColor   write fSegColorMid;
    property _prop_NoSegColorMid: TColor write fNoSegColorMid;
    property _prop_SegColorMax: TColor   write fSegColorMax;
    property _prop_NoSegColorMax: TColor write fNoSegColorMax;

    procedure Init;override;
    procedure _work_doPosition(var _Data:TData; Index:word);
    procedure _work_doMax(var _Data:TData; Index:word);
    
    procedure _work_doCount(var _Data:TData; Index:word);
    procedure _work_doSpacing(var _Data:TData; Index:word);
    procedure _work_doMinMid(var _Data:TData; Index:word);
    procedure _work_doMidMax(var _Data:TData; Index:word);    
    procedure _work_doFonColor(var _Data:TData; Index:word);
    procedure _work_doSegColorMin(var _Data:TData; Index:word);
    procedure _work_doNoSegColorMin(var _Data:TData; Index:word);
    procedure _work_doSegColorMid(var _Data:TData; Index:word);
    procedure _work_doNoSegColorMid(var _Data:TData; Index:word);
    procedure _work_doSegColorMax(var _Data:TData; Index:word);
    procedure _work_doNoSegColorMax(var _Data:TData; Index:word);
    procedure _work_doGradient(var _Data:TData; Index:word);
    
    procedure _var_Position(var _Data:TData; Index:word);
end;

implementation

//-----------------------   Графические методы   ----------------------

type

  AGRBQuad = array [0..0] of RGBQuad;
  PAGRBQuad = ^AGRBQuad;

  PColor = ^TColor;

function GetLightColor(Color: TColor; Light: Byte) : TColor;
var   fFrom: TRGB;
begin
  PColor(@fFrom)^:= Color2RGB(Color);
  Result := RGB(
    (FFrom.R*100 + (255 - FFrom.R) * Light) div 100,
    (FFrom.G*100 + (255 - FFrom.G) * Light) div 100,
    (FFrom.B*100 + (255 - FFrom.B) * Light) div 100
  );
end;

function GetShadeColor(Color: TColor; Shade: Byte) : TColor;
var   fFrom: TRGB;
begin
  PColor(@fFrom)^:= Color2RGB(Color);
  Result := RGB(
    Max(0, FFrom.R - Shade),
    Max(0, FFrom.G - Shade),
    Max(0, FFrom.B - Shade)
  );
end;

/////////////////////////////////////////////////////////////////
//            Градиентная заливка прямоугольника               //
/////////////////////////////////////////////////////////////////

procedure _Gradient(DC:HDC; cbRect:TRect; Gradient:boolean; ContrastGradient:integer; StartColor,EndColor:TColor; Orientation:TOrientation; InversGrad:boolean);
var
  //Массив вершин (нам нужны две - верхнелевая и нижнеправая)
  vert: array[0..1] of TTriVertex;
  gRect: TGradientRect; //Индексы вершин в массиве vert (из Windows.pas)
begin

   if Gradient then
      StartColor:= GetLightColor(StartColor, max(0,100-ContrastGradient))
   else
      EndColor := StartColor; 
       
   // Определяем вершины
   vert[0].x      := cbRect.Left;
   vert[0].y      := cbRect.Top;
   vert[1].x      := cbRect.Right;
   vert[1].y      := cbRect.Bottom;
   vert[0].Alpha  := $ff00; // ???
   vert[1].Alpha  := vert[0].Alpha;  

   if not InversGrad then begin
      vert[0].Red    := GetRValue(StartColor) shl 8; // Значение цвета смещаем
      vert[0].Green  := GetGValue(StartColor) shl 8; // влево на 1 байт,
      vert[0].Blue   := GetBValue(StartColor) shl 8; // чтобы получилось 2 байта.
      vert[1].Red    := GetRValue(EndColor) shl 8;
      vert[1].Green  := GetGValue(EndColor) shl 8;
      vert[1].Blue   := GetBValue(EndColor) shl 8;
   end else begin
      vert[1].Red    := GetRValue(StartColor) shl 8; // Значение цвета смещаем
      vert[1].Green  := GetGValue(StartColor) shl 8; // влево на 1 байт,
      vert[1].Blue   := GetBValue(StartColor) shl 8; // чтобы получилось 2 байта.
      vert[0].Red    := GetRValue(EndColor) shl 8;
      vert[0].Green  := GetGValue(EndColor) shl 8;
      vert[0].Blue   := GetBValue(EndColor) shl 8;
   end;

   gRect.UpperLeft  := 0; // Назначаем вершины верхнелевому
   gRect.LowerRight := 1; // и нижнеправому углам.

   // Заливаем в зависимости от ориентации
   if Orientation = orHorizontal then
      GradientFill(DC, @vert, 2, @gRect, 1, GRADIENT_FILL_RECT_H)
   else
      GradientFill(DC, @vert, 2, @gRect, 1, GRADIENT_FILL_RECT_V);
end;

procedure ThiLedLadder.Init;
begin
   Control := NewPaintbox(FParent);
   Control.Tag := longint(Self);
   Control.OnPaint := _OnPaint;
   Control.OnClick := _OnClick;
   case _prop_Kind of
    0: fOrientation := trHorizontal;
    1: fOrientation := trVertical;
   end; 
   fPosition := 0;
inherited;
end;

procedure ThiLedLadder._OnClick;
begin
   _hi_OnEvent(_event_OnClick);
end;

Procedure ThiLedLadder._OnPaint;
var   i, ledHeight, posLED, posMinMid, posMidMax, delta: Integer;
      rect: TRect;
      FBitMap: PBitMap;
      SColor, GColor: TColor;
begin
   with Control {$ifndef F_P}^{$endif} do begin
      FBitMap := NewDIBBitmap(width, height, pf32bit);
   TRY
      with FBitMap.Canvas{$ifndef F_P}^{$endif} do begin
         Brush.Color := fFonColor;
         Fillrect(ClipRect);
         FrameRect (MakeRect (0, 0, Width, Height));
         posLED := ((fLedPosition * fLedCount + fLedCount div 2) * fLedCount - 1) div (fMax * fLEDCount);
         posMinMid := fLedCount * fMinMid div fMax - 1;
         posMidMax := fLedCount * fMidMax div fMax - 1;
         if fOrientation = trVertical then begin
            ledHeight := height div fLedCount;
            delta := height mod fLedCount;
         end else begin
            ledHeight := (width - fSpacing) div fLedCount - fSpacing;       
            delta := 0;
         end;
         for i := 0 to fLedCount - 1 do begin
            if (i < posLED) and (i < posMinMid) then
               Brush.Color := fSegColorMin
            else if (i < posLED) and (i < posMidMax) then
               Brush.Color := fSegColorMid                  
            else if (i < posLED) and (i < fLEDCount) then
               Brush.Color := fSegColorMax
            else if (i >= posLED) and (i < posMinMid) then
               Brush.Color := fNoSegColorMin
            else if (i >= posLED) and (i < posMidMax) then
               Brush.Color := fNoSegColorMid                  
            else if (i >= posLED) and (i < fLEDCount) then
               Brush.Color := fNoSegColorMax
            else
               Brush.Color := fFonColor;    
            GColor := Brush.Color;
            SColor := GetShadeColor(GColor,100);
               
            if fOrientation = trVertical then begin
               rect.Left := 1;
               rect.right := width - 1;
               rect.Top := (fLedCount - i - 1) * ledHeight + delta;
               rect.Bottom := rect.Top + ledHeight - fSpacing;
               if fGradient then
                  _Gradient(Handle,Rect,true,100,GColor,SColor,orHorizontal,false)
               else
                  FillRect(rect);
            end else begin
               rect.top := 1;
               rect.bottom := height - 1;
               rect.left := i * (ledHeight + fSpacing) + fSpacing;
               if (i = 0) and (fSpacing = 0) then rect.left := rect.left +1; 
               rect.right := rect.left + ledHeight;
               if fGradient then
                  _Gradient(Handle,Rect,true,100,GColor,SColor,orVertical,false)
               else
                  FillRect(rect);
            end;
         end;   
      end;
//      FBitMap.Draw( Control.Canvas.Handle, 0, 0 );
      BitBlt(Control.Canvas.Handle, 0, 0, width, height, FBitMap.Canvas.Handle, 0, 0, SRCCOPY);
   FINALLY
      FBitMap.free;
   END;
   end;
end;

Procedure ThiLedLadder._work_doPosition;
begin
   fLedPosition := ToInteger(_Data);
   Control.Invalidate;
end;

Procedure ThiLedLadder._work_doMax;
begin
   fMax := ToInteger(_Data);
end;

procedure ThiLedLadder._work_doMinMid;
begin
   FMinMid := ToInteger(_Data);
end;

procedure ThiLedLadder._work_doMidMax;    
begin
   FMidMax := ToInteger(_Data);
end;

procedure ThiLedLadder._work_doCount;
begin
   fLEDCount := ToInteger(_Data);
   if fLEDCount < 2 then fLEDCount := 2;   
   Control.Invalidate;
end;

procedure ThiLedLadder._work_doSpacing;
begin
   fSpacing := ToInteger(_Data);
   if fSpacing < 0 then fSpacing := 0;
   Control.Invalidate;
end;

procedure ThiLedLadder._work_doFonColor;
begin
   fFonColor := ToInteger(_Data);
   Control.Invalidate;
end;

procedure ThiLedLadder._work_doSegColorMin;
begin
   fSegColorMin := ToInteger(_Data);
   Control.Invalidate;
end;

procedure ThiLedLadder._work_doNoSegColorMin;
begin
   fNoSegColorMin := ToInteger(_Data);
   Control.Invalidate;
end;

procedure ThiLedLadder._work_doSegColorMid;
begin
   fSegColorMid := ToInteger(_Data);
   Control.Invalidate;
end;

procedure ThiLedLadder._work_doNoSegColorMid;
begin
   fNoSegColorMid := ToInteger(_Data);
   Control.Invalidate;
end;

procedure ThiLedLadder._work_doSegColorMax;
begin
   fSegColorMax := ToInteger(_Data);
   Control.Invalidate;
end;

procedure ThiLedLadder._work_doNoSegColorMax;
begin
   fNoSegColorMax := ToInteger(_Data);
   Control.Invalidate;
end;

procedure ThiLedLadder._work_doGradient;
begin
   fGradient := ReadBool(_Data);
   Control.Invalidate;
end;

procedure ThiLedLadder._var_Position;
begin
   dtInteger(_Data,fLedPosition);
end;

end.
