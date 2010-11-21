unit hiFSOwner;

interface

uses windows,Kol,Share,Debug;

type
  THIFSOwner = class(TDebug)
   private
    OwnerSID: PSID;
    OwnerDefault: BOOL;
   public

    _data_PSD:THI_Event;
    _event_onGetOwner:THI_Event;
    _event_onError:THI_Event;

    constructor Create;
    destructor Destroy; override;    
    procedure _work_doGetOwner(var _Data:TData; Index:word);
    procedure _var_SID(var _Data:TData; Index:word);
  end;

var SID_GUID:integer;

implementation

uses hiFileSecurity;

constructor THIFSOwner.Create;
begin
   inherited;
   GenGUID(SID_GUID);     
end;

destructor THIFSOwner.Destroy;
begin
   inherited;
end;

procedure THIFSOwner._work_doGetOwner;
var SecDescr: PSecurityDescriptor;
    dt:TData;
begin
   dt := ReadData(_Data,_data_PSD,nil);
   SecDescr := PSecurityDescriptor(ToObject(dt));
   if _IsObject(dt,PSD_GUID) then
    begin
      if not GetSecurityDescriptorOwner(SecDescr, OwnerSID, OwnerDefault) then
        _hi_onEvent(_event_onError);
    end;
   dtObject(_Data,SID_GUID,OwnerSID);
   _hi_onEvent(_event_onGetOwner, _Data);  
end;

procedure THIFSOwner._var_SID;
begin
   dtObject(_Data,SID_GUID,OwnerSID);
end;

end.
