unit HiProcessInfo;  { Компонент ProcessInfo (компонент для определения параметров запущенных процессов) ver 1.00 }

interface

uses Windows,KOL,KOLComObj,ActiveX,Share,Debug;

const STGM_default =STGM_READWRITE + STGM_SHARE_EXCLUSIVE;
      STGM_BASE    =STGM_READ + STGM_SHARE_EXCLUSIVE;

type
  TScriptLanguage = (slVBScript, slJScript);
  
type
  THiProcessInfo = class(TDebug)
   private
      ProcessID      : string;
      ParentProcessID: string;
      Name           : string;
      ExecutablePath : string;
      CommandLine    : string;
      PageFileUsage  : string;
      Priority       : string;
      ThreadCount    : string;
      WorkingSetSize : string;
      OSName         : string;
      WindowsVersion : string;
            
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

      procedure _var_ProcessID(var _Data:TData; Index:word);
      procedure _var_ParentProcessID(var _Data:TData; Index:word);
      procedure _var_Name(var _Data:TData; Index:word);
      procedure _var_ExecutablePath(var _Data:TData; Index:word);
      procedure _var_PageFileUsage(var _Data:TData; Index:word);
      procedure _var_Priority(var _Data:TData; Index:word);
      procedure _var_ThreadCount(var _Data:TData; Index:word);
      procedure _var_WorkingSetSize(var _Data:TData; Index:word);
      procedure _var_OSName(var _Data:TData; Index:word);
      procedure _var_WindowsVersion(var _Data:TData; Index:word);
      procedure _var_CommandLine(var _Data:TData; Index:word);
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

constructor THiProcessInfo.Create;
begin
   inherited;
   OleInit;
   InitCLSIDs;
   FListID := NewStrList;
end;

destructor THiProcessInfo.Destroy;
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

procedure THiProcessInfo._work_doArrayId;
var   objService : Variant;
      objProcess : Variant;
      colProcess : Variant;
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
   colProcess := objService.ExecQuery('SELECT ProcessID FROM Win32_Process');   
   oEnum := IUnknown(colProcess._NewEnum) as IEnumVariant;
   iValue := nil;
   while oEnum.Next(1,objProcess,iValue) = 0 do begin
      FlistId.Add(Trim(VarToStr(objProcess.ProcessID)));
      objProcess := Unassigned;
   end;
end;

procedure THiProcessInfo._work_doInfo;
var   objService: Variant;
      objProcess: Variant; 
      colProcess: Variant;
      oEnum : IEnumvariant;
      iValue : PLongint;
      sDevice : string;
      sComputer :string;
      sQuery : string;
      dt : TData;
begin
   dtNull(dt);
   sComputer := ReadString(dt,_data_Computer,_prop_Computer);
   if sComputer = '' then sComputer := '.';
   sQuery := Trim(ReadString(dt,_data_Query,_prop_Query),',');
   sDevice := ReadString(_Data, _data_Id,'');
   if sQuery = '' then
      sQuery := '*'
   else
      sQuery := 'ProcessID,' + sQuery;
   objService := GetObject('winmgmts:{impersonationLevel=impersonate}!\\' + sComputer + '\root\CIMV2');
   if VarIsEmpty(objService) then begin
      _hi_CreateEvent(_Data, @_event_onErr);
      exit;
   end;
   if length(sDevice) > 0 then sDevice := ' WHERE ProcessID = "' + sDevice + '"';
   colProcess := objService.ExecQuery('SELECT ' + sQuery + ' FROM Win32_Process' + sDevice);
   oEnum := IUnknown(colProcess._NewEnum) as IEnumVariant;
   iValue := nil;
   while oEnum.Next(1,objProcess,iValue) = 0 do begin
      ProcessID         := Trim(VarToStr(objProcess.ProcessID));
      ParentProcessID   := Trim(VarToStr(objProcess.ParentProcessID));
      Name              := Trim(VarToStr(objProcess.Name));
      ExecutablePath    := Trim(VarToStr(objProcess.ExecutablePath));
      CommandLine       := Trim(VarToStr(objProcess.CommandLine));
      if not VarIsEmpty(objProcess.PageFileUsage) then
         PageFileUsage  := double2str(Round(str2double(Trim(VarToStr(objProcess.PageFileUsage)))/1024))
      else
         PageFileUsage  := ''; 
      if not VarIsEmpty(objProcess.WorkingSetSize) then
         WorkingSetSize := double2str(Round(str2double(Trim(VarToStr(objProcess.WorkingSetSize)))/1024))
      else
         WorkingSetSize := '';      
      Priority          := Trim(VarToStr(objProcess.Priority));
      ThreadCount       := Trim(VarToStr(objProcess.ThreadCount));
      OSName            := Trim(VarToStr(objProcess.OSName));
      WindowsVersion    := Trim(VarToStr(objProcess.WindowsVersion));
      _hi_onEvent(_event_onInfo);
      objProcess := Unassigned;
   end;
end;

procedure THiProcessInfo._var_ProcessID;begin dtString(_Data,ProcessID);end;
procedure THiProcessInfo._var_ParentProcessID;begin dtString(_Data,ParentProcessID);end;
procedure THiProcessInfo._var_Name;begin dtString(_Data,Name);end;
procedure THiProcessInfo._var_ExecutablePath;begin dtString(_Data,ExecutablePath);end;
procedure THiProcessInfo._var_CommandLine;begin dtString(_Data,CommandLine);end;
procedure THiProcessInfo._var_PageFileUsage;begin dtString(_Data,PageFileUsage);end;
procedure THiProcessInfo._var_Priority;begin dtString(_Data,Priority);end;
procedure THiProcessInfo._var_ThreadCount;begin dtString(_Data,ThreadCount);end;
procedure THiProcessInfo._var_WorkingSetSize;begin dtString(_Data,WorkingSetSize);end;
procedure THiProcessInfo._var_OSName;begin dtString(_Data,OSName);end; 
procedure THiProcessInfo._var_WindowsVersion;begin dtString(_Data,WindowsVersion);end;

procedure THiProcessInfo._var_IdArray;
begin
   if IdArray = nil then
      IdArray:= CreateArray(nil, _GetId, _CountId, nil);
   dtArray(_Data,IdArray);
end;

function THiProcessInfo._GetId;
var   ind:integer;
begin
   ind := ToIntIndex(Item);
   if(ind >= 0)and(ind < FListId.Count)then begin
      Result:= true;
      dtString(Val,FListId.Items[ind]);
   end
   else Result:= false;
end;

function THiProcessInfo._CountId;begin Result:= FListId.Count;end;

end.
