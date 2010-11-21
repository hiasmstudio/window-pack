unit hiEditPolyMulti;

interface

uses Kol,Share,Debug;

type
 THIEditPolyMulti = class(TDebug)
   private
     FParent:pointer;
   public
     MainClass:TObject;
     Works:array of THI_Event;
     Vars:array of THI_Event;

     procedure onEvent(var Data:TData; Index:word);
     procedure _Data(var Data:TData; Index:word);
     property Parent:pointer write FParent;
 end;

 PListEH = ^TListEH;
 TListEH = record
   Hnd:THIEditPolyMulti;
   Prv:PListEH;
 end;

implementation

uses hiPolymorphMulti;

procedure THIEditPolyMulti.onEvent;
var X:TListEH;
begin
  X.Hnd := Self;
  X.Prv := THIPolymorphMulti(FParent).EvHandle;
  THIPolymorphMulti(FParent).EvHandle := @X;
  _hi_onEvent(THIPolymorphMulti(FParent).Events[Index],Data);
  THIPolymorphMulti(FParent).EvHandle := X.Prv;
end;

procedure THIEditPolyMulti._Data;
var X:TListEH;
begin
  X.Hnd := Self;
  X.Prv := THIPolymorphMulti(FParent).EvHandle;
  THIPolymorphMulti(FParent).EvHandle := @X;
  _ReadData(Data,THIPolymorphMulti(FParent).Datas[Index]);
  THIPolymorphMulti(FParent).EvHandle := X.Prv;
end;

end.