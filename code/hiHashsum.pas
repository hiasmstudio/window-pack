unit hiHashsum;

interface

uses Kol,Share,Debug,MD5,CryptoAPI;

type
  THIHashsum = class(TDebug)
   private
   public
    _prop_HashType:integer;
    _data_Data:THI_Event;
    _event_onResult:THI_Event;

    procedure _work_doHashsum0(var _Data:TData; Index:word);
    procedure _work_doFileHashsum0(var _Data:TData; Index:word);
    procedure _work_doHashsum1(var _Data:TData; Index:word);
    procedure _work_doFileHashsum1(var _Data:TData; Index:word);
    procedure _work_doHashsum2(var _Data:TData; Index:word);
    procedure _work_doFileHashsum2(var _Data:TData; Index:word);
    procedure _work_doHashsum3(var _Data:TData; Index:word);
    procedure _work_doFileHashsum3(var _Data:TData; Index:word);
    procedure _work_doHashsum4(var _Data:TData; Index:word);
    procedure _work_doFileHashsum4(var _Data:TData; Index:word);
  end;

implementation

procedure THIHashsum._work_doHashsum0;
var dt:TData;
    Res:string;
begin
   dt := ReadData(_Data,_data_Data,nil);
   case dt.Data_type of
    data_str,data_int,data_real: Res := MD5DigestToStr( MD5String(ToString(dt)) );
    data_stream:
      if(PStream(dt.idata) <> nil)and(PStream(dt.idata).Size > 0)then
       Res := MD5DigestToStr( MD5Stream(PStream(dt.idata)) )
      else Res := '';
    else Res := '';
   end;
  _hi_OnEvent(_event_onResult,Res);
end;

procedure THIHashsum._work_doFileHashsum0;
var Res:string;
begin
   Res := ReadFileName(ReadString(_Data,_data_Data,''));
   if FileExists(Res) then
    Res := MD5DigestToStr( MD5File(Res) )
   else Res := '';
   _hi_OnEvent(_event_onResult,Res);
end;

procedure THIHashsum._work_doHashsum1(var _Data:TData; Index:word);
var dt:TData;
    Res:string;
begin
   dt := ReadData(_Data,_data_Data,nil);
   case dt.Data_type of
    data_str,data_int,data_real: HashStr(HASH_SHA1, ToString(dt), Res);
    data_stream:
      if(PStream(dt.idata) <> nil)and(PStream(dt.idata).Size > 0)then
        HashBuf(HASH_SHA1, PStream(dt.idata).Memory, PStream(dt.idata).Size, Res)
      else Res := '';
    else Res := '';
   end;
  _hi_OnEvent(_event_onResult,Res);
end;

procedure THIHashsum._work_doFileHashsum1(var _Data:TData; Index:word);
var Res:string;
begin
   Res := ReadFileName(ReadString(_Data,_data_Data,''));
   if FileExists(Res) then
      HashFile(HASH_SHA1, Res, Res)
   else Res := '';
   _hi_OnEvent(_event_onResult,Res);
end;

procedure THIHashsum._work_doHashsum2(var _Data:TData; Index:word);
var dt:TData;
    Res:string;
begin
   dt := ReadData(_Data,_data_Data,nil);
   case dt.Data_type of
    data_str,data_int,data_real: HashStr(HASH_SHA256, ToString(dt), Res);
    data_stream:
      if(PStream(dt.idata) <> nil)and(PStream(dt.idata).Size > 0)then
        HashBuf(HASH_SHA256, PStream(dt.idata).Memory, PStream(dt.idata).Size, Res)
      else Res := '';
    else Res := '';
   end;
  _hi_OnEvent(_event_onResult,Res);
end;

procedure THIHashsum._work_doFileHashsum2(var _Data:TData; Index:word);
var Res:string;
begin
   Res := ReadFileName(ReadString(_Data,_data_Data,''));
   if FileExists(Res) then
      HashFile(HASH_SHA256, Res, Res)
   else Res := '';
   _hi_OnEvent(_event_onResult,Res);
end;

procedure THIHashsum._work_doHashsum3(var _Data:TData; Index:word);
var dt:TData;
    Res:string;
begin
   dt := ReadData(_Data,_data_Data,nil);
   case dt.Data_type of
    data_str,data_int,data_real: HashStr(HASH_SHA384, ToString(dt), Res);
    data_stream:
      if(PStream(dt.idata) <> nil)and(PStream(dt.idata).Size > 0)then
        HashBuf(HASH_SHA384, PStream(dt.idata).Memory, PStream(dt.idata).Size, Res)
      else Res := '';
    else Res := '';
   end;
  _hi_OnEvent(_event_onResult,Res);
end;

procedure THIHashsum._work_doFileHashsum3(var _Data:TData; Index:word);
var Res:string;
begin
   Res := ReadFileName(ReadString(_Data,_data_Data,''));
   if FileExists(Res) then
      HashFile(HASH_SHA384, Res, Res)
   else Res := '';
   _hi_OnEvent(_event_onResult,Res);
end;

procedure THIHashsum._work_doHashsum4(var _Data:TData; Index:word);
var dt:TData;
    Res:string;
begin
   dt := ReadData(_Data,_data_Data,nil);
   case dt.Data_type of
    data_str,data_int,data_real: HashStr(HASH_SHA512, ToString(dt), Res);
    data_stream:
      if(PStream(dt.idata) <> nil)and(PStream(dt.idata).Size > 0)then
        HashBuf(HASH_SHA512, PStream(dt.idata).Memory, PStream(dt.idata).Size, Res)
      else Res := '';
    else Res := '';
   end;
  _hi_OnEvent(_event_onResult,Res);
end;

procedure THIHashsum._work_doFileHashsum4(var _Data:TData; Index:word);
var Res:string;
begin
   Res := ReadFileName(ReadString(_Data,_data_Data,''));
   if FileExists(Res) then
      HashFile(HASH_SHA512, Res, Res)
   else Res := '';
   _hi_OnEvent(_event_onResult,Res);
end;

end.
