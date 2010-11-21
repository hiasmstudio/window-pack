unit hiFormatStr;

interface

uses Kol,Share,Debug;

type
  THIFormatStr = class(TDebug)
   private
    FStr,substr:string;
    FDataCount:integer;
    function TestRep(P:integer):boolean;
    procedure SetCount(Value:integer);
   public
    Str:array of THI_Event;
    _prop_Mask:string;

    _event_onFString:THI_Event;

    procedure _work_doString(var _Data:TData; Index:word);
    procedure _work_doMask(var _Data:TData; Index:word);
    procedure _var_FString(var _Data:TData; Index:word);
    property _prop_DataCount:integer write SetCount;
  end;

implementation

procedure THIFormatStr.SetCount;
begin
   SetLength(Str,Value);
   FDataCount := Value;
end;

function THIFormatStr.TestRep(P:integer):boolean;
begin
//  Result := false;
  Result :=  not (FStr[P+length(substr)] in ['0'..'9']);
end;

procedure THIFormatStr._work_doString;
var i:integer;
begin
  FStr := _prop_Mask;
  Replace(FStr,'%%',#0);
  for i := 1 to FDataCount do begin
    substr := '%'+int2str(i);
    Replace(FStr,substr,#1+ReadString(_Data,Str[i-1]),TestRep);
  end;
  Replace(FStr,#1,'');
  Replace(FStr,#0,'%');
  _hi_CreateEvent(_Data,@_event_onFString,FStr);
end;

procedure THIFormatStr._work_doMask(var _Data:TData; Index:word);
begin
   _prop_Mask := ToString(_Data);
end;

procedure THIFormatStr._var_FString(var _Data:TData; Index:word);
begin
   dtString(_Data,FStr);
end;

end.
