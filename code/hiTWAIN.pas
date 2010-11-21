unit hiTWAIN;

interface

uses Windows,Kol,Share,Debug;

const

  TWRC_SUCCESS          = 0;
  TWRC_FAILURE          = 1;
  TWRC_CHECKSTATUS      = 2;
  TWRC_CANCEL           = 3;
  TWRC_DSEVENT          = 4;
  TWRC_NOTDSEVENT       = 5;
  TWRC_XFERDONE         = 6;
  TWRC_ENDOFLIST        = 7;
  TWRC_INFONOTSUPPORTED = 8;
  TWRC_DATANOTAVAILABLE = 9;

  DG_CONTROL  = 1;
  DG_IMAGE    = 2;

  DAT_NULL            = $0;
  DAT_CAPABILITY      = $1;
  DAT_EVENT           = $2;
  DAT_IDENTITY        = $3;
  DAT_PARENT          = $4;
  DAT_PENDINGXFERS    = $5;
  DAT_SETUPMEMXFER    = $6;
  DAT_SETUPFILEXFER   = $7;
  DAT_STATUS          = $8;
  DAT_USERINTERFACE   = $9;
  DAT_XFERGROUP       = $a;
  DAT_TWUNKIDENTITY   = $b;
  DAT_CUSTOMDSDATA    = $c;
  DAT_DEVICEEVENT     = $d;
  DAT_FILESYSTEM      = $e;
  DAT_PASSTHRU        = $f;

  DAT_IMAGEINFO       = $101;
  DAT_IMAGELAYOUT     = $102;
  DAT_IMAGEMEMXFER    = $103;
  DAT_IMAGENATIVEXFER = $104;
  DAT_IMAGEFILEXFER   = $105;
  DAT_CIECOLOR        = $106;
  DAT_GRAYRESPONSE    = $107;
  DAT_RGBRESPONSE     = $108;
  DAT_JPEGCOMPRESSION = $109;
  DAT_PALETTE8        = $10a;
  DAT_EXTIMAGEINFO    = $10b;

  MSG_NULL         = $0;
  MSG_GET          = $1;
  MSG_GETCURRENT   = $2;
  MSG_GETDEFAULT   = $3;
  MSG_GETFIRST     = $4;
  MSG_GETNEXT      = $5;
  MSG_SET          = $6;
  MSG_RESET        = $7;
  MSG_QUERYSUPPORT = $8;
  MSG_XFERREADY    = $101;
  MSG_CLOSEDSREQ   = $102;
  MSG_CLOSEDSOK    = $103;
  MSG_DEVICEEVENT  = $104;
  MSG_CHECKSTATUS  = $201;
  MSG_OPENDSM      = $301;
  MSG_CLOSEDSM     = $302;
  MSG_OPENDS       = $401;
  MSG_CLOSEDS      = $402;
  MSG_USERSELECT   = $403;
  MSG_DISABLEDS    = $501;
  MSG_ENABLEDS     = $502;
  MSG_ENABLEDSUIONLY = $503;
  MSG_PROCESSEVENT   = $601;
  MSG_ENDXFER        = $701;
  MSG_CHANGEDIRECTORY = $801;
  MSG_CREATEDIRECTORY = $802;
  MSG_DELETE          = $803;
  MSG_FORMATMEDIA     = $804; 
  MSG_GETCLOSE        = $805;
  MSG_GETFIRSTFILE    = $806;
  MSG_GETINFO         = $807;
  MSG_GETNEXTFILE     = $808;
  MSG_RENAME          = $809;
  MSG_PASSTHRU        = $901;

  TWLG_RUSSIAN = 78;
  TWCY_USSR = 7;

  TWTY_INT8   = 0;
  TWTY_INT16  = 1;
  TWTY_INT32  = 2;
  TWTY_UINT8  = 3;
  TWTY_UINT16 = 4;
  TWTY_UINT32 = 5;
  TWTY_BOOL   = 6;
  TWTY_FIX32  = 7;
  TWTY_FRAME  = 8;
  TWTY_STR32  = 9;
  TWTY_STR64  = $a;
  TWTY_STR128 = $b;
  TWTY_STR255 = $c;

  TWON_ARRAY       = 3;
  TWON_ENUMERATION = 4;
  TWON_ONEVALUE    = 5;
  TWON_RANGE       = 6;
  TWON_ICONID      = 962;
  TWON_DSMID       = 461;
  TWON_DSMCODEID   = 63;
  TWON_DONTCARE8   = $ff;
  TWON_DONTCARE16  = $ffff;
  TWON_DONTCARE32  = $ffffffff;

  CAP_XFERCOUNT = 1;

  ICAP_COMPRESSION = $100;
  ICAP_PIXELTYPE   = $101;
  ICAP_UNITS       = $102;
  ICAP_XFERMECH    = $103;

  CAP_AUTHOR                  = $1000;
  CAP_CAPTION                 = $1001;
  CAP_FEEDERENABLED           = $1002;
  CAP_FEEDERLOADED            = $1003;
  CAP_TIMEDATE                = $1004;
  CAP_SUPPORTEDCAPS           = $1005;
  CAP_EXTENDEDCAPS            = $1006;
  CAP_AUTOFEED                = $1007;
  CAP_CLEARPAGE               = $1008;
  CAP_FEEDPAGE                = $1009;
  CAP_REWINDPAGE              = $100a;
  CAP_INDICATORS              = $100b;
  CAP_SUPPORTEDCAPSEXT        = $100c;
  CAP_PAPERDETECTABLE         = $100d;
  CAP_UICONTROLLABLE          = $100e;
  CAP_DEVICEONLINE            = $100f;
  CAP_AUTOSCAN                = $1010;
  CAP_THUMBNAILSENABLED       = $1011;
  CAP_DUPLEX                  = $1012;
  CAP_DUPLEXENABLED           = $1013;
  CAP_ENABLEDSUIONLY          = $1014;
  CAP_CUSTOMDSDATA            = $1015;
  CAP_ENDORSER                = $1016;
  CAP_JOBCONTROL              = $1017;
  CAP_ALARMS                  = $1018;
  CAP_ALARMVOLUME             = $1019;
  CAP_AUTOMATICCAPTURE        = $101a;
  CAP_TIMEBEFOREFIRSTCAPTURE  = $101b;
  CAP_TIMEBETWEENCAPTURES     = $101c;
  CAP_CLEARBUFFERS            = $101d;
  CAP_MAXBATCHBUFFERS         = $101e;
  CAP_DEVICETIMEDATE          = $101f;
  CAP_POWERSUPPLY             = $1020;
  CAP_CAMERAPREVIEWUI         = $1021;
  CAP_DEVICEEVENT             = $1022;
  CAP_PAGEMULTIPLEACQUIRE     = $1023;
  CAP_SERIALNUMBER            = $1024;
  CAP_FILESYSTEM              = $1025;
  CAP_PRINTER                 = $1026;
  CAP_PRINTERENABLED          = $1027;
  CAP_PRINTERINDEX            = $1028;
  CAP_PRINTERMODE             = $1029;
  CAP_PRINTERSTRING           = $102a;
  CAP_PRINTERSUFFIX           = $102b;
  CAP_LANGUAGE                = $102c;
  CAP_FEEDERALIGNMENT         = $102d;
  CAP_FEEDERORDER             = $102e;
  CAP_PAPERBINDING            = $102f;
  CAP_REACQUIREALLOWED        = $1030;
  CAP_PASSTHRU                = $1031;
  CAP_BATTERYMINUTES          = $1032;
  CAP_BATTERYPERCENTAGE       = $1033;
  CAP_POWERDOWNTIME           = $1034;

  ICAP_AUTOBRIGHT                   = $1100;
  ICAP_BRIGHTNESS                   = $1101;
  ICAP_CONTRAST                     = $1103;
  ICAP_CUSTHALFTONE                 = $1104;
  ICAP_EXPOSURETIME                 = $1105;
  ICAP_FILTER                       = $1106;
  ICAP_FLASHUSED                    = $1107;
  ICAP_GAMMA                        = $1108;
  ICAP_HALFTONES                    = $1109;
  ICAP_HIGHLIGHT                    = $110a;
  ICAP_IMAGEFILEFORMAT              = $110c;
  ICAP_LAMPSTATE                    = $110d;
  ICAP_LIGHTSOURCE                  = $110e;
  ICAP_ORIENTATION                  = $1110;
  ICAP_PHYSICALWIDTH                = $1111;
  ICAP_PHYSICALHEIGHT               = $1112;
  ICAP_SHADOW                       = $1113;
  ICAP_FRAMES                       = $1114;
  ICAP_XNATIVERESOLUTION            = $1116;
  ICAP_YNATIVERESOLUTION            = $1117;
  ICAP_XRESOLUTION                  = $1118;
  ICAP_YRESOLUTION                  = $1119;
  ICAP_MAXFRAMES                    = $111a;
  ICAP_TILES                        = $111b;
  ICAP_BITORDER                     = $111c;
  ICAP_CCITTKFACTOR                 = $111d;
  ICAP_LIGHTPATH                    = $111e;
  ICAP_PIXELFLAVOR                  = $111f;
  ICAP_PLANARCHUNKY                 = $1120;
  ICAP_ROTATION                     = $1121;
  ICAP_SUPPORTEDSIZES               = $1122;
  ICAP_THRESHOLD                    = $1123;
  ICAP_XSCALING                     = $1124;
  ICAP_YSCALING                     = $1125;
  ICAP_BITORDERCODES                = $1126;
  ICAP_PIXELFLAVORCODES             = $1127;
  ICAP_JPEGPIXELTYPE                = $1128;
  ICAP_TIMEFILL                     = $112a;
  ICAP_BITDEPTH                     = $112b;
  ICAP_BITDEPTHREDUCTION            = $112c;  
  ICAP_UNDEFINEDIMAGESIZE           = $112d;  
  ICAP_IMAGEDATASET                 = $112e;  
  ICAP_EXTIMAGEINFO                 = $112f;  
  ICAP_MINIMUMHEIGHT                = $1130;  
  ICAP_MINIMUMWIDTH                 = $1131;  
  ICAP_AUTODISCARDBLANKPAGES        = $1134;  
  ICAP_FLIPROTATION                 = $1136;  
  ICAP_BARCODEDETECTIONENABLED      = $1137;  
  ICAP_SUPPORTEDBARCODETYPES        = $1138;  
  ICAP_BARCODEMAXSEARCHPRIORITIES   = $1139;  
  ICAP_BARCODESEARCHPRIORITIES      = $113a;  
  ICAP_BARCODESEARCHMODE            = $113b;  
  ICAP_BARCODEMAXRETRIES            = $113c;  
  ICAP_BARCODETIMEOUT               = $113d;  
  ICAP_ZOOMFACTOR                   = $113e;  
  ICAP_PATCHCODEDETECTIONENABLED    = $113f;  
  ICAP_SUPPORTEDPATCHCODETYPES      = $1140;  
  ICAP_PATCHCODEMAXSEARCHPRIORITIES = $1141;  
  ICAP_PATCHCODESEARCHPRIORITIES    = $1142;  
  ICAP_PATCHCODESEARCHMODE          = $1143;  
  ICAP_PATCHCODEMAXRETRIES          = $1144;  
  ICAP_PATCHCODETIMEOUT             = $1145;  
  ICAP_FLASHUSED2                   = $1146;  
  ICAP_IMAGEFILTER                  = $1147;  
  ICAP_NOISEFILTER                  = $1148;  
  ICAP_OVERSCAN                     = $1149;  
  ICAP_AUTOMATICBORDERDETECTION     = $1150;  
  ICAP_AUTOMATICDESKEW              = $1151;  
  ICAP_AUTOMATICROTATE              = $1152;  

  TWSX_NATIVE = 0;
  TWSX_FILE   = 1;
  TWSX_MEMORY = 2;

  TWCC_SUCCESS           = 0;
  TWCC_BUMMER            = 1;
  TWCC_LOWMEMORY         = 2;
  TWCC_NODS              = 3;
  TWCC_MAXCONNECTIONS    = 4;
  TWCC_OPERATIONERROR    = 5;
  TWCC_BADCAP            = 6;
  TWCC_BADPROTOCOL       = 9;
  TWCC_BADVALUE          = 10;
  TWCC_SEQERROR          = 11;
  TWCC_BADDEST           = 12;
  TWCC_CAPUNSUPPORTED    = 13;
  TWCC_CAPBADOPERATION   = 14;
  TWCC_CAPSEQERROR       = 15;
  TWCC_DENIED            = 16;
  TWCC_FILEEXISTS        = 17;
  TWCC_FILENOTFOUND      = 18;
  TWCC_NOTEMPTY          = 19;
  TWCC_PAPERJAM          = 20;
  TWCC_PAPERDOUBLEFEED   = 21;
  TWCC_FILEWRITEERROR    = 22;
  TWCC_CHECKDEVICEONLINE = 23;

