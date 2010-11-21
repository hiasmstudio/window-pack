unit hiUseActiveX;

interface

uses Win,Share,ActiveX,ActiveKOL,KOLComObj,KOL,err,Windows;

type

  PMyOleCtl = ^TMyOleCtl;
  TMyOleCtl = object(TOleCtl)
   protected
    procedure InitControlData; virtual;
    function IsInvisibleAtRuntime: boolean;
   public
    function GetEventTypeInfo: ITypeInfo;
  end;

  TMyEventHandler = class;
  
  THIUseActiveX = class(THIWin)
   private
    FEventHandler: TMyEventHandler;
    FEventConnection: longint;
    function doCallDispatch(var Data:TData; callType:word; res:PVariantArg):boolean;
   public
    _prop_CLSID: string;
    _event_onEvent: THI_Event;
    _event_onGetProp: THI_Event;
    _event_onError: THI_Event;
    procedure Init; override;
    procedure _work_doExecute(var Data:TData; Index:word);
    procedure _work_doGetProp(var Data:TData; Index:word);
    procedure _work_doSetProp(var Data:TData; Index:word);
  end;

  TMyEventHandler = class(TObject, IUnknown, IDispatch)
  private
    FMe: THIUseActiveX;
    FTypeInfo: ITypeInfo;
    FEventIID: TGUID;
  protected
    { IUnknown }
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
    { IDispatch }
    function GetTypeInfoCount(out Count: Integer): HResult; stdcall;
    function GetTypeInfo(Index, LocaleID: Integer; out TypeInfo): HResult; stdcall;
    function GetIDsOfNames(const IID: TGUID; Names: Pointer;  NameCount, LocaleID: Integer; DispIDs: Pointer): HResult; stdcall;
    function Invoke(DispID: Integer; const IID: TGUID; LocaleID: Integer; Flags: Word; var Params; VarResult, ExcepInfo, ArgErr: Pointer): HResult; stdcall;
  public
    constructor Create(Me: THIUseActiveX; EventTypeInfo: ITypeInfo);
    property IID: TGUID read FEventIID;
  end;

implementation

const
  NULL_GUID: TGUID = '{00000000-0000-0000-0000-000000000000}';

var NewCLSID:string;

procedure OleToData(var dt:TData; va:TVariantArg);
var v:PVariantArg;
begin
   v := @va; while v.vt=(VT_VARIANT or VT_BYREF) do v := PVariantArg(v.pvarVal); 
   case v.vt of
    VT_EMPTY: dtString(dt,'');
    VT_I1: dtInteger(dt,THiInt(v.cVal));
    VT_I2: dtInteger(dt,THiInt(v.iVal));
    VT_I4: dtInteger(dt,THiInt(v.lVal));
    VT_INT: dtInteger(dt,THiInt(v.intVal));
    VT_UI1: dtInteger(dt,THiInt(v.bVal));
    VT_UI2: dtInteger(dt,THiInt(v.uiVal));
    VT_UI4: dtInteger(dt,THiInt(v.ulVal));
    VT_UINT: dtInteger(dt,THiInt(v.uintVal));
    VT_R4: dtReal(dt,v.fltVal);
    VT_R8: dtReal(dt,v.dblVal);
    VT_DATE: dtReal(dt,v.date);
    VT_BOOL: if v.vbool then dtInteger(dt,1) else dtInteger(dt,0); 
    VT_BSTR: dtString(dt,WideString(v.bstrVal));
    VT_I1 or VT_BYREF: dtInteger(dt,THiInt(v.pcVal^));
    VT_I2 or VT_BYREF: dtInteger(dt,THiInt(v.piVal^));
    VT_I4 or VT_BYREF: dtInteger(dt,THiInt(v.plVal^));
    VT_INT or VT_BYREF: dtInteger(dt,THiInt(v.pintVal^));
    VT_UI1 or VT_BYREF: dtInteger(dt,THiInt(v.pbVal^));
    VT_UI2 or VT_BYREF: dtInteger(dt,THiInt(v.puiVal^));
    VT_UI4 or VT_BYREF: dtInteger(dt,THiInt(v.pulVal^));
    VT_UINT or VT_BYREF: dtInteger(dt,THiInt(v.puintVal^));
    VT_R4 or VT_BYREF: dtReal(dt,v.pfltVal^);
    VT_R8 or VT_BYREF: dtReal(dt,v.pdblVal^);
    VT_DATE or VT_BYREF: dtReal(dt,v.pdate^);
    VT_BOOL or VT_BYREF: if v.pbool^ then dtInteger(dt,1) else dtInteger(dt,0); 
    VT_BSTR or VT_BYREF: dtString(dt,WideString(v.pbstrVal^));
    else dtString(dt,'{vt='+int2str(v.vt)+'}');
   end;
