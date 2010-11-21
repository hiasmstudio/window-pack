unit hiGetData;

interface

uses Kol,Share,Debug;

type
  THIGetData = class(TDebug)
   private
   public
    _prop_Count:integer;
    _data_Data:THI_Event;

    procedure Data(var _Data:TData; Index:word);
  end;

implementation

procedure THIGetData.Data;
begin
   _ReadData(_Data,_data_Data);
end;

end.
