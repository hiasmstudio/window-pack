unit hiSIDConvertor;

interface

uses Windows,Kol,Share,Debug;

type
  THISIDConvertor = class(TDebug)
   private
   public
    _prop_Mode:byte;

    _data_Data:THI_Event;
    _event_onConvert:THI_Event;

    procedure _work_doConvert0(var _Data:TData; Index:word);
    procedure _work_doConvert1(var _Data:TData; Index:word);
  end;

implementation

uses hiFSOwner;

type PPChar = ^PChar; 

function ConvertSidToStringSidA(SID:PSID; var pStringSID:PChar):LongBool; stdcall; external 'advapi32.dll'; 
function ConvertStringSidToSidA(StringSid:PChar; var Sid:PSID):LongBool; stdcall; external 'advapi32.dll';

procedure THISIDConvertor._work_doConvert0;
var sid: PSID;
    dt:TData;
    sd:PChar;
begin
   dt := ReadData(_Data,_data_Data,nil);
   if _IsObject(dt,SID_GUID) then
    begin    
      sid := PSID(ToObject(dt));
      sd := nil;
      if not ConvertSidToStringSidA(sid, sd) then
         ;
      _hi_onEvent(_event_onConvert, string(sd));
      LocalFree(cardinal(sd));
    end;
end;

procedure THISIDConvertor._work_doConvert1;
var s:string;
    sid:PSID;
begin
   s := ReadString(_Data, _data_Data, '');
   if not ConvertStringSidToSidA(PChar(s), sid) then
     ;
   dtObject(_Data,SID_GUID,sid); 
   _hi_onEvent(_event_onConvert, _Data);
   LocalFree(cardinal(sid));    
end;

end.
