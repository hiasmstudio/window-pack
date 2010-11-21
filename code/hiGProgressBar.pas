unit hiGProgressBar;

interface

uses Kol,Share,Win,Windows;

type
  THIGProgressBar = class(THIWin)
   private
    FPosition:integer;
    FLightProgress:TColor;
    FDarkProgress:TColor;
    FKind:byte;
    FInvKindGrad:boolean;
    FMax:integer;
    function CalcViewPos(Value:integer):integer;
    procedure _OnPaint( Sender: PControl; DC: HDC );
    procedure _OnClick( Sender: PObj );
   public
    _event_OnClick:THI_Event;

    property _prop_LightProgress: TColor  write FLightProgress;
    property _prop_DarkProgress : TColor  write FDarkProgress;
    property _prop_Kind         : byte    write FKind;
    property _prop_Max          : integer write FMax;
    property _prop_InvKindGrad  : boolean write FInvKindGrad;

    procedure Init; override;
    procedure _work_doPosition(var _Data:TData; Index:word);
    procedure _work_doLightProgress(var _Data:TData; Index:word);
    procedure _work_doDarkProgress(var _Data:TData; Index:word);
    procedure _work_doInvKindGrad(var _Data:TData; Index:word);
        
    procedure _work_doMax(var _Data:TData; Index:word);
    procedure _var_Position(var _Data:TData; Index:word);
  end;

implementation

//****************************** Градиент **************************************
  
type
  COLOR16 = $0000..$FF00;
  TTriVertex = packed record
    x, y: DWORD;
    Red, Green, Blue, Alpha: COLOR16;
  end;
function GradientFill(DC: HDC; Vertex: Pointer; NumVertex: Cardinal;
                      Mesh: Pointer; NumMesh, Mode: DWORD): BOOL; stdcall;
                      external 'msimg32.dll' name 'GradientFill';

//******************************************************************************

procedure THIGProgressBar.Init;
begin
   Control := NewPaintbox(FParent);
   Control.OnPaint := _OnPaint;
   Control.OnClick := _OnClick;
   inherited;
end;

procedure THIGProgressBar._OnClick;
begin
   _hi_OnEvent(_event_OnClick);
end;

procedure THIGProgressBar._work_doPosition;
begin
   FPosition := max(0, min(FMax, ToInteger(_Data)));
   Control.Invalidate;
end;

procedure THIGProgressBar._work_doMax;
begin
   FMax := ToInteger(_Data);
end;

procedure THIGProgressBar._work_doLightProgress;
begin
   FLightProgress := ToInteger(_Data);
   Control.Invalidate;
end;

procedure THIGProgressBar._work_doDarkProgress;
begin
   FDarkProgress := ToInteger(_Data);
   Control.Invalidate;
end;

procedure THIGProgressBar._work_doInvKindGrad;
begin
   FInvKindGrad := ReadBool(_Data);
   Control.Invalidate;
end;

procedure THIGProgressBar._var_Position;
begin
  dtInteger(_Data,FPosition);
end;

function THIGProgressBar.CalcViewPos;
begin
   Result := 0;
   if FMax = 0 then exit;
   case FKind of
    0: Result := Round((Control.Width / FMax) * value);
    1: Result := Round(Control.Height - (Control.Height / FMax) * value);
   end;
end;

procedure THIGProgressBar._OnPaint;
var   hdcMem: HDC;
      hdcBmp: HBITMAP;
      hWidth,hHeight: integer;
      vert: array[0..1] of TTriVertex;
      gRect: TGradientRect;
      cbRect: TRect;
      StartColor,EndColor: TColor;
      SKind :boolean;
begin
   with Sender{$ifndef F_P}^{$endif} do begin
      Canvas.Brush.Color := Color2RGB(Color);
      if FKind = 0 then
         cbRect := MakeRect(0,0,CalcViewPos(FPosition),Height)
      else
         cbRect := MakeRect(0,CalcViewPos(FPosition),Width,Height);
      hWidth  := cbRect.Right - cbRect.Left;
      hHeight := cbRect.Bottom - cbRect.Top;
      hdcMem  := CreateCompatibleDC(0);
      hdcBmp  := CreateCompatibleBitmap(DC,hWidth,hHeight);
      SelectObject(hdcMem, hdcBmp);

      StartColor := Color2RGB(FDarkProgress);
      EndColor   := Color2RGB(FLightProgress);

      SKind := boolean(FKind); 
      if FInvKindGrad then begin
         SKind := not SKind;
         if SKind then begin
            StartColor := Color2RGB(FLightProgress);
            EndColor   := Color2RGB(FDarkProgress);
         end;
      end;;

      vert[0].x      := 0;
      vert[0].y      := 0;
      vert[0].Alpha  := $ff00; // ???
      vert[0].Red    := GetRValue(EndColor) shl 8;
      vert[0].Green  := GetGValue(EndColor) shl 8;
      vert[0].Blue   := GetBValue(EndColor) shl 8;

      vert[1].x      := hWidth;
      vert[1].y      := hHeight;
      vert[1].Alpha  := vert[0].Alpha;  
      vert[1].Red    := GetRValue(StartColor) shl 8;
      vert[1].Green  := GetGValue(StartColor) shl 8;
      vert[1].Blue   := GetBValue(StartColor) shl 8;

      gRect.UpperLeft  := 0;
      gRect.LowerRight := 1;

      if SKind then
         GradientFill(hdcMem, @vert, 2, @gRect, 1, GRADIENT_FILL_RECT_H)
      else
         GradientFill(hdcMem, @vert, 2, @gRect, 1, GRADIENT_FILL_RECT_V);

      BitBlt(DC, cbRect.Left, cbRect.Top, hWidth, hHeight, hdcMem, 0, 0, SRCCOPY);

      if FKind = 0 then
        FillRect(DC,MakeRect(cbRect.Right,0,Width,Height),Brush.Handle)
      else
        FillRect(DC,MakeRect(0,0,Width,Height - hHeight),Brush.Handle);        
      DeleteDC(hdcMem);
      DeleteObject(hdcBmp);
   end;
end;

end.