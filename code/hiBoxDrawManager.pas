unit hiBoxDrawManager;

interface
     
uses Messages,Windows,Kol,Share,Debug;

const
   NONE     = 0;
   GRADIENT = 1;

const   SHIFT_PICTURE = 6;

type
  TIBoxDrawManager = record
    draw:function(Sender: PObj; DC: HDC; const Rect: TRect; ItemIdx: integer; ItemState: TDrawState; Transparent:boolean; sFont:HFONT; strItemIdx:string=''): Boolean of object;
    shift:function:byte of object;
  end;
  IBoxDrawManager = ^TIBoxDrawManager;

  THIBoxDrawManager = class(TDebug)
   private
     bdm:TIBoxDrawManager;
     function _shift:byte;
     function draw(Sender: PObj; DC: HDC; const Rect: TRect; ItemIdx: integer; ItemState: TDrawState; Transparent:boolean; sFont:HFONT; strItemIdx:string=''): Boolean;
     function shift:byte;
          
   public
     _prop_Name:string;
     _prop_Gradient      : boolean;
     _prop_Gutter        : boolean;
     _prop_Horizontal    : boolean;
     _prop_Frame         : boolean;
     _prop_BumpText      : boolean;
     _prop_InversClrTxt  : boolean;
     _prop_InversGrad    : boolean;
     _prop_InversGutt    : boolean;
     _prop_InversBack    : boolean;
     _prop_CutText       : boolean;
     _prop_SelComboEdit  : boolean;     
//
     _prop_LightColor    : TColor;
     _prop_DarkColor     : TColor;
     _prop_ColorFrame    : TColor;
     _prop_LightClrGutt  : TColor;
     _prop_DarkClrGutt   : TColor;
     _prop_LightClrBack  : TColor;
     _prop_DarkClrBack   : TColor;
     _prop_DepthGradient : integer;
     _prop_DepthGutter   : integer;
     _prop_DepthBack     : integer;
     _prop_StyleBack     : byte;
     _prop_ImageShift    : integer;
     _prop_GutterWidth   : integer;
     _prop_GutterShift   : integer;     

     constructor Create;
     function getInterfaceBoxDraw:IBoxDrawManager;

     procedure _work_doGradient(var _Data:TData; Index:word);
     procedure _work_doGutter(var _Data:TData; Index:word);
     procedure _work_doHorizontal(var _Data:TData; Index:word);     
     procedure _work_doFrame(var _Data:TData; Index:word);
     procedure _work_doBumpText(var _Data:TData; Index:word);
     procedure _work_doInversClrTxt(var _Data:TData; Index:word);
     procedure _work_doInversGrad(var _Data:TData; Index:word);
     procedure _work_doInversGutt(var _Data:TData; Index:word);
     procedure _work_doInversBack(var _Data:TData; Index:word);
     procedure _work_doCutText(var _Data:TData; Index:word);
     procedure _work_doSelComboEdit(var _Data:TData; Index:word);
//
     procedure _work_doLightColor(var _Data:TData; Index:word);
     procedure _work_doDarkColor(var _Data:TData; Index:word);
     procedure _work_doColorFrame(var _Data:TData; Index:word);
     procedure _work_doLightClrGutt(var _Data:TData; Index:word);
     procedure _work_doDarkClrGutt(var _Data:TData; Index:word);
     procedure _work_doLightClrBack(var _Data:TData; Index:word);
     procedure _work_doDarkClrBack(var _Data:TData; Index:word);
     procedure _work_doDepthGradient(var _Data:TData; Index:word);
     procedure _work_doDepthGutter(var _Data:TData; Index:word);
     procedure _work_doDepthBack(var _Data:TData; Index:word);
     procedure _work_doStyleBack(var _Data:TData; Index:word);
     procedure _work_doImageShift(var _Data:TData; Index:word);
     procedure _work_doGutterWidth(var _Data:TData; Index:word);
     procedure _work_doGutterShift(var _Data:TData; Index:word);
     
  end;

implementation

//-----------------------   Графические методы   ----------------------

type

  AGRBQuad = array [0..0] of RGBQuad;
  PAGRBQuad = ^AGRBQuad;

  PPoints = ^TPoints;
  TPoints = array[0..0] of TPoint;

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

procedure _Gradient(Sender:PControl; DC:HDC; cbRect:TRect; Gradient:boolean; DepthGradient:integer;
                    StartColor,EndColor,ColorFrame:TColor; Frame,Horizontal,InversGrad:boolean);
