unit hiImg_Copy;

interface

uses Windows,Kol,Share,Debug;

type
  THIImg_Copy = class(TDebug)
   private
    dest:PBitmap;
   public
    _prop_X:integer;
    _prop_Y:integer;
    _prop_Width:integer;
    _prop_Height:integer;
    _prop_DrawSource:byte;

    _data_Height:THI_Event;
    _data_Width:THI_Event;
    _data_Y:THI_Event;
    _data_X:THI_Event;
    _data_Source:THI_Event;
    _event_onCopy:THI_Event;

    destructor Destroy; override;
    procedure _work_doCopy0(var _Data:TData; Index:word);
    procedure _work_doCopy1(var _Data:TData; Index:word);
    procedure _var_Result(var _Data:TData; Index:word);
  end;

implementation

destructor THIImg_Copy.Destroy;
begin
   if Assigned(dest) then dest.free;
   inherited;
end;

procedure THIImg_Copy._work_doCopy0; //Bitmap
var   bmp:PBitmap;
      x,y,w,h:integer;
begin
   bmp := ReadBitmap(_Data,_data_Source,nil);
   if (bmp = nil) or bmp.Empty then exit;
   x := ReadInteger(_Data,_data_X,_prop_X);
   y := ReadInteger(_Data,_data_Y,_prop_Y);
   w := ReadInteger(_Data,_data_Width,_prop_Width);
   h := ReadInteger(_Data,_data_Height,_prop_Height);
   if Assigned(dest) then dest.free;
   dest := NewBitmap(w,h);
   if dest.Empty then exit;
   BitBlt(dest.Canvas.Handle, 0, 0, w, h, bmp.Canvas.Handle, X, Y, SRCCOPY);
   _hi_onEvent(_event_onCopy, dest);
end;

procedure THIImg_Copy._work_doCopy1; //Handle
var   DC:HDC;
      Wnd:HWND;
      x,y,w,h:integer;
begin
   Wnd := ReadInteger(_Data,_data_Source,0);
   DC := GetDC(wnd);
   x := ReadInteger(_Data,_data_X,_prop_X);
   y := ReadInteger(_Data,_data_Y,_prop_Y);
   w := ReadInteger(_Data,_data_Width,_prop_Width);
   h := ReadInteger(_Data,_data_Height,_prop_Height);
   if Assigned(dest) then dest.free;
   dest := NewBitmap(w,h);
   if dest.Empty then exit;
   BitBlt(dest.Canvas.Handle, 0, 0, w, h, DC, X, Y, SRCCOPY);
   ReleaseDC(Wnd,dc);
   _hi_onEvent(_event_onCopy, dest);
end;

procedure THIImg_Copy._var_Result;
begin
   if (dest = nil) or dest.Empty then exit;
   dtBitmap(_Data, dest);
end;

end.
