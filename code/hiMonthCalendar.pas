unit hiMonthCalendar;

interface

uses Windows,Kol,Share,Debug;

type
  THIMonthCalendar = class(TDebug)
   private
     Items:PStrListEx;
     
     procedure SetHolidays(Value:PStrListEx);
     procedure FillEmptyBefore(y, m, c:integer);
     procedure FillEmptyAfter(y, m, c:integer);
     function isHoliday(m, d:integer):boolean;
     
     procedure doEvent(d, dof, m:integer; dat:TDateTime);
   public
    _prop_Year:integer;
    _prop_Month:integer;
    _prop_EmptyDays:boolean;
    _prop_CurrentDay:boolean;    

    _data_Month:THI_Event;
    _data_Year:THI_Event;
    _data_Holidays:THI_Event;    
    _event_onDay:THI_Event;

    destructor Destroy; override;
    procedure _work_doEnumDays(var _Data:TData; Index:word);
    procedure _work_doEmptyDays(var _Data:TData; Index:word);
    procedure _work_doCurrentDay(var _Data:TData; Index:word);    
    property _prop_Holidays: PStrListEx write SetHolidays;
  end;

implementation

const 
   DAY_WORK = $01;
   DAY_OFF  = $02;
   DAY_HOLIDAY = $04;
   DAY_CURRENT = $08;

destructor THIMonthCalendar.Destroy;
begin
   free_and_nil(Items);
   inherited;
end;

function THIMonthCalendar.isHoliday(m, d:integer):boolean;
var
  i:integer;
  Arr:PArray;
  Ind, FItem:TData;
begin
   Result := false;
   if (Items <> nil) and not Assigned(_data_Holidays.Event) then
   begin
     for i := 0 to Items.Count-1 do
       if((Items.Objects[i] and $FF) = d)and((Items.Objects[i] shr 8) = m)then
       begin
         Result := true;
         exit;
       end;
   end
   else
   begin
     Arr := ReadArray(_data_Holidays);
     if Arr = nil then  exit;
     for i := 0 to Arr._Count - 1 do
	 begin
	   dtInteger(Ind, i);
       if not Arr._Get(ind, FItem) then exit;
       if((ToInteger(FItem) and $FF) = d)and((ToInteger(FItem) shr 8) = m)then
       begin
         Result := true;
         exit;
       end;       
	 end;     
   end;    
end;

procedure THIMonthCalendar.doEvent(d, dof, m:integer; dat:TDateTime);
var
    dt,_d:TData;
    f:PData;
    cdat:TDateTime;    
    sdat:TSystemTime;
begin
    if _prop_CurrentDay then
    begin
      GetLocalTime(sdat);
      SystemTime2DateTime(sdat, cdat);
      if dat = trunc(cdat) then
      m := m or DAY_CURRENT;
    end;
    dtInteger(dt, d);
    dtInteger(_d, dof);
    AddMTData(@dt, @_d, f);
    dtInteger(_d, m);
    AddMTData(@dt, @_d, f);
    dtInteger(_d, trunc(dat));
    AddMTData(@dt, @_d, f);
     _hi_onEvent(_event_onDay, dt);
    FreeData(f);
end;

procedure THIMonthCalendar.FillEmptyBefore(y, m, c:integer);
var i,fd:integer;
    dat:TDateTime;
begin
  if m = 1 then
   begin
     dec(y);
     m := 12;
   end
  else dec(m);
              
  for i := 31 downto 1 do
    if EncodeDate(y, m, i, dat) then
      begin
        fd := i;
        break;
      end;
      
  for i := fd - c + 1 to fd do
    if EncodeDate(y, m, i, dat) then  
      doEvent(i, DayOfWeek(dat), 0, dat);
end;

procedure THIMonthCalendar.FillEmptyAfter(y, m, c:integer);
var i:integer;
    dat:TDateTime;
begin
  if m = 12 then
   begin
     inc(y);
     m := 1;
   end
  else inc(m);
              
  for i := 1 to c do
    if EncodeDate(y, m, i, dat) then  
      doEvent(i, DayOfWeek(dat), 0, dat);
end;

procedure THIMonthCalendar._work_doEnumDays;
var y,m,i,days:cardinal;
    dat:TDateTime;
    td:integer;
    msk:integer;
begin
   y := ReadInteger(_Data, _data_Year, _prop_Year);
   m := ReadInteger(_Data, _data_Month, _prop_Month);
   
   days := 0;
   for i := 1 to 31 do
     if EncodeDate(y, m, i, dat) then
       begin          
          td := DayOfWeek(dat);          
          if (i = 1) and _prop_EmptyDays and (td > 1) then
            begin
              FillEmptyBefore(y, m, td-1);
              days := td-1;
            end;
                
          msk := 0;
          if td > 5 then 
            msk := DAY_OFF
          else
            msk := DAY_WORK;

          if isHoliday(m, i) then
            msk := msk or DAY_HOLIDAY;
            
          doEvent(i, td, msk, dat);
          
          inc(days);  
       end
     else break; 
   if _prop_EmptyDays then
     FillEmptyAfter(y, m, 6*7 - days);
end;

procedure THIMonthCalendar.SetHolidays;
begin
   //Items.Free;
   Items := Value;
end;

procedure THIMonthCalendar._work_doEmptyDays;
begin
  _prop_EmptyDays := ReadBool(_Data);
end;

procedure THIMonthCalendar._work_doCurrentDay;
begin
  _prop_CurrentDay := ReadBool(_Data);
end;
 

end.
