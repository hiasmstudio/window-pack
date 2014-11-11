unit hiRGN_Collision;

interface

uses Windows,Kol,Share,Debug;

type
  THIRGN_Collision = class(TDebug)
   private
    Collision: byte;
    FRegion: HRGN;
    Count: integer;
   public

    _prop_FindStop:boolean;
    _data_Region1:THI_Event;
    _data_Region2:THI_Event;
    _data_Array:THI_Event;

    _event_onTrue:THI_Event;
    _event_onFalse:THI_Event;
    _event_onCollision:THI_Event;

    constructor Create;
    destructor Destroy; override;
    procedure _work_doCollision(var _Data:TData; Index:word);
    procedure _work_doEnum(var _Data:TData; Index:word);
    procedure _var_Result(var _Data:TData; Index:word);
    procedure _var_Collision(var _Data:TData; Index:word);
    procedure _var_Count(var _Data:TData; Index:word);
  end;

implementation

constructor THIRGN_Collision.Create;
begin
    inherited Create;
    FRegion := CreateRectRgn(0, 0, 0, 0);
    Collision := 0;
    Count := 0;
end;

destructor THIRGN_Collision.Destroy;
begin
    DeleteObject(FRegion);
    inherited Destroy;
end;

procedure THIRGN_Collision._work_doCollision;
var rgn1, rgn2: HRGN;
begin
    rgn1 := ReadInteger(_Data, _data_Region1);
    rgn2 := ReadInteger(_Data, _data_Region2);
    if CombineRgn(FRegion, rgn1, rgn2, RGN_AND) < 2 then // 0 - ошибка, 1 - пустой, 2 - простой, 3 - сложный
     begin
      Collision := 0;
      Count := 0;
      _hi_onEvent(_event_onFalse, rgn1);
     end
    else
     begin
      Collision := 1;
      Count := 1;
      _hi_onEvent(_event_onTrue);
     end;
    _hi_onEvent(_event_onCollision, Collision);
end;

procedure THIRGN_Collision._work_doEnum;
var Arr: PArray;
    rgn1, rgn2, rgn3: HRGN;
    ind: integer;
    Item, eIndex: TData;
    dt, d: TData;
    f: PData;
begin
    Arr := ReadArray(_data_Array);
    if Arr = nil then exit;
    rgn1 := ReadInteger(_Data, _data_Region1);
    rgn2 := ReadInteger(_Data, _data_Region2);
    dtNull(dt);
    dtNull(d);
    Ind := 0;
    Collision := 0;
    Count := 0;
    dtInteger(eIndex,Ind);
    while Arr._Get(eIndex,Item) do
     begin
      rgn3 := ToInteger(Item);
      if rgn2 <> rgn3 then
       begin
        if CombineRgn(FRegion, rgn1, rgn3, RGN_AND) > 1 then  // 0 - ошибка, 1 - пустой, 2 - простой, 3 - сложный
         if _prop_FindStop then
          begin
           Collision := 1;
           break;
          end
         else
          begin
           inc(Count);
           Collision := 1;
           dtInteger(d, ind);
           AddMTData(@dt, @d, f);
          end; 
       end;
      inc(Ind);
      dtInteger(eIndex,Ind);
     end;
   case Collision of
    0: _hi_onEvent(_event_onFalse, integer(rgn1));
    1: if _prop_FindStop then _hi_onEvent(_event_onTrue, ind)
       else
        begin
         _hi_onEvent(_event_onTrue, dt);
         FreeData(f);
        end;
   end;     
end;

procedure THIRGN_Collision._var_Result;
begin
   dtInteger(_Data, FRegion);
end;

procedure THIRGN_Collision._var_Collision;
begin
   dtInteger(_Data, Collision);
end;

procedure THIRGN_Collision._var_Count;
begin
   dtInteger(_Data, Count);
end;

end.