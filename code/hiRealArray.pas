unit hiRealArray;

interface

uses Kol,Share;

type
  THIRealArray = class(TArray)
   private
     function DataToPointer(var Data:TData):cardinal; override;
     procedure PointerToData(Data:cardinal; var Result:TData); override;

     procedure Save(P:pointer; Data:cardinal); override;
     procedure Load(P:pointer; var Data:cardinal); override;

     procedure Delete(Value:cardinal); override;
   public
     property _prop_RealArray:PStrListEx write SetItems;
  end;

implementation

function THIRealArray.DataToPointer;
var r:^real;
begin
   new(r);
   r^ := ToReal(Data);
   Result := cardinal(r);
end;

procedure THIRealArray.PointerToData;
begin
   dtreal(Result,real(pointer(Data)^));
end;

procedure THIRealArray.Save;
begin
   if _prop_FileFormat = 0 then
    PStream(p).write(Real(pointer(Data)^),sizeof(real))
   else string(p^) := double2str(Real(pointer(Data)^));
end;

procedure THIRealArray.Load;
var r:^real;
begin
   new(r);
   if _prop_FileFormat = 0 then
    PStream(p).Read(r^,sizeof(real))
   else r^ := str2double(string(p^));
   Data := integer(r);
end;

procedure THIRealArray.Delete;
var r:^real;
begin
   r := pointer(Value);
   dispose( r );
end;

end.