var   vert: array[0..1] of TTriVertex;
      points: array[0..4] of TPoint;
      gRect: TGradientRect;
      pen: HPEN;
      Mode: DWORD;
begin
   StartColor := Color2RGB(StartColor);
   EndColor   := Color2RGB(EndColor);

   if Gradient then
      StartColor:= GetLightColor(StartColor, max(0,min(100,DepthGradient)))
   else
      EndColor := StartColor;

   if Frame then begin
      vert[0].x      := cbRect.Left + 1;
      vert[0].y      := cbRect.Top + 1;
      vert[1].x      := cbRect.Right - 1;
      vert[1].y      := cbRect.Bottom - 1;

      points[0].x    := cbRect.Left;
      points[0].y    := cbRect.Bottom - 1;
      points[1].x    := cbRect.Left;      
      points[1].y    := cbRect.Top;      
      points[2].x    := cbRect.Right - 1;      
      points[2].y    := cbRect.Top;      
      points[3].x    := cbRect.Right - 1;      
      points[3].y    := cbRect.Bottom - 1;      
      points[4].x    := cbRect.Left;      
      points[4].y    := cbRect.Bottom - 1;      

      pen := CreatePen(PS_SOLID, 1, Color2RGB(ColorFrame));
      SelectObject(DC, pen);      
      polyline(DC, PPoints(@points)^, Length(points));
      DeleteObject(pen);
   end else begin
      vert[0].x      := cbRect.Left;
      vert[0].y      := cbRect.Top;
      vert[1].x      := cbRect.Right;
      vert[1].y      := cbRect.Bottom;
   end;
   vert[0].Alpha  := $ff00; // ???
   vert[1].Alpha  := vert[0].Alpha;

   if not InversGrad then begin
      vert[0].Red    := GetRValue(StartColor) shl 8;
      vert[0].Green  := GetGValue(StartColor) shl 8;
      vert[0].Blue   := GetBValue(StartColor) shl 8;
      vert[1].Red    := GetRValue(EndColor)   shl 8;
      vert[1].Green  := GetGValue(EndColor)   shl 8;
      vert[1].Blue   := GetBValue(EndColor)   shl 8;
   end else begin
      vert[1].Red    := GetRValue(StartColor) shl 8;
      vert[1].Green  := GetGValue(StartColor) shl 8;
      vert[1].Blue   := GetBValue(StartColor) shl 8;
      vert[0].Red    := GetRValue(EndColor)   shl 8;
      vert[0].Green  := GetGValue(EndColor)   shl 8;
      vert[0].Blue   := GetBValue(EndColor)   shl 8;
   end;

   gRect.UpperLeft  := 0;
   gRect.LowerRight := 1;

   if Horizontal then
      Mode := GRADIENT_FILL_RECT_H
   else
      Mode := GRADIENT_FILL_RECT_V;

   GradientFill(DC, @vert, 2, @gRect, 1, Mode);
end;

//******************************************************************************

constructor THIBoxDrawManager.Create;
begin
   inherited;
   bdm.draw := draw;
   bdm.shift := shift;
end;

function THIBoxDrawManager.getInterfaceBoxDraw;
begin
   Result := @bdm;
end;

function THIBoxDrawManager._shift;
begin
  if _prop_ImageShift = 0 then
    Result := SHIFT_PICTURE       
  else  
    Result := _prop_ImageShift;
end;

function THIBoxDrawManager.shift;
begin
  Result := _shift;
end;

function THIBoxDrawManager.draw;
var     fControl: PControl;
        ARect,BRect,cbRect,gtRect: TRect;
        _Flags: dword;
        dy,gsh:integer;
