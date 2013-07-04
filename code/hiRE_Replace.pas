unit hiRE_Replace;

interface

uses Kol,Share,Debug,RegExpr;

type
  THIRE_Replace = class(TDebug)
   private
    RE:TRegExpr;
    _Res:string;
   public
    _prop_Expression:string;
    _prop_ReplaceStr:string;

    _data_ReplaceStr:THI_Event;
    _data_Expression:THI_Event;
    _data_SourceStr:THI_Event;
    _event_onReplace:THI_Event;

    constructor Create;
    destructor Destroy; override;
    procedure _work_doReplace(var _Data:TData; Index:word);
    procedure _var_Result(var _Data:TData; Index:word);
  end;

implementation

constructor THIRE_Replace.Create;
begin
  inherited Create;
  RE := TRegExpr.Create;
end;

destructor THIRE_Replace.Destroy;
begin
  RE.Free;
  inherited Destroy;
end;

procedure THIRE_Replace._work_doReplace;
var sstr, rstr:string;
    expr:string;
begin
  sstr := ReadString(_Data, _data_SourceStr, '');
  expr := ReadString(_Data, _data_Expression, _prop_Expression);
  rstr := ReadString(_Data, _data_ReplaceStr, _prop_ReplaceStr);
  Replace(expr,' ','\x20');
  RE.Expression := expr;
  _Res := RE.Replace(sstr, rstr, true);
  _hi_CreateEvent(_Data, @_event_onReplace, _Res);
end;

procedure THIRE_Replace._var_Result;
begin
  dtString(_Data, _Res);
end;

end.
