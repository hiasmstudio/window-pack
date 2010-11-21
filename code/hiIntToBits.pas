unit hiIntToBits;

interface

uses Kol,Share,Debug;

type
  THIIntToBits = class(TDebug)
   private
    FStop:boolean;
    FCount:word;
    procedure SetCount(Value:word);
   public
    _prop_Data_0:TData;
    _prop_Data_1:TData;
    _prop_ZeroBits:boolean;
    _prop_Direct:byte;

    _data_Value:THI_Event;
    onBit:array of THI_Event;

    procedure _work_doStop(var _Data:TData; Index:word);
    procedure _work_doBits(var _Data:TData; Index:word);
    procedure _work_doBitsRev(var _Data:TData; Index:word);
    property _prop_Count:word write SetCount;
  end;

implementation

procedure THIIntToBits.SetCount;
begin
   SetLength(onBit,Value);
   FCount := Value;
end;

procedure THIIntToBits._work_doStop;
begin
   FStop := True;
end;

procedure THIIntToBits._work_doBits;
var i:integer;val:cardinal;
begin
  FStop := false;
  val := ReadInteger(_data,_data_Value,0);
  for i := 0 to FCount-1 do begin
    if ((val shr i) and 1) = 1 then
      _hi_OnEvent_(onBit[i],_prop_Data_1)
    else if _prop_ZeroBits then
      _hi_OnEvent_(onBit[i],_prop_Data_0);
    if FStop then break;
  end;
end;

procedure THIIntToBits._work_doBitsRev;
var i:integer;val:cardinal;
begin
  FStop := false;
  val := ReadInteger(_data,_data_Value,0);
  for i := FCount-1 downto 0 do begin
    if ((val shr i) and 1) = 1 then
      _hi_OnEvent_(onBit[i],_prop_Data_1)
    else if _prop_ZeroBits then
      _hi_OnEvent_(onBit[i],_prop_Data_0);
    if FStop then break;
  end;
end;

end.
