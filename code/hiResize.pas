unit hiResize;

interface

uses Windows,Kol,Share,Debug;

type
  THIResize = class(TDebug)
   private
    src:PBitmap;
    BltMode: dword;
    procedure SetBltMode(ht:boolean);    
   public
    _prop_Width:integer;
    _prop_Height:integer;

    _data_Height:THI_Event;
    _data_Width:THI_Event;
    _data_Bitmap:THI_Event;
    _event_onResult:THI_Event;

    property _prop_HalfTone:boolean write SetBltMode;
    destructor Destroy; override;
    procedure _work_doResize(var _Data:TData; Index:word);
    procedure _work_doHalfTone(var _Data:TData; Index:word);    
    procedure _var_Result(var _Data:TData; Index:word);
  end;

implementation

destructor THIResize.Destroy;
begin
   if Assigned(src) then src.free;
   inherited;
end;

procedure THIResize._work_doResize;
var   bitmap : PBitmap;
begin
   bitmap := ReadBitmap(_Data,_data_Bitmap,nil);
   if (Bitmap = nil) or Bitmap.Empty then exit;
   if Assigned(src) then src.free;
   src := NewBitmap(ReadInteger(_Data,_data_Width,_prop_Width),
                    ReadInteger(_Data,_data_Height,_prop_Height));
   SetStretchBltMode(src.Canvas.Handle, BltMode);
   StretchBlt(src.Canvas.Handle, 0, 0, src.width, src.height, bitmap.Canvas.Handle,
              0, 0, bitmap.width, bitmap.height, SRCCOPY);
   _hi_OnEvent(_event_onResult, src);
end;

procedure THIResize.SetBltMode;
begin
   if ht and (WinVer >= wvNT) then
      BltMode := HALFTONE
   else
      BltMode := COLORONCOLOR;
end;

procedure THIResize._work_doHalfTone;
begin
   SetBltMode(ReadBool(_Data));
end;

procedure THIResize._var_Result;
begin
   if (src = nil) or src.Empty then exit;
   dtBitmap(_Data, src);
end;

end.