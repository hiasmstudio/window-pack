unit hiScreenShort;

interface

uses Share,WIndows,Kol,Debug;

type
  THIScreenShort = class(TDebug)
   private
   public
    _event_onCapture:THI_Event;
    _data_Handle:THI_Event;

    procedure _work_doCapture(var _Data:TData; Index:word);
  end;

implementation

procedure THIScreenShort._work_doCapture;
var
   wnd:HWND;
   dc:HDC;
   Bmp:PBitmap;
   r:TRect;
begin
   wnd := ReadInteger(_data,_data_Handle,0);
   if wnd = 0 then begin
      dc := GetDC(0);
      Bmp := NewBitmap(ScreenWidth,ScreenHeight);
   end else begin
      dc := GetWindowDC(wnd);
      GetWindowRect(wnd,r);
      Bmp := NewBitmap(r.Right-r.Left,r.Bottom-r.Top);
   end;
   BitBlt(Bmp.Canvas.Handle,0,0,Bmp.Width,Bmp.Height,DC,0,0,SRCCOPY);
   _hi_OnEvent(_event_onCapture,bmp);
   bmp.Free;
   ReleaseDC(wnd,dc);
end;

end.