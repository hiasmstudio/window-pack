unit hiSIDInfo;

interface

uses Windows,Kol,Share,Debug;

type
  THISIDInfo = class(TDebug)
   private
    FInfo:string;
   public

    _data_SID:THI_Event;
    _event_onGetInfo:THI_Event;

    procedure _work_doGetInfo(var _Data:TData; Index:word);
    procedure _var_Result(var _Data:TData; Index:word);
  end;

implementation

uses hiFSOwner;

procedure THISIDInfo._work_doGetInfo;
var sid: PSID;
    dt:TData;
    OwnerName, DomainName:array[0..512] of char;
    SizeNeeded, SizeNeeded2: DWORD;
    OwnerType: SID_NAME_USE;
begin
   dt := ReadData(_Data,_data_SID,nil);
   if _IsObject(dt,SID_GUID) then
    begin    
      sid := PSID(ToObject(dt));
      SizeNeeded := 512;
      SizeNeeded2 := 512;
      if not LookupAccountSID(nil, sid, OwnerName, SizeNeeded, DomainName, SizeNeeded2, OwnerType) then
        ;
      FInfo := string(DomainName) + '\' + string(OwnerName);  
      _hi_onEvent(_event_onGetInfo, FInfo);
    end;
end;

procedure THISIDInfo._var_Result;
begin
  dtString(_Data, FInfo);
end;

end.
