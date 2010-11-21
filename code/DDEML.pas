unit DDEML;

interface

uses KOL,Debug,Windows;

const

 CP_WINANSI = 1004;

 DDE_FACK               = $8000;
 DDE_FBUSY              = $4000;
 DDE_FDEFERUPD          = $4000;
 DDE_FACKREQ            = $8000;
 DDE_FRELEASE           = $2000;
 DDE_FREQUESTED         = $1000;
 DDE_FAPPSTATUS         = $00ff;
 DDE_FNOTPROCESSED      = $0000;

 XST_NULL             = 0;
 XST_INCOMPLETE       = 1;
 XST_CONNECTED        = 2;
 XST_INIT1            = 3;
 XST_INIT2            = 4;
 XST_REQSENT          = 5;
 XST_DATARCVD         = 6;
 XST_POKESENT         = 7;
 XST_POKEACKRCVD      = 8;
 XST_EXECSENT         = 9;
 XST_EXECACKRCVD      = 10;
 XST_ADVSENT          = 11;
 XST_UNADVSENT        = 12;
 XST_ADVACKRCVD       = 13;
 XST_UNADVACKRCVD     = 14;
 XST_ADVDATASENT      = 15;
 XST_ADVDATAACKRCVD   = 16;

 XTYPF_NOBLOCK          =  $0002;
 XTYPF_NODATA           =  $0004;
 XTYPF_ACKREQ           =  $0008;

 XCLASS_MASK            =  $FC00;
 XCLASS_BOOL            =  $1000;
 XCLASS_DATA            =  $2000;
 XCLASS_FLAGS           =  $4000;
 XCLASS_NOTIFICATION    =  $8000;

 XTYP_ERROR             = ($0000 or XCLASS_NOTIFICATION or XTYPF_NOBLOCK );
 XTYP_ADVDATA           = ($0010 or XCLASS_FLAGS         );
 XTYP_ADVREQ            = ($0020 or XCLASS_DATA or XTYPF_NOBLOCK );
 XTYP_ADVSTART          = ($0030 or XCLASS_BOOL          );
 XTYP_ADVSTOP           = ($0040 or XCLASS_NOTIFICATION);
 XTYP_EXECUTE           = ($0050 or XCLASS_FLAGS         );
 XTYP_CONNECT           = ($0060 or XCLASS_BOOL or XTYPF_NOBLOCK);
 XTYP_CONNECT_CONFIRM   = ($0070 or XCLASS_NOTIFICATION or XTYPF_NOBLOCK);
 XTYP_XACT_COMPLETE     = ($0080 or XCLASS_NOTIFICATION  );
 XTYP_POKE              = ($0090 or XCLASS_FLAGS         );
 XTYP_REGISTER          = ($00A0 or XCLASS_NOTIFICATION or XTYPF_NOBLOCK);
 XTYP_REQUEST           = ($00B0 or XCLASS_DATA          );
 XTYP_DISCONNECT        = ($00C0 or XCLASS_NOTIFICATION or XTYPF_NOBLOCK);
 XTYP_UNREGISTER        = ($00D0 or XCLASS_NOTIFICATION or XTYPF_NOBLOCK);
 XTYP_WILDCONNECT       = ($00E0 or XCLASS_DATA or XTYPF_NOBLOCK);
 XTYP_MASK              =  $00F0;

 DNS_REGISTER       = 1;
 DNS_UNREGISTER     = 2;
 DNS_FILTERON       = 4;
 DNS_FILTEROFF      = 8;

type

 TDdeCallback = function (uType,uFmt:cardinal; hConv,hSz1,hSz2,hData:THandle; dwData1,dwData2:DWORD):cardinal of object;

 TDdeConversation = class(TDebug)
 public
   FConv:THandle;
   FCallback:TDdeCallback;
   constructor Create;
   destructor Destroy; override;
 end;

