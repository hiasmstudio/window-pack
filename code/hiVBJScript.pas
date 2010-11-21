unit hiVBJScript;

interface

uses Kol,Share,Debug,Windows,ActiveX,activescp,ActiveKOL,KOLComObj,nmitems;

type
  TScriptLanguage = (slVBScript, slJScript);

  THIArraySink = class(TInterfacedObject, IDispatch)
  private
    FArray: PArray;
  protected
    { IDispatch }
    function GetTypeInfoCount(out Count: Integer): HResult; stdcall;
    function GetTypeInfo(Index, LocaleID: Integer; out TypeInfo): HResult; stdcall;
    function GetIDsOfNames(const IID: TGUID; Names: Pointer;  NameCount, LocaleID: Integer; DispIDs: Pointer): HResult; stdcall;
    function Invoke(DispID: Integer; const IID: TGUID; LocaleID: Integer; Flags: Word; var Params; VarResult, ExcepInfo, ArgErr: Pointer): HResult; stdcall;
  public
    constructor Create(arr: PArray);
  end;

  PScriptArraySink = ^TScriptArraySink;
  TScriptArraySink = object
  private
    FArray:TVariantArg;
    FXArray:TXArray;
  protected
    procedure _Set(var Item:TData; var Val:TData);
    function _Get(Var Item:TData; var Val:TData):boolean;
    function _Count:integer;
    procedure _Add(var Val:TData);
  public
    constructor Create(var arr:TVariantArg);
    procedure SetArray(var arr:TVariantArg);
    function GetArray:PArray;
  end;

  TMe = class;
  THIVBJScript = class(TOleCtlIntf,IActiveScriptSite, IActiveScriptSiteWindow)
  private
    Me:TMe;
    Err:PStrList;
    FECount,FDCount:PStrList;
    WP,VP:PStrList;
    FVArray: array of PScriptArraySink;

    procedure SetEvent(const value:string);
    procedure SetData(const value:string);
    procedure SetWP(const value:string);
    procedure SetVP(const value:string);
    procedure SetScript(const value:string);
    procedure _DoWork(const data,ind:TData);
    function _GetVar(const data,ind:TData; index:integer):Tdata;

    function ReadPointIndex(List:PStrList; Data:PData):integer;

    procedure _OnEvent(const Index:TData; var Data:TData);
    procedure _direct_OnEvent(const Index:integer; var Data:TData);
    function _GetData(const Index:TData):TData;
    function _direct_GetData(const Index:integer):TData;

    function GetLCID(out plcid: LCID): HResult; stdcall;
    function GetItemInfo(pstrName: LPCOLESTR; dwReturnMask: DWORD;
      out ppiunkItem: IUnknown; out ppti: ITypeInfo): HResult; stdcall;
    function GetDocVersionString(out pbstrVersion: WideString): HResult; stdcall;
    function OnScriptTerminate(var pvarResult: OleVariant;
      var pexcepinfo: EXCEPINFO): HResult; stdcall;
    function OnStateChange(ssScriptState: SCRIPTSTATE): HResult; stdcall;
    function OnScriptError(const FScriptError: IActiveScriptError): HResult; stdcall;
    function OnEnterScript: HResult; stdcall;
    function OnLeaveScript: HResult; stdcall;
  private
    FEngine: IActiveScript;
    FParser: IActiveScriptParse;
    FNamedItems: TNamedItemList;

    procedure CreateScriptEngine(Language: TScriptLanguage);
    procedure CloseScriptEngine;
    procedure AddNamedItem(const Name: string; Flags: DWORD; Item: TInterfacedObject);
  protected
    {IActiveSriptSiteWindow}
    function GetWindow(out phwnd: HWND): HResult; stdcall;
    function EnableModeless(fEnable: BOOL): HResult; stdcall;
  public
    _event_EventPoints:array of THI_Event;
    _data_DataPoints:array of THI_Event;

    _prop_UseName:boolean;
    _prop_Language:byte;

    constructor Create;
    destructor Destroy; override;
    procedure GetScriptDispatch(var pdisp:IDispatch);

    procedure _work_WorkPoints(var Data:TData; Index:word);
    procedure _var_VarPoints(var Data:TData; Index:word);

    property _prop_EventPoints:string write SetEvent;
    property _prop_DataPoints:string write SetData;
    property _prop_WorkPoints:string write SetWP;
    property _prop_VarPoints:string write SetVP;

    property _prop_Script:string write SetScript;
  end;

  TMe = class(TInterfacedObject, IDispatch)
  private
    FScript:THIVBJScript;
    function GetEventTypeInfo(const pCLSID:TGUID; pdisp: IDispatch): ITypeInfo;
  protected
    function GetTypeInfoCount(out Count: Integer): HResult; stdcall;
    function GetTypeInfo(Index, LocaleID: Integer; out TypeInfo): HResult; stdcall;
    function GetIDsOfNames(const IID: TGUID; Names: Pointer;  NameCount, LocaleID: Integer; DispIDs: Pointer): HResult; stdcall;
    function Invoke(DispID: Integer; const IID: TGUID; LocaleID: Integer; Flags: Word; var Params; VarResult, ExcepInfo, ArgErr: Pointer): HResult; stdcall;
  public
    constructor Create(Parent:THIVBJScript);
    destructor Destroy; override;
  end;

  TMyEventHandler = class(TObject, IUnknown, IDispatch)
  private
    FMe: IDispatch;
    FTypeInfo: ITypeInfo;
    FEventIID: TGUID;
    FPrefix: WideString;
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
    constructor Create(Me: IDispatch; EventTypeInfo: ITypeInfo; Prefix:WideString);
    property IID: TGUID read FEventIID;
  end;

