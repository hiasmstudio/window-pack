unit hiDateConvertor; { Конвертор даты-времени ver 2.10 }

interface

uses Windows,Kol,Share,Debug;

const
   // Sets UnixStartDate to TDateTime of 01/01/1970 in VCL format
  UnixStartDate: TDateTime = 25569;

type
 THIDateConvertor = class(TDebug)
   private
      FResult:TData;
      ST:TSystemTime;
      DateTime:TDateTime;
      FDateTime:string;
      procedure HeapIntToXXXX(d:PData);
   public
     _prop_Mode:byte;
     _prop_Format:string;

     _data_DYear:THI_Event;
     _data_DMonth:THI_Event;
     _data_DDay:THI_Event;
     _data_DHour:THI_Event;
     _data_DMinute:THI_Event;
     _data_DSecond:THI_Event;
     _data_DMilliseconds:THI_Event;

     _data_Data:THI_Event;
     _event_OnResult:THI_Event;

     procedure _work_doConvert0  (var _Data:TData; Index:word);//DateRealToHeapInt
     procedure _work_doConvert1  (var _Data:TData; Index:word);//HeapIntToDateReal
     procedure _work_doConvert2  (var _Data:TData; Index:word);//DateVCLHeapInt
     procedure _work_doConvert3  (var _Data:TData; Index:word);//HeapIntToDateVCL
     procedure _work_doConvert4  (var _Data:TData; Index:word);//StrFmtToHeapInt
     procedure _work_doConvert5  (var _Data:TData; Index:word);//HeapIntToStrFmt
     procedure _work_doConvert6  (var _Data:TData; Index:word);//DateRealToDateVCL
     procedure _work_doConvert7  (var _Data:TData; Index:word);//DateVCLToDateReal
     procedure _work_doConvert8  (var _Data:TData; Index:word);//StrFmtToDateReal
     procedure _work_doConvert9  (var _Data:TData; Index:word);//DateRealToStrFmt
     procedure _work_doConvert10 (var _Data:TData; Index:word);//StrFmtToDateVCL
     procedure _work_doConvert11 (var _Data:TData; Index:word);//DateVCLToStrFmt
     
     procedure _work_doConvert12  (var _Data:TData; Index:word);//DateUnixToHeapInt
     procedure _work_doConvert13  (var _Data:TData; Index:word);//HeapIntToDateUnix     
     procedure _work_doConvert14  (var _Data:TData; Index:word);//DateUnixToDateVCL
     procedure _work_doConvert15  (var _Data:TData; Index:word);//DateVCLToDateUnix
     procedure _work_doConvert16  (var _Data:TData; Index:word);//DateUnixToStrFmt               
     procedure _work_doConvert17  (var _Data:TData; Index:word);//StrFmtToDateUnix
     procedure _work_doConvert18  (var _Data:TData; Index:word);//DateUnixToDateReal
     procedure _work_doConvert19  (var _Data:TData; Index:word);//DateRealToDateUnix          

     procedure _var_LeapYear     (var _Data:TData; Index:word);
     procedure _var_DayOfWeek    (var _Data:TData; Index:word);
     procedure _var_Year         (var _Data:TData; Index:word);
     procedure _var_Month        (var _Data:TData; Index:word);
     procedure _var_Day          (var _Data:TData; Index:word);
     procedure _var_Hour         (var _Data:TData; Index:word);
     procedure _var_Minute       (var _Data:TData; Index:word);
     procedure _var_Second       (var _Data:TData; Index:word);
     procedure _var_Milliseconds (var _Data:TData; Index:word);
     procedure _var_Result       (var _Data:TData; Index:word);

end;

implementation

procedure THIDateConvertor.HeapIntToXXXX;
begin
   FillChar(ST, Sizeof(ST), 0);
   ST.wYear:=         ReadInteger(d^, _data_DYear, 0);
   ST.wMonth:=        ReadInteger(d^, _data_DMonth, 0);
   ST.wDay:=          ReadInteger(d^, _data_DDay, 0);
   ST.wHour:=         ReadInteger(d^, _data_DHour, 0);
   ST.wMinute:=       ReadInteger(d^, _data_DMinute, 0);
   ST.wSecond:=       ReadInteger(d^, _data_DSecond, 0);
   ST.wMilliseconds:= ReadInteger(d^, _data_DMilliseconds, 0); 
   SystemTime2DateTime(ST, DateTime);
