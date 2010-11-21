unit hiVBScript;

interface

uses Kol,Share,Debug,Script;

type
  THIVBScript = class(TDebug)
   private
     Scr:TScript;
     Err:PStrList;
     FECount,FDCount:PStrList;
     WP,VP:PStrList;

     procedure SetEvent(const value:string);
     procedure SetData(const value:string);
     procedure SetWP(const value:string);
     procedure SetVP(const value:string);
     procedure SetScript(const value:string);

     function ReadPointIndex(List:PStrList; Data:PData):integer;

     function _OnEvent(Args:TRealFuncArg):TData;
     function _GetData(Args:TRealFuncArg):TData;

     function _Read(Args:TRealFuncArg):TData;
     function _Write(Args:TRealFuncArg):TData;
     function _Count(Args:TRealFuncArg):TData;
     function _Add(Args:TRealFuncArg):TData;
   public
     _event_EventPoints:array of THI_Event;
     _data_DataPoints:array of THI_Event;

     _prop_UseName:boolean;

     constructor Create;
     destructor Destroy; override;
     procedure _work_WorkPoints(var Data:TData; Index:word);
     procedure _var_VarPoints(var Data:TData; Index:word);

     property _prop_EventPoints:string write SetEvent;
     property _prop_DataPoints:string write SetData;
     property _prop_WorkPoints:string write SetWP;
     property _prop_VarPoints:string write SetVP;

     property _prop_Script:string write SetScript;
  end;

implementation

constructor THIVBScript.Create;
begin
   inherited;
   Scr :=  TScript.Create;
   Err := NewStrList;
   with Scr.LocRFuncs do
    begin
      Add('onEvent',_onEvent,['Index','Data']);
      Add('GetData',_GetData,['Index']);
    end;
  with Scr.Oop.Add('Array').Obj do
   begin
     AddMethod('Read',_Read,['Point','Index']);
     AddMethod('Write',_Write,['Point','Index','Data']);
     AddMethod('Count',_Count,['Point']);
     AddMethod('Add',_Add,['Point','Data']);
   end;
end;

destructor THIVBScript.Destroy;
begin
   Scr.Destroy;
   Err.Free;
   inherited;
end;

function THIVBScript.ReadPointIndex;
var k:integer;
begin
   Result := -1;
   if _IsStr(Data^) then
    for k := 0 to List.Count-1 do
     if StriComp(PChar(List.Items[k]),PChar(ToString(Data^))) = 0 then
      begin
       Result := k;
       break;
      end;

   if Result = -1 then
     Result := ToIntIndex(Data^);
end;


function THIVBScript._OnEvent;
var Ind:integer;dt:TData;
begin
   //_debug(Args[0].sdata);
   Ind := ReadPointIndex(FECount,Args[0]);
   if(ind >= 0)and(Ind < FECount.Count)then begin
     dtData(dt,Args[1]^);
     _hi_OnEvent(_event_EventPoints[Ind],dt);
   end;
end;

function THIVBScript._GetData;
var Ind:integer;
begin
   Ind := ReadPointIndex(FDCount,Args[0]);
   if(ind >= 0)and(Ind < FDCount.Count)then
    _ReadData(Result,_data_DataPoints[Ind]);
end;

//_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+
function THIVBScript._Read;
var Ind:integer;
    Arr:PArray;
begin
   Ind := ReadPointIndex(FDCount,Args[0]);

   if(ind >= 0)and(Ind < FDCount.Count)then begin
      Arr := ReadArray(_data_DataPoints[Ind]);
      if Arr <> nil then Arr._Get(Args[1]^,Result);
   end;
end;

function THIVBScript._Write;
var Ind:integer;
    Arr:PArray;
begin
   Ind := ReadPointIndex(FDCount,Args[0]);
   if(ind >= 0)and(Ind < FDCount.Count)then
    begin
      Arr := ReadArray(_data_DataPoints[Ind]);
      if Arr <> nil then
        Arr._Set(Args[1]^,Args[2]^);
    end;
end;

function THIVBScript._Add;
var Ind:integer;
    Arr:PArray;
begin
   Ind := ReadPointIndex(FDCount,Args[0]);
   if(ind >= 0)and(Ind < FDCount.Count)then
    begin
      Arr := ReadArray(_data_DataPoints[Ind]);
      if Arr <> nil then
        Arr._Add(Args[1]^);
    end;
end;

function THIVBScript._Count;
var Ind:integer;
   Arr:PArray;
begin
   Ind := ReadPointIndex(FDCount,Args[0]);
   dtNull(Result);

   if(ind >= 0)and(Ind < FDCount.Count)then
    begin
      Arr := ReadArray(_data_DataPoints[Ind]);
      if Arr <> nil then
         dtInteger(Result,Arr._Count);
    end;
end;
//_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+

procedure THIVBScript.SetEvent;
begin
   FECount := NewStrList;
   FECount.text := Value;
   SetLength(_event_EventPoints,FECount.Count);
end;

procedure THIVBScript.SetData;
begin
   FDCount := NewStrList;
   FDCount.text := Value;
   SetLength(_data_DataPoints,FDCount.Count);
end;

procedure THIVBScript.SetWP;
begin
   WP := NewStrList;
   WP.Text := Value;
end;

procedure THIVBScript.SetVP;
begin
   VP := NewStrList;
   VP.Text := Value;
end;

procedure THIVBScript.SetScript;
begin
   Scr.Text := Value;
   Scr.BuildFromText(Err);
   //_debug(Err.Text);
end;

procedure THIVBScript._work_WorkPoints(var Data:TData; Index:word);
var Ind:TData;
begin
   if StrIComp(PChar(WP.Items[Index]),'##SetScript') = 0 then
    begin
      Scr.Text := ToString(Data);
      Scr.BuildFromText(Err);
    end
   else
    begin
     if _prop_UseName then
       dtString(Ind,WP.Items[Index])
     else
       dtInteger(Ind,Index);
     Scr.Run('doWork',[@Data,@Ind]);
    end;
end;

procedure THIVBScript._var_VarPoints(var Data:TData; Index:word);
var Ind:TData;
begin
   if StrIComp(PChar(VP.Items[Index]),'##Errors') = 0 then
      dtString(Data,Err.Text)
   else
    begin
     if _prop_UseName then
       dtString(Ind,VP.Items[Index])
     else
       dtInteger(Ind,Index);
     Data := Scr.Run('GetVar',[@Data,@Ind]);
    end;
end;

end.