end;

procedure DataToOle(var v:TVariantArg; const dt:TData);
begin
  case dt.data_type of
   data_int: begin v.vt := VT_I4; v.lVal := dt.idata; end;
   data_real:begin v.vt := VT_R8; v.dblVal := dt.rdata; end;
   data_str: begin v.vt := VT_BSTR; v.bstrVal := StringToOleStr(dt.sdata); end;
   else begin v.vt := VT_BSTR; v.bstrVal := SysAllocString('NULL'); end;
  end;
end;

function CallDispatch(const pdisp:IDispatch; wsName:WideString; callType:word; res:PVariantArg; const args:array of TVariantArg):HRESULT;
const dispid_put:integer = DISPID_PROPERTYPUT;
var dispid:integer; dparam:TDispParams;
begin
  Result := pdisp.GetIDsOfNames(NULL_GUID,@wsName,1,0,@dispid);
  if Result = S_OK then begin
    dparam.rgvarg := @args[0];
    dparam.cArgs := length(args);
    if callType=DISPATCH_PROPERTYPUT then begin
      dparam.rgdispidNamedArgs := @dispid_put;
      dparam.cNamedArgs := 1;
    end else
      dparam.cNamedArgs := 0;
    Result := pdisp.Invoke(dispid,NULL_GUID,0,callType,dparam,res,nil,nil);
  end;
end;

{ TMyOleCtl }

procedure TMyOleCtl.InitControlData;
var data: ^TControlData2; sid:POleStr; nResult:cardinal;
begin
  new(data);
  with data^ do begin
    sid := StringToOleStr(NewCLSID);
    nResult := CLSIDFromString(sid, ClassID);
    SysFreeString(sid);
    if nResult<>S_OK then
      raise Exception.Create(e_InvalidPointer,'ActiveX control not registered.');
    Version := 401;
  end;
  ControlData := pointer(data);
end;

function TMyOleCtl.IsInvisibleAtRuntime;
begin
  Result := FMiscStatus and OLEMISC_INVISIBLEATRUNTIME <> 0;
end;

function TMyOleCtl.GetEventTypeInfo;
var pdisp:IDispatch; nti:integer; pti:ITypeInfo;
    plib:ITypeLib; pattr:PTypeAttr; nFlags:integer; hRef:HRefType;
begin
  Result := nil; pdisp := OleObject;
  pdisp.GetTypeInfoCount(nti); if nti=0 then exit;
  pdisp.GetTypeInfo(0, LOCALE_SYSTEM_DEFAULT, pti);
  pti.GetContainingTypeLib(plib, nti); pti := nil;
  plib.GetTypeInfoOfGuid(FControlData^.ClassID, pti);
  pti.GetTypeAttr(pattr);
  for nti:=0 to pattr.cImplTypes do begin
    pti.GetImplTypeFlags(nti, nFlags);
    if ((nFlags and IMPLTYPEFLAG_FDEFAULT)<>0) and ((nFlags and IMPLTYPEFLAG_FSOURCE)<>0) then begin
      pti.GetRefTypeOfImplType(nti, hRef);
      pti.GetRefTypeInfo(hRef, Result);
      break;
    end;
  end;
  pti.ReleaseTypeAttr(pattr);
end;

function NewMyOleCtl(AParent:PControl; CLSID:string): PMyOleCtl;
begin
  NewCLSID := CLSID;
  New(Result, CreateParented(AParent));
end;

{ THIUseActiveX }

procedure THIUseActiveX.Init;
var pCtl: PMyOleCtl; tiEvents: ITypeInfo;
begin
  try
    pCtl := NewMyOleCtl(FParent, _prop_CLSID); Control := pCtl;
    tiEvents := pCtl.GetEventTypeInfo;
    if tiEvents<>nil then begin
      FEventHandler := TMyEventHandler.Create(Self, tiEvents);
      InterfaceConnect(pCtl.OleObject, FEventHandler.IID, FEventHandler, FEventConnection);
    end;
    if pCtl.IsInvisibleAtRuntime then _prop_Visible := False;
  except
    on E:Exception do begin
      Control := NewLabel(FParent, E.Message);
      _prop_Color := $FFFFFF;
      _prop_Font.Color := $FF;
    end;
  end;
  inherited Init;
