unit activescp;

interface

uses
  Windows, ActiveX;

const
  SCATID_ActiveScript =               '{F0B7A1A1-9847-11cf-8F20-00805F2CD064}';
  SCATID_ActiveScriptParse =          '{F0B7A1A2-9847-11cf-8F20-00805F2CD064}';
  SID_IActiveScript =                 '{BB1A2AE1-A4F9-11cf-8F20-00805F2CD064}';
  SID_IActiveScriptParse =            '{BB1A2AE2-A4F9-11cf-8F20-00805F2CD064}';
  SID_IActiveScriptParseProcedureOld ='{1CFF0050-6FDD-11d0-9328-00A0C90DCAA9}';
  SID_IActiveScriptParseProcedure =   '{AA5B6A80-B834-11d0-932F-00A0C90DCAA9}';
  SID_IActiveScriptSite =             '{DB01A1E3-A42B-11cf-8F20-00805F2CD064}';
  SID_IActiveScriptSiteWindow =       '{D10F6761-83E9-11cf-8F20-00805F2CD064}';
  SID_IActiveScriptSiteInterruptPoll ='{539698A0-CDCA-11CF-A5EB-00AA0047A063}';
  SID_IActiveScriptError =            '{EAE1BA61-A4ED-11cf-8F20-00805F2CD064}';
  SID_IBindEventHandler =             '{63CDBCB0-C1B1-11d0-9336-00A0C90DCAA9}';
  SID_IActiveScriptStats =            '{B8DA6310-E19B-11d0-933C-00A0C90DCAA9}';

  CATID_ActiveScript:                 TGUID = SCATID_ActiveScript;
  CATID_ActiveScriptParse:            TGUID = SCATID_ActiveScriptParse;
  IID_IActiveScript:                  TGUID = SID_IActiveScript;
  IID_IActiveScriptParse:             TGUID = SID_IActiveScriptParse;
  IID_IActiveScriptParseProcedureOld: TGUID = SID_IActiveScriptParseProcedureOld;
  IID_IActiveScriptParseProcedure:    TGUID = SID_IActiveScriptParseProcedure;
  IID_IActiveScriptSite:              TGUID = SID_IActiveScriptSite;
  IID_IActiveScriptSiteWindow:        TGUID = SID_IActiveScriptSiteWindow;
  IID_IActiveScriptSiteInterruptPoll: TGUID = SID_IActiveScriptSiteInterruptPoll;
  IID_IActiveScriptError:             TGUID = SID_IActiveScriptError;
  IID_IBindEventHandler:              TGUID = SID_IBindEventHandler;
  IID_IActiveScriptStats:             TGUID = SID_IActiveScriptStats;

// Constants used by ActiveX Scripting:
//

(* IActiveScript::AddNamedItem() input flags *)

  SCRIPTITEM_ISVISIBLE     = $00000002;
  SCRIPTITEM_ISSOURCE      = $00000004;
  SCRIPTITEM_GLOBALMEMBERS = $00000008;
  SCRIPTITEM_ISPERSISTENT  = $00000040;
  SCRIPTITEM_CODEONLY      = $00000200;
  SCRIPTITEM_NOCODE        = $00000400;
  SCRIPTITEM_ALL_FLAGS     =(SCRIPTITEM_ISSOURCE or
                             SCRIPTITEM_ISVISIBLE or
                             SCRIPTITEM_ISPERSISTENT or
                             SCRIPTITEM_GLOBALMEMBERS or
                             SCRIPTITEM_NOCODE or
                             SCRIPTITEM_CODEONLY);

(* IActiveScript::AddTypeLib() input flags *)

  SCRIPTTYPELIB_ISCONTROL    = $00000010;
  SCRIPTTYPELIB_ISPERSISTENT = $00000040;
  SCRIPTTYPELIB_ALL_FLAGS    = (SCRIPTTYPELIB_ISCONTROL or
                                SCRIPTTYPELIB_ISPERSISTENT);

(* IActiveScriptParse::AddScriptlet() and
   IActiveScriptParse::ParseScriptText() input flags *)

  SCRIPTTEXT_DELAYEXECUTION    = $00000001;
  SCRIPTTEXT_ISVISIBLE         = $00000002;
  SCRIPTTEXT_ISEXPRESSION      = $00000020;
  SCRIPTTEXT_ISPERSISTENT      = $00000040;
  SCRIPTTEXT_HOSTMANAGESSOURCE = $00000080;
  SCRIPTTEXT_ALL_FLAGS         = (SCRIPTTEXT_DELAYEXECUTION or
                                  SCRIPTTEXT_ISVISIBLE or
                                  SCRIPTTEXT_ISEXPRESSION or
                                  SCRIPTTEXT_ISPERSISTENT or
                                  SCRIPTTEXT_HOSTMANAGESSOURCE);

