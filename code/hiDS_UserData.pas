unit hiDS_UserData;

interface

uses Kol,Share,Debug,hiDS_StaticData;

type
  TUDData = record
    i:integer;
    c:integer;
  end;
  PUDData = ^TUDData;
  THIDS_UserData = class(TDebug)
   private
    dst:TIDS_Table;
    lst:PStrList;
    
    function init:pointer;
    function count(id:pointer):integer;
    function columns(id:pointer):PStrList; 
    function row(id:pointer; var data:TDataArray):boolean;
    procedure close(id:pointer);
   public 
    _prop_Name:string;
    _data_Columns:THI_Event;
    _data_Count:THI_Event;
    _data_Row:THI_Event;
    _event_onClose:THI_Event;
    _event_onRow:THI_Event;
    _event_onInit:THI_Event;
    
    constructor Create;
    function getInterfaceDS_Table:IDS_Table;
  end;

implementation

constructor THIDS_UserData.Create;
begin
   inherited;
   dst.init := init;
   dst.count := count;
   dst.columns := columns;
   dst.row := row;
   dst.close := close;
end;

function THIDS_UserData.getInterfaceDS_Table;
begin
  Result := @dst;
end;

function THIDS_UserData.init:pointer;
var d:PUDData;
begin
   new(d);
   d.i := 0;
   d.c := ToIntegerEvent(_data_Count);
   Result := d;
   _hi_onEvent(_event_onInit);
end;

function THIDS_UserData.count(id:pointer):integer;
begin
  Result := PUDData(id).c;
end;

function THIDS_UserData.columns(id:pointer):PStrList; 
begin
  if lst = nil then
   begin
    lst := NewStrList;
    lst.text := ToStringEvent(_data_Columns);
   end;
  Result := lst;  
end;

function THIDS_UserData.row(id:pointer; var data:TDataArray):boolean;
var d:PData;
    dt:TData;
    i:integer;
begin
  if PUDData(id).i = PUDData(id).c then 
   begin
      Result := false;
      exit;
   end; 
 
  dtInteger(dt, PUDData(id).i);
  _ReadData(dt, _data_Row);
  d := @dt;
  i := 0;
  SetLength(data, lst.count);
  while d <> nil do
   begin
     data[i] := d^;
     inc(i);
     d := d.ldata;
   end;
  inc(PUDData(id).i);
  Result := true; 
end;
     
procedure THIDS_UserData.close(id:pointer);
begin
  dispose(id);
  _hi_onEvent(_event_onClose); 
end;

end.