end;

function THIUseActiveX.doCallDispatch;
var pdisp:IDispatch; meth:string; dt:PData; i:integer;
    args:array of TVariantArg; hr:HRESULT;
begin
  pdisp := PMyOleCtl(Control).OleObject; meth := ToString(Data);
  dt:=Data.ldata; i:=0;
  while dt<>nil do begin Inc(i); dt:=dt.ldata; end;
  dt:=Data.ldata; SetLength(args,i);
  while dt<>nil do begin
    Dec(i); DataToOle(args[i],dt^);
    dt:=dt.ldata;
  end;
  hr := CallDispatch(pdisp,meth,callType,res,args);
  for i:=0 to Length(args)-1 do VariantClear(OleVariant(args[i]));
  if hr <> S_OK then _hi_OnEvent(_event_onError, SysErrorMessage(hr)); 
  Result := hr=S_OK;
end;

procedure THIUseActiveX._work_doExecute;
begin
  doCallDispatch(Data,DISPATCH_METHOD,nil);
end;

procedure THIUseActiveX._work_doGetProp;
var res:TVariantArg; dt:TData;
begin
  if doCallDispatch(Data,DISPATCH_PROPERTYGET,@res) then begin
    OleToData(dt,res);
    VariantClear(OleVariant(res));
    _hi_OnEvent(_event_onGetProp, dt);
  end;
end;

procedure THIUseActiveX._work_doSetProp;
begin
  doCallDispatch(Data,DISPATCH_PROPERTYPUT,nil);
end;

{ TMyEventHandler implementation }

constructor TMyEventHandler.Create;
var pattr:PTypeAttr;
begin
  FMe := Me; FTypeInfo := EventTypeInfo;
  FTypeInfo.GetTypeAttr(pattr);
  FEventIID := pattr.guid;
  FTypeInfo.ReleaseTypeAttr(pattr);
end;

function TMyEventHandler.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  if GetInterface(IID, Obj) then begin
    Result := S_OK;
    Exit;
  end;
  if IsEqualIID(IID, FEventIID) then begin
    GetInterface(IDispatch, Obj);
    Result := S_OK;
    Exit;
  end;
  Result := E_NOINTERFACE;
end;

function TMyEventHandler._AddRef: Integer;
var pdisp: IDispatch;
begin
  pdisp := PMyOleCtl(FMe.Control).OleObject;
  Result := pdisp._AddRef;
end;

function TMyEventHandler._Release: Integer;
var pdisp: IDispatch;
begin
  pdisp := PMyOleCtl(FMe.Control).OleObject;
  Result := pdisp._Release;
end;

function TMyEventHandler.GetIDsOfNames(const IID: TGUID; Names: Pointer; NameCount,
  LocaleID: Integer; DispIDs: Pointer): HResult;
begin
  Result := DISP_E_UNKNOWNNAME
end;

function TMyEventHandler.GetTypeInfo(Index, LocaleID: Integer; out TypeInfo): HResult;
begin
  Pointer(TypeInfo) := nil;
  Result := E_NOTIMPL;
end;

function TMyEventHandler.GetTypeInfoCount(out Count: Integer): HResult;
begin
  Count := 0;
  Result := S_OK;
end;

function TMyEventHandler.Invoke(DispID: Integer; const IID: TGUID;
  LocaleID: Integer; Flags: Word; var Params; VarResult, ExcepInfo,
  ArgErr: Pointer): HResult;
var p:TDispParams absolute Params; name: PWideChar;
    i:integer; d:PData; dt:TData;
begin
  FTypeInfo.GetDocumentation(DispID,@name,nil,nil,nil);
  dtString(dt,OleStrToString(name));
  SysFreeString(name);
  d := @dt;
  for i:=p.cArgs-1 downto 0 do begin
    new(d.ldata); d := d.ldata;
    OleToData(d^,p.rgvarg[i]);  
  end;
  d := @dt;
  _hi_OnEvent(FMe._event_onEvent, dt);
  FreeData(d);
  Result := S_OK;
end;

end.
