unit hiImg_Gradient;

interface

{$I share.inc}

uses Windows,Messages,Kol,Share,Img_Draw;

type
  TGradientStyle  = (SingleVert, SingleHoriz, SingleLeft, SingleRight, DoubleVert, DoubleHoriz, DoubleLeft, DoubleRight, AngleLeftTop, AngleLeftBott, AngleRightTop, AngleRightBott, Center);
   
type
  ThiImg_Gradient = class(THIImg)
   private
    fFrame: boolean;
    fGradient: boolean;
    fInversGrad:boolean;
    fLineSize: integer;
    fStartColor:TColor;
    fEndColor:TColor;
    fFrameColor:TColor;
    fGradientStyle:TGradientStyle;
   public
    
    property _prop_GradientStyle : TGradientStyle write fGradientStyle;
    property _prop_Frame         : boolean write fFrame;
    property _prop_Gradient      : boolean write fGradient;
    property _prop_InversGrad    : boolean write fInversGrad;
    property _prop_StartColor    : integer write fStartColor;
    property _prop_EndColor      : integer write fEndColor;
    property _prop_FrameColor    : integer write fFrameColor;

    procedure _work_doDraw(var _Data:TData; Index:word);
    procedure _work_doGradientStyle(var _Data:TData; Index:word);
    procedure _work_doFrame(var _Data:TData; Index:word);
    procedure _work_doGradient(var _Data:TData; Index:word);
    procedure _work_doInversGrad(var _Data:TData; Index:word);
    procedure _work_doStartColor(var _Data:TData; Index:word);
    procedure _work_doEndColor(var _Data:TData; Index:word);
    procedure _work_doFrameColor(var _Data:TData; Index:word);

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

procedure _Gradient(DC:HDC; cbRect:TRect; Gradient:boolean; StartColor,EndColor,FrameColor:TColor; Frame:boolean; LineSize:integer; InversGrad:boolean; GradientStyle:TGradientStyle; Scale:TScale; LineStyle:Integer);
var   EColor: TRGB;
      SColor: TRGB;
      hdcMem:HDC;
      hdcBmp:HBITMAP;
      br: HBRUSH;
      pen: HPEN;
      Nvert, NgRect:integer;
      vert: array[0..4] of TTriVertex;
      gRect: array[0..1] of TGradientRect;
      gTri: array[0..3] of TGradientTriangle;
