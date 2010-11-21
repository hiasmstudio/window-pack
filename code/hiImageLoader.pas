unit HiImageLoader; { компонент загрузки и отрисовки изображений ImageLoader}

interface

uses Windows,Messages,Share,Debug,ActiveX,KOLComObj,KOL;

const
   IMGCHG_SIZE         = $0001;
   IMGCHG_VIEW         = $0002;
   IMGCHG_COMPLETE     = $0004;
   IMGCHG_ANIMATE      = $0008;
   IMGCHG_MASK         = $000F;

   IMGLOAD_NOTLOADED   = $00100000;
   IMGLOAD_LOADING     = $00200000;
   IMGLOAD_STOPPED     = $00400000;
   IMGLOAD_ERROR       = $00800000;
   IMGLOAD_COMPLETE    = $01000000;
   IMGLOAD_MASK        = $01F00000;

   IMGBITS_NONE        = $02000000;
   IMGBITS_PARTIAL     = $04000000;
   IMGBITS_TOTAL       = $08000000;
   IMGBITS_MASK        = $0E000000;

   IMGANIM_ANIMATED    = $10000000;
   IMGANIM_MASK        = $10000000;

   IMGTRANS_OPAQUE     = $20000000;
   IMGTRANS_MASK       = $20000000;

   DWN_COLORMODE       = $0000003F;
   DWN_DOWNLOADONLY    = $00000040;
   DWN_FORCEDITHER     = $00000080;
   DWN_RAWIMAGE        = $00000100;

type
   IImgCtx = interface(IUnknown)
      ['{3050f3d7-98b5-11cf-bb82-00aa00bdce0b}']
      // Initialization/Download methods
      function Load(pszUrl:PWChar; dwFlags:DWORD): HResult; stdcall;
      function SelectChanges(ulChgOn:DWORD; ulChgOff:DWORD; fSignal:DWORD): HResult; stdcall;
      function SetCallback(pCallback:pointer; pUserData:pointer): HResult; stdcall;
      function Disconnect: HResult; stdcall;

      // Query methods
      function GetUpdateRects(prc:PRect; var prcImg:TRect; var pcrc:integer): HResult; stdcall;
      function GetStateInfo(var pulState:DWORD; var pSize:TSize; fClearChanges:DWORD): HResult; stdcall;
      function GetPalette(var phpal:HPalette): HResult; stdcall;

      // Rendering methods
      function Draw(_hdc:HDC; var prcBounds:TRect): HResult; stdcall;
      function Tile(_hdc:HDC; var pptBackOrg:TPoint; var prcClip:TRect; var psize:TSize): HResult; stdcall;
      function StretchBlt(_hdc:HDC; dstX,dstY,dstXE,dstYE,srcX,srcY,srcXE,srcYE:integer; dwROP:DWORD): HResult; stdcall;
 end;

THiImageLoader = class(TDebug)
   private
      FImgCtx              : IImgCtx;
      sz                   : TSize;
      sg                   : boolean;
      x1,y1,w1,h1          : integer; //TRect
      x3,y3,w3,h3          : integer; //TRect
   public
      _prop_FileName       : string;
      _prop_BitmapOnLoad   : boolean;
      _prop_DrawSource     : byte;
      _prop_Point1         : integer;
      _prop_Point2         : integer;
      _prop_Point3         : integer;
      _prop_Point4         : integer;
      _prop_Point2AsOffset : boolean;
      _prop_Point4AsOffset : boolean;

      _data_FileName       : THI_Event;
      _data_Bitmap         : THI_Event;
      _data_Point1         : THI_Event;
      _data_Point2         : THI_Event;
      _data_Point3         : THI_Event;
      _data_Point4         : THI_Event;
      _event_onLoad        : THI_Event;
      _event_onDraw        : THI_Event;

      _prop_ScaleMode      : procedure(dc:hdc) of object;

      procedure Draw(dc:hdc);
      procedure Stretch(dc:hdc);
      procedure ScaleMin(dc:hdc);
      procedure ScaleMax(dc:hdc);
      procedure Mosaic(dc:hdc);
      procedure ReadPoints(var _Data:TData);

      procedure _work_doLoad(var _Data:TData; idx:word);
      procedure _work_doDraw0(var _Data:TData; idx:word);
      procedure _work_doDraw1(var _Data:TData; idx:word);
      procedure _work_doDraw2(var _Data:TData; idx:word);
      procedure _work_doScaleMode(var _Data:TData; idx:word);
      procedure _var_ImageWidth(var _Data:TData; idx:word);
      procedure _var_ImageHeight(var _Data:TData; idx:word);
      procedure _var_Busy(var _Data:TData; idx:word);
