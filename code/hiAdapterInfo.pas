unit HiAdapterInfo;  { Компонент AdapterInfo (компонент для определения параметров сетевых адаптеров) ver 1.40 }

interface

uses Windows,KOL,KOLComObj,ActiveX,Share,Debug;

const STGM_default =STGM_READWRITE + STGM_SHARE_EXCLUSIVE;
      STGM_BASE    =STGM_READ + STGM_SHARE_EXCLUSIVE;

type
  TScriptLanguage = (slVBScript, slJScript);
  
type
  THiAdapterInfo = class(TDebug)
   private
      SystemName   : string;
      Name         : string;
      ServiceName  : string;
      Manufacturer : string;
      AdapterType  : string;
      DeviceID     : string;
      PNPDeviceID  : string;
      MACAddress   : string;
      DNSHostName  : string;
      DNSDomain    : string;
      DHCPEnabled  : string;
      WINSServer   : string;
      DHCPServer   : string;
            
      IdArray,IPArray,MaskArray,GatewayArray,DNSArray,MetricArray : PArray;
      FListId,FListIP,FListMask,FListGateway,FListDNS,FListMetric : PStrList;
      function _GetIP(Var Item:TData; var Val:TData):boolean;
      function _CountIP:integer;    
      function _GetId(Var Item:TData; var Val:TData):boolean;
      function _CountId:integer;
      function _GetMask(Var Item:TData; var Val:TData):boolean;
      function _CountMask:integer;    
      function _GetGateway(Var Item:TData; var Val:TData):boolean;
      function _CountGateway:integer;    
      function _GetDNS(Var Item:TData; var Val:TData):boolean;
      function _CountDNS:integer;    
      function _GetMetric(Var Item:TData; var Val:TData):boolean;
      function _CountMetric:integer; 

   public
      _prop_Computer: string;
      _prop_Query: string; 
      _data_Computer: THI_Event;
      _data_Query: THI_Event; 
      _event_onInfo: THI_Event;
      _event_onErr: THI_Event;
      _data_ID: THI_Event;
      constructor Create;
      destructor Destroy; override;      
      procedure _work_doInfo(var _Data:TData; Index:word);
      procedure _work_doArrayId(var _Data:TData; Index:word);
      procedure _var_SystemName(var _Data:TData; Index:word);
      procedure _var_Name(var _Data:TData; Index:word);
      procedure _var_ServiceName(var _Data:TData; Index:word);
      procedure _var_Manufacturer(var _Data:TData; Index:word);
      procedure _var_AdapterType(var _Data:TData; Index:word);
      procedure _var_DeviceID(var _Data:TData; Index:word);
      procedure _var_PNPDeviceID(var _Data:TData; Index:word);
      procedure _var_MACAddress(var _Data:TData; Index:word);
      procedure _var_IdArray(var _Data:TData; Index:word);
      procedure _var_IPArray(var _Data:TData; Index:word);
      procedure _var_MaskArray(var _Data:TData; Index:word);
      procedure _var_GatewayArray(var _Data:TData; Index:word);
      procedure _var_DNSArray(var _Data:TData; Index:word);
      procedure _var_MetricArray(var _Data:TData; Index:word);
      procedure _var_DNSHostName(var _Data:TData; Index:word);
      procedure _var_DNSDomain(var _Data:TData; Index:word);
      procedure _var_DHCPEnabled(var _Data:TData; Index:word);
      procedure _var_WINSServer(var _Data:TData; Index:word);
      procedure _var_DHCPServer(var _Data:TData; Index:word);

 end;

implementation

function Trim(s:string; d:string = ' '): string;
var   st :integer;
begin
   if Length(s) > 0 then begin
      st := 1;
      while (st <= Length(s))and(s[st] = d[1]) do inc(st);
      delete(s,1,st-1);
      st := Length(s);
      while (st > 0)and(s[st] = d[1]) do dec(st);
      delete(s,st+1,Length(s) - st);
   end;
   Result := s;
end;

const
  NULL_GUID: TGUID = '{00000000-0000-0000-0000-000000000000}';

var
  ScriptCLSIDs: array[TScriptLanguage] of TGUID;

const
  ScriptProgIDs: array[TScriptLanguage] of PWideChar = (
    'VBScript',
    'JScript'
  );

procedure InitCLSIDs;
var
  L: TScriptLanguage;
begin
  for L := Low(TScriptLanguage) to High(TScriptLanguage) do
    if CLSIDFromProgID(ScriptProgIDs[L], ScriptCLSIDs[L]) <> S_OK
      then ScriptCLSIDs[L] := NULL_GUID;
end;

