unit hiRE_Search;

interface

uses Kol, Share, RegExpr,Debug;

type
  THIRegExpr = class(TDebug)
  private
    RE: TRegExpr;
    
    procedure SetModifier(idx:integer; nw:boolean);
  public
    _prop_SourceStr: String;
    _prop_Expression: String;

    _data_SourceStr: THI_Event;
    _data_Expression: THI_Event;
    _event_onError: THI_Event;
    _event_onMatch: THI_Event;
    _event_onNotFound: THI_Event;

    constructor Create;
    destructor Destroy; override;
    procedure _work_doExec(var _Data:TData; Index:word);
    procedure _work_doExecNext(var _Data:TData; Index:word);
    procedure _var_MatchPos(var _Data:TData; Index:word);
    procedure _var_MatchLen(var _Data:TData; Index:word);
    procedure _var_Match(var _Data:TData; Index:word);
    
    property _prop_ModifierI:boolean index 1 write SetModifier;
    property _prop_ModifierR:boolean index 2 write SetModifier;
    property _prop_ModifierS:boolean index 3 write SetModifier;
    property _prop_ModifierG:boolean index 4 write SetModifier;
    property _prop_ModifierM:boolean index 5 write SetModifier;
    property _prop_ModifierX:boolean index 6 write SetModifier;
    
  end;

  THIRE_Search = THIRegExpr; //Лень было переписывать

implementation

procedure THIRegExpr.SetModifier;
begin
  with RE do
    case idx of
      1: ModifierI := nw;
      2: ModifierR := nw;
      3: ModifierS := nw;
      4: ModifierG := nw;
      5: ModifierM := nw;
      6: ModifierX := nw;
    end;
end;

constructor THIRegExpr.Create;
begin
  inherited Create;
  RE := TRegExpr.Create;
end;

destructor THIRegExpr.Destroy;
begin
  RE.Free;
  inherited Destroy;
end;

procedure THIRegExpr._work_doExec;
var
  Expression, InputStr: String;
  err:integer;
  _f:boolean;
begin
  InputStr := ReadString(_Data, _data_SourceStr, _prop_SourceStr);
  Expression := ReadString(_Data,_data_Expression, _prop_Expression);
  Replace(Expression,' ','\x20');
  RE.Expression := Expression;

  _f := RE.Exec(InputStr);
  err := RE.LastError;
  if err <> 0 then _hi_OnEvent(_event_onError, RE.ErrorMsg(err))
  else if _f then _hi_OnEvent(_event_onMatch, RE.Match[0])
  else _hi_OnEvent(_event_onNotFound);
end;

procedure THIRegExpr._work_doExecNext;
var _f:boolean;
    err:integer;
begin
  _f := RE.ExecNext;
  err := RE.LastError;
  if err <> 0 then _hi_OnEvent(_event_onError, RE.ErrorMsg(err))
  else if _f then _hi_OnEvent(_event_onMatch, RE.Match[0])
  else _hi_OnEvent(_event_onNotFound);
end;

procedure THIRegExpr._var_MatchPos;
begin
  if RE = nil then dtNull(_Data)
  else dtInteger(_Data,RE.MatchPos[0]);
end;

procedure THIRegExpr._var_MatchLen;
begin
  if RE = nil then dtNull(_Data)
  else dtInteger(_Data,RE.MatchLen[0]);
end;

procedure THIRegExpr._var_Match;
begin
  if RE = nil then dtNull(_Data)
  else dtString(_Data,RE.Match[0]);
end;

end.