end;

procedure THIDateConvertor._work_doConvert0;//DateRealToHeapInt
begin
   DateTime:= ReadReal(_Data,_data_Data,0);
   if DateTime > 202751589 then exit;
   FillChar(ST, Sizeof(ST), 0);
   DateTime2SystemTime(DateTime, ST);
   dtNull(FResult);
   _hi_CreateEvent(_Data,@_event_onResult, FResult); 
end;

procedure THIDateConvertor._work_doConvert1;//HeapIntToDateReal
begin
   HeapIntToXXXX(@_Data);
   dtReal(FResult,DateTime);
   _hi_CreateEvent(_Data,@_event_onResult, FResult); 
end;

procedure THIDateConvertor._work_doConvert2;//DateVCLHeapInt
begin
   DateTime:= ReadReal(_Data,_data_Data,0) + VCLDATE0;
   if DateTime > 202751589 then exit;
   FillChar(ST, Sizeof(ST), 0);
   DateTime2SystemTime(DateTime, ST);
   dtNull(FResult);
   _hi_CreateEvent(_Data,@_event_onResult, FResult);
end;

procedure THIDateConvertor._work_doConvert3;//HeapIntToDateVCL
begin
   HeapIntToXXXX(@_Data);
   dtReal(FResult,DateTime - VCLDATE0);
   _hi_CreateEvent(_Data,@_event_onResult, FResult); 
end;

procedure THIDateConvertor._work_doConvert4;//StrFmtToHeapInt
begin
   FDateTime:= ReadString(_Data,_data_Data,'');
   DateTime:= Str2DateTimeFmt(_prop_Format, FDateTime);
   if DateTime > 202751589 then exit;
   FillChar(ST, Sizeof(ST), 0);
   DateTime2SystemTime(DateTime, ST);
   dtNull(FResult);
   _hi_CreateEvent(_Data,@_event_onResult, FResult);  
end;

procedure THIDateConvertor._work_doConvert5;//HeapIntToStrFmt
begin
   HeapIntToXXXX(@_Data);
   dtString(FResult,Time2StrFmt(Date2StrFmt(_prop_Format, DateTime), DateTime));
   _hi_CreateEvent(_Data,@_event_onResult, FResult); 
end;

procedure THIDateConvertor._work_doConvert6;//DateRealToDateVCL
begin
   dtReal(FResult, ReadReal(_Data,_data_Data,0) - VCLDATE0);
   _hi_CreateEvent(_Data,@_event_onResult, FResult);   
end;

procedure THIDateConvertor._work_doConvert7;//DateVCLToDateReal
begin
   dtReal(FResult, ReadReal(_Data,_data_Data,0) + VCLDATE0);
   _hi_CreateEvent(_Data,@_event_onResult, FResult);  
end;

procedure THIDateConvertor._work_doConvert8;//StrFmtToDateReal
begin
   FDateTime:= ReadString(_Data,_data_Data,'');
   DateTime:= Str2DateTimeFmt(_prop_Format, FDateTime);
   if DateTime > 202751589 then exit;
   dtReal(FResult,DateTime);
   _hi_CreateEvent(_Data,@_event_onResult, FResult);   
end;

procedure THIDateConvertor._work_doConvert9;//DateRealToStrFmt
begin
   DateTime:= ReadReal(_Data,_data_Data,0);
   if DateTime > 202751589 then exit;
   dtString(FResult,Time2StrFmt(Date2StrFmt(_prop_Format, DateTime), DateTime));
   _hi_CreateEvent(_Data,@_event_onResult, FResult);
end;

procedure THIDateConvertor._work_doConvert10;//StrFmtToDateVCL
begin
   FDateTime:= ReadString(_Data,_data_Data,'');
   DateTime:= Str2DateTimeFmt(_prop_Format, FDateTime) - VCLDATE0;;
   if DateTime > 202751589 then exit;
   dtReal(FResult,DateTime);
   _hi_CreateEvent(_Data,@_event_onResult, FResult);   
end;