implementation

const
  NULL_GUID: TGUID = '{00000000-0000-0000-0000-000000000000}';
  IID_IDispatch: TGUID = '{00020400-0000-0000-C000-000000000046}';

var
  ScriptCLSIDs: array[TScriptLanguage] of TGUID;

const
  ScriptProgIDs: array[TScriptLanguage] of PWideChar = (
    'VBScript',
    'JScript'
  );

procedure OleToData(var dt:TData; v:TVariantArg);
var v1:OleVariant absolute v; s:string;
begin
   case v.vt of
    VT_I2: dt := _DoData(THiInt(v.iVal));
    VT_I4: dt := _DoData(THiInt(v.lVal));
    VT_R4: dt := _DoData(v.fltVal);
    VT_R8: dt := _DoData(v.dblVal);
    else begin
      if v.vt<>VT_BSTR then VariantChangeType(v1,v1,0,VT_BSTR);
      OleStrToStrVar(v.bstrVal,s);
      dt := _DoData(s);
    end;
   end;
end;

procedure DataToOle(var v:TVariantArg; const dt:TData);
var pdisp:IDispatch;
begin
  case dt.data_type of
   data_int: begin v.vt := VT_I4; v.lVal := dt.idata; end;
   data_real:begin v.vt := VT_R8; v.dblVal := dt.rdata; end;
   data_str: begin v.vt := VT_BSTR; v.bstrVal := StringToOleStr(dt.sdata); end;
   data_array: begin
     pdisp := THIArraySink.Create(PArray(dt.idata)) as IDispatch;
     v.vt := VT_DISPATCH;
     v.dispVal := pointer(pdisp); pdisp._AddRef();
   end;
   else begin v.vt := VT_BSTR; v.bstrVal := StringToOleStr('NULL'); end;
  end;
end;