type

  TW_BOOL = WORD;
  TW_UINT16 = WORD;
  TW_UINT32 = DWORD;
  TW_STR32 = array [0..33] of char;
  TW_MEMREF = pointer;
  TW_HANDLE = THandle;

  TW_VERSION = packed record
    MajorNum: TW_UINT16;
    MinorNum: TW_UINT16;
    Language: TW_UINT16;
    Country: TW_UINT16;
    Info: TW_STR32;
  end;

  TW_STATUS = packed record
    ConditionCode: TW_UINT16;
    Reserved: TW_UINT16;
  end;

  pTW_IDENTITY = ^TW_IDENTITY;
  TW_IDENTITY = packed record
    Id: TW_UINT32;
    Version: TW_VERSION;
    ProtocolMajor: TW_UINT16;
    ProtocolMinor: TW_UINT16;
    SupportedGroups: TW_UINT32;
    Manufacturer: TW_STR32;
    ProductFamily: TW_STR32;
    ProductName: TW_STR32;
  end;

  pTW_ONEVALUE = ^TW_ONEVALUE;
  TW_ONEVALUE = packed record
    ItemType: TW_UINT16;
    Item: TW_UINT32;
  end;

  TW_CAPABILITY = packed record
    Cap: TW_UINT16;
    ConType: TW_UINT16;
    hContainer: TW_HANDLE;
  end;

  TW_USERINTERFACE = packed record
    ShowUI: TW_BOOL;
    ModalUI: TW_BOOL;
    hParent: TW_HANDLE;
  end;

  TW_EVENT = packed record
    pEvent: TW_MEMREF;
    twMessage: TW_UINT16;
  end;

  TW_PENDINGXFERS = packed record
    Count: TW_UINT16;
    EOJ: TW_UINT32;
  end;

  TDSMEntry = function (pOrigin: pTW_IDENTITY; pDest: pTW_IDENTITY;
    DG: TW_UINT32; DAT: TW_UINT32; MSG: TW_UINT32; pData: TW_MEMREF) : TW_UINT16; stdcall;

  THITWAIN = class(TDebug)
  private
    DS_ID: TW_IDENTITY;
    Bmp: PBitmap;

    procedure Init;
    procedure SetCapability(Capability:TW_UINT16; Value:TW_UINT16);
    procedure EnableDS(var _Data:TData);
    procedure DisableDS();
    procedure DispatchMessage(var m:TMsg);
  public
    _prop_ShowUI:boolean;
    _prop_ModalUI:boolean;
    _data_ShowUI:THI_Event;
    _data_ModalUI:THI_Event;
    _event_onScan:THI_Event;

    procedure _work_doSelectSource(var _Data:TData; Index:word);
    procedure _work_doScan(var _Data:TData; Index:word);
    procedure _var_Bitmap(var _Data:TData; Index:word);
    procedure _var_Width(var _Data:TData; Index:word);
    procedure _var_Height(var _Data:TData; Index:word);
  end;

