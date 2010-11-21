unit hiRepeat;

interface

uses Kol,Share,If_arg,Debug;

type
  THIRepeat = class(TDebug)
   private
    FStop:boolean;
    function cmp:boolean;
   public
    _prop_Type:byte;
    _prop_Op1:TData;
    _prop_Op2:TData;
    _prop_Check:byte;
    _data_Op2:THI_Event;
    _data_Op1:THI_Event;
    _event_onRepeat:THI_Event;

    procedure _work_doRepeat0(var _Data:TData; Index:word);
    procedure _work_doRepeat1(var _Data:TData; Index:word);
    procedure _work_doStop(var _Data:TData; Index:word);
  end;

implementation


function THIRepeat.Cmp;
var dt:TData;
begin
  dt := ReadData(_data_Empty,_data_Op1,@_prop_Op1);
  Result := Compare(dt,ReadData(_data_Empty,_data_Op2,@_prop_Op2),_prop_Type);
end;

procedure THIRepeat._work_doRepeat0;//Before
begin
  FStop := false;
  while not FStop and Cmp do
    _hi_OnEvent(_event_onRepeat);
end;

procedure THIRepeat._work_doRepeat1;//After
begin
  FStop := false;
  repeat
    _hi_OnEvent(_event_onRepeat);
  until FStop or Cmp;
end;

procedure THIRepeat._work_doStop;
begin
  FStop := true;
end;

end.
