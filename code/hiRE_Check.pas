unit hiRE_Check;

interface

uses Kol,Share,Debug,RegExpr;

type
  THIRE_Check = class(TDebug)
   private
    RE:TRegExpr;
   public
    _prop_Expression:string;
    _prop_FullStrCheck:boolean;

    _data_Expression:THI_Event;
    _data_Str:THI_Event;
    _event_onDismatch:THI_Event;
    _event_onMatch:THI_Event;

    constructor Create;
    destructor Destroy; override;
    procedure _work_doCheck(var _Data:TData; Index:word);
  end;

implementation

constructor THIRE_Check.Create;
begin
  inherited Create;
  RE := TRegExpr.Create;
end;

destructor THIRE_Check.Destroy;
begin
  RE.Free;
  inherited Destroy;
end;

procedure THIRE_Check._work_doCheck;
var str:string;
    expr:string;
    dt:TData;
begin
  dt := _Data;
  str := ReadString(_Data, _data_Str, '');
  expr := ReadString(_Data, _data_Expression, _prop_Expression);
  Replace(expr,' ','\x20');
  if _prop_FullStrCheck then
    expr := '^' + expr + '$';
  RE.Expression := expr;
  if RE.Exec(str) then
    _hi_CreateEvent(_Data, @_event_onMatch, dt)
  else
    _hi_CreateEvent(_data, @_event_onDismatch, dt);
end;

end.
