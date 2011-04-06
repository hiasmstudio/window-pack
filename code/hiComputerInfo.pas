unit hiComputerInfo;

interface

uses Kol,Share,Windows,Debug;

type
  TWinVersion = (wvUnknown,wv95,wv98,wvME,wvNT3,wvNT4,wvW2K,wvXP,wv2003,wvVista,wv7);
  THIComputerInfo = class(TDebug)
   private
    ver,CSDVer:string;
    MajVer,MinVer,BuildN,PlID:DWORD;
   
    function DetectWinVersion:TWinVersion;
    function DetectWinVersionStr:string;
   public
    _prop_Mask:string;
    _prop_WinInfoMask:string;

    procedure _var_UserName(var _Data:TData; Index:word);
    procedure _var_CompName(var _Data:TData; Index:word);
    procedure _var_CPU(var _Data:TData; Index:word);
    procedure _var_WinInfo(var _Data:TData; Index:word);
  end;

implementation

const UNLEN = 256;

procedure THIComputerInfo._var_UserName;
var Size:cardinal;
    s:array[0..UNLEN] of char;
begin
    Size := length(s);
    GetUserName(s,Size);
    dtString(_Data,s);
end;

function GetComputerNameEx(
         NameType: Integer; // name type
         Buffer: PChar; // name buffer
         var Size: Dword // size of name buffer
): BOOL; stdcall; external 'kernel32.dll' name 'GetComputerNameExA';

procedure THIComputerInfo._var_CompName;
var Size:cardinal;
    s:array[0..MAX_COMPUTERNAME_LENGTH] of char;
begin
    Size := length(s);
    GetComputerNameEx(1, s, Size);
    dtString(_Data,s);
end;

procedure THIComputerInfo._var_CPU;
var lpSystemInfo:_SYSTEM_INFO;
    s:string;
begin
   GetSystemInfo(lpSystemInfo);
   s := _prop_Mask;
   Replace(s,'%t',Int2Str(lpSystemInfo.dwProcessorType));
   Replace(s,'%n',Int2Str(lpSystemInfo.dwNumberOfProcessors));
   dtString(_Data,s);
end;

procedure THIComputerInfo._var_WinInfo;
var name,res:string;
begin
  name := DetectWinVersionStr;
  res := _prop_WinInfoMask;
  Replace(res,'%n',name);
  Replace(res,'%M',int2str(MajVer));
  Replace(res,'%m',int2str(MinVer));
  Replace(res,'%p',int2str(PlID));
  Replace(res,'%b',int2str(BuildN));
  Replace(res,'%o',CSDVer);
  dtString(_Data,res);
end;


function THIComputerInfo.DetectWinVersion:TWinVersion;
var OSVersionInfo:TOSVersionInfo;
    i:integer;
begin
  Result := wvUnknown;
  OSVersionInfo.dwOSVersionInfoSize := sizeof(TOSVersionInfo);
  if GetVersionEx(OSVersionInfo) then
   begin
    CSDVer := OSVersionInfo.szCSDVersion;
    MajVer := OSVersionInfo.DwMajorVersion;
    MinVer := OSVersionInfo.DwMinorVersion;
    PlID := OSVersionInfo.dwPlatformId;
    BuildN := OSVersionInfo.dwBuildNumber;
    case MajVer of
      3: Result := wvNT3;              // Windows NT 3
      4: case MinVer of
           0: if PlID = VER_PLATFORM_WIN32_NT
                then Result := wvNT4   // Windows NT 4
               else Result := wv95;    // Windows 95
           10: Result := wv98;         // Windows 98
           90: Result := wvME;         // Windows ME
             end;
      5: case MinVer of
           0: Result := wvW2K;         // Windows 2000
           1: Result := wvXP;          // Windows XP
           2: Result := wv2003;        // Windows 2003
         end;
      6: case MinVer of
           0: Result := wvVista;       // Windows Vista
           1: Result := wv7;           // Windows 7
         end;
   end;
  end;
end;

function THIComputerInfo.DetectWinVersionStr:string;
const 
  VersStr : array[TWinVersion] of string = (
    'Unknown',
    '95',
    '98',
    'ME',
    'NT 3',
    'NT 4',
    '2000',
    'XP',
    '2003',
    'Vista',
    '7'
  );
begin
  Result := VersStr[DetectWinVersion];
end;

end.