procedure THIDateConvertor._work_doConvert11;//DateVCLToStrFmt
begin
   DateTime:= ReadReal(_Data,_data_Data,0) + VCLDATE0;
   if DateTime > 202751589 then exit;
   dtString(FResult,Time2StrFmt(Date2StrFmt(_prop_Format, DateTime), DateTime));
   _hi_CreateEvent(_Data,@_event_onResult, FResult); 
end;

procedure THIDateConvertor._work_doConvert12;//DateUnixToHeapInt
begin
   DateTime:= ((ReadInteger(_Data,_data_Data,0) / 86400) + UnixStartDate  + VCLDATE0);
   if DateTime > 202751589 then exit;
   FillChar(ST, Sizeof(ST), 0);
   DateTime2SystemTime(DateTime, ST);
   dtNull(FResult);
   _hi_CreateEvent(_Data,@_event_onResult, FResult); 
end;

procedure THIDateConvertor._work_doConvert13;//HeapIntToDateUnix     
begin
   HeapIntToXXXX(@_Data);
   dtInteger(FResult, Round((DateTime - UnixStartDate - VCLDATE0) * 86400));
   _hi_CreateEvent(_Data,@_event_onResult, FResult);
end;

procedure THIDateConvertor._work_doConvert14;//DateUnixToDateVCL
begin
   dtReal(FResult,(ReadInteger(_Data,_data_Data,0) / 86400) + UnixStartDate);
   _hi_CreateEvent(_Data,@_event_onResult, FResult);
end;

procedure THIDateConvertor._work_doConvert15;//DateVCLToDateUnix
begin
   dtInteger(FResult,Round((ReadReal(_Data,_data_Data,0) - UnixStartDate) * 86400));
   _hi_CreateEvent(_Data,@_event_onResult, FResult);
end;

procedure THIDateConvertor._work_doConvert16;//DateUnixToStrFmt               
begin
   DateTime:= ((ReadInteger(_Data,_data_Data,0) / 86400) + UnixStartDate  + VCLDATE0);
   if DateTime > 202751589 then exit;
   dtString(FResult,Time2StrFmt(Date2StrFmt(_prop_Format, DateTime), DateTime));
   _hi_CreateEvent(_Data,@_event_onResult, FResult);
end;

procedure THIDateConvertor._work_doConvert17;//StrFmtToDateUnix
begin
   FDateTime:= ReadString(_Data,_data_Data,'');
   DateTime:= Str2DateTimeFmt(_prop_Format, FDateTime);
   if DateTime > 202751589 then exit;
   dtInteger(FResult, Round((DateTime - UnixStartDate - VCLDATE0) * 86400));
   _hi_CreateEvent(_Data,@_event_onResult, FResult); 
end;

procedure THIDateConvertor._work_doConvert18;//DateUnixToDateReal
begin
   dtReal(FResult,(ReadInteger(_Data,_data_Data,0) / 86400) + UnixStartDate + VCLDATE0);
   _hi_CreateEvent(_Data,@_event_onResult, FResult);
end;

procedure THIDateConvertor._work_doConvert19;//DateRealToDateUnix  
begin
   dtInteger(FResult,Round((ReadReal(_Data,_data_Data,0) - UnixStartDate - VCLDATE0) * 86400));
   _hi_CreateEvent(_Data,@_event_onResult, FResult);
end;

procedure THIDateConvertor._var_Result;
begin
   _Data := FResult; 
end;

procedure THIDateConvertor._var_LeapYear;
begin
  dtInteger(_Data, ord(IsLeapYear(ST.wYear)));
end;

procedure THIDateConvertor._var_DayOfWeek;    begin dtInteger(_Data,DayOfWeek(DateTime)); end;
procedure THIDateConvertor._var_Year;         begin dtInteger(_Data,ST.wYear); end;
procedure THIDateConvertor._var_Month;        begin dtInteger(_Data,ST.wMonth); end;
procedure THIDateConvertor._var_Day;          begin dtInteger(_Data,ST.wDay); end;
procedure THIDateConvertor._var_Hour;         begin dtInteger(_Data,ST.wHour); end;
procedure THIDateConvertor._var_Minute;       begin dtInteger(_Data,ST.wMinute); end;
procedure THIDateConvertor._var_Second;       begin dtInteger(_Data,ST.wSecond); end;
procedure THIDateConvertor._var_Milliseconds; begin dtInteger(_Data,ST.wMilliseconds); end;

end.