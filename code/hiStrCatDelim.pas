unit hiStrCatDelim;

interface

uses Kol,Share,Debug;

type
  THIStrCatDelim = class(TDebug)
   private
     FRes:string;
   public
    _prop_Delimiter:string;
    _prop_Str1:string;
    _prop_Str2:string;

    _data_Delimiter:THI_Event;
    _data_Str2:THI_Event;
    _data_Str1:THI_Event;
    _event_onStrCatDlm:THI_Event;

    procedure _work_doStrCatDlm(var _Data:TData; Index:word);
    procedure _work_doClear(var _Data:TData; Index:word);
    procedure _var_Result(var _Data:TData; Index:word);
  end;

implementation

procedure THIStrCatDelim._work_doStrCatDlm;
var   s1,s2,d1:string;
begin
   s1 := ReadString(_Data,_data_Str1,_prop_Str1);
   s2 := ReadString(_Data,_data_Str2,_prop_Str2);
   d1 := ReadString(_Data,_data_Delimiter,_prop_Delimiter);
   FRes := s1 + d1 + s2;
   _hi_CreateEvent(_data, @_event_onStrCatDlm, FRes);
end;

procedure THIStrCatDelim._work_doClear;
begin
   FRes := '';
end;

procedure THIStrCatDelim._var_Result;
begin
   dtString(_data, FRes);
end;

end.