function CallDispatch(const pdisp:IDispatch; wsName:WideString; callType:word; res:PVariantArg; const args:array of TVariantArg):boolean;
const dispid_put:integer = DISPID_PROPERTYPUT;
var dispid:integer; dparam:TDispParams;
begin
  Result := False;
  if pdisp.GetIDsOfNames(NULL_GUID,@wsName,1,0,@dispid) = S_OK then begin
    dparam.rgvarg := @args[0];
    dparam.cArgs := length(args);
    if callType=DISPATCH_PROPERTYPUT then begin
      dparam.rgdispidNamedArgs := @dispid_put;
      dparam.cNamedArgs := 1;
    end else
      dparam.cNamedArgs := 0;
    Result := pdisp.Invoke(dispid,NULL_GUID,0,callType,dparam,res,nil,nil)=S_OK;
  end;
end;

{ THIArraySink implementation }

constructor THIArraySink.Create;
begin
  inherited Create;
  FArray := arr;
end;

function THIArraySink.GetTypeInfoCount(out Count: Integer): HResult;
begin
  Count := 0;
  Result := S_OK;
end;

function THIArraySink.GetTypeInfo(Index, LocaleID: Integer; out TypeInfo): HResult;
begin
  Pointer(TypeInfo) := nil;
  Result := E_NOTIMPL;
end;

function THIArraySink.GetIDsOfNames(const IID: TGUID; Names: Pointer; NameCount,
  LocaleID: Integer; DispIDs: Pointer): HResult;
const
    cNames: array [0..3] of string = ('count','get','set','add');
type
    TDispIDsArray = array[1..1] of TDISPID;
    TPOleStrArray = array [1..1] of POleStr;
var IDs:^TDispIDsArray absolute DispIDs; i,j:integer;
    sNames:^TPOleStrArray absolute Names; Name:string;
begin
  for i:=1 to NameCount do begin
    IDs[i] := DISPID_UNKNOWN;
    OleStrToStrVar(sNames[i], Name);
    Name := LowerCase(Name);
    for j:=0 to 3 do if Name=cNames[j] then
      begin IDs[i] := j; break; end;
  end;
  Result := S_OK;
end;

function THIArraySink.Invoke(DispID: Integer; const IID: TGUID;
  LocaleID: Integer; Flags: Word; var Params; VarResult, ExcepInfo,
  ArgErr: Pointer): HResult;
const argc:array [0..3] of integer = (0,1,2,1);
var p:TDispParams absolute Params; a1,a2:TData;
begin
  if (DispID<0) or (DispID>3) then Result := DISP_E_MEMBERNOTFOUND else
  if p.cArgs <> argc[DispID] then Result := DISP_E_BADPARAMCOUNT else begin
    if p.cArgs>=1 then OleToData(a1,p.rgvarg[0]);
    if p.cArgs>=2 then OleToData(a2,p.rgvarg[1]);
    Result := S_OK;
    case DispID of
     0: DataToOle(TVariantArg(VarResult^), _DoData(FArray._Count));
     1: begin
       FArray._Get(a1,a2);
       DataToOle(TVariantArg(VarResult^), a2);
     end;
     2: FArray._Set(a2,a1);
     3: FArray._Add(a1);
    end;
  end;
end;

{ TScriptArraySink }

procedure TScriptArraySink._Set(var Item:TData; var Val:TData);
var el:TVariantArg;
begin
  if FArray.vt = VT_DISPATCH then begin
    DataToOle(el,Val);
    CallDispatch(IDispatch(FArray.dispVal), ToString(Item), DISPATCH_PROPERTYPUT, nil, [el]);
    VariantClear(OleVariant(el));
  end;
end;

function TScriptArraySink._Get(Var Item:TData; var Val:TData):boolean;
var el:TVariantArg; idx:integer;
begin
  Result := False;
  if (FArray.vt and VT_ARRAY)<>0 then begin
    idx := ToInteger(Item);
    Result := SafeArrayGetElement(FArray.parray,idx,el)=S_OK;
  end;
  if FArray.vt = VT_DISPATCH then
    Result := CallDispatch(IDispatch(FArray.dispVal), ToString(Item), DISPATCH_PROPERTYGET, @el, []);
  if Result then begin
    OleToData(Val,el);
    VariantClear(OleVariant(el));
  end;  
