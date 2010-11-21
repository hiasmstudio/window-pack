unit drawShare;

interface

uses Windows,kol;

type
  TParamRec = record
    Name:string;
    Value:pointer;
    DataType:byte;   // i s d c
    buf:pointer;
    Index:byte;
  end;
  TParamRecArray = array[0..1024] of TParamRec;
  PParamRec = ^TParamRecArray;
  PPParamRec = ^TParamRec;
  TDrawTools = object
   public
    CreateBitmap:function (PRec:PPParamRec):cardinal; cdecl;
    DrawBitmap:procedure (Bmp:cardinal; DC:HDC; X,Y:integer); cdecl;
    DeleteBitmap:procedure (Bmp:cardinal); cdecl;
    GetSizeBitmap:procedure (Bmp:cardinal; var w,h:cardinal); cdecl;
  end;
  PDrawTools = ^TDrawTools;

function ColorRGB(c:cardinal):cardinal;
function SearchParam(p:PParamRec; const name:string):PPParamRec;

implementation

function SearchParam(p:PParamRec; const name:string):PPParamRec;
var i:integer;
begin
    i := 0;
    while lowercase(p^[i].name) <> lowercase(name) do
      inc(i);
    result := @p^[i];
end;

function ColorRGB(c:cardinal):cardinal;
begin
    if c and $FF000000 > 0 then
      Result := GetSysColor(c and $FF)
    else result := c;
end;

end.