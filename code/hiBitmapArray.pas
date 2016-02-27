unit hiBitmapArray;

interface

uses Kol,Share;

type
  THIBitmapArray = class(TArray)
   private
     function DataToPointer(var Data:TData):cardinal; override;
     procedure PointerToData(Data:cardinal; var Result:TData); override;
     procedure Delete(Value:cardinal); override;

     procedure SetArray(const value:PStrListEx);

     procedure Save(P:pointer; Data:cardinal); override;
     procedure Load(P:pointer; var Data:cardinal); override;
   public
	 _data_IdxToName,
	 _event_onGetName: THI_Event;
     property _prop_Bitmaps:PStrListEx write SetArray;
     procedure _work_doGetName(var _Data: TData; Index: word);
  end;

implementation

function THIBitmapArray.DataToPointer;
var bmp:PBitMap;
begin
   if Data.Data_type = data_bitmap then
    begin
      bmp := NewBitmap(0,0);
      bmp.Assign(PBitmap( data.idata) );
      Result := integer(bmp);
    end
   else result := 0;
end;

procedure THIBitmapArray.PointerToData;
begin
   dtBitmap(Result,PBitmap(Data));
end;

procedure THIBitmapArray.Delete;
begin
   PBitMap(Value).Free;
end;

procedure THIBitmapArray.SetArray;
var bmp:PBitMap;
    i:integer;
begin
    SetItems(Value);
    for i := 0 to value.Count-1 do
     begin
      bmp := NewBitmap(0,0);
      bmp.Handle := Value.Objects[i];
      value.Objects[i] := cardinal(bmp);
     end;
end;

procedure THIBitmapArray.Save;
begin
   if _prop_FileFormat = 0 then
     PBitmap(Data).SaveToStream( PStream(p) )
   else ;
end;

procedure THIBitmapArray.Load;
var bmp:PBitmap;
begin
   bmp := NewBitmap(0,0);
   if _prop_FileFormat = 0 then
    bmp.LoadFromStream( PStream(p) )
   else ;
   Data := integer(bmp);
end;

procedure THIBitmapArray._work_doGetName;
var
  ind: integer; 
begin
  ind := ReadInteger(_Data, _data_IdxToName);
  if (ind >= 0) and (ind < Items.Count) then
    _hi_CreateEvent(_Data, @_event_onGetName, Items.Items[ind])
  else
    _hi_CreateEvent(_Data, @_event_onGetName, '');
end;

end.
