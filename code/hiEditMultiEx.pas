unit hiEditMultiEx;

interface

uses Kol,Share,Debug,hiMultiBase;

type
 THIEditMultiEx = class(TDebug)
   private
     FParent:pointer;
   public
     MainClass:TClassMultiBase;
     Works:array of THI_Event;
     Vars:array of THI_Event;

     procedure onEvent(var Data:TData; Index:word);
     procedure _Data(var Data:TData; Index:word);
     property Parent:pointer read FParent write FParent;
 end;

 PListEH = ^TListEH;
 TListEH = record
   Hnd:THIEditMultiEx;
   Prv:PListEH;
 end;

implementation

uses hiMultiElementEx;

procedure THIEditMultiEx.onEvent;
var X:TListEH;
begin
  X.Hnd := Self;
  X.Prv := THIMultiElementEx(FParent).EvHandle;
  THIMultiElementEx(FParent).EvHandle := @X;
  _hi_onEvent(THIMultiElementEx(FParent).Events[Index],Data);
  THIMultiElementEx(FParent).EvHandle := X.Prv;
end;

procedure THIEditMultiEx._Data;
var X:TListEH;
begin
  X.Hnd := Self;
  X.Prv := THIMultiElementEx(FParent).EvHandle;
  THIMultiElementEx(FParent).EvHandle := @X;
  _ReadData(Data,THIMultiElementEx(FParent).Datas[Index]);
  THIMultiElementEx(FParent).EvHandle := X.Prv;
end;

end.
