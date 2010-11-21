unit hiFileSecurity;

interface

uses windows, Kol,Share,Debug;

type
  THIFileSecurity = class(TDebug)
   private
    SecDescr: PSecurityDescriptor;
   public
    _prop_FileName:string;

    _data_FileName:THI_Event;
    _event_onGetFileSecurity:THI_Event;
    _event_onError:THI_Event;

    constructor Create;
    destructor Destroy; override;
    procedure _work_doGetFileSecurity(var _Data:TData; Index:word);
    procedure _var_PSD(var _Data:TData; Index:word);
  end;

var PSD_GUID:integer;

implementation

constructor THIFileSecurity.Create;
begin
   inherited;
   GenGUID(PSD_GUID);     
   GetMem(SecDescr, 1024);  
end;

destructor THIFileSecurity.Destroy;
begin
   FreeMem(SecDescr);  
   inherited;
end;

procedure THIFileSecurity._work_doGetFileSecurity;
var SizeNeeded:DWORD;
begin
  if not GetFileSecurity(PChar(ReadString(_Data, _data_FileName, _prop_FileName)),OWNER_SECURITY_INFORMATION or DACL_SECURITY_INFORMATION, SecDescr, 1024, SizeNeeded) then
    _hi_onEvent(_event_onError);
  dtObject(_Data,PSD_GUID,SecDescr);
  _hi_onEvent(_event_onGetFileSecurity, _Data);
end;

procedure THIFileSecurity._var_PSD;
begin
  dtObject(_Data,PSD_GUID,SecDescr);
end;

end.