begin
TRY
   if (GradientStyle = SingleRight) or (GradientStyle = DoubleRight) then InversGrad := not InversGrad;

   if Gradient and InversGrad then begin
      PColor(@SColor)^:= Color2RGB(EndColor);
      PColor(@EColor)^:= Color2RGB(StartColor);
   end else if Gradient and not InversGrad then begin
      PColor(@SColor)^:= Color2RGB(StartColor);
      PColor(@EColor)^:= Color2RGB(EndColor);
   end else begin
      if InversGrad then
         br := CreateSolidBrush(Color2RGB(StartColor))
      else
         br := CreateSolidBrush(Color2RGB(EndColor));
      SelectObject(DC,br);
      FillRect(DC, cbRect, br);
      DeleteObject(br);
      exit;
   end;

   if (GradientStyle = SingleVert) or (GradientStyle = SingleHoriz) or (GradientStyle = DoubleVert) or (GradientStyle = DoubleHoriz) then begin

      vert[0].x := cbRect.Left;
      vert[0].y := cbRect.Top;
      if (GradientStyle = DoubleHoriz) or (GradientStyle = DoubleVert) then begin
         if GradientStyle = DoubleVert then begin
            vert[1].x := cbRect.Right;
            vert[1].y := (cbRect.Bottom + cbRect.Top) div 2;
            vert[2].x := cbRect.Left;
            vert[2].y := (cbRect.Bottom + cbRect.Top) div 2;
         end else begin
            vert[1].x := (cbRect.Right + cbRect.Left) div 2;
            vert[1].y := cbRect.Bottom;
            vert[2].x := (cbRect.Right + cbRect.Left) div 2;
            vert[2].y := cbRect.Top;
         end;
         vert[3].x     := cbRect.Right;
         vert[3].y     := cbRect.Bottom;
         vert[2].Red   := EColor.R shl 8;
         vert[2].Green := EColor.G shl 8;
         vert[2].Blue  := EColor.B shl 8;
         vert[2].Alpha := $0000;
         vert[3].Red   := SColor.R shl 8;
         vert[3].Green := SColor.G shl 8;
         vert[3].Blue  := SColor.B shl 8;
         vert[3].Alpha := $0000;         
         gRect[1].UpperLeft  := 2;
         gRect[1].LowerRight := 3;
         Nvert := 4;
         NgRect := 2;
      end else begin  
         vert[1].x      := cbRect.Right;
         vert[1].y      := cbRect.Bottom;
         Nvert := 2;
         NgRect := 1;
      end;   

      vert[0].Red    := SColor.R shl 8;
      vert[0].Green  := SColor.G shl 8;
      vert[0].Blue   := SColor.B shl 8;
      vert[0].Alpha  := $0000;
      vert[1].Red    := EColor.R shl 8;
      vert[1].Green  := EColor.G shl 8;
      vert[1].Blue   := EColor.B shl 8;
      vert[1].Alpha  := $0000;
      gRect[0].UpperLeft  := 0;
      gRect[0].LowerRight := 1;

      if (GradientStyle = SingleVert) or (GradientStyle = DoubleVert) then
         GradientFill(DC, @vert, Nvert, @gRect, NgRect, GRADIENT_FILL_RECT_V)
      else
         GradientFill(DC, @vert, Nvert, @gRect, NgRect, GRADIENT_FILL_RECT_H);

   end else begin

      vert[0].x     := cbRect.Left;
      vert[0].y     := cbRect.Top;
      if (GradientStyle = AngleRightTop) or (GradientStyle = AngleLeftBott)  or (GradientStyle = AngleRightBott) then begin
         vert[0].Red   := EColor.R shl 8;
         vert[0].Green := EColor.G shl 8;
         vert[0].Blue  := EColor.B shl 8;
      end else begin
         vert[0].Red   := SColor.R shl 8;
         vert[0].Green := SColor.G shl 8;
         vert[0].Blue  := SColor.B shl 8;
      end;
      vert[0].Alpha := $0000;
      
      vert[1].x     := cbRect.Right;
      vert[1].y     := cbRect.Top;
      if (GradientStyle = Center) or (GradientStyle = AngleRightTop) then begin 
         vert[1].Red   := SColor.R shl 8;
         vert[1].Green := SColor.G shl 8;
         vert[1].Blue  := SColor.B shl 8;
      end else begin
         vert[1].Red   := EColor.R shl 8;
         vert[1].Green := EColor.G shl 8;
         vert[1].Blue  := EColor.B shl 8;
      end;
      vert[1].Alpha := $0000;

      vert[2].x     := cbRect.Left;
      vert[2].y     := cbRect.Bottom;
      if (GradientStyle = Center) or (GradientStyle = AngleLeftBott) then begin
         vert[2].Red   := SColor.R shl 8;
         vert[2].Green := SColor.G shl 8;
         vert[2].Blue  := SColor.B shl 8;
      end else begin
         vert[2].Red   := EColor.R shl 8;
         vert[2].Green := EColor.G shl 8;
         vert[2].Blue  := EColor.B shl 8;
      end;
      vert[2].Alpha := $0000;

      vert[3].x     := cbRect.Right;
      vert[3].y     := cbRect.Bottom;
      if (GradientStyle = AngleRightTop) or (GradientStyle = AngleLeftTop) or (GradientStyle = AngleLeftBott) then begin
         vert[3].Red   := EColor.R shl 8;
         vert[3].Green := EColor.G shl 8;
         vert[3].Blue  := EColor.B shl 8;
      end else begin
         vert[3].Red   := SColor.R shl 8;
         vert[3].Green := SColor.G shl 8;
         vert[3].Blue  := SColor.B shl 8;
      end;
      vert[3].Alpha := $0000;
  
      vert[4].x     := (cbRect.Right + cbRect.Left) div 2;
      vert[4].y     := (cbRect.Bottom + cbRect.Top) div 2;
      vert[4].Red   := EColor.R shl 8;
      vert[4].Green := EColor.G shl 8;
      vert[4].Blue  := EColor.B shl 8;
      vert[4].Alpha := $0000;

      if (GradientStyle = SingleRight) or (GradientStyle = SingleLeft) then begin
         vert[1].x     := vert[1].x * 2;
         vert[2].y     := vert[2].y * 2;
         vert[3].x     := vert[3].x * 2;
         vert[3].y     := vert[3].y * 2;                      
      end;

      if GradientStyle = Center then begin
         gTri[0].Vertex1 := 0;
         gTri[0].Vertex2 := 1;
         gTri[0].Vertex3 := 4;
         gTri[1].Vertex1 := 1;
         gTri[1].Vertex2 := 3;
         gTri[1].Vertex3 := 4;
         gTri[2].Vertex1 := 2;
         gTri[2].Vertex2 := 3;
         gTri[2].Vertex3 := 4;
         gTri[3].Vertex1 := 2;
         gTri[3].Vertex2 := 0;
         gTri[3].Vertex3 := 4;
      end else if (GradientStyle = AngleRightTop) or (GradientStyle = AngleLeftTop) then begin
            gTri[0].Vertex2 := 2;
            gTri[0].Vertex3 := 3;
            gTri[1].Vertex2 := 0;
            gTri[1].Vertex3 := 1;
            if GradientStyle = AngleLeftTop then begin
               gTri[0].Vertex1 := 0;
               gTri[1].Vertex1 := 3;
            end else begin  
               gTri[0].Vertex1 := 1;
               gTri[1].Vertex1 := 2;
            end;
      end else if (GradientStyle = AngleRightBott) or (GradientStyle = AngleLeftBott) then begin
               gTri[0].Vertex2 := 0;
               gTri[0].Vertex3 := 1;
               gTri[1].Vertex1 := 2;
               gTri[1].Vertex2 := 3;
            if GradientStyle = AngleLeftBott then begin
               gTri[0].Vertex1 := 2;
               gTri[1].Vertex3 := 1;
            end else begin  
               gTri[0].Vertex1 := 3;
               gTri[1].Vertex3 := 0;
            end;
      end else begin
         gTri[0].Vertex1 := 0;
         gTri[0].Vertex2 := 1;
         gTri[1].Vertex1 := 3;
         gTri[1].Vertex3 := 2;
         if (GradientStyle = SingleLeft) or (GradientStyle = DoubleLeft) then begin
            gTri[0].Vertex3 := 2;
            gTri[1].Vertex2 := 1;
         end else begin  
            gTri[0].Vertex3 := 3;
            gTri[1].Vertex2 := 0;
         end;
      end;

      if GradientStyle = Center then
         GradientFill(DC, @vert, 5, @gTri, 4, GRADIENT_FILL_TRIANGLE)
      else if (GradientStyle = SingleRight) or (GradientStyle = SingleLeft) then begin
         hdcMem:= CreateCompatibleDC(0);
         hdcBmp:= CreateCompatibleBitmap(DC,vert[1].x-vert[0].x, vert[2].y-vert[0].y);
         SelectObject(hdcMem, hdcBmp);         
         GradientFill(hdcMem, @vert, 4, @gTri, 1, GRADIENT_FILL_TRIANGLE);
         if GradientStyle = SingleLeft then
            BitBlt(DC, cbRect.Left, cbRect.Top, cbRect.Right-cbRect.Left, cbRect.Bottom-cbRect.Top, hdcMem, vert[0].x, vert[0].y, SRCCOPY)
         else
            BitBlt(DC, cbRect.Left, cbRect.Top, cbRect.Right-cbRect.Left, cbRect.Bottom-cbRect.Top, hdcMem, vert[1].x div 2, vert[1].y, SRCCOPY);         
         DeleteDC(hdcMem);
         DeleteObject(hdcBmp);        
      end else          
         GradientFill(DC, @vert, 4, @gTri, 2, GRADIENT_FILL_TRIANGLE)

   end;      

