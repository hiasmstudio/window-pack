unit hiBitmapStream;

interface

uses Kol,Share,Debug;

type
  THIBitmapStream = class(TDebug)
   private
   public
    _data_Bitmap:THI_Event;
    _data_Stream:THI_Event;
    _event_onRead:THI_Event;

    procedure _work_doRead(var _Data:TData; Index:word);
    procedure _work_doWrite(var _Data:TData; Index:word);
  end;

implementation

procedure THIBitmapStream._work_doRead;
var
  st:PStream;
  bmp:pbitmap;
begin
   st := ReadStream(_Data,_data_Stream);
   if(st <> nil)then
    begin
      bmp := NewBitmap(0,0);
      bmp.LoadFromStream(st);
      _hi_OnEvent(_event_onRead,bmp);
      bmp.free;
    end;
end;

procedure THIBitmapStream._work_doWrite;
var
  st:PStream;
  bmp:pbitmap;
begin
   st := ReadStream(_Data,_data_Stream);
   bmp := ReadBitmap(_Data,_data_Bitmap);
   if(st <> nil)and(bmp <> nil)then
     bmp.SaveToStream(st);
end;

end.
