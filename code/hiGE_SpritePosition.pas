unit hiGE_SpritePosition;

interface

uses Kol,Share,Debug,hiGE_Scene;

type
  THIGE_SpritePosition = class(TDebug)
   private
    function readSprite(var _Data:TData):TGE_Object; 
   public
    _prop_Sprite:TGE_Object;

    _data_Sprite:THI_Event;

    procedure _var_X(var _Data:TData; Index:word);
    procedure _var_Y(var _Data:TData; Index:word);
  end;

implementation

function THIGE_SpritePosition.readSprite;
var dt:TData;
begin
  if _prop_Sprite = nil then
    begin
      dt := ReadData(_Data, _data_Sprite); 
      Result := ToObject(dt);
      if Result = nil then _debug('null');
    end
   else Result := _prop_Sprite;
end; 

procedure THIGE_SpritePosition._var_X;
begin
  dtReal(_Data, readSprite(_Data).X);
end;

procedure THIGE_SpritePosition._var_Y;
begin
  dtReal(_Data, readSprite(_Data).Y);
end;

end.