end;
implementation

const
   CLSID_IImgCtx:TGUID = '{3050f3d6-98b5-11cf-bb82-00aa00bdce0b}';
   IID_IImgCtx:TGUID   = '{3050f3d7-98b5-11cf-bb82-00aa00bdce0b}';

function StringToWideString(const s: String; codePage: Word): WideString;
var   len: integer;
begin
   Result := '';
   if s = '' then exit;
   len := MultiByteToWideChar(codePage, MB_PRECOMPOSED, PChar(@s[1]), -1, nil, 0);
   SetLength(Result, len - 1);
   if len <= 1 then exit;
   MultiByteToWideChar(CodePage, MB_PRECOMPOSED, PChar(@s[1]), -1, PWideChar(@Result[1]), len);
end;

procedure MyCallback(pCtx:pointer; pUserData:pointer); stdcall;
var   stat: dword;
begin
   with THiImageLoader(pUserData) do  begin
      sg := true;
      FImgCtx.GetStateInfo(stat, sz, 0);
      FImgCtx.Disconnect;
      _hi_onEvent(_event_onLoad);
  end;
end;

procedure THiImageLoader._work_doLoad;
var   s,s1: string;
      len: dword;
      fn: pchar;
begin
   sg := false;
   s1 := ReadString(_Data,_data_FileName,_prop_FileName);
   len := GetFullPathName(@s1[1],0,nil,fn);
   setlength(s,len-1);
   GetFullPathName(@s1[1], len, @s[1], fn);
   if not FileExists(s) then exit;

   FImgCtx := CreateComObject(CLSID_IImgCtx) as IImgCtx;
   FImgCtx.Load(PWChar(StringToWideString(s,3)), 0);
   FImgCtx.SetCallback(@MyCallback, pointer(Self));
   FImgCtx.SelectChanges(IMGCHG_COMPLETE,0,1);
end;

procedure THiImageLoader.ReadPoints;
var p:dword;
begin
   p  := ReadInteger(_Data,_data_Point1,_prop_Point1);
   y1 := smallint(p shr 16);
   x1 := smallint(p and $FFFF);
   p  := ReadInteger(_Data,_data_Point2,_prop_Point2);
   if p <> 0 then begin
      h1 := smallint(p shr 16);
      w1 := smallint(p and $FFFF);
   end;
   if not _prop_Point2AsOffset then begin
      dec(w1,x1);
      dec(h1,y1);
   end;
   p  := ReadInteger(_Data,_data_Point3,_prop_Point3);
   y3 := smallint(p shr 16);
   x3 := smallint(p and $FFFF);
   p  := ReadInteger(_Data,_data_Point4,_prop_Point4);
   if p <> 0 then begin
      h3 := smallint(p shr 16);
      w3 := smallint(p and $FFFF);
   end else begin
      h3 := sz.cy;
      w3 := sz.cx;
   end;
   if not _prop_Point4AsOffset then begin
      dec(w3,x3);
      dec(h3,y3);
   end;
end;


procedure THiImageLoader._work_doDraw0; //Bitmap
var   bmp: PBitmap;
begin
   if (not sg) or (sz.cx = 0) or (sz.cy = 0) then exit;
   bmp := ReadBitmap(_Data,_data_Bitmap);
   if (bmp = nil) or bmp.Empty then exit;
   w1:=bmp.Width; h1:=bmp.Height;
   ReadPoints(_Data);
   _prop_ScaleMode(bmp.Canvas.Handle);
   _hi_CreateEvent(_Data,@_event_onDraw);
