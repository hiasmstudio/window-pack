unit hiNetInterfaceInfo;

interface

uses Windows,Kol,Share,Debug,hiNetInterfaces;

type
  THINetInterfaceInfo = class(TDebug)
   private
    _MibIfTable:TMibIfTable;
    row:PMibIfRow;
   public
    _prop_Index:integer;

    _data_Index:THI_Event;
    _event_onReadInfo:THI_Event;

    procedure _work_doReadinfo(var _Data:TData; Index:word);
    procedure _var_PhysAddr(var _Data:TData; Index:word);
    procedure _var_Speed(var _Data:TData; Index:word);
    procedure _var_Mtu(var _Data:TData; Index:word);
    procedure _var_InOctets(var _Data:TData; Index:word);
    procedure _var_InErrors(var _Data:TData; Index:word);
    procedure _var_OutOctets(var _Data:TData; Index:word);
    procedure _var_OutErrors(var _Data:TData; Index:word);
  end;

implementation

procedure THINetInterfaceInfo._work_doReadinfo;
var
  _buflen:dword;
  i:integer;
begin
   _buflen := sizeof(_MibIfTable);
   if GetIfTable(@_MibIfTable, @_buflen, false) = NO_ERROR then
       begin
         i := ReadInteger(_Data, _data_Index, _prop_Index); 
         row := @_MibIfTable.Table[i]; 
         _hi_onEvent(_event_onReadInfo);
       end;
end;

procedure THINetInterfaceInfo._var_PhysAddr;
var i:integer;
    s:string;
begin
   s := '';
   for i := 0 to 7 do
      s := s + ':' + int2hex(row.bPhysAddr[i], 2);
   delete(s, 1, 1);
   dtString(_Data, s);
end;

procedure THINetInterfaceInfo._var_Speed;
begin
  dtInteger(_Data, row.dwSpeed);
end;

procedure THINetInterfaceInfo._var_Mtu;
begin
  dtInteger(_Data, row.dwMTU);
end;

procedure THINetInterfaceInfo._var_InOctets;
begin
  dtInteger(_Data, row.dwInOctets);
end;

procedure THINetInterfaceInfo._var_InErrors;
begin
  dtInteger(_Data, row.dwInErrors);
end;

procedure THINetInterfaceInfo._var_OutOctets;
begin
  dtInteger(_Data, row.dwOutOctets);
end;

procedure THINetInterfaceInfo._var_OutErrors;
begin
  dtInteger(_Data, row.dwOutErrors);
end;

end.