begin
   Result:= False;
   fControl:= PControl(Sender);
   with fControl{$ifndef F_P}^{$endif} do begin
      if (Rect.Bottom - Rect.Top > Height) then exit;
      dy := Rect.Bottom - Rect.Top;
      gtRect:= Rect;

      if _prop_GutterShift = 0 then
        gsh:= _shift - 1
      else  
        gsh:= _prop_GutterShift;

      gtRect.Left:= gtRect.Left + gsh;
        
      if _prop_GutterWidth = 0 then
        gtRect.Right:= gtRect.Left + dy + 2
      else
        gtRect.Right:= gtRect.Left + _prop_GutterWidth;

      SelectObject(DC, sFont);

      if not Transparent then begin 
         if (_prop_StyleBack = GRADIENT) then begin
            _Gradient(fControl,DC,Rect,true,_prop_DepthBack,_prop_LightClrBack,
                      _prop_DarkClrBack,0,false,true,_prop_InversBack);
         end;
         if _prop_Gutter and not (odsComboboxEdit in ItemState) then begin
            _Gradient(fControl,DC,gtRect,true,_prop_DepthGutter,_prop_LightClrGutt,
                      _prop_DarkClrGutt,0,false,true,_prop_InversGutt);
         end;
      end;

      if (Itemidx = Count - 1) then begin
         cbRect:= Rect;
         cbRect.Top:= cbRect.Bottom;
         cbRect.Bottom:= Height + Rect.Bottom;
         if ((_prop_StyleBack = GRADIENT) and not (odsComboboxEdit in ItemState)) and not Transparent then begin
            _Gradient(fControl,DC,cbRect,true,_prop_DepthBack,_prop_LightClrBack,
                      _prop_DarkClrBack,0,false,true,_prop_InversBack);
         end;
         if _prop_Gutter and not (odsComboboxEdit in ItemState) then begin
            gtRect.Top:= gtRect.Bottom;
            gtRect.Bottom:= cbRect.Bottom;
            _Gradient(fControl,DC,gtRect,true,_prop_DepthGutter,_prop_LightClrGutt,
                      _prop_DarkClrGutt,0,false,true,_prop_InversGutt);
         end;
      end;
      cbRect:= Rect;
      gtRect.Top:= Rect.Top;
      gtRect.Bottom:= Rect.Bottom;

      if (odsSelected in ItemState) and not (odsComboboxEdit in ItemState) then
         _Gradient(fControl,DC,cbRect,_prop_Gradient,_prop_DepthGradient,_prop_LightColor,_prop_DarkColor,
                   _prop_ColorFrame,_prop_Frame,_prop_Horizontal,_prop_InversGrad)
      else if (odsComboboxEdit in ItemState) and (odsFocused in ItemState) and _prop_SelComboEdit then
         _Gradient(fControl,DC,cbRect,_prop_Gradient,_prop_DepthGradient,_prop_LightColor,_prop_DarkColor,
                   _prop_ColorFrame,_prop_Frame,_prop_Horizontal,_prop_InversGrad)
      else begin
         if (_prop_StyleBack <> GRADIENT) and not Transparent then begin
            Canvas.Brush.Color:= Color;
            FillRect(DC,cbRect,Canvas.Brush.Handle);
         end;
         if _prop_Gutter and not (odsComboboxEdit in ItemState) then
            _Gradient(fControl,DC,gtRect,true,_prop_DepthGutter,_prop_LightClrGutt,
                      _prop_DarkClrGutt,0,false,true,_prop_InversGutt);

      end;

      ARect:= Rect;
      ARect.Left := gtRect.Right + Canvas.TextExtent('W').cx div 2;  

      if (odsComboboxEdit in ItemState) then ARect.Left:= ARect.Left - 2;
      BRect:= ARect;
      inc(BRect.Left); inc(BRect.Top); inc(BRect.Right); inc(BRect.Bottom);
      SetTextColor(DC,Color2RGB(Font.Color));
      SetBkMode(DC, Windows.TRANSPARENT);

      if ItemIdx >= 0 then begin
         if _prop_CutText then
            _Flags:=  DT_SINGLELINE or DT_VCENTER or DT_NOPREFIX or DT_WORD_ELLIPSIS
         else
            _Flags:=  DT_SINGLELINE or DT_VCENTER or DT_NOPREFIX;

         if _prop_BumpText then begin
            if (odsSelected in ItemState) and _prop_Gradient then begin
               if _prop_InversClrTxt then
                  SetTextColor(DC,Color2RGB(clBackground))
               else
                  SetTextColor(DC,Color2RGB(clHighlightText));
                  if strItemIdx = '' then
                    DrawText(DC, PChar(Items[ItemIdx]), -1, BRect, _Flags)                  
                  else
                    DrawText(DC, PChar(strItemIdx), -1, BRect, _Flags);

               if _prop_InversClrTxt then
                  SetTextColor(DC,Color2RGB(clHighlightText))
               else
                  SetTextColor(DC,Color2RGB(Font.Color));
            end else if not (odsSelected in ItemState) and (_prop_StyleBack = GRADIENT) then begin
               SetTextColor(DC,Color2RGB(clBackground));
               if strItemIdx = '' then
                 DrawText(DC, PChar(Items[ItemIdx]), -1, BRect, _Flags)
               else
                 DrawText(DC, PChar(strItemIdx), -1, BRect, _Flags);               
               SetTextColor(DC,Color2RGB(clHighlightText));
            end else
               SetTextColor(DC,Color2RGB(Font.Color));
         end else if (odsSelected in ItemState) then begin
            if _prop_InversClrTxt then
               SetTextColor(DC,Color2RGB(clHighlightText))
            else
               SetTextColor(DC,Color2RGB(Font.Color));
         end else
            SetTextColor(DC,Color2RGB(Font.Color));
            if strItemIdx = '' then
              DrawText(DC, PChar(Items[ItemIdx]), -1, ARect, _Flags)
            else
              DrawText(DC, PChar(strItemIdx), -1, ARect, _Flags)              
      end;
   end;  
   Result:= True;
