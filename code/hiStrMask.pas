unit hiStrMask;

interface

uses Windows,Kol,Share,Debug;

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

 function StrCmp(const Str,M:string):boolean;

implementation

function _StrCmp(const Str,M:string; sInd,mInd:integer ):boolean;
begin
  while (mInd <= length(M))or(sInd <= length(Str)) do begin
    case M[mInd] of
{      '\':
         begin
           inc(mInd);
           if M[mInd] = Str[sInd] then begin
             inc(sInd); inc(mInd);
           end else Break;
         end;
}      '?':
        if Str[sInd] <> #0  then
         begin
          inc(sInd); inc(mInd);
         end
        else Break;
      '#':
        if Str[sInd] in ['0'..'9'] then
         begin
          inc(sInd); inc(mInd);
         end
        else Break;
      '*':
        begin
          if _StrCmp(Str,M,sInd,mInd+1) then 
           begin
             Result := true;
             exit;
           end
          else if sInd >= length(Str) then
           begin
              Result := false;
              exit;
           end
          else 
           begin
            while sInd < length(str) do
             begin
               inc(sInd);
               if _StrCmp(Str,M,sInd,mInd+1) then
                begin
                   Result := true;
                   Exit;
                end;
             end;            
           end;
        end;
      else
        if M[mInd] = Str[sInd] then
         begin
           inc(sInd); inc(mInd);
         end
        else Break;
    end;
  end;
  Result := (mInd > length(M))and(sInd > Length(Str));
end;

function StrCmp(const Str,M:string):boolean;
begin
  Result := _StrCmp(Str+#0,M+#0,1,1);
end;

procedure THIStrMask._work_doCompare;
var str,sstr,m:string;
begin
  str := ReadString(_Data,_data_Str);
  sstr := str+#0;
  m := _prop_Mask+#0;
  if (_prop_CaseSensitive = 1) then
  begin
    CharLower(PChar(sstr));
    CharLower(PChar(m));
  end;
  if _StrCmp(sstr,m,1,1) then
    _hi_CreateEvent(_Data,@_event_onTrue,str)
  else
    _hi_CreateEvent(_Data,@_event_onFalse,str);
end;

procedure THIStrMask._work_doMask;
begin
  _prop_Mask := ToString(_Data);
end;

end.
