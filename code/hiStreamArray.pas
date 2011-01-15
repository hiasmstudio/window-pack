unit hiStreamArray;

interface

uses Kol,Share;

type
  THIStreamArray = class(TArray)
   private
     function DataToPointer(var Data:TData):cardinal; override;
     procedure PointerToData(Data:cardinal; var Result:TData); override;
     procedure Delete(Value:cardinal); override;

     procedure Save(P:pointer; Data:cardinal); override;
     procedure Load(P:pointer; var Data:cardinal); override;
   public
     property _prop_Streams:PStrListEx write SetItems;
  end;

implementation

function THIStreamArray.DataToPointer;
var Strm:PStream;
begin
   Result := 0;  
   if (Data.Data_type = data_stream) then
     begin
       Strm := NewMemoryStream;
       Strm.Size := PStream(data.idata).Size; 
       Stream2Stream(Strm, PStream(data.idata), Strm.Size);
//       Strm.Write((PStream(data.idata).Memory)^,PStream(data.idata).Size);
       Result := cardinal(Strm);
     end;
end;

procedure THIStreamArray.PointerToData;
begin
  if Data <> 0 then
  begin
    PStream(Data).Position := 0;
    dtStream(Result, PStream(Data));
  end
  else
    dtStream(Result, nil);    
end;

procedure THIStreamArray.Delete;
begin
  PStream(Value).free;
end;

procedure THIStreamArray.Save;
var i:cardinal;
begin
   if _prop_FileFormat = 0 then
   begin
     i := PStream(Data).Size; 
     PStream(p).Write(pointer(i), Sizeof(i));
     PStream(p).Write((PStream(Data).Memory)^, PStream(Data).Size);
   end
   else ;
end;

procedure THIStreamArray.Load;
var Strm:PStream;
    i:cardinal;
begin
   Strm := NewMemoryStream;
   if _prop_FileFormat = 0 then
   begin
     PStream(p).Read(i, Sizeof(i));
     Stream2Stream(Strm, PStream(p), i);
   end
   else ;
   Data := cardinal(Strm);
end;

end.
