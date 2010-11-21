unit hiRect;

interface

uses Windows,Kol,Share,Debug;

type
  THIRect = class(TDebug)
   private
     R:TRect;
   public
    _prop_X1:integer;
    _prop_Y1:integer;
    _prop_X2:integer;
    _prop_Y2:integer;

    _data_Y1:THI_Event;
    _data_X1:THI_Event;
    _data_Y2:THI_Event;
    _data_X2:THI_Event;

    procedure _var_Rect(var _Data:TData; Index:word);
  end;

implementation

procedure THIRect._var_Rect;
begin
  with R do begin
    Left := ReadInteger(_Data,_data_X1,_prop_X1);
    Top := ReadInteger(_Data,_data_Y1,_prop_Y1);
    Right := ReadInteger(_Data,_data_X2,_prop_X2);
    Bottom := ReadInteger(_Data,_data_Y2,_prop_Y2);
  end;
  dtRect(_Data,@R);
end;

end.
