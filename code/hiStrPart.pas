unit hiStrPart;

interface

uses Kol,Share,Debug;

{$I def.inc}

type
  THIStrPart = class(TDebug)
   private
    Str,FLeft:string;
   public
    _prop_Char:string;
    _prop_DirectEvent:boolean;
    
    _data_Str:THI_Event;
    _event_onPart:THI_Event;
    _event_onSplit:THI_Event;
    _event_onNotFound:THI_Event;

    procedure _work_doSplit(var _Data:TData; Index:word);
    procedure _var_Left(var _Data:TData; Index:word);
    procedure _var_Right(var _Data:TData; Index:word);    
  end;

implementation

procedure THIStrPart._work_doSplit;
begin
  str := ReadString(_Data, _data_Str, '');
  {$ifdef _PROTECT_MAX_}
  if (_prop_Char = '') or (str = '') then exit;
  {$endif}
  if (pos(_prop_Char,str) = 0) then
    _hi_CreateEvent(_Data,@_event_onNotFound, str)
  else
  begin
    FLeft := GetTok(str, _prop_Char[1]);
    If not _prop_DirectEvent then
    begin
      _hi_onEvent(_event_onPart, FLeft);
      _hi_CreateEvent(_Data, @_event_onSplit, Str);
    end
    else
    begin
      _hi_onEvent(_event_onSplit, Str);
      _hi_CreateEvent(_Data, @_event_onPart, FLeft);
    end;
  end;
end;

procedure THIStrPart._var_Left(var _Data:TData; Index:word);
begin
  dtString(_Data, FLeft);
end;

procedure THIStrPart._var_Right(var _Data:TData; Index:word);
begin
  dtString(_Data, Str);
end;

end.
