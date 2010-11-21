unit hiIntegerArray;

interface

uses Kol,Share;

type
  THIIntegerArray = class(TArray)
   private
     function DataToPointer(var Data:TData):cardinal; override;
     procedure PointerToData(Data:cardinal; var Result:TData); override;

     procedure Save(P:pointer; Data:cardinal); override;
     procedure Load(P:pointer; var Data:cardinal); override;
     function Swap(d1,d2:cardinal):boolean; override;
   public
     property _prop_IntArray:PStrListEx write SetItems;
  end;

implementation

function THIIntegerArray.Swap;
begin
  Result := integer(d1) > integer(d2);
end;

function THIIntegerArray.DataToPointer;
begin
   Result := ToInteger(Data);
end;

procedure THIIntegerArray.PointerToData;
begin
   dtInteger(Result,Data);
end;

procedure THIIntegerArray.Save;
begin
   if _prop_FileFormat = 0 then
    PStream(p).write(Data,sizeof(data))
   else string(p^) := int2str(data);
end;

procedure THIIntegerArray.Load;
begin
   if _prop_FileFormat = 0 then
    PStream(p).Read(Data,sizeof(data))
   else Data := str2int(string(p^));
end;

end.