end;

function TScriptArraySink._Count:integer;
var uBound:integer; el:TVariantArg; dt:TData;
begin
  Result := 0;
  if (FArray.vt and VT_ARRAY)<>0 then begin
    SafeArrayGetUBound(FArray.parray,1,uBound);
    Result := uBound+1;
  end;
  if FArray.vt = VT_DISPATCH then begin
    if CallDispatch(IDispatch(FArray.dispVal), 'length', DISPATCH_PROPERTYGET, @el, []) then begin
      OleToData(dt,el);
      VariantClear(OleVariant(el));
      Result := ToInteger(dt);
    end;
  end;
end;

procedure TScriptArraySink._Add(var Val:TData);
var el:TVariantArg;
begin
  if FArray.vt = VT_DISPATCH then begin
    DataToOle(el,Val);
    CallDispatch(IDispatch(FArray.dispVal), 'push', DISPATCH_METHOD, nil, [el]);
    VariantClear(OleVariant(el));
  end;
end;

constructor TScriptArraySink.Create(var arr:TVariantArg);
begin
  FXArray._Set := _Set;
  FXArray._Get := _Get;
  FXArray._Count := _Count;
  FXArray._Add := _Add;
  FArray := arr;
end;

procedure TScriptArraySink.SetArray(var arr:TVariantArg);
begin
  VariantClear(OleVariant(FArray));
  FArray := arr;
end;

function TScriptArraySink.GetArray:PArray;
begin
  Result := @FXArray;
end;

//_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+

procedure InitCLSIDs;
var
  L: TScriptLanguage;
begin
  for L := Low(TScriptLanguage) to High(TScriptLanguage) do
    if CLSIDFromProgID(ScriptProgIDs[L], ScriptCLSIDs[L]) <> S_OK
      then ScriptCLSIDs[L] := NULL_GUID;
end;

constructor THIVBJScript.Create;
begin
  inherited;
  OleInit;
  Err := NewStrList;

  InitCLSIDs;
  FNamedItems := TNamedItemList.Create;
  CreateScriptEngine(slVBScript);

end;

destructor THIVBJScript.Destroy;
begin
   CloseScriptEngine;
   Err.Free;
   FNamedItems.Free;
   FECount.Free;
   FDCount.Free;
   WP.Free;
   VP.Free;
   inherited;
end;

function THIVBJScript.ReadPointIndex;
var k:integer;
begin
   Result := -1;
   if Data.Data_type = data_str then
    for k := 0 to FECount.Count-1 do
     if StriComp(PChar(List.Items[k]),PChar(Data.sdata)) = 0 then
      begin
       Result := k;
       break;
      end;

   if Result = -1 then
     Result := ToIntIndex(Data^);
end;

procedure THIVBJScript._OnEvent;
var Ind:integer;
begin
   Ind := ReadPointIndex(FECount,@Index);
   if(ind >= 0)and(Ind < FECount.Count)then
    _hi_OnEvent(_event_EventPoints[Ind],Data);
end;

procedure THIVBJScript._direct_OnEvent;
begin
   _hi_OnEvent(_event_EventPoints[Index],Data);
end;

function THIVBJScript._GetData;
var Ind:integer;
begin
   Ind := ReadPointIndex(FDCount,@Index);
   if(ind >= 0)and(Ind < FDCount.Count)then
    _ReadData(Result,_data_DataPoints[Ind]);
end;

function THIVBJScript._direct_GetData;
begin
   _ReadData(Result,_data_DataPoints[Index]);
end;

//_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+

procedure THIVBJScript.SetEvent;
begin
   FECount := NewStrList;
   FECount.text := LowerCase(Value);
   SetLength(_event_EventPoints,FECount.Count);
end;