function DdeInitialize(var pid:DWORD; pfnCallback:pointer; afCmd:DWORD; ulRes:DWORD): UINT; stdcall;
function DdeNameService(pid:DWORD; hszService,hszTopic:THandle; afCmd:UINT):THandle; stdcall; 
function DdeCreateStringHandle(pid:DWORD; sz:PChar; iCodePage:integer):THandle; stdcall;
function DdeFreeStringHandle(pid:DWORD; hsz:THandle):boolean; stdcall;
function DdeConnect(pid:DWORD; hszService,hszTopic:THandle; pCC:pointer):THandle; stdcall;
function DdeClientTransaction(pData:pointer; cbData:DWORD; hConv:THandle; hszItem:THandle; wFmt,wType:UINT; dwTimeout:DWORD; var dwResult:DWORD):THandle; stdcall;
function DdeQueryString(pid:DWORD; hsz:THandle; psz:PChar; cchMax:DWORD; iCodePage:integer):DWORD; stdcall;
function DdeCreateDataHandle(pid:DWORD; pSrc:pointer; cb,cbOff:DWORD; hszItem:THandle; wFmt,afCmd:UINT):THandle; stdcall;
function DdeGetData(hData:THandle; pBuffer:pointer; cbMax,cbOffset:DWORD):DWORD; stdcall;
function DdeFreeDataHandle(hData:THandle):boolean; stdcall;
function DdePostAdvise(pid:DWORD; hszTopic,hszItem:THandle):boolean; stdcall;
function DdeDisconnect(hConv:THandle):boolean; stdcall;
function DdeUninitialize(pid:DWORD):boolean; stdcall;

var g_DdeInstance:DWORD;

implementation

var ConvList:PList;

constructor TDdeConversation.Create;
begin
  inherited;
  ConvList.Add(Self);
end;

destructor TDdeConversation.Destroy;
begin
  ConvList.Remove(Self);
  inherited;
end;

function DdeInitialize(var pid:DWORD; pfnCallback:pointer; afCmd:DWORD; ulRes:DWORD): UINT; stdcall; external 'USER32.DLL' name 'DdeInitializeA';
function DdeNameService(pid:DWORD; hszService,hszTopic:THandle; afCmd:UINT):THandle; stdcall; external 'USER32.DLL' name 'DdeNameService'; 
function DdeCreateStringHandle(pid:DWORD; sz:PChar; iCodePage:integer):THandle; stdcall; external 'USER32.DLL' name 'DdeCreateStringHandleA';
function DdeFreeStringHandle(pid:DWORD; hsz:THandle):boolean; stdcall; external 'USER32.DLL' name 'DdeFreeStringHandle'; 
function DdeConnect(pid:DWORD; hszService,hszTopic:THandle; pCC:pointer):THandle; stdcall; external 'USER32.DLL' name 'DdeConnect';
function DdeClientTransaction(pData:pointer; cbData:DWORD; hConv:THandle; hszItem:THandle; wFmt,wType:UINT; dwTimeout:DWORD; var dwResult:DWORD):THandle; stdcall; external 'USER32.DLL' name 'DdeClientTransaction';
function DdeQueryString(pid:DWORD; hsz:THandle; psz:PChar; cchMax:DWORD; iCodePage:integer):DWORD; stdcall; external 'USER32.DLL' name 'DdeQueryStringA';
function DdeCreateDataHandle(pid:DWORD; pSrc:pointer; cb,cbOff:DWORD; hszItem:THandle; wFmt,afCmd:UINT):THandle; stdcall; external 'USER32.DLL' name 'DdeCreateDataHandle';
function DdeGetData(hData:THandle; pBuffer:pointer; cbMax,cbOffset:DWORD):DWORD; stdcall; external 'USER32.DLL' name 'DdeGetData';  
function DdeFreeDataHandle(hData:THandle):boolean; stdcall; external 'USER32.DLL' name 'DdeFreeDataHandle';
function DdePostAdvise(pid:DWORD; hszTopic,hszItem:THandle):boolean; stdcall; external 'USER32.DLL' name 'DdePostAdvise';
function DdeDisconnect(hConv:THandle):boolean; stdcall; external 'USER32.DLL' name 'DdeDisconnect';  
function DdeUninitialize(pid:DWORD):boolean; stdcall; external 'USER32.DLL' name 'DdeUninitialize';  

function MyCallback(uType,uFmt:cardinal; hConv,hSz1,hSz2,hData:THandle; dwData1,dwData2:DWORD):cardinal; stdcall;
var i:integer; conv:TDdeConversation; nRes:cardinal;
begin
  Result := DDE_FNOTPROCESSED; 
  for i:=0 to ConvList.Count-1 do begin
    conv := TDdeConversation(ConvList.Items[i]);
    if (conv.FConv = 0) or (conv.FConv = hConv) then begin
      nRes := conv.FCallback(uType,uFmt,hConv,hSz1,hSz2,hData,dwData1,dwData2);
      if nRes<>DDE_FNOTPROCESSED then Result := nRes;
    end;
  end;
end;

initialization
  DdeInitialize(g_DdeInstance,@MyCallback,0,0);
  ConvList := NewList;

finalization
  ConvList.Free;
  DdeUninitialize(g_DdeInstance);
  
end.
