unit hiFSGetDACL;

interface

uses Windows,Kol,Share,Debug;

type
  THIFSGetDACL = class(TDebug)
   private
    FDacl:PACL; 
   public
    _data_PSD:THI_Event;
    _event_onGetDACL:THI_Event;
    _event_onError:THI_Event;

    constructor Create;
    procedure _work_doGetDACL(var _Data:TData; Index:word);
    procedure _var_DACL(var _Data:TData; Index:word);
  end;
  
var PACL_GUID:integer;

implementation

uses hiFileSecurity;

constructor THIFSGetDACL.Create;
begin
   inherited;
   GenGUID(PACL_GUID);     
end;

procedure THIFSGetDACL._work_doGetDACL;
var 
   SecDescr: PSecurityDescriptor;
   p:longbool;
   dt:TData;
begin
   dt := ReadData(_Data,_data_PSD,nil);
   SecDescr := PSecurityDescriptor(ToObject(dt));
   if _IsObject(dt,PSD_GUID) then
    begin
      if not GetSecurityDescriptorDacl(SecDescr, p, FDacl, p) then
        _hi_onEvent(_event_onError);
    end;
  dtObject(_Data,PACL_GUID,FDacl);
  _hi_onEvent(_event_onGetDACL, _Data); 
end;

procedure THIFSGetDACL._var_DACL;
begin
  dtObject(_Data,PACL_GUID,FDacl)
end;

end.
