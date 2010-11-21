unit hiGlobalVar;

interface

uses Kol,Share,Debug;

type
  THIGlobalVar = class(TDebug)
   protected
    GData:PData;
    procedure SetData(Data:TData);virtual;
    procedure SetName(const Value:string);virtual;
   public
    _event_onValue:THI_Event;
     
    procedure _work_doValue(var _Data:TData; Index:word);
    procedure _work_doName(var _Data:TData; Index:word);
    procedure _var_Var(var _Data:TData; Index:word);
    property _prop_Name:string write SetName;
    property _prop_Data:TData write SetData;
  end;

var NList:PStrListEx;

function ForceGVar(const Name:string):PData;

implementation

function ForceGVar(const Name:string):PData;
var i:integer;s:string;
begin
  Result := nil;
  if Name='' then exit;
  s := LowerCase(Name);
  i := NList.IndexOf(s);
  if i>=0 then
    Result := PData(NList.Objects[i])
  else begin
    new(Result);
    dtNull(Result^);
    NList.AddObject(s,cardinal(Result));
  end;
end;

procedure THIGlobalVar.SetName;
begin
  GData := ForceGVar(Value);
end;

procedure THIGlobalVar._work_doName;
begin
  SetName(ToString(_Data));
end;

procedure THIGlobalVar.SetData;
begin
  if GData <> nil then dtData(GData^,Data);
end;

procedure THIGlobalVar._work_doValue;
begin
  SetData(_Data);
  _hi_onEvent(_event_onValue, _Data);
end;

procedure THIGlobalVar._var_Var;
begin
  if GData <> nil then
    _Data := GData^
  else dtNull(_Data);
end;

procedure ClearGVars;
var i:integer;
begin
  for i := 0 to NList.Count-1 do 
    dispose(PData(NList.Objects[i]));
  NList.free;
end;

initialization NList := NewStrListEx;
finalization ClearGVars;

end.
