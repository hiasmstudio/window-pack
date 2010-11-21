unit hiBASS_CPU;

interface

uses Kol,Share,Debug,BASS;

type
  THIBASS_CPU = class(TDebug)
   private
   public
    procedure _var_UsageCPU(var _Data:TData; Index:word);
  end;

implementation

procedure THIBASS_CPU._var_UsageCPU;
begin
   dtReal(_Data, BASS_GetCPU());
end;

end.