FINALLY
   if Frame then begin
      br := GetStockObject(NULL_BRUSH);
      pen := CreatePen(LineStyle, Round((Scale.x + Scale.y) * LineSize/2), Color2RGB(FrameColor));
      SelectObject(DC,br);
      SelectObject(DC,Pen);
      Rectangle(DC, cbRect.Left, cbRect.Top, cbRect.Right, cbRect.Bottom);
      DeleteObject(br);
      DeleteObject(Pen);   
   end;
END;   
end;

//******************************************************************************

procedure ThiImg_Gradient._work_doDraw;
var   dt: TData;
      ARect:TRect;
      hdcMem:HDC;
      hdcBmp:HBITMAP;
      mTransform: PTransform;
      change: boolean;
begin
   dt := _Data;
TRY
   if not ImgGetDC(_Data) then exit;

   ReadXY(_Data);
   ImgNewSizeDC;
   fLineSize := ReadInteger(_Data,_data_Size,_prop_Size);
   mTransform := ReadObject(_Data, _data_Transform, TRANSFORM_GUID);
   case fDrawSource of
      dcHandle, 
      dcBitmap : begin
                  if mTransform <> nil then
                   if mTransform._Set(pDC,oldx1,oldy1,oldx2,oldy2) then  //если необходимо изменить координаты (rotate, flip)
                     PRect(@oldx1)^ := mTransform._GetRect(MakeRect(oldx1, oldy1, oldx2, oldy2));
                  _Gradient(pDC, PRect(@oldx1)^, fGradient, fStartColor, fEndColor, fFrameColor, fFrame, fLineSize, fInversGrad, fGradientStyle, SingleScale, ord(_prop_LineStyle)); 
                 end;
      dcContext: begin 
                  if mTransform <> nil then
                   if mTransform._Set(pDC,x1,y1,x2,y2) then  //если необходимо изменить координаты (rotate, flip)
                    begin
                     PRect(@x1)^ := mTransform._GetRect(MakeRect(x1,y1,x2,y2));
                     newwh := x2-x1;
                     newhh := y2-y1;
                    end; 
                    hdcMem:= CreateCompatibleDC(0);
                    hdcBmp:= CreateCompatibleBitmap(pDC, newwh, newhh);
                    SelectObject(hdcMem, hdcBmp);  
                    ARect := MakeRect(0, 0, newwh, newhh);
                    _Gradient(hdcMem, ARect, fGradient, fStartColor, fEndColor, fFrameColor, fFrame, fLineSize, fInversGrad, fGradientStyle, fScale, ord(_prop_LineStyle));
                    BitBlt(pDC, x1, y1, newwh, newhh, hdcMem, 0, 0, SRCCOPY);
                    DeleteDC(hdcMem);
                    DeleteObject(hdcBmp);
               end;
   end;               
   if mTransform <> nil then mTransform._Reset(pDC); // сброс трансформации
FINALLY
   ImgReleaseDC;
   _hi_CreateEvent(_Data,@_event_onDraw,dt);
END;
end;

procedure ThiImg_Gradient._work_doGradientStyle;begin fGradientStyle := TGradientStyle(ToInteger(_Data));end;
procedure ThiImg_Gradient._work_doFrame;        begin fFrame := ReadBool(_Data);end;
procedure ThiImg_Gradient._work_doGradient;     begin fGradient := ReadBool(_Data);end;
procedure ThiImg_Gradient._work_doInversGrad;   begin fInversGrad := ReadBool(_Data);end;
procedure ThiImg_Gradient._work_doStartColor;   begin fStartColor := ToInteger(_Data);end;
procedure ThiImg_Gradient._work_doEndColor;     begin fEndColor := ToInteger(_Data);end;
procedure ThiImg_Gradient._work_doFrameColor;   begin fFrameColor := ToInteger(_Data);end;

end.