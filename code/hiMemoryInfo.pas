unit HiMemoryInfo;  { Компонент MemoryInfo (компонент для определения параметров слотов физической памяти) ver 1.00 }

interface

uses Windows,KOL,KOLComObj,ActiveX,Share,Debug;

const STGM_default =STGM_READWRITE + STGM_SHARE_EXCLUSIVE;
      STGM_BASE    =STGM_READ + STGM_SHARE_EXCLUSIVE;

type
  TScriptLanguage = (slVBScript, slJScript);
  
type
  THiMemoryInfo = class(TDebug)
   private
      BankLabel    : string;
      Capacity     : string;
      FormFactor   : string;
      Manufacturer : string; 
      MemoryType   : string;
      Model        : string;
      Name         : string;
      SerialNumber : string;
      Speed        : string; 
      Tag          : string;
      Version      : string;
      DataWidth    : string;
            
      IdArray : PArray;
      FListId : PStrList;
      function _GetId(Var Item:TData; var Val:TData):boolean;
      function _CountId:integer;

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

      procedure _var_BankLabel(var _Data:TData; Index:word);
      procedure _var_Capacity(var _Data:TData; Index:word);
      procedure _var_FormFactor(var _Data:TData; Index:word);
      procedure _var_Manufacturer(var _Data:TData; Index:word);
      procedure _var_MemoryType(var _Data:TData; Index:word);
      procedure _var_Name(var _Data:TData; Index:word);
      procedure _var_SerialNumber(var _Data:TData; Index:word);
      procedure _var_Speed(var _Data:TData; Index:word);
      procedure _var_Tag(var _Data:TData; Index:word);
      procedure _var_Model(var _Data:TData; Index:word);
      procedure _var_Version(var _Data:TData; Index:word);
      procedure _var_DataWidth(var _Data:TData; Index:word);

      procedure _var_IdArray(var _Data:TData; Index:word);

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

constructor THiMemoryInfo.Create;
begin
   inherited;
   OleInit;
   InitCLSIDs;
   FListID := NewStrList;
end;

destructor THiMemoryInfo.Destroy;
begin
   FListId.Free;
   if IdArray <> nil then Dispose(IdArray);
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

procedure THiMemoryInfo._work_doArrayId;
var   objService : Variant;
      objMemory : Variant;
      colMemory : Variant;
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
   colMemory := objService.ExecQuery('SELECT BankLabel FROM Win32_PhysicalMemory');   
   oEnum := IUnknown(colMemory._NewEnum) as IEnumVariant;
   iValue := nil;
   while oEnum.Next(1,objMemory,iValue) = 0 do begin
      FlistId.Add(Trim(VarToStr(objMemory.ProcessID)));
      objMemory := Unassigned;
   end;
end;

procedure THiMemoryInfo._work_doInfo;
var   objService: Variant;
      objMemory: Variant; 
      colMemory: Variant;
      oEnum : IEnumvariant;
      iValue : PLongint;
      sDevice : string;
      sComputer :string;
      sQuery : string;
      dt : TData;
      Num: integer;
begin
   dtNull(dt);
   sComputer := ReadString(dt,_data_Computer,_prop_Computer);
   if sComputer = '' then sComputer := '.';
   sQuery := Trim(ReadString(dt,_data_Query,_prop_Query),',');
   sDevice := ReadString(_Data, _data_Id,'');
   if sQuery = '' then
      sQuery := '*'
   else
      sQuery := 'BankLabel,' + sQuery;
   objService := GetObject('winmgmts:{impersonationLevel=impersonate}!\\' + sComputer + '\root\CIMV2');
   if VarIsEmpty(objService) then begin
      _hi_CreateEvent(_Data, @_event_onErr);
      exit;
   end;
   if length(sDevice) > 0 then sDevice := ' WHERE BankLabel = "' + sDevice + '"';
   colMemory := objService.ExecQuery('SELECT ' + sQuery + ' FROM Win32_PhysicalMemory' + sDevice);
   oEnum := IUnknown(colMemory._NewEnum) as IEnumVariant;
   iValue := nil;
   while oEnum.Next(1,objMemory,iValue) = 0 do begin
      BankLabel           := Trim(VarToStr(objMemory.BankLabel));
      Name                := Trim(VarToStr(objMemory.Name));
      Capacity            := Trim(VarToStr(objMemory.Capacity));
      Manufacturer        := Trim(VarToStr(objMemory.Manufacturer));
      if not VarIsEmpty(objMemory.FormFactor) then begin
         Num              := str2int(Trim(VarToStr(objMemory.FormFactor)));
         case Num of
            7 : FormFactor := 'SIMM';
            8 : FormFactor := 'DIMM';
            9 : FormFactor := 'TSOP';
           10 : FormFactor := 'PGA';
         end;
      end else FormFactor := '';
      MemoryType          := Trim(VarToStr(objMemory.MemoryType));
      Model               := Trim(VarToStr(objMemory.Model));
      SerialNumber        := Trim(VarToStr(objMemory.SerialNumber));
      Speed               := Trim(VarToStr(objMemory.Speed));
      Tag                 := Trim(VarToStr(objMemory.Tag));
      Version             := Trim(VarToStr(objMemory.Version));
      DataWidth           := Trim(VarToStr(objMemory.DataWidth));
      _hi_onEvent(_event_onInfo);
      objMemory := Unassigned;
   end;
end;

procedure THiMemoryInfo._var_BankLabel;begin dtString(_Data,BankLabel);end;
procedure THiMemoryInfo._var_Name;begin dtString(_Data,Name);end;
procedure THiMemoryInfo._var_Capacity;begin dtString(_Data,Capacity);end;
procedure THiMemoryInfo._var_Manufacturer;begin dtString(_Data,Manufacturer);end;
procedure THiMemoryInfo._var_MemoryType;begin dtString(_Data,MemoryType);end;
procedure THiMemoryInfo._var_Model;begin dtString(_Data,Model);end;
procedure THiMemoryInfo._var_SerialNumber;begin dtString(_Data,SerialNumber);end;
procedure THiMemoryInfo._var_Speed;begin dtString(_Data,Speed);end;
procedure THiMemoryInfo._var_FormFactor;begin dtString(_Data,FormFactor);end; 
procedure THiMemoryInfo._var_Tag;begin dtString(_Data,Tag);end;
procedure THiMemoryInfo._var_Version;begin dtString(_Data,Version);end; 
procedure THiMemoryInfo._var_DataWidth;begin dtString(_Data,DataWidth);end;

procedure THiMemoryInfo._var_IdArray;
begin
   if IdArray = nil then
      IdArray:= CreateArray(nil, _GetId, _CountId, nil);
   dtArray(_Data,IdArray);
end;

function THiMemoryInfo._GetId;
var   ind:integer;
begin
   ind := ToIntIndex(Item);
   if(ind >= 0)and(ind < FListId.Count)then begin
      Result:= true;
      dtString(Val,FListId.Items[ind]);
   end
   else Result:= false;
end;

function THiMemoryInfo._CountId;begin Result:= FListId.Count;end;

end.