procedure THIVBJScript.SetData;
begin
   FDCount := NewStrList;
   FDCount.text := LowerCase(Value);
   SetLength(_data_DataPoints,FDCount.Count);
end;

procedure THIVBJScript.SetWP;
begin
   WP := NewStrList;
   WP.Text := Value;
end;

procedure THIVBJScript.SetVP;
begin
   VP := NewStrList;
   VP.Text := Value;
   SetLength(FVArray, VP.Count);
end;

procedure THIVBJScript._work_WorkPoints(var Data:TData; Index:word);
var Ind:TData;
begin
   if StrIComp(PChar(WP.Items[Index]),'##SetScript') = 0 then
    begin
      SetScript( ToString(Data) );
    end
   else
    begin
     if _prop_UseName then
      begin
       Ind.Data_type := data_str;
       Ind.sdata := WP.Items[Index];
      end
     else
      begin
       Ind.Data_type := data_int;
       Ind.idata := Index;
      end;
     _DoWork(Data,ind);
    end;
end;

procedure THIVBJScript._var_VarPoints(var Data:TData; Index:word);
var Ind:TData;
begin
   if StrIComp(PChar(VP.Items[Index]),'##Errors') = 0 then
    begin
      Data.Data_type := data_str;
      Data.sdata := Err.Text;
    end
   else
    begin
     if _prop_UseName then
      begin
       Ind.Data_type := data_str;
       Ind.sdata := VP.Items[Index];
      end
     else
      begin
       Ind.Data_type := data_int;
       Ind.idata := Index;
      end;
     Data := _GetVar(Data,Ind,Index);
    end;
end;

procedure THIVBJScript.SetScript;
var
  Code: WideString;
  Result: OleVariant;
  ExcepInfo: TEXCEPINFO;
begin
  CreateScriptEngine(TScriptLanguage(_prop_Language));
  Code := Value;
  Me := TMe.Create(Self);
  AddNamedItem('sys', SCRIPTITEM_ISVISIBLE, Me);
  FParser.ParseScriptText(PWideChar(Code), nil, nil, nil, 0, 0, 0, Result, ExcepInfo);
end;

procedure THIVBJScript._DoWork;
var Disp:IDispatch; dt,idx:TVariantArg;
begin
  if FEngine = nil then Exit;
  FEngine.GetScriptDispatch(nil, Disp);
  DataToOle(dt, Data); 
  DataToOle(idx, Ind);
  CallDispatch(Disp, 'doWork', DISPATCH_METHOD, nil, [idx,dt]);
  VariantClear(OleVariant(dt));
  VariantClear(OleVariant(idx));
end;

function THIVBJScript._GetVar;
var Disp:IDispatch; res,dt,idx:TVariantArg;
begin
  if FEngine = nil then Exit;
  FEngine.GetScriptDispatch(nil, Disp);
  DataToOle(dt, Data); 
  DataToOle(idx, Ind);
  CallDispatch(Disp, 'GetVar', DISPATCH_METHOD, @res, [idx,dt]);
  VariantClear(OleVariant(dt));
  VariantClear(OleVariant(idx));
  if ((res.vt and VT_ARRAY)<>0) or (res.vt=VT_DISPATCH) then begin
    if Assigned(FVArray[Index]) then FVArray[Index].SetArray(res)
      else new(FVArray[Index], Create(res));
    Result.data_type := data_array;
    Result.idata := integer(FVArray[Index].GetArray);
  end else begin
    OleToData(Result, res);
    VariantClear(OleVariant(res));
  end;  
end;

procedure THIVBJScript.GetScriptDispatch;
begin
  FEngine.GetScriptDispatch(nil, pdisp);
end;

//*********************************************************
//              OLE
//*********************************************************

// IActiveScriptSite implementation
function THIVBJScript.GetDocVersionString(out pbstrVersion: WideString): HResult;
begin // _debug('doc');
  Result := E_NOTIMPL;
end;

