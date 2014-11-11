unit hiScreenShort;

interface

uses Share,WIndows,Kol,Debug;

type
  THIScreenShort = class(TDebug)
   private
   public
    _prop_UseRegion:boolean;
    _prop_Color:TColor;
    
    _event_onCapture:THI_Event;
    _data_Handle:THI_Event;
    _data_Region:THI_Event;
    procedure _work_doCapture(var _Data:TData; Index:word);
    procedure _work_doColor(var _Data:TData; Index:word);
  end;

implementation

procedure THIScreenShort._work_doCapture;
var wnd:HWND;
    dc:HDC;
    Bmp:PBitmap;
    r:TRect;
    rgn: HRGN;
    RgnDword: DWORD;
    RgnData:  PRgnData;
begin
    wnd := ReadInteger(_data,_data_Handle,0);
    if _prop_UseRegion then
     begin 
      if wnd = 0 then dc := GetDC(0)
       else dc := GetWindowDC(wnd);
      rgn := CreateRectRgn(0, 0, 0, 0);
      if 0 = CombineRgn(rgn, ReadInteger(_Data, _data_Region), 0, RGN_COPY) then Bmp := NewBitmap(0,0)
      else
       begin
        RgnDword := GetRegionData(rgn, 0, nil);                
        GetMem(RgnData, SizeOf(RgnData) * RgnDword);
        GetRegionData(rgn, RgnDword, RgnData);
        r.Left   := RgnData.rdh.rcBound.Left;
        r.Top    := RgnData.rdh.rcBound.Top; 
        r.Right  := RgnData.rdh.rcBound.Right - r.Left;
        r.Bottom := RgnData.rdh.rcBound.Bottom - r.Top;
        FreeMem(RgnData);
        Bmp := NewBitmap(r.Right,r.Bottom);
        Bmp.BkColor := _prop_Color;
        Bmp.Canvas.Brush.BrushStyle := bsSolid;
        Bmp.Canvas.FillRect(Bmp.BoundsRect);
        OffsetRgn(rgn, -r.Left, -r.Top);
        SelectClipRGN(Bmp.Canvas.Handle, rgn);
        BitBlt(Bmp.Canvas.Handle,0,0,Bmp.Width,Bmp.Height,dc,r.Left,r.Top,SRCCOPY);   
        DeleteObject(rgn);
       end;
     end
    else
     begin
      if wnd = 0 then
       begin
        dc := GetDC(0);
        Bmp := NewBitmap(ScreenWidth,ScreenHeight);
       end
      else
       begin
        dc := GetWindowDC(wnd);
        GetWindowRect(wnd,r);
        Bmp := NewBitmap(r.Right-r.Left,r.Bottom-r.Top);
       end;
      BitBlt(Bmp.Canvas.Handle,0,0,Bmp.Width,Bmp.Height,DC,0,0,SRCCOPY);
     end;
    _hi_OnEvent(_event_onCapture, bmp);
    bmp.Free;
    ReleaseDC(wnd,dc);
end;

procedure THIScreenShort._work_doColor;
begin
    _prop_Color :=  ToInteger(_Data);
end;

end.