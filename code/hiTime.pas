unit hiTime; {системные дата-время ver 2.50}

interface

uses Kol,Share,Windows,Debug;

type
  THITime = class(TDebug)
   private
   public
      _prop_Time_Date:byte;
      _prop_Format:string;

      _data_newHours:THi_Event;
      _data_newMinute:THi_Event;
      _data_newSecond:THi_Event;

      procedure _var_DateTime(var _Data:TData; Index:word);
      procedure _var_FormatTime(var _Data:TData; Index:word);
      procedure _var_Hours(var _Data:TData; Index:word);
      procedure _var_Minute(var _Data:TData; Index:word);
      procedure _var_Second(var _Data:TData; Index:word);
      procedure _work_doTimeDate(var _Data:TData; Index:word);
  end;

  function TimeToStr(const Format:string; const t:TSystemTime):string;

implementation

function TimeToStr(const Format:string; const t:TSystemTime):string;
const namstr:string = 'YMWDhms';
type TTimeValue = array[0..6] of WORD;
     PTimeValue = ^TTimeValue;
var
  i:byte;
  function TwoDigit(value:integer):string;
  begin
    if Value < 10 then
      Result := '0' + Int2Str(value)
    else Result := Int2Str(value);
  end;
begin
   Result := Format;
   for i := 0 to 6 do
     Replace(Result,namstr[i+1],TwoDigit(PTimeValue(@t)^[i]));
end;

procedure THITime._var_FormatTime;
var   SystemTime: TSystemTime;
begin
   GetLocalTime(SystemTime);
   dtString(_Data,TimeToStr(_prop_Format,SystemTime));
end;

procedure THITime._var_DateTime;
var   SystemTime: TSystemTime;
      DateTime:TDateTime;
begin
   GetLocalTime(SystemTime);
   SystemTime2DateTime(SystemTime, DateTime);
   dtReal(_Data, DateTime);
end;

procedure THITime._var_Hours;
var
  SystemTime: TSystemTime;
begin
   GetLocalTime(SystemTime);
   if _prop_Time_Date = 0 then
      dtInteger(_Data, SystemTime.wHour)
   else dtInteger(_Data,SystemTime.wYear);
end;

procedure THITime._var_Minute;
var
  SystemTime: TSystemTime;
begin
   GetLocalTime(SystemTime);
   if _prop_Time_Date = 0 then
     dtInteger(_Data,SystemTime.wMinute)
   else dtInteger(_Data,SystemTime.wMonth);
end;

procedure THITime._var_Second;
var
  SystemTime: TSystemTime;
begin
   GetLocalTime(SystemTime);
   if _prop_Time_Date = 0 then
     dtInteger(_Data,SystemTime.wSecond)
   else dtInteger(_Data,SystemTime.wDay);
end;

procedure THITime._work_doTimeDate;
var
  SystemTime: TSystemTime;
begin
   GetLocalTime(SystemTime);
   with SystemTime do
    if _prop_Time_Date = 0 then
      begin
       wHour := ReadInteger(_Data,_data_newHours,0);
       wMinute := ReadInteger(_Data,_data_newMinute,0);
       wSecond := ReadInteger(_Data,_data_newSecond,0);
      end
    else
      begin
       wYear := ReadInteger(_Data,_data_newHours,0);
       wMonth := ReadInteger(_Data,_data_newMinute,0);
       wDay := ReadInteger(_Data,_data_newSecond,0);
      end;
   SetLocalTime(SystemTime);
end;

end.