constructor THiAdapterInfo.Create;
begin
   inherited;
   OleInit;
   InitCLSIDs;
   FListID := NewStrList;
   FListIP := NewStrList;
   FListMask := NewStrList;
   FListGateway := NewStrList;
   FListDNS := NewStrList;
   FListMetric := NewStrList;
end;

destructor THiAdapterInfo.Destroy;
begin
   FListId.Free;
   FListIP.Free;
   FListMask.Free;
   FListGateway.Free;
   FListDNS.Free;
   FListMetric.Free;   
   if IdArray <> nil then Dispose(IdArray);
   if IPArray <> nil then Dispose(IPArray);
   if MaskArray <> nil then Dispose(MaskArray);
   if GatewayArray <> nil then Dispose(GatewayArray);
   if DNSArray <> nil then Dispose(DNSArray);
   if MetricArray <> nil then Dispose(MetricArray);
   OleUnInit;
   inherited;
end;

function GetObject(const name:string; accs:dword=STGM_default): OLEVariant;
var   err:HResult;
      bo:tBINDOPTS;
      res:IDispatch;
      nm:widestring;
begin
   nm := name;
   fillchar(bo,sizeof(bo),0);
   with bo do begin cbStruct := sizeof(bo);
      grfFlags := BIND_MAYBOTHERUSER;
      grfMode := accs;
   end;
   err := CoGetObject(  @nm[1] , @bo , IDispatch , @res );
   OleCheck(err);
   Result := res;
end;

procedure THiAdapterInfo._work_doArrayId;
var   objService : Variant;
      objNetConfig : Variant;
      colNetConfig : Variant;
      oEnum : IEnumvariant;
      iValue : PLongint;
      sComputer : string;
begin
   sComputer := ReadString(_Data,_data_Computer,_prop_Computer);
   if sComputer = '' then sComputer := '.'; 
   FListId.Clear;
   objService := GetObject('winmgmts:{impersonationLevel=impersonate}!\\' + sComputer + '\root\CIMV2');
   if VarIsEmpty(objService) then begin
      _hi_CreateEvent(_Data, @_event_onErr);
      exit; 
   end;
   colNetConfig := objService.ExecQuery('SELECT DeviceID FROM Win32_NetworkAdapter');   
   oEnum := IUnknown(colNetConfig._NewEnum) as IEnumVariant;
   iValue := nil;
   while oEnum.Next(1,objNetConfig,iValue) = 0 do begin
      FlistId.Add(Trim(VarToStr(objNetConfig.DeviceID)));
      objNetConfig := Unassigned;
   end;
end;

procedure THiAdapterInfo._work_doInfo;
var   objService : Variant;
      objNetConfig : Variant;
      colNetConfig : Variant;
      colLiveNetAdp  : Variant;
      objLiveNetAdp  : Variant;      
      colLiveNetAdp2  : Variant;
      objLiveNetAdp2  : Variant;      
      oEnum : IEnumvariant;
      oEnum2 : IEnumvariant;
      oEnum3 : IEnumvariant;
      iValue : PLongint;
      iValue2 : PLongint;
      iValue3 : PLongint;
      FIndex, Ind : string;
      i : integer;
      sDevice : string;
      sComputer : string;
      sQuery : string;
      dQuery,dQ : string;
      dt: TData;
