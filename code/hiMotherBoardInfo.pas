unit hiMotherBoardInfo;  { Компонент MotherBoardInfo (компонент для определения параметров материнской платы) ver 1.00 }

interface

uses Windows,KOL,KOLComObj,ActiveX,Share,Debug;

const STGM_default =STGM_READWRITE + STGM_SHARE_EXCLUSIVE;
      STGM_BASE    =STGM_READ + STGM_SHARE_EXCLUSIVE;

const wbemFlagUseAmendedQualifiers  = $20000;

type
  TScriptLanguage = (slVBScript, slJScript);
  
type
  THiMotherBoardInfo = class(TDebug)
   private
      Manufacturer            : string;
      Model                   : string;
      Name                    : string;
      Product                 : string;
      SerialNumber            : string;
      Tag                     : string;
      Version                 : string;
   public
      _prop_Computer: string;
      _prop_Query: string; 
      _data_Computer: THI_Event;
      _data_Query: THI_Event; 
      _event_onInfo: THI_Event;
      _event_onErr: THI_Event;
      constructor Create;
      destructor Destroy; override;      
      procedure _work_doInfo(var _Data:TData; Index:word);

      procedure _var_Manufacturer(var _Data:TData; Index:word);
      procedure _var_Model(var _Data:TData; Index:word);
      procedure _var_Name(var _Data:TData; Index:word);
      procedure _var_Product(var _Data:TData; Index:word);
      procedure _var_SerialNumber(var _Data:TData; Index:word);
      procedure _var_Tag(var _Data:TData; Index:word);
      procedure _var_Version(var _Data:TData; Index:word);

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

constructor THiMotherBoardInfo.Create;
begin
   inherited;
   OleInit;
   InitCLSIDs;
end;

destructor THiMotherBoardInfo.Destroy;
begin
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

procedure THiMotherBoardInfo._work_doInfo;
var   objService: Variant;
      objMB: Variant; 
      colMB: Variant;
      oEnum : IEnumvariant;
      iValue : PLongint;
      sComputer :string;
      sQuery : string;
      dt : TData;
begin
   dtNull(dt);
   sComputer := ReadString(dt,_data_Computer,_prop_Computer);
   if sComputer = '' then sComputer := '.';
   sQuery := Trim(ReadString(dt,_data_Query,_prop_Query),',');
   if sQuery = '' then sQuery := '*';
   objService := GetObject('winmgmts:{impersonationLevel=impersonate}!\\' + sComputer + '\root\CIMV2');
   if VarIsEmpty(objService) then begin
      _hi_CreateEvent(_Data, @_event_onErr);
      exit;
   end;
   colMB := objService.ExecQuery('SELECT ' + sQuery + ' FROM Win32_BaseBoard');
   oEnum := IUnknown(colMB._NewEnum) as IEnumVariant;
   iValue := nil;
   while oEnum.Next(1,objMB,iValue) = 0 do begin
      Manufacturer            := Trim(VarToStr(objMB.Manufacturer));
      Model                   := Trim(VarToStr(objMB.Model));
      Name                    := Trim(VarToStr(objMB.Name));
      Product                 := Trim(VarToStr(objMB.Product));
      SerialNumber            := Trim(VarToStr(objMB.SerialNumber));
      Tag                     := Trim(VarToStr(objMB.Tag));
      Version                 := Trim(VarToStr(objMB.Version));
      _hi_onEvent(_event_onInfo);
      objMB := Unassigned;
   end;
end;

procedure THiMotherBoardInfo._var_Manufacturer;begin dtString(_Data,Manufacturer);end;
procedure THiMotherBoardInfo._var_Model;begin dtString(_Data,Model);end;
procedure THiMotherBoardInfo._var_Name;begin dtString(_Data,Name);end;
procedure THiMotherBoardInfo._var_Product;begin dtString(_Data,Product);end;
procedure THiMotherBoardInfo._var_Tag;begin dtString(_Data,Tag);end;
procedure THiMotherBoardInfo._var_SerialNumber;begin dtString(_Data,SerialNumber);end;
procedure THiMotherBoardInfo._var_Version;begin dtString(_Data,Version);end;

end.
