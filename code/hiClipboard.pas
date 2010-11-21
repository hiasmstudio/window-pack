unit hiClipboard;

interface

uses Kol,Share,Debug;

type
  THIClipboard = class(TDebug)
   private
    Bmp:PBitmap;
   public
    _data_PutText:THI_Event;
    _data_PutBitmap:THI_Event;

    destructor Destroy; override;
    procedure _work_doPutText(var _Data:TData; Index:word);
    procedure _var_Text(var _Data:TData; Index:word);
    procedure _var_Bitmap(var _Data:TData; Index:word);
    procedure _work_doPutBitmap(var _Data:TData; Index:word);
  end;

implementation

destructor THIClipboard.Destroy;
begin
   if Bmp <> nil then
     Bmp.Free;
   inherited;
end;

procedure THIClipboard._work_doPutText;
begin
   Text2Clipboard(ReadString(_Data,_data_PutText,''));
end;

procedure THIClipboard._work_doPutBitmap;
var Bitmap:PBitmap;
begin
   Bitmap:=ReadBitmap(_Data,_data_PutBitmap);
   Bitmap.CopyToClipboard;
end;

procedure THIClipboard._var_Text;
begin
   dtString(_Data,Clipboard2Text);
end;

procedure THIClipboard._var_Bitmap;
begin
  if Bmp = nil then
    Bmp := NewBitmap(0,0);
  Bmp.PasteFromClipboard;
  dtBitmap(_Data,Bmp);
end;

end.