begin
   dtNull(dt);
   sComputer := ReadString(dt,_data_Computer,_prop_Computer);
   if sComputer = '' then sComputer := '.'; 
   sQuery := Trim(ReadString(dt,_data_Query,_prop_Query),',');
   sDevice := ReadString(_Data, _data_Id,'');
   if sQuery = '' then begin
      sQuery := '*';
      dQuery := sQuery
   end else begin
      sQuery := sQuery + ',Index'; 
      dQuery := sQuery;
      Replace(dQuery,'DNSHostName,','');
      Replace(dQuery,'DNSDomain,','');
      Replace(dQuery,'WINSPrimaryServer,','');   
      Replace(dQuery,'DHCPServer,','');
      Replace(dQuery,'DHCPEnabled,','');
      Replace(dQuery,'IPAddress,','');
      Replace(dQuery,'IPSubnet,','');
      Replace(dQuery,'DefaultIPGateway,','');
      Replace(dQuery,'DNSServerSearchOrder,','');
      Replace(dQuery,'GatewayCostMetric,','');
      dQ := dQuery;
      Replace(dQ, 'Index','');
      Replace(sQuery,dQ,'');
   end;

   FListIP.Clear;
   FListMask.Clear;
   FListGateway.Clear;
   FListDNS.Clear;
   FListMetric.Clear;
   DNSHostName := '';
   DNSDomain   := '';
   DHCPEnabled := '';
   WINSServer  := '';
   DHCPServer  := '';
   if length(sDevice) > 0 then sDevice := ' Where Index = ' +  sDevice;
   objService := GetObject('winmgmts:{impersonationLevel=impersonate}!\\' + sComputer + '\root\CIMV2');
   if VarIsEmpty(objService) then begin
      _hi_CreateEvent(_Data, @_event_onErr);
      exit; 
   end;
   colNetConfig := objService.ExecQuery('Select ' + sQuery + ' from Win32_NetworkAdapterConfiguration Where IPEnabled = True');
   oEnum := IUnknown(colNetConfig._NewEnum) as IEnumVariant;
   colLiveNetAdp  := objService.ExecQuery('Select ' + dQuery + ' from Win32_NetworkAdapter' + sDevice);
   oEnum2 := IUnknown(colLiveNetAdp._NewEnum) as IEnumVariant; 
   iValue2 := nil;
   while oEnum2.Next(1,objLiveNetAdp,iValue2) = 0 do begin
      SystemName := Trim(VarToStr(objLiveNetAdp.SystemName));
      Name := Trim(VarToStr(objLiveNetAdp.Name));
      ServiceName := Trim(VarToStr(objLiveNetAdp.ServiceName));
      Manufacturer := Trim(VarToStr(objLiveNetAdp.Manufacturer));
      AdapterType := Trim(VarToStr(objLiveNetAdp.AdapterType));
      DeviceID := Trim(VarToStr(objLiveNetAdp.DeviceID));
      PNPDeviceID := Trim(VarToStr(objLiveNetAdp.PNPDeviceID));
      MACAddress := Trim(VarToStr(objLiveNetAdp.MACAddress));
      FIndex := Trim(VarToStr(objLiveNetAdp.Index));
      iValue := nil;
      while oEnum.Next(1,objNetConfig,iValue) = 0 do begin
         Ind:= Trim(VarToStr(objNetConfig.Index));
         if FIndex = Ind then begin
            colLiveNetAdp2  := objService.ExecQuery('Select AdapterType from Win32_NetworkAdapter Where Index = ' +  Ind);
            oEnum3 := IUnknown(colLiveNetAdp2._NewEnum) as IEnumVariant; 
            iValue3 := nil;
            while oEnum3.Next(1,objLiveNetAdp2,iValue3) = 0 do begin
               if Trim(VarToStr(objLiveNetAdp2.AdapterType)) <> '' then begin 
                  DNSHostName  := Trim(VarToStr(objNetConfig.DNSHostName));
                  DNSDomain    := Trim(VarToStr(objNetConfig.DNSDomain));
                  if (Trim(VarToStr(objNetConfig.DHCPEnabled)) <> '') then
                     if abs(str2int(Trim(VarToStr(objNetConfig.DHCPEnabled)))) = 1 then 
                        DHCPEnabled  := '1'
                     else
                        DHCPEnabled  := '0'; 
                  WINSServer   := Trim(VarToStr(objNetConfig.WINSPrimaryServer));
                  DHCPServer   := Trim(VarToStr(objNetConfig.DHCPServer));
                  if VarIsArray(objNetConfig.IPAddress) then 
                     for i:= 0 to VarArrayHighBound(objNetConfig.IPAddress, 1) do   
                        FListIP.Add(Trim(VarToStr(objNetConfig.IPAddress[i])));
                  if VarIsArray(objNetConfig.IPSubnet) then 
                     for i:= 0 to VarArrayHighBound(objNetConfig.IPSubnet, 1) do   
                        FListMask.Add(Trim(VarToStr(objNetConfig.IPSubnet[i])));
                  if VarIsArray(objNetConfig.DefaultIPGateway) then
                     for i:= 0 to VarArrayHighBound(objNetConfig.DefaultIPGateway, 1) do   
                        FListGateway.Add(Trim(VarToStr(objNetConfig.DefaultIPGateway[i])));
                  if VarIsArray(objNetConfig.DNSServerSearchOrder) then
                     for i:= 0 to VarArrayHighBound(objNetConfig.DNSServerSearchOrder, 1) do   
                        FListDNS.Add(objNetConfig.DNSServerSearchOrder[i]);                  
                  if VarIsArray(objNetConfig.GatewayCostMetric) then
                     for i:= 0 to VarArrayHighBound(objNetConfig.GatewayCostMetric, 1) do   
                        FListMetric.Add(objNetConfig.GatewayCostMetric[i]);
               end;    
               objLiveNetAdp2 := Unassigned;
            end;   
         end;
         objNetConfig := Unassigned;
      end;
      objLiveNetAdp := Unassigned;
      _hi_onEvent(_event_onInfo);
   end;
end;

