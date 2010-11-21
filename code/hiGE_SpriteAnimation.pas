unit hiGE_SpriteAnimation;

interface

uses Kol,Share,Debug,hiGE_Scene;

type
  THIGE_SpriteAnimation = class(TDebug)
   private
   public
    _prop_Sprite:TGE_Object;
    _prop_Frames:integer;
    _prop_StartFrame:integer;
    _prop_Speed:integer;

    _data_Speed:THI_Event;
    _data_StartFrame:THI_Event;
    _data_Frames:THI_Event;
    _data_Sprite:THI_Event;
    _event_onAnimate:THI_Event;

    procedure _work_doAnimate(var _Data:TData; Index:word);
  end;

implementation

uses hiGE_Sprite;

procedure THIGE_SpriteAnimation._work_doAnimate;
var obj:TGE_Object;
    dt:TData;
begin
  if _prop_Sprite = nil then
    begin
      dt := ReadData(_Data, _data_Sprite); 
      obj := ToObject(dt);
    end
   else obj := _prop_Sprite;

  if obj <> nil then
    with TGE_SpriteObject(obj) do
    begin
      Frames := ReadInteger(_Data, _data_Frames, _prop_Frames); 
      StartFrame := ReadInteger(_Data, _data_StartFrame, _prop_StartFrame); 
      Speed := ReadInteger(_Data, _data_Speed, _prop_Speed);
      init; 
    end; 
  _hi_onEvent(_event_onAnimate);
end;

end.
