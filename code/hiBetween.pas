unit hiBetween;

interface

uses Kol, Share, If_arg, Debug;

type
  THIBetween = class(TDebug)
  private
  public
    _prop_InBorders: Integer;
    _prop_Data,
    _prop_Left,
    _prop_Right: TData;

    _event_onTrue,
    _event_onFalse,
    _data_Data,
    _data_Left,
    _data_Right: THI_Event;

    procedure _work_doBetween(var _Data:TData; Index:word);

  end;

implementation

procedure THIBetween._work_doBetween;
var
  L, R, D: TData;
  Result: Boolean;
begin
  D := ReadData(_Data, _data_Data, @_prop_Data);
  L := ReadData(_Data, _data_Left, @_prop_Left);
  R := ReadData(_Data, _data_Right, @_prop_Right);
  case _prop_InBorders of
    0: Result := Compare(D, L, 4) and Compare(D, R, 3);
    1: Result := Compare(D, L, 2) and Compare(D, R, 3);
    2: Result := Compare(D, L, 4) and Compare(D, R, 1);
    3: Result := Compare(D, L, 2) and Compare(D, R, 1)
  else
    Result := false;    
  end;
  if Result then
    _hi_CreateEvent(_Data, @_event_onTrue, D)
  else
    _hi_CreateEvent(_Data, @_event_onFalse, D);  
end;

end.