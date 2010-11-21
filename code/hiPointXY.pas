unit hiPointXY;

interface

uses Kol,Share,Debug;

type
  THIPointXY = class(TDebug)
   private
   public
    _prop_X:integer;
    _prop_Y:integer;
    _data_Y:THI_Event;
    _data_X:THI_Event;

    procedure _var_Point(var _Data:TData; Index:word);
  end;

implementation

procedure THIPointXY._var_Point;
begin
   dtNull(_Data);
   dtInteger(_Data,word(ReadInteger(_Data,_data_Y,_prop_Y)) shl 16 + word(ReadInteger(_Data,_data_X,_prop_X)));
end;

end.
