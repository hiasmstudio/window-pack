unit hiStrCat;

interface

uses Kol,Share,Debug;

type
  THIStrCat = class(TDebug)
   private
     r:string;
   public
    _prop_Str1:string;
    _prop_Str2:string;

    _data_Str2:THI_Event;
    _data_Str1:THI_Event;
    _event_onStrCat:THI_Event;

    procedure _work_doStrCat(var _Data:TData; Index:word);
    procedure _work_doClear(var _Data:TData; Index:word);
    procedure _var_Result(var _Data:TData; Index:word);
  end;

implementation

procedure THIStrCat._work_doStrCat;
var   s1,s2:string;
begin
   s1 := ReadString(_Data,_data_Str1,_prop_Str1);
   s2 := ReadString(_Data,_data_Str2,_prop_Str2);
   r := s1 + s2; 
   _hi_CreateEvent(_data, @_event_onStrCat, r);
end;

procedure THIStrCat._work_doClear;
begin
   r := '';
end;

procedure THIStrCat._var_Result;
begin
   dtString(_data, r);
end;

end.