function THIVBJScript.GetItemInfo(pstrName: LPCOLESTR; dwReturnMask: DWORD;
  out ppiunkItem: IUnknown; out ppti: ITypeInfo): HResult;
begin
  if @ppiunkItem <> nil then Pointer(ppiunkItem) := nil;
  if @ppti <> nil then Pointer(ppti) := nil;
  if (dwReturnMask and SCRIPTINFO_IUNKNOWN) <> 0 then
    ppiunkItem := FNamedItems.GetItemIUnknown(pstrName);
  Result := S_OK;
end;

function THIVBJScript.GetLCID(out plcid: LCID): HResult;
begin
  plcid := GetSystemDefaultLCID;
  Result := S_OK;
end;

function THIVBJScript.OnEnterScript: HResult;
begin
  Result := S_OK;
end;

function THIVBJScript.OnLeaveScript: HResult;
begin
  Result := S_OK;
end;

function THIVBJScript.OnScriptError;
var
  ei: EXCEPINFO;
  //Context: DWORD;
  //Line: UINT;
  //Pos: integer;
  //SourceLineW: WideString;
  //SourceLine: string;
begin
  Result := S_OK;
  if FScriptError = nil then exit;
  FScriptError.GetExceptionInfo(ei);
  if @ei.pfnDeferredFillIn <> nil then ei.pfnDeferredFillIn(@ei);
  //FScriptError.GetSourcePosition(Context, Line, Pos);
  //FScriptError.GetSourceLineText(SourceLineW);
  //SourceLine := SourceLineW;

  MessageBox(ReadHandle,PChar(string(ei.bstrDescription)),PChar(string(ei.bstrSource)),MB_OK);
  //DescriptionLabel.Caption := ei.bstrDescription;
  //Caption := ei.bstrSource;

  //DetailStatic.Caption := Format('Строка: %d'#13#10'Позиция: %d'#13#10'%s',
  //   [Line+1, Pos+1, SourceLine]);
  //FScriptError := nil;
  //MessageBeep(MB_ICONHAND);
end;

function THIVBJScript.OnScriptTerminate(var pvarResult: OleVariant;
  var pexcepinfo: EXCEPINFO): HResult;
begin
  Result := S_OK;
end;

function THIVBJScript.OnStateChange(ssScriptState: SCRIPTSTATE): HResult;
begin
  Result := S_OK;
end;

// IActiveScriptSiteWindow implementation
function THIVBJScript.EnableModeless(fEnable: BOOL): HResult;
begin
  Result := S_OK;
end;

function THIVBJScript.GetWindow(out phwnd: HWND): HResult;
begin
  phwnd := readhandle;
  Result := S_OK;
end;

procedure THIVBJScript.CreateScriptEngine(Language: TScriptLanguage);
begin
  CloseScriptEngine;
  FEngine := CreateComObject(ScriptCLSIDs[Language]) as IActiveScript;
  FParser := FEngine as IActiveScriptParse;
  FEngine.SetScriptSite(Self);
  FParser.InitNew;
end;

procedure THIVBJScript.CloseScriptEngine;
begin
  FParser := nil;
  if FEngine <> nil then FEngine.Close;
  FEngine := nil;
end;

procedure THIVBJScript.AddNamedItem(const Name: string; Flags: DWORD; Item: TInterfacedObject);
var
  NameW: WideString;
begin
  FNamedItems.AddItem(Name, Item);
  NameW := Name;
  FEngine.AddNamedItem(PWideChar(NameW), Flags);
end;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&& ME &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

const
  DISPID_EVENT = 1;
  DISPID_GETDATA = 2;
  DISPID_CREATEOBJECT = 3;

constructor TMe.Create;
begin
  inherited Create;
  FScript := Parent;
end;

destructor TMe.Destroy; 
begin
   inherited;
end;

function TMe.GetIDsOfNames(const IID: TGUID; Names: Pointer; NameCount,
  LocaleID: Integer; DispIDs: Pointer): HResult;
