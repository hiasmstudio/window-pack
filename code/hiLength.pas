unit hiLength;

interface

uses Kol,Share,Debug;

type
  THILength = class(TDebug)
   private
    FResult:integer;
   public  
    _data_Str:THI_Event;
    _event_onLength:THI_Event;

    procedure _work_doLength(var _Data:TData; Index:word);
    procedure _var_Result(var _Data:TData; Index:word);
  end;

implementation

procedure THILength._work_doLength;
begin
   FResult := Length(ReadString(_Data,_data_Str,''));
   _hi_OnEvent(_event_onLength,FResult);
end;

procedure THILength._var_Result;
begin
   dtInteger(_Data,FResult);
end;


end.

