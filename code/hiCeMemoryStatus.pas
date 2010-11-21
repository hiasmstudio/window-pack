unit hiCeMemoryStatus;

interface

uses Kol,KolRapi,Share,Windows,Debug;

type
  THICeMemoryStatus = class(TDebug)
   private
     lpMemoryStatus : TMemoryStatus;
   public
    _prop_Scale:byte;

    procedure _work_Refresh(var _Data:TData; Index:word);
    procedure _var_RAM(var _Data:TData; Index:word);
    procedure _var_RAM_free(var _Data:TData; Index:word);
    procedure _var_Virtual(var _Data:TData; Index:word);
    procedure _var_Virtual_free(var _Data:TData; Index:word);
    procedure _var_MemLoad(var _Data:TData; Index:word);
  end;

implementation

const Sc:array[0..2] of cardinal = (1,1024,1024*1024);

procedure THICeMemoryStatus._work_Refresh;
begin
  lpMemoryStatus.dwLength := SizeOf(lpMemoryStatus);
  CeGlobalMemoryStatus(@lpMemoryStatus);
end;

procedure THICeMemoryStatus._var_RAM;
begin
   dtInteger(_Data,lpMemoryStatus.dwTotalPhys div Sc[_prop_Scale]);
end;

procedure THICeMemoryStatus._var_RAM_free;
begin
   dtInteger(_Data,lpMemoryStatus.dwAvailPhys div Sc[_prop_Scale]);
end;

procedure THICeMemoryStatus._var_Virtual;
begin
   dtInteger(_Data,lpMemoryStatus.dwTotalVirtual div Sc[_prop_Scale]);
end;

procedure THICeMemoryStatus._var_Virtual_free;
begin
   dtInteger(_Data,lpMemoryStatus.dwAvailVirtual div Sc[_prop_Scale]);
end;

procedure THICeMemoryStatus._var_MemLoad;
begin
   dtInteger(_Data,lpMemoryStatus.dwMemoryLoad);
end;

end.