(* IActiveScriptParseProcedure::ParseProcedureText() input flags *)

  SCRIPTPROC_HOSTMANAGESSOURCE = $00000080;
  SCRIPTPROC_IMPLICIT_THIS     = $00000100;
  SCRIPTPROC_IMPLICIT_PARENTS  = $00000200;
  SCRIPTPROC_ALL_FLAGS         = (SCRIPTPROC_HOSTMANAGESSOURCE or
                                  SCRIPTPROC_IMPLICIT_THIS or
                                  SCRIPTPROC_IMPLICIT_PARENTS);

(* IActiveScriptSite::GetItemInfo() input flags *)

  SCRIPTINFO_IUNKNOWN  = $00000001;
  SCRIPTINFO_ITYPEINFO = $00000002;
  SCRIPTINFO_ALL_FLAGS = (SCRIPTINFO_IUNKNOWN or
                          SCRIPTINFO_ITYPEINFO);

(* IActiveScript::Interrupt() Flags *)

  SCRIPTINTERRUPT_DEBUG          = $00000001;
  SCRIPTINTERRUPT_RAISEEXCEPTION = $00000002;
  SCRIPTINTERRUPT_ALL_FLAGS      = (SCRIPTINTERRUPT_DEBUG or
                                    SCRIPTINTERRUPT_RAISEEXCEPTION);

(* IActiveScriptStats::GetStat() values *)

  SCRIPTSTAT_STATEMENT_COUNT   = 1;
  SCRIPTSTAT_INSTRUCTION_COUNT = 2;
  SCRIPTSTAT_INTSTRUCTION_TIME = 3;
  SCRIPTSTAT_TOTAL_TIME        = 4;

(* script state values *)

type
  tagSCRIPTSTATE = integer;
  SCRIPTSTATE = tagSCRIPTSTATE;
const
  SCRIPTSTATE_UNINITIALIZED = $00000000;
  SCRIPTSTATE_INITIALIZED   = $00000005;
  SCRIPTSTATE_STARTED       = $00000001;
  SCRIPTSTATE_CONNECTED     = $00000002;
  SCRIPTSTATE_DISCONNECTED  = $00000003;
  SCRIPTSTATE_CLOSED        = $00000004;

(* script thread state values *)

type
  tagSCRIPTTHREADSTATE = integer;
  SCRIPTTHREADSTATE = tagSCRIPTTHREADSTATE;
const
  SCRIPTTHREADSTATE_NOTINSCRIPT = $00000000;
  SCRIPTTHREADSTATE_RUNNING     = $00000001;

(* Thread IDs *)

type
  SCRIPTTHREADID = DWORD;
const
  SCRIPTTHREADID_CURRENT = SCRIPTTHREADID(-1);
  SCRIPTTHREADID_BASE    = SCRIPTTHREADID(-2);
  SCRIPTTHREADID_ALL     = SCRIPTTHREADID(-3);