var
  hDLL:cardinal; DSM:TDSMEntry; wc:TWndClass; hNotifyWnd:HWND;
  App_ID:TW_IDENTITY; stat:TW_STATUS; pLast:THITWAIN;

implementation

function CallDSM(pDS:pTW_IDENTITY;
  DG:TW_UINT32; DAT:TW_UINT16; MSG:TW_UINT16; pData:TW_MEMREF) : TW_UINT16;
begin
  if Assigned(DSM) then begin
    Result := DSM(@App_ID, pDS, DG, DAT, MSG, pData);
    if (Result<>TWRC_SUCCESS) and (MSG<>MSG_PROCESSEVENT) then
      DSM(@App_ID, pDS, DG_CONTROL, DAT_STATUS, MSG_GET, @stat);
  end else
    Result := TWRC_FAILURE;
end;

procedure THITWAIN.SetCapability(Capability:TW_UINT16; Value:TW_UINT16);
var cap:TW_CAPABILITY; p:pTW_ONEVALUE;
begin
  cap.Cap := Capability;
  cap.ConType := TWON_ONEVALUE;
  cap.hContainer := GlobalAlloc(GHND, sizeof(TW_ONEVALUE));
  p := GlobalLock(cap.hContainer);
  p^.ItemType := TWTY_UINT16;
  p^.Item := Value;
  GlobalUnlock(cap.hContainer);
  CallDSM(@DS_ID, DG_CONTROL, DAT_CAPABILITY, MSG_SET, @cap);
  GlobalFree(cap.hContainer);