type
  TDispIDsArray = array[0..0] of TDISPID;
  PDispIDsArray = ^TDispIDsArray;
  TNamesArray = array[0..0] of PWideChar;
  PNamesArray = ^TNamesArray;
var
  IDs: PDispIDsArray absolute DispIDs;
  NMs: PNamesArray absolute Names;
  i,j: integer; Name: string;
begin
  if NameCount < 1 then Result := E_INVALIDARG else Result := S_OK;
  for i := 0 to NameCount - 1 do begin
    IDs[i] := DISPID_UNKNOWN; Name := LowerCase(NMs[i]);
    if Name='createobject' then
      IDs[i] := DISPID_CREATEOBJECT
    else if not FScript._prop_UseName then
      if Name = 'onevent' then IDs[i] := DISPID_EVENT
      else if Name = 'getdata' then IDs[i] := DISPID_GETDATA
      else Result := DISP_E_UNKNOWNNAME
    else begin
      if (FScript.FECount <> nil) then begin
        j := FScript.FECount.IndexOf(Name);
        if j<0 then j := FScript.FECount.IndexOfName(Name);
        if j>=0 then IDs[i] := 1000 + j;
      end;
      if (FScript.FDCount <> nil) then begin
        j := FScript.FDCount.IndexOf(Name);
        if j<0 then j := FScript.FDCount.IndexOfName(Name);
        if j>=0 then IDs[i] := 2000 + j;
      end;
    end;
  end;
end;

function TMe.GetTypeInfo(Index, LocaleID: Integer; out TypeInfo): HResult;
begin
  Pointer(TypeInfo) := nil;
  Result := E_NOTIMPL;
end;

function TMe.GetTypeInfoCount(out Count: Integer): HResult;
begin
  Count := 0;
  Result := S_OK;
end;

function TMe.Invoke(DispID: Integer; const IID: TGUID;
  LocaleID: Integer; Flags: Word; var Params; VarResult, ExcepInfo,
  ArgErr: Pointer): HResult;
var
  P: TDISPPARAMS absolute Params;
  ind,dt:TData; clsid:TGUID; pdisp:pointer; pme:IDispatch;
  tiEvents: ITypeInfo; eh:TMyEventHandler; eConn:integer;
