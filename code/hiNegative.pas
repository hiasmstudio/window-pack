unit hiNegative;

interface

uses Windows,Kol,Share,Debug;

type
  THINegative = class(TDebug)
   private
    src:PBitmap;
   public
    _data_Bitmap:THI_Event;
    _event_onResult:THI_Event;

    destructor Destroy; override;
    procedure _work_doNegative(var _Data:TData; Index:word);
    procedure _var_Result(var _Data:TData; Index:word);
  end;

implementation

destructor THINegative.Destroy;
begin
   if Assigned(src) then src.free;
   inherited;
end;

procedure THINegative._work_doNegative;
var   bmp:PBitmap;
begin
   bmp := ReadBitmap(_Data,_data_Bitmap,nil);
   if (bmp = nil) or bmp.Empty then exit;
   if Assigned(src) then src.free;
   src := NewBitmap(bmp.width, bmp.height);
   BitBlt(src.Canvas.Handle, 0, 0, src.width, src.height, bmp.Canvas.Handle, 0, 0, NOTSRCCOPY);   
   _hi_OnEvent(_event_onResult,src);
end;

procedure THINegative._var_Result;
begin
   if (src = nil) or src.Empty then exit;
   dtBitmap(_Data, src);
end;

end.
