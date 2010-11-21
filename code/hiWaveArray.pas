unit hiWaveArray;

interface

uses Kol,Share;

type
  THIWaveArray = class(TArray)
   private
     procedure PointerToData(Data:cardinal; var Result:TData); override;
     procedure Delete(Value:cardinal); override;
   public
     _prop_PlayType:byte;
     procedure _work_doPlay(var _Data:TData; Index:word);
     property _prop_Waves:PStrListEx write SetItems;
  end;

implementation

uses hiPlaySound;

procedure THIWaveArray.PointerToData;
begin
   dtString(Result,String(pointer(Data)^));
end;

procedure THIWaveArray.Delete;
var r:^string;
begin
   r := pointer(Value);
   dispose( r );
end;

procedure THIWaveArray._work_doPlay;
var dt:TData;
begin
  if Read(_Data,dt) then
    Play( dt.sdata, PlaySound_value[_prop_PlayType]);
end;

end.