end;

procedure THITWAIN.EnableDS;
var ui:TW_USERINTERFACE;
begin
  ui.ShowUI := ReadInteger(_Data,_data_ShowUI,THiInt(_prop_ShowUI));
  ui.ModalUI := ReadInteger(_Data,_data_ModalUI,THiInt(_prop_ModalUI));
  ui.hParent := ReadHandle;
  CallDSM(@DS_ID, DG_CONTROL, DAT_USERINTERFACE, MSG_ENABLEDS, @ui);
end;

procedure THITWAIN.DisableDS;
var ui:TW_USERINTERFACE;
begin
  ui.ShowUI := 0;
  ui.ModalUI := 0;
  ui.hParent := ReadHandle;
  CallDSM(@DS_ID, DG_CONTROL, DAT_USERINTERFACE, MSG_DISABLEDS, @ui);
end;

procedure THITWAIN.DispatchMessage;
var ev:TW_EVENT; rc:TW_UINT16;
    hBitmap:TW_HANDLE; pending:TW_PENDINGXFERS;
    sz:integer; pmem:pChar; stm:PStream;
begin
  ev.pEvent := @m; ev.twMessage := MSG_NULL;
  rc := CallDSM(@DS_ID, DG_CONTROL, DAT_EVENT, MSG_PROCESSEVENT, @ev);
  if rc<>TWRC_NOTDSEVENT then begin
    if ev.twMessage=MSG_CLOSEDSREQ then begin
      DisableDS;
      CallDSM(nil, DG_CONTROL, DAT_IDENTITY, MSG_CLOSEDS, @DS_ID);
    end else if ev.twMessage=MSG_XFERREADY then begin
      pending.Count := 1;
      while pending.Count>0 do begin
        CallDSM(@DS_ID, DG_IMAGE, DAT_IMAGENATIVEXFER, MSG_GET, @hBitmap);
        CallDSM(@DS_ID, DG_CONTROL, DAT_PENDINGXFERS, MSG_ENDXFER, @pending);
        sz := GlobalSize(hBitmap);
        pmem := GlobalLock(hBitmap);
        if (sz>0) and (pmem<>nil) then begin
          stm := NewMemoryStream;
          stm.Write(pmem^, sz);
          stm.Position := 0;
          bmp.LoadFromStreamEx(stm);
          stm.Free;
        end;
        GlobalUnlock(hBitmap);
        GlobalFree(hBitmap);
        _hi_OnEvent(_event_onScan, bmp);
      end;
      DisableDS;
      CallDSM(nil, DG_CONTROL, DAT_IDENTITY, MSG_CLOSEDS, @DS_ID);
    end;
  end;