type
  IActiveScriptSite =           interface;
  IActiveScriptSiteWindow =     interface;
  IActiveScript =               interface;
  IActiveScriptParse =          interface;
  IActiveScriptParseProcedure = interface;
  IActiveScriptError =          interface;
  LPCOLESTR = PWideChar;

  IActiveScriptSite = interface(IUnknown)
    [SID_IActiveScript]
    function GetLCID(out plcid: LCID): HResult; stdcall;
    function GetItemInfo(
      pstrName: LPCOLESTR;
      dwReturnMask: DWORD;
      out ppiunkItem: IUnknown;
      out ppti: ITypeInfo): HResult; stdcall;
    function GetDocVersionString(out pbstrVersion: WideString): HResult; stdcall;
    function OnScriptTerminate(
      var pvarResult: OleVariant;
      var pexcepinfo: EXCEPINFO): HResult; stdcall;
    function OnStateChange(ssScriptState: SCRIPTSTATE): HResult; stdcall;
    function OnScriptError(
      const pscripterror: IActiveScriptError): HResult; stdcall;
    function OnEnterScript: HResult; stdcall;
    function OnLeaveScript: HResult; stdcall;
  end;

  IActiveScriptError = interface(IUnknown)
    [SID_IActiveScriptError]
    function GetExceptionInfo(out pexcepinfo: EXCEPINFO): HResult; stdcall;
    function GetSourcePosition(
      out pdwSourceContext: DWORD;
      out pulLineNumber: ULONG;
      out plCharacterPosition: Integer): HResult; stdcall;
    function GetSourceLineText(out pbstrSourceLine: WideString): HResult; stdcall;
  end;

  IActiveScriptSiteWindow = interface(IUnknown)
    [SID_IActiveScriptSiteWindow]
    function GetWindow(out phwnd: HWND): HResult; stdcall;
    function EnableModeless(fEnable: BOOL): HResult; stdcall;
  end;

  IActiveScriptSiteInterruptPoll = interface(IUnknown)
    [SID_IActiveScriptSiteInterruptPoll]
    function QueryContinue: HResult; stdcall;
  end;

  IActiveScript = interface(IUnknown)
    [SID_IActiveScript]
    function SetScriptSite(const pass: IActiveScriptSite): HResult; stdcall;
    function GetScriptSite(
      const riid: TGUID;
      out ppvObject: Pointer): HResult; stdcall;
    function SetScriptState(ss: SCRIPTSTATE): HResult; stdcall;
    function GetScriptState(out pssState: SCRIPTSTATE): HResult; stdcall;
    function Close: HResult; stdcall;
    function AddNamedItem(
      pstrName: LPCOLESTR;
      dwFlags: DWORD): HResult; stdcall;
    function AddTypeLib(
      const rguidTypeLib: TGUID;
      dwMajor: DWORD;
      dwMinor: DWORD;
      dwFlags: DWORD): HResult; stdcall;
    function GetScriptDispatch(
      pstrItemName: LPCOLESTR;
      out ppdisp: IDispatch): HResult; stdcall;
    function GetCurrentScriptThreadID(
      out pstidThread: SCRIPTTHREADID): HResult; stdcall;
    function GetScriptThreadID(dwWin32ThreadId: DWORD;
      out pstidThread: SCRIPTTHREADID): HResult; stdcall;
    function GetScriptThreadState(
      stidThread: SCRIPTTHREADID;
      out pstsState: SCRIPTTHREADSTATE): HResult; stdcall;
    function InterruptScriptThread(
      stidThread: SCRIPTTHREADID;
      var pexcepinfo: EXCEPINFO;
      dwFlags: DWORD): HResult; stdcall;
    function Clone(out ppscript: IActiveScript): HResult; stdcall;
  end;

  IActiveScriptParse = interface(IUnknown)
    [SID_IActiveScriptParse]
    function InitNew: HResult; stdcall;
    function AddScriptlet(
      pstrDefaultName: LPCOLESTR;
      pstrCode: LPCOLESTR;
      pstrItemName: LPCOLESTR;
      pstrSubItemName: LPCOLESTR;
      pstrEventName: LPCOLESTR;
      pstrDelimiter: LPCOLESTR;
      dwSourceContextCookie: DWORD;
      ulStartingLineNumber: ULONG;
      dwFlags: DWORD;
      out pbstrName: WideString;
      out pexcepinfo: EXCEPINFO): HResult; stdcall;
    function ParseScriptText(
      pstrCode: LPCOLESTR;
      pstrItemName: LPCOLESTR;
      const punkContext: IUnknown;
      pstrDelimiter: LPCOLESTR;
      dwSourceContextCookie: DWORD;
      ulStartingLineNumber: ULONG;
      dwFlags: DWORD;
      out pvarResult: OleVariant;
      out pexcepinfo: EXCEPINFO): HResult; stdcall;
  end;

  IActiveScriptParseProcedureOld = interface(IUnknown)
    [SID_IActiveScriptParseProcedureOld]
    function ParseProcedureText(
      pstrCode: LPCOLESTR;
      pstrFormalParams: LPCOLESTR;
      pstrItemName: LPCOLESTR;
      const punkContext: IUnknown;
      pstrDelimiter: LPCOLESTR;
      dwSourceContextCookie: DWORD;
      ulStartingLineNumber: ULONG;
      dwFlags: DWORD;
      out ppdisp: IDispatch): HResult; stdcall;
  end;

  IActiveScriptParseProcedure = interface(IUnknown)
    [SID_IActiveScriptParseProcedure]
    function ParseProcedureText(
      pstrCode: LPCOLESTR;
      pstrFormalParams: LPCOLESTR;
      pstrProcedureName: LPCOLESTR;
      pstrItemName: LPCOLESTR;
      const punkContext: IUnknown;
      pstrDelimiter: LPCOLESTR;
      dwSourceContextCookie: DWORD;
      ulStartingLineNumber: ULONG;
      dwFlags: DWORD;
      out ppdisp: IDispatch): HResult; stdcall;
  end;

  IBindEventHandler = interface(IUnknown)
    [SID_IBindEventHandler]
    function BindHandler(
      pstrEvent: LPCOLESTR;
      const pdisp: IDispatch): HResult; stdcall;
  end;

  IActiveScriptStats = interface(IUnknown)
    [SID_IActiveScriptStats]
    function GetStat(
      stid: DWORD;
      out pluHi: ULONG;
      out pluLo: ULONG): HResult; stdcall;
    function GetStatEx(
      const guid: TGUID;
      out pluHi: ULONG;
      out pluLo: ULONG): HResult; stdcall;
    function ResetStats: HResult; stdcall;
  end;

implementation
end.
