unit hiChangeMon;

interface

uses Kol,Share,Debug;

type
  THIChangeMon = class(TDebug)
   private
    _Dt:TData;
    function CmpData(const D1,D2:TData):boolean;
   public
    _data_Data:THI_Event;
    _event_onData:THI_Event;

    procedure _work_doData(var _Data:TData; Index:word);
    property _prop_Data:TData write _Dt;
  end;

implementation

function THIChangeMon.CmpData;
begin
   if D1.Data_type = D2.Data_type then
    case D1.Data_type of
      data_null: Result := true;
      data_int : Result := d1.idata = d2.idata;
      data_str : Result := D1.sdata = D2.sdata;
      data_real: Result := D1.rdata = D2.rdata;
    else Result := false;
    end
   else Result := false;
end;

procedure THIChangeMon._work_doData;
begin
  _Data := ReadData(_Data,_data_Data);
  if not CmpData(_Dt,_Data) then begin
    _Dt := _Data;
    _hi_CreateEvent_(_Data,@_event_onData);
  end;
end;

end.
