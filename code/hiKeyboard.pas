unit hiKeyboard;

interface

uses Kol,Share,Windows,Debug;

type
  THIKeyboard = class(TDebug)
   private
    Key:smallint;
    _Arr:PArray;
    function _Count:integer;
    procedure _Write(var Item:TData; var Val:TData);
    function _Read(Var Item:TData; var Val:TData):boolean;
   public
    _prop_Key:integer;
    _data_Key:THI_Event;
    _event_onReadKey:THI_Event;

    destructor Destroy; override;
    procedure _work_doReadKey(var _Data:TData; Index:word);
    procedure _var_Keys(var _Data:TData; Index:word);
    procedure _var_ToggleState(var _Data:TData; Index:word);
  end;

implementation

destructor THIKeyboard.Destroy;
begin
   if _Arr <> nil then dispose(_Arr);
   inherited;
end;

procedure THIKeyboard._work_doReadKey;
begin
   Key := GetKeyState(ReadInteger(_Data,_data_Key,_prop_Key));
   _hi_CreateEvent(_Data,@_event_onReadKey,byte(Key < 0));
end;

procedure THIKeyboard._Write;
var Keys:TKeyboardState;
   ind:integer;
begin
   GetKeyboardState(keys);
   ind := ToInteger(Item);
//   if ind in [0..255] then
   if (ind >= 0) and (ind <= 255) then begin
      Keys[ind] := byte(ReadBool(Val));
      SetKeyboardState(Keys);
   end;
end;

function THIKeyboard._Count;
begin
   Result := 256;
end;

function THIKeyboard._Read;
var   ind:integer;
begin
   ind := ToInteger(Item);
   Result := (ind >= 0) and (ind <= 255); 
//   Result := ind in [0..255];
   if Result then
      dtInteger(Val,byte(GetKeyState(ind) < 0));
end;

procedure THIKeyboard._var_Keys;
begin
   if _Arr = nil then
    _Arr := CreateArray(_Write,_Read,_Count,nil);
   dtArray(_data,_Arr);
end;

procedure THIKeyboard._var_ToggleState;
begin
   dtInteger(_data,Key and 1);
end;

end.
