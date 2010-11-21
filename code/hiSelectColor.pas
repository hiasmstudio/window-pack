unit hiSelectColor;

interface

uses Windows,Kol,Share,Debug;

type
  ThiSelectColor = class(TDebug)
   private

   public
    _prop_Color: TColor;
    _event_onColor: THI_Event;    

    procedure _work_doColor(var _Data: TData; Index: word);
    procedure _var_Result(var _Data: TData; Index: word);
  end;

implementation

procedure ThiSelectColor._work_doColor;
begin
  _hi_CreateEvent(_Data, @_event_onColor, Color2RGB(_prop_Color));
end;

procedure ThiSelectColor._var_Result;
begin
  dtInteger(_Data, Color2RGB(_prop_Color));
end;

end.