end;

procedure THITWAIN.Init;
begin
  if Bmp = nil then begin
    Bmp := NewBitmap(0,0);
    CallDSM(nil, DG_CONTROL, DAT_IDENTITY, MSG_GETDEFAULT, @DS_ID);
  end;
end;

procedure THITWAIN._work_doSelectSource;
begin
  Init; pLast := Self;
  CallDSM(nil, DG_CONTROL, DAT_IDENTITY, MSG_USERSELECT, @DS_ID);
end;

procedure THITWAIN._work_doScan;
begin
  Init; pLast := Self;
  CallDSM(nil, DG_CONTROL, DAT_IDENTITY, MSG_OPENDS, @DS_ID);
  SetCapability(ICAP_XFERMECH, TWSX_NATIVE);
  EnableDS(_Data);
end;

procedure THITWAIN._var_Bitmap;
begin
  Init;
  dtBitmap(_Data,Bmp);
end;

procedure THITWAIN._var_Width;
begin
  Init;
  dtInteger(_Data,Bmp.Width);
end;

procedure THITWAIN._var_Height;
begin
  Init;
  dtInteger(_Data,Bmp.Height);
end;

function NotifyWindowProc(Wnd: HWnd; Msg, wParam, lParam: Integer): Integer; stdcall;
var m:TMsg;
begin
  m.hWnd := Wnd;
  m.Message := Msg;
  m.wParam := wParam;
  m.lParam := lParam;
  if pLast<>nil then pLast.DispatchMessage(m);
  Result := DefWindowProc(Wnd, Msg, wParam, lParam)