end;


procedure THiImageLoader._work_doDraw1; //Handle
var   DC: HDC;
      Wnd: HWND;
begin
   if (not sg) or (sz.cx = 0) or (sz.cy = 0) then exit;
   Wnd := ReadInteger(_Data,_data_Bitmap);
   if Wnd = 0 then exit;
   DC := GetWindowDC(Wnd);
   GetWindowRect(Wnd,PRect(@x1)^);
   dec(w1,x1); dec(h1,y1);
   ReadPoints(_Data);
   _prop_ScaleMode(DC);
   ReleaseDC(Wnd,DC);
   _hi_CreateEvent(_Data,@_event_onDraw);
end;

procedure THiImageLoader._work_doDraw2; //NewBitmap
var   bmp: PBitmap;
begin
   if (not sg) or (sz.cx = 0) or (sz.cy = 0) then exit;
   w1:=sz.cx; h1:=sz.cy;
   ReadPoints(_Data);
   bmp := NewBitmap(w1, h1);
   _prop_ScaleMode(bmp.Canvas.Handle);
   _hi_onEvent(_event_onDraw,bmp);
   bmp.free;
end;

procedure THiImageLoader.Draw;
begin
   if w3>w1 then w3 := w1;
   if h3>h1 then h3 := h1;
   FImgCtx.StretchBlt(DC, x1,y1,w3,h3,x3,y3,w3,h3, SRCCOPY);
end;

procedure THiImageLoader.Stretch;
begin
   FImgCtx.StretchBlt(DC, x1,y1,w1,h1,x3,y3,w3,h3, SRCCOPY);
end;

procedure THiImageLoader.ScaleMin;
var   Z,z1,z2: integer;
begin
   z1 := w3*h1;
   z2 := h3*w1;
   if z1 > z2 then begin
      Z  := z2 div w3;
      inc(y1, (h1-Z) div 2);
      h1 := Z;
   end else begin
      Z  := z1 div h3;
      inc(x1, (w1-Z) div 2);
      w1 := Z;
   end;
   FImgCtx.StretchBlt(DC, x1,y1,w1,h1,x3,y3,w3,h3, SRCCOPY);
end;

procedure THiImageLoader.ScaleMax;
var   Z,z1,z2: integer;
begin
   z1 := w3*h1;
   z2 := h3*w1;
   if z1 < z2 then begin
      Z  := z2 div w3;
      inc(y1, (h1-Z) div 2);
      h1 := Z;
   end else begin
      Z  := z1 div h3;
      inc(x1, (w1-Z) div 2);
      w1 := Z;
   end;
   FImgCtx.StretchBlt(DC, x1,y1,w1,h1,x3,y3,w3,h3, SRCCOPY);
end;

procedure THiImageLoader.Mosaic;
begin
   inc(w1,x1);inc(h1,y1);
   FImgCtx.Tile(DC, PPoint(@x3)^, PRect(@x1)^, PSize(@w3)^);
end;

procedure THiImageLoader._work_doScaleMode;
begin
  case ToInteger(_Data) of
    0: _prop_ScaleMode := Draw;
    1: _prop_ScaleMode := Stretch;
    2: _prop_ScaleMode := ScaleMin;
    3: _prop_ScaleMode := ScaleMax;
    4: _prop_ScaleMode := Mosaic;
  end;
end;

procedure THiImageLoader._var_ImageWidth;
begin
   if not sg then exit;
   dtInteger(_Data,sz.cx);
end;

procedure THiImageLoader._var_ImageHeight;
begin
   if not sg then exit;
   dtInteger(_Data,sz.cy);
end;

procedure THiImageLoader._var_Busy;
begin
   dtInteger(_Data, integer(not sg));
end;

initialization
  CoInitialize(nil);
finalization
  CoUninitialize;

end.
