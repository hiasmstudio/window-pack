unit hiNetInterfaces;

interface

uses Windows,Kol,Share,Debug;

type
 PMibIfRow = ^TMibIfRow;
 TMibIfRow = packed record
    wszName		: array[0..255] of WideChar;
    dwIndex		: DWORD;
    dwType		: DWORD;
    dwMtu		: DWORD;
    dwSpeed		: DWORD;
    dwPhysAddrLen	: DWORD;
    bPhysAddr		: array[1..8] of Byte;
    dwAdminStatus	: DWORD;
    dwOperStatus	: DWORD;
    dwLastChange	: DWORD;
    dwInOctets		: DWORD;
    dwInUcastPkts	: DWORD;
    dwInNUCastPkts	: DWORD;
    dwInDiscards	: DWORD;
    dwInErrors		: DWORD;
    dwInUnknownProtos	: DWORD;
    dwOutOctets		: DWORD;
    dwOutUCastPkts	: DWORD;
    dwOutNUCastPkts	: DWORD;
    dwOutDiscards	: DWORD;
    dwOutErrors		: DWORD;
    dwOutQLen		: DWORD;
    dwDescrLen		: DWORD;
    bDescr		: array[0..255] of Char;
 end;

 pMibIfArray = ^TMIBIFARRAY;
 TMibIfArray = array [0..512] of TMibIfRow;

 PMibIfTable = ^TMibIfTable;
 TMibIfTable = packed record
   dwNumEntries	: DWORD;
   Table    	: TMibIfArray;
 end;

 TMacAddress=array [1..8] of byte;
 
  THINetInterfaces = class(TDebug)
   private
   public

    _event_onEnum:THI_Event;

    procedure _work_doEnum(var _Data:TData; Index:word);
    procedure _var_Count(var _Data:TData; Index:word);
  end;

    function GetIfTable(pIfTable:PMibIfTable; pdwSize: PULONG;
                bOrder: boolean ): DWORD; stdCall; external 'IPHLPAPI.DLL';

implementation

procedure THINetInterfaces._work_doEnum;
var
  _MibIfTable:PMibIfTable;
  _buflen:dword;
  i:integer;
  dt:TData;
  mt:PMT;
begin
   _buflen := sizeof(_MibIfTable^);
   New(_MibIfTable);
   if GetIfTable(_MibIfTable, @_buflen, false) = NO_ERROR then
     for i := 0 to _MibIfTable.dwNumEntries-1 do
       begin
         dtString(dt, PWideChar(@_MibIfTable.Table[i].wszName));
         mt := mt_make(dt);
         mt_string(mt, _MibIfTable.Table[i].bDescr); 
         mt_int(mt, _MibIfTable.Table[i].dwSpeed);
         _hi_onEvent(_event_onEnum, dt);
         mt_free(mt);
       end;
   dispose(_MibIfTable);
end;

procedure THINetInterfaces._var_Count;
var
  _MibIfTable:PMibIfTable;
  _buflen:dword;
begin
   _buflen := sizeof(_MibIfTable^);
   New(_MibIfTable);
   if GetIfTable(_MibIfTable, @_buflen, false) = NO_ERROR then
     dtInteger(_Data, _MibIfTable.dwNumEntries)
   else dtInteger(_Data, -1); 
   
   dispose(_MibIfTable);
end;

end.