begin
  Result := DISP_E_MEMBERNOTFOUND;
  if (DispID >= 1000)and(Flags = DISPATCH_METHOD) then
   begin
       if p.cArgs <> 1 then
        begin
          Result := DISP_E_BADPARAMCOUNT;
          Exit;
        end;
       OleToData(dt,P.rgvarg[0]);
       FScript._direct_OnEvent( DispID - 1000, dt );
       Result := S_OK;
   end
  else if (DispID >= 2000) then
   begin
     // _debug(Flags);
      if Flags and (DISPATCH_METHOD or DISPATCH_PROPERTYGET) > 0 then
       begin
       if p.cArgs <> 0 then
        begin
          Result := DISP_E_BADPARAMCOUNT;
          Exit;
        end;
       dt := FScript._direct_GetData(DispID - 2000);
       DataToOle(TVariantArg(VarResult^), dt);
      end;
     {else if Flags = DISPATCH_PROPERTYPUT then
      begin
       if p.cArgs <> 1 then
        begin
          Result := DISP_E_BADPARAMCOUNT;
          Exit;
        end;
       OleToData(dt,P.rgvarg[0]);

      end; }
     result := S_OK;
   end
  else
    case DispID of
     DISPID_EVENT:
      if Flags = DISPATCH_METHOD then
      begin
       if p.cArgs <> 2 then
        begin
          Result := DISP_E_BADPARAMCOUNT;
          Exit;
        end;

       OleToData(ind,P.rgvarg[1]);
       OleToData(dt,P.rgvarg[0]);
       FScript._OnEvent(ind,dt);

       Result := S_OK;
      end;
     DISPID_GETDATA:
      if Flags and (DISPATCH_METHOD or DISPATCH_PROPERTYGET) > 0 then
      begin
       if p.cArgs <> 1 then
        begin
          Result := DISP_E_BADPARAMCOUNT;
          Exit;
        end;

       OleToData(ind,P.rgvarg[0]);
       dt := FScript._GetData(ind);
       DataToOle(TVariantArg(VarResult^), dt);

       Result := S_OK;
      end;
     DISPID_CREATEOBJECT:
      if Flags and DISPATCH_METHOD > 0 then
      begin
        if p.cArgs <> 2 then
        begin
          Result := DISP_E_BADPARAMCOUNT;
          Exit;
        end;
        if (P.rgvarg[0].vt<>VT_BSTR) or (P.rgvarg[1].vt<>VT_BSTR) then
        begin
          Result := DISP_E_TYPEMISMATCH;
          Exit;
        end;
        Result := CLSIDFromString(P.rgvarg[1].bstrVal, clsid);
        if Result<>S_OK then Exit;
        Result := CoCreateInstance(clsid,nil,CLSCTX_INPROC_SERVER or CLSCTX_LOCAL_SERVER,IID_IDispatch,pdisp);
        if (Result<>S_OK) or (VarResult=nil) then Exit;
        PVariantArg(VarResult).vt := VT_DISPATCH;
        PVariantArg(VarResult).dispVal := pdisp;
        tiEvents := GetEventTypeInfo(clsid, IDispatch(pdisp));
        if tiEvents<>nil then begin
          FScript.GetScriptDispatch(pme);
          eh := TMyEventHandler.Create(pme, tiEvents, P.rgvarg[0].bstrVal);
          InterfaceConnect(IDispatch(pdisp), eh.IID, eh, eConn);
        end;
      end;
    end;
end;

function TMe.GetEventTypeInfo;
var nti:integer; pti:ITypeInfo;
    plib:ITypeLib; pattr:PTypeAttr; nFlags:integer; hRef:HRefType;
begin
  Result := nil;
  pdisp.GetTypeInfoCount(nti); if nti=0 then exit;
  pdisp.GetTypeInfo(0, LOCALE_SYSTEM_DEFAULT, pti);
  pti.GetContainingTypeLib(plib, nti); pti := nil;
  plib.GetTypeInfoOfGuid(pCLSID, pti);
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

{ TMyEventHandler implementation }

constructor TMyEventHandler.Create;
var pattr:PTypeAttr;
begin
  FMe := Me; FTypeInfo := EventTypeInfo; FPrefix := Prefix;
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
begin
  Result := FMe._AddRef;
end;

function TMyEventHandler._Release: Integer;
begin
  Result := FMe._Release;
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
var name:PWideChar; s:WideString; medispid:TDISPID;
    i:integer; args:array[0..15] of TVariantArg; dparam:TDispParams;
begin
  FTypeInfo.GetDocumentation(DispID,@name,nil,nil,nil);
  s := FPrefix + name;
  SysFreeString(name);
  for i:=0 to TDISPPARAMS(Params).cArgs-1 do begin
    args[i] := TDISPPARAMS(Params).rgvarg[i];
    if args[i].vt=VT_DISPATCH then begin
      args[i].vt := VT_VARIANT or VT_BYREF;
      args[i].pvarVal := @TDISPPARAMS(Params).rgvarg[i];
    end;
  end;
  Result := FMe.GetIDsOfNames(NULL_GUID,@s,1,0,@medispid);
  if Result<>S_OK then begin Result := S_OK; Exit; end;
  dparam.rgvarg := @args[0];
  dparam.cArgs := TDISPPARAMS(Params).cArgs;
  dparam.cNamedArgs := 0;
  Result := FMe.Invoke(medispid,NULL_GUID,0,DISPATCH_METHOD,dparam,nil,nil,nil);
end;

end.
