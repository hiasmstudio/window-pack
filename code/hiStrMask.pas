unit hiStrMask;

interface

uses Windows,Share,Debug;

type
  THIStrMask = class(TDebug)
   private
   public
    _prop_Mask:string;
    _prop_CaseSensitive:byte;

    _data_Str:THI_Event;
    _event_onTrue:THI_Event;
    _event_onFalse:THI_Event;

    procedure _work_doCompare(var _Data:TData; Index:word);
    procedure _work_doMask(var _Data:TData; Index:word);
  end;

function StrCmp(Str,Msk:string):boolean;

implementation

function _StrCmp(Str,Msk:PChar):boolean;
begin
  while (Str^<>#0)and(Msk^<>#0) do begin
    if Msk^ = '*' then  begin
      if _StrCmp(Str,Msk+1) then begin 
        Result := true;  
        exit; 
      end;
    end else if Msk^ = '#' then begin
        if Str^ in ['0'..'9'] then Inc(Msk)
        else break;
    end else if (Msk^ = '?')or(Msk^ = Str^) then Inc(Msk)
    else break;
    Inc(Str);          
  end;
  Result := (Str^ = #0)and(Msk^ = #0);
end;

function StrCmp(Str,Msk:string):boolean;
begin
  Result := _StrCmp(Pchar(Str+#1),Pchar(Msk+#1));
end;

procedure THIStrMask._work_doCompare;
var sstr,str,msk:string;
begin
  sstr := ReadString(_Data,_data_Str);
  str  := sstr+#1;
  msk  := _prop_Mask+#1;
  if (_prop_CaseSensitive = 1) then begin
    CharLower(PChar(str));
    CharLower(PChar(msk));
  end;
  if _StrCmp(PChar(str),PChar(msk)) then
    _hi_CreateEvent(_Data,@_event_onTrue, sstr)
  else
    _hi_CreateEvent(_Data,@_event_onFalse,sstr);
end;

procedure THIStrMask._work_doMask;
begin
  _prop_Mask := ToString(_Data);
end;

end.