end;

initialization

  hDLL := LoadLibrary('TWAIN_32.DLL');

  if hDLL > 0 then begin
    DSM := GetProcAddress(hDLL,'DSM_Entry');

    wc.style := 0;
    wc.lpfnWndProc := @NotifyWindowProc;
    wc.cbClsExtra := 0;
    wc.cbWndExtra := 0;
    wc.hInstance := hInstance;
    wc.hIcon := 0;
    wc.hCursor := 0;
    wc.hbrBackground := 0;
    wc.lpszMenuName := nil;
    wc.lpszClassName := 'HIASM_TWAIN_NOTIFY';
    RegisterClass(wc);

    hNotifyWnd := CreateWindow(wc.lpszClassName, nil, 0, 0, 0, 0, 0,
      0, 0, hInstance, nil);

    with App_ID do begin
      Id := 0;
      with Version do begin
        MajorNum := 1;
        MinorNum := 1;
        Language := TWLG_RUSSIAN;
        Country := TWCY_USSR;
        Info := '1.0';
      end;
      ProtocolMajor := 1;
      ProtocolMinor := 8;
      SupportedGroups := DG_CONTROL+DG_IMAGE;
      Manufacturer := 'tsdima';
      ProductFamily := 'HiAsm';
      ProductName := 'HiAsm TWAIN control';
    end;
    CallDSM(nil, DG_CONTROL, DAT_PARENT, MSG_OPENDSM, @hNotifyWnd);
  end;

finalization

  if hDLL > 0 then begin
    CallDSM(nil, DG_CONTROL, DAT_PARENT, MSG_CLOSEDSM, @hNotifyWnd);
    DestroyWindow(hNotifyWnd);
    FreeLibrary(hDLL);
  end;

end.
