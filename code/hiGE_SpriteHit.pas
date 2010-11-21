unit hiGE_SpriteHit;

interface

uses Kol,Share,Debug,hiGE_Scene;

type
  THIGE_SpriteHit = class(TDebug)
   private
    flt:array of boolean;
    CFlt:integer;
    
    procedure setFilter(const value:string); 
   public
    _prop_Sprite:TGE_Object;

    _data_Sprite:THI_Event;
    _event_onCheckHit:THI_Event;

    procedure _work_doCheckHit(var _Data:TData; Index:word);
    property _prop_Filter:string write setFilter;
  end;

implementation

procedure THIGE_SpriteHit.setFilter;
var s:string;
    id:integer;
begin
   s := value + ',';
   CFlt := 0;
   while pos(',', s) > 0 do
     begin
       id := str2int(GetTok(s, ',')); 
       if id >= CFlt then 
         begin
           CFlt := id+1;
           SetLength(Flt, CFlt);
         end;
       Flt[id] := true;
     end;
end;

procedure THIGE_SpriteHit._work_doCheckHit;
var obj:TGE_Object;
    dt,dto:TData;
    ff:PData;
    id:integer;
begin
  if _prop_Sprite = nil then
    begin
      dt := ReadData(_Data, _data_Sprite); 
      obj := ToObject(dt);
    end
   else obj := _prop_Sprite;
  obj := obj.scene.checkHit(@Flt, obj, id);
  if obj <> nil then
    begin
      dtInteger(dt, id);
      dtObject(dto, Sprite_GUID, obj);
      AddMTData(@dt, @dto, ff);
      _hi_onEvent(_event_onCheckHit, dt);
    end;   
end;

end.
