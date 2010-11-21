unit hiChangeFileSecurity;

interface

uses Windows,Kol,Share,Debug;

type
  THIChangeFileSecurity = class(TDebug)
   private
   public
    _prop_FileName:string;

    _data_FileName:THI_Event;
    _data_PSD:THI_Event;
    _event_onError:THI_Event;
    _event_onSetFileSecurity:THI_Event;

    procedure _work_doSetFileSecurity(var _Data:TData; Index:word);
  end;

implementation

uses hiFileSecurity;

procedure THIChangeFileSecurity._work_doSetFileSecurity;
var SecDescr: PSecurityDescriptor;
    fn:string;
    dt:TData;
begin
   dt := ReadData(_Data,_data_PSD,nil);
   fn := ReadString(_Data, _data_Filename, _prop_FileName); 
   SecDescr := PSecurityDescriptor(ToObject(dt));
   if _IsObject(dt,PSD_GUID) then
    begin
      if not SetFileSecurity(PChar(fn), OWNER_SECURITY_INFORMATION or DACL_SECURITY_INFORMATION, SecDescr) then
        _hi_onEvent(_event_onError);
    end;
  _hi_onEvent(_event_onSetFileSecurity);  
end;

end.
