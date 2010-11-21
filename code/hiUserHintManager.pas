unit hiUserHintManager;

interface

uses windows,Kol,Share,Debug,hiHintManager;

type
  TUHM_Data = record
    visible:boolean;
    text:string;
  end;
  PUHM_Data = ^TUHM_Data;
  THIUserHintManager = class(TDebug)
   private
     hm:TIHintManager;
     
     function init(HintParent:HWND):pointer;
     procedure free(id:pointer);
     procedure hint(id:pointer; const text:string);
     procedure title(id:pointer; const idx:integer; const text:string);
     procedure show(id:pointer);
     procedure hide(id:pointer);
     procedure move(id:pointer; x,y:integer);
   public
    _prop_Name:string;

    _event_onChangeHint:THI_Event;
    _event_onShow:THI_Event;
    _event_onHide:THI_Event;
    
    constructor Create;
    function getInterfaceHint:IHintManager;
  end;

implementation

constructor THIUserHintManager.Create;
begin
   inherited;
   hm.init := init;
   hm.free := free;
   hm.hint := hint;
   hm.title := title;
   hm.show := show;
   hm.hide := hide;
   hm.move := move;
end;

function THIUserHintManager.getInterfaceHint;
begin
   Result := @hm;
end;

function THIUserHintManager.init;
var dt:PUHM_Data;
begin
   new(dt);
   FillChar(dt^, sizeof(TUHM_Data), 0);
   result := dt;
end;

procedure THIUserHintManager.free;
begin
   PUHM_Data(id).text := ''; 
   dispose(PUHM_Data(id));
end;

procedure THIUserHintManager.hint;
begin
  PUHM_Data(id).text := text;
  if PUHM_Data(id).visible then
    _hi_onEvent(_event_onChangeHint, text);
end;

procedure THIUserHintManager.show;
begin
  PUHM_Data(id).visible := true;
  _hi_onEvent(_event_onShow, PUHM_Data(id).text);
end;

procedure THIUserHintManager.hide;
begin
  PUHM_Data(id).visible := false;
  _hi_onEvent(_event_onHide);
end;

procedure THIUserHintManager.move;
begin

end;

procedure THIUserHintManager.title;
begin

end;

end.
