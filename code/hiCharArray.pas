unit hiCharArray;

interface

uses Kol,Share,Debug;

type
  THICharArray = class(TDebug)
   private
    Arr:PArray;
    FStr:string;

    procedure _Set(var Item:TData; var Val:TData);
    function _Get(Var Item:TData; var Val:TData):boolean;
    function _Count:integer;
    procedure _Add(var Val:TData);
   public
    _data_String:THI_Event;
    _event_onLoad:THI_Event;
    _event_onGetStr:THI_Event;

    destructor Destroy; override;
    procedure _work_doLoad(var _Data:TData; Index:word);
    procedure _work_doGetStr(var _Data:TData; Index:word);
    procedure _work_doClear(var _Data:TData; Index:word);
    procedure _var_Array(var _Data:TData; Index:word);
    procedure _var_Str(var _Data:TData; Index:word);
    procedure _var_Count(var _Data:TData; Index:word);
  end;

implementation

destructor THICharArray.Destroy;
begin
   if Arr <> nil then dispose(Arr);
   inherited; 
end;

procedure THICharArray._Set;
var ind:integer;
    s:string;
begin
   ind := ToIntIndex(Item);
   if(ind >= 0)and(ind < _Count)then
     begin
      s := ToString(Val);
      if s = '' then s := ' ';
      FStr[ind+1] := s[1];
     end;
end;

procedure THICharArray._Add;
begin
   FStr := FStr + ToString(val);
end;

function THICharArray._Get;
var ind:integer;
begin
   ind := ToIntIndex(Item);
   if(ind >= 0)and(ind < _Count)then
     begin
        Result := true;
        dtString(Val,FStr[ind+1]);
     end
   else Result := false;
end;

function THICharArray._Count;
begin
   Result := length(FStr);
end;

procedure THICharArray._work_doLoad;
begin
   FStr := ReadString(_Data,_data_String,'');
   _hi_CreateEvent(_Data,@_event_onLoad);
end;

procedure THICharArray._work_doGetStr;
begin
   _hi_CreateEvent(_Data,@_event_onGetStr,Fstr);
end;

procedure THICharArray._work_doClear;
begin
   FStr := '';
end;

procedure THICharArray._var_Str;
begin
   dtString(_Data, Fstr);
end;

procedure THICharArray._var_Array;
begin
   if Arr = nil then
    Arr := CreateArray(_Set, _Get, _Count, _Add);
   dtArray(_Data,Arr);
end;

procedure THICharArray._var_Count;
begin
  dtInteger(_Data, length(FStr));
end;

end.