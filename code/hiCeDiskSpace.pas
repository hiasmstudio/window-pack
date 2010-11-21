unit hiCeDiskSpace;

interface

uses Kol,KolRapi,Share,Debug,Windows;

type
  THICeDiskSpace = class(TDebug)
   private
   public
    _data_Dir:THI_Event;
    _prop_Dir:string;
    _prop_Size:integer;

    procedure _var_Size(var _Data:TData; Index:word);
    procedure _var_FreeSize(var _Data:TData; Index:word);
    procedure _var_FreeSizeForCaller(var _Data:TData; Index:word);
    procedure _var_ObjectStoreSize(var _Data:TData; Index:word);
    procedure _var_ObjectStoreFreeSize(var _Data:TData; Index:word);
  end;

implementation

const _sx:array[0..2] of cardinal = (1,1024,1024*1024);

type T=record L,H:integer end;

procedure THICeDiskSpace._var_Size;
var X,Y,Z:Int64;
    d:string;
begin
  d := ReadString(_Data,_data_Dir,_prop_Dir);
  CeGetDiskFreeSpaceEx(StringToOleStr(d),@X,@Y,@Z);
  if (T(Y).H = 0) and (T(Y).L >= 0) then dtInteger(_Data,T(Y).L  div _sx[_prop_Size])
   else dtReal(_Data,Y  div _sx[_prop_Size]);
end;

procedure THICeDiskSpace._var_FreeSize;
var X,Y,Z:Int64;
    d:string;
begin
  d := ReadString(_Data,_data_Dir,_prop_Dir);
  CeGetDiskFreeSpaceEx(StringToOleStr(d),@X,@Y,@Z);
  if (T(Z).H = 0) and (T(Z).L >= 0) then dtInteger(_Data,T(Z).L  div _sx[_prop_Size])
   else dtReal(_Data,Z  div _sx[_prop_Size]);
end;

procedure THICeDiskSpace._var_FreeSizeForCaller;
var X,Y,Z:Int64;
    d:string;
begin
  d := ReadString(_Data,_data_Dir,_prop_Dir);
  CeGetDiskFreeSpaceEx(StringToOleStr(d),@X,@Y,@Z);
  if (T(X).H = 0) and (T(X).L >= 0) then dtInteger(_Data,T(X).L  div _sx[_prop_Size])
   else dtReal(_Data,X  div _sx[_prop_Size]);
end;

procedure THICeDiskSpace._var_ObjectStoreSize;
var sti:TStoreInformation;
begin
  CeGetStoreInformation(@sti);
  dtInteger(_Data,sti.dwStoreSize  div _sx[_prop_Size]);
end;

procedure THICeDiskSpace._var_ObjectStoreFreeSize;
var sti:TStoreInformation;
begin
  CeGetStoreInformation(@sti);
  dtInteger(_Data,sti.dwFreeSize  div _sx[_prop_Size]);
end;

end.