end;

procedure THIBoxDrawManager._work_doGradient;
begin
  _prop_Gradient := ReadBool(_Data);
end;

procedure THIBoxDrawManager._work_doGutter;
begin
  _prop_Gutter := ReadBool(_Data);
end;

procedure THIBoxDrawManager._work_doHorizontal;     
begin
  _prop_Horizontal := ReadBool(_Data);
end;

procedure THIBoxDrawManager._work_doFrame;
begin
  _prop_Frame := ReadBool(_Data);
end;

procedure THIBoxDrawManager._work_doBumpText;
begin
  _prop_BumpText := ReadBool(_Data);
end;

procedure THIBoxDrawManager._work_doInversClrTxt;
begin
  _prop_InversClrTxt := ReadBool(_Data);
end;

procedure THIBoxDrawManager._work_doInversGrad;
begin
  _prop_InversGrad := ReadBool(_Data);
end;

procedure THIBoxDrawManager._work_doInversGutt;
begin
  _prop_InversGutt := ReadBool(_Data);
end;

procedure THIBoxDrawManager._work_doInversBack;
begin
  _prop_InversBack := ReadBool(_Data);
end;

procedure THIBoxDrawManager._work_doCutText;
begin
  _prop_CutText := ReadBool(_Data);
end;

procedure THIBoxDrawManager._work_doSelComboEdit;
begin
  _prop_SelComboEdit := ReadBool(_Data);
end;

procedure THIBoxDrawManager._work_doLightColor;
begin
  _prop_LightColor := ToInteger(_Data);
end;

procedure THIBoxDrawManager._work_doDarkColor;
begin
  _prop_DarkColor := ToInteger(_Data);
end;

procedure THIBoxDrawManager._work_doColorFrame;
begin
  _prop_ColorFrame := ToInteger(_Data);
end;

procedure THIBoxDrawManager._work_doLightClrGutt;
begin
  _prop_LightClrGutt := ToInteger(_Data);
end;

procedure THIBoxDrawManager._work_doDarkClrGutt;
begin
  _prop_DarkClrGutt := ToInteger(_Data);
end;

procedure THIBoxDrawManager._work_doLightClrBack;
begin
  _prop_LightClrBack := ToInteger(_Data);
end;

procedure THIBoxDrawManager._work_doDarkClrBack;
begin
  _prop_DarkClrBack := ToInteger(_Data);
end;

procedure THIBoxDrawManager._work_doDepthGradient;
begin
  _prop_DepthGradient := ToInteger(_Data);
end;

procedure THIBoxDrawManager._work_doDepthGutter;
begin
  _prop_DepthGutter := ToInteger(_Data);
end;

procedure THIBoxDrawManager._work_doDepthBack;
begin
  _prop_DepthBack := ToInteger(_Data);
end;

procedure THIBoxDrawManager._work_doStyleBack;
begin
  _prop_StyleBack := ToInteger(_Data);
end;

procedure THIBoxDrawManager._work_doImageShift;
begin
  _prop_ImageShift := ToInteger(_Data);
end;

procedure THIBoxDrawManager._work_doGutterWidth;
begin
  _prop_GutterWidth := ToInteger(_Data);
end;

procedure THIBoxDrawManager._work_doGutterShift;
begin
  _prop_GutterShift := ToInteger(_Data);
end;

end.