procedure THiAdapterInfo._var_SystemName;begin dtString(_Data,SystemName);end;
procedure THiAdapterInfo._var_Name;begin dtString(_Data,Name);end;
procedure THiAdapterInfo._var_ServiceName;begin dtString(_Data,ServiceName);end;
procedure THiAdapterInfo._var_Manufacturer;begin dtString(_Data,Manufacturer);end;
procedure THiAdapterInfo._var_AdapterType;begin dtString(_Data,AdapterType);end;
procedure THiAdapterInfo._var_DeviceID;begin dtString(_Data,DeviceID);end;
procedure THiAdapterInfo._var_PNPDeviceID;begin dtString(_Data,PNPDeviceID);end;
procedure THiAdapterInfo._var_MACAddress;begin dtString(_Data,MACAddress);end;
procedure THiAdapterInfo._var_DNSHostName;begin dtString(_Data,DNSHostName);end;
procedure THiAdapterInfo._var_DNSDomain;begin dtString(_Data,DNSDomain);end;
procedure THiAdapterInfo._var_DHCPEnabled;begin dtString(_Data,DHCPEnabled);end;
procedure THiAdapterInfo._var_WINSServer;begin dtString(_Data,WINSServer);end;
procedure THiAdapterInfo._var_DHCPServer;begin dtString(_Data,DHCPServer);end;

procedure THiAdapterInfo._var_IdArray;
begin
   if IdArray = nil then
      IdArray:= CreateArray(nil, _GetId, _CountId, nil);
   dtArray(_Data,IdArray);
end;

function THiAdapterInfo._GetId;
var   ind:integer;
begin
   ind := ToIntIndex(Item);
   if(ind >= 0)and(ind < FListId.Count)then begin
      Result:= true;
      dtString(Val,FListId.Items[ind]);
   end
   else Result:= false;
end;

function THiAdapterInfo._CountId;begin Result:= FListId.Count;end;

procedure THiAdapterInfo._var_IPArray;
begin
   if IPArray = nil then
      IPArray:= CreateArray(nil, _GetIP, _CountIP, nil);
   dtArray(_Data,IPArray);
end;

function THiAdapterInfo._GetIP;
var   ind:integer;
begin
   ind := ToIntIndex(Item);
   if(ind >= 0)and(ind < FListIP.Count)then begin
      Result:= true;
      dtString(Val,FListIP.Items[ind]);
   end
   else Result:= false;
end;

function THiAdapterInfo._CountIP;begin Result:= FListIP.Count;end;

procedure THiAdapterInfo._var_MaskArray;
begin
   if MaskArray = nil then
      MaskArray:= CreateArray(nil, _GetMask, _CountMask, nil);
   dtArray(_Data,MaskArray);
end;

function THiAdapterInfo._GetMask;
var   ind:integer;
begin
   ind := ToIntIndex(Item);
   if(ind >= 0)and(ind < FListMask.Count)then begin
      Result:= true;
      dtString(Val,FListMask.Items[ind]);
   end else Result:= false;
end;

function THiAdapterInfo._CountMask;begin Result:= FListMask.Count;end;

procedure THiAdapterInfo._var_GatewayArray;
begin
   if GatewayArray = nil then
      GatewayArray:= CreateArray(nil, _GetGateway, _CountGateway, nil);
   dtArray(_Data,GatewayArray);
end;

function THiAdapterInfo._GetGateway;
var   ind:integer;
begin
   ind := ToIntIndex(Item);
   if(ind >= 0)and(ind < FListGateway.Count)then begin
      Result:= true;
      dtString(Val,FListGateway.Items[ind]);
   end else Result:= false;
end;

function THiAdapterInfo._CountGateway;begin Result:= FListGateway.Count;end;

procedure THiAdapterInfo._var_DNSArray;
begin
   if DNSArray = nil then
      DNSArray:= CreateArray(nil, _GetDNS, _CountDNS, nil);
   dtArray(_Data,DNSArray);
end;

function THiAdapterInfo._GetDNS;
var   ind:integer;
begin
   ind := ToIntIndex(Item);
   if(ind >= 0)and(ind < FListDNS.Count)then begin
      Result:= true;
      dtString(Val,FListDNS.Items[ind]);
   end else Result:= false;
end;

function THiAdapterInfo._CountDNS;begin Result:= FListDNS.Count;end;

procedure THiAdapterInfo._var_MetricArray;
begin
   if MetricArray = nil then
      MetricArray:= CreateArray(nil, _GetMetric, _CountMetric, nil);
   dtArray(_Data,MetricArray);
end;

function THiAdapterInfo._GetMetric;
var   ind:integer;
begin
   ind := ToIntIndex(Item);
   if(ind >= 0)and(ind < FListMetric.Count)then begin
      Result:= true;
      dtString(Val,FListMetric.Items[ind]);
   end else Result:= false;
end;

function THiAdapterInfo._CountMetric;begin Result:= FListMetric.Count;end;

end.