unit KOLMHToolTip;

interface

uses Windows, KOL, Messages;

{$I share.inc}

const

  TTS_ALWAYSTIP = $01;
  TTS_NOPREFIX  = $02;
  TTS_BALLOON   = $40;

type

  TFE = (eTextColor, eBkColor, eAPDelay, eRDelay, eIDelay);

  TFI = record
    FE: set of TFE;
    Colors: array[0..1] of TColor;
    Delays: array[0..3] of Integer;
  end;

  {$ifdef F_P}
  TMHToolTipManager = class;
  PMHToolTipManager = TMHToolTipManager;
  TKOLMHToolTipManager = PMHToolTipManager;

  TMHToolTip = class;
  PMHToolTip = TMHToolTip;
  TKOLMHToolTip = PMHToolTip;

  TMHHint = class;
  PMHHint = TMHHint;
  TKOLMHHint = PMHHint;

  TMHToolTipManager = class(TObj)
  {$else}
  PMHToolTipManager = ^TMHToolTipManager;
  TKOLMHToolTipManager = PMHToolTipManager;

  PMHToolTip = ^TMHToolTip;
  TKOLMHToolTip = PMHToolTip;

  PMHHint = ^TMHHint;
  TKOLMHHint = PMHHint;

  TMHToolTipManager = object(TObj)
  {$endif}
  protected

  public
    HintStyle: Byte;
    TTT: array of PMHToolTip;
//    destructor Destroy; virtual;
    destructor Destroy; {$ifndef F_P}virtual{$else}override{$endif};
    function AddTip: Integer;
    function FindNeed(FI: TFI): PMHToolTip;
    function CreateNeed(FI: TFI): PMHToolTip;
  end;

  {$ifdef F_P}
  TMHHint = class(TObj)
  {$else}
  TMHHint = object(TObj)
  {$endif}
  private
    function GetManager:PMHToolTipManager;
    // Spec
    procedure ProcBegin(var TI: TToolInfo);
    procedure ProcEnd(var TI: TToolInfo);
    procedure ReConnect(FI: TFI);
    procedure MoveTool(T1: PMHToolTip);
    procedure CreateToolTip;
    function GetFI: TFI;

    // Group
    function GetDelay(const Index: Integer): Integer;
    procedure SetDelay(const Index: Integer; const Value: Integer);
    function GetColor(const Index: Integer): TColor;
    procedure SetColor(const Index: Integer; const Value: TColor);

    // Local
    procedure SetText(Value: string);
    function GetText: string;
  public
    ToolTip: PMHToolTip;
    HasTool: Boolean;
    Parent: PControl;
    HintStyle: byte;
//    destructor Destroy; virtual;
    destructor Destroy; {$ifndef F_P}virtual{$else}override{$endif};
    procedure Pop;

    property AutoPopDelay: Integer index 2 read GetDelay write SetDelay;
    property InitialDelay: Integer index 3 read GetDelay write SetDelay;
    property ReshowDelay: Integer index 1 read GetDelay write SetDelay;

    property TextColor: TColor index 1 read GetColor write SetColor;
    property BkColor: TColor index 0 read GetColor write SetColor;
    property Text: string read GetText write SetText;
  end;

  {$ifdef F_P}
  TMHToolTip = class(TObj)
  {$else}
  TMHToolTip = object(TObj)
  {$endif}
  private
    fHandle: THandle;
    Count: Integer;

    function GetDelay(const Index: Integer): Integer;
    procedure SetDelay(const Index: Integer; const Value: Integer);
    function GetColor(const Index: Integer): TColor;
    procedure SetColor(const Index: Integer; const Value: TColor);
    function GetMaxWidth: Integer;
    procedure SetMaxWidth(const Value: Integer);
    function GetMargin: TRect;
    procedure SetMargin(const Value: TRect);
    function GetActivate: Boolean;
    procedure SetActivate(const Value: Boolean);
  protected

  public
//    destructor Destroy; virtual;
    destructor Destroy; {$ifndef F_P}virtual{$else}override{$endif};
    procedure Pop;
    procedure Update;

    property AutoPopDelay: Integer index 2 read GetDelay write SetDelay;
    property InitialDelay: Integer index 3 read GetDelay write SetDelay;
    property ReshowDelay: Integer index 1 read GetDelay write SetDelay;

    property TextColor: TColor index 1 read GetColor write SetColor;
    property BkColor: TColor index 0 read GetColor write SetColor;

    property MaxWidth: Integer read GetMaxWidth write SetMaxWidth;

    property Margin: TRect read GetMargin write SetMargin;
    property Activate: Boolean read GetActivate write SetActivate;
    property Handle: THandle read fHandle;
  end;

const
  Dummy = 0;


function NewHint(A: PControl): PMHHint;
function NewManager(HintStyle:byte): PMHToolTipManager;
function NewMHToolTip(AParent: PControl; HintStyle:byte): PMHToolTip;

var
  Manager: PMHToolTipManager;

implementation

const
  Dummy1 = 1;

  TTDT_AUTOMATIC = 0;
  TTDT_RESHOW = 1;
  TTDT_AUTOPOP = 2;
  TTDT_INITIAL = 3;

function WndProcMHDateTimePicker(Sender: PControl; var Msg: TMsg; var Rslt: Integer): Boolean;
begin
  Result := False;
end;

function NewMHToolTip(AParent: PControl; HintStyle:byte): PMHToolTip;
const
  CS_DROPSHADOW = $00020000;
var
  Style: dword;
begin
  DoInitCommonControls(ICC_BAR_CLASSES);
  {$ifdef F_P}
  Result := PMHToolTip.Create;
  {$else}
  New(Result, Create);
  {$endif}
  Style := TTS_NOPREFIX or TTS_ALWAYSTIP or WS_POPUP;

  if HintStyle = 0 then Style := Style or TTS_BALLOON;

  Result.fHandle := CreateWindowEx({WS_EX_TOOLWINDOW} WS_EX_TOPMOST, TOOLTIPS_CLASS, '', Style, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, AParent.Handle, 0, HInstance, nil);
  SetWindowPos(Result.fHandle, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE);
end;

function TMHToolTip.GetDelay(const Index: Integer): Integer;
begin
  Result := SendMessage(fHandle, TTM_GETDELAYTIME, Index, 0);
end;


procedure TMHToolTip.SetDelay(const Index, Value: Integer);
begin
  SendMessage(handle, TTM_SETDELAYTIME, Index, MAKELONG(Value, 0));
end;


function TMHToolTip.GetColor(const Index: Integer): TColor;
begin
  Result := SendMessage(handle, TTM_GETTIPBKCOLOR + Index, 0, 0);
end;

procedure TMHToolTip.SetColor(const Index: Integer; const Value: TColor);
begin
  SendMessage(handle, TTM_SETTIPBKCOLOR + Index, Value, 0);
end;

function TMHToolTip.GetMaxWidth: Integer;
begin
  Result := SendMessage(fHandle, TTM_GETMAXTIPWIDTH, 0, 0);
end;

procedure TMHToolTip.SetMaxWidth(const Value: Integer);
begin
  SendMessage(fHandle, TTM_SETMAXTIPWIDTH, 0, Value);
end;

function TMHToolTip.GetMargin: TRect;
begin
  SendMessage(fHandle, TTM_GETMARGIN, 0, DWord(@Result));
end;

procedure TMHToolTip.SetMargin(const Value: TRect);
begin
  SendMessage(fHandle, TTM_SETMARGIN, 0, DWord(@Value));
end;

function TMHToolTip.GetActivate: Boolean;
begin
  // ??????
  Result := False;
end;

procedure TMHToolTip.SetActivate(const Value: Boolean);
begin
  SendMessage(fHandle, TTM_ACTIVATE, DWord(Value), 0);
end;

procedure TMHToolTip.Pop;
begin
  SendMessage(fHandle, TTM_POP, 0, 0);
end;

procedure TMHToolTip.Update;
begin
  inherited; // ???
  SendMessage(fHandle, TTM_UPDATE, 0, 0);
end;

function NewHint(A: PControl): PMHHint;
begin
  {$ifdef F_P}
  Result := PMHHint.Create;
  {$else}
  New(Result, Create);
  {$endif}

  Result.Parent := A;
  Result.ToolTip := nil; // ???
  Result.HasTool := False; // ???
end;

function NewManager(HintStyle:byte): PMHToolTipManager;
begin
  {$ifdef F_P}
  Result := PMHToolTipManager.Create;
  {$else}
  New(Result, Create);
  {$endif}
  Result.HintStyle := HintStyle;
end;

{ TMHHint }

function TMHHint.GetDelay(const Index: Integer): Integer;
begin
//  CreateToolTip;
  if Assigned(ToolTip) then
    Result := ToolTip.GetDelay(Index)
  else Result := 0;
end;

function TMHHint.GetFI: TFI;
begin
  /// !!! DANGER-WITH !!!
  {$ifdef F_P}
  with Result, ToolTip do
  {$else}
  with Result, ToolTip^ do
  {$endif}
  begin
    FE := FE + [eTextColor];
    Colors[1] := TextColor;

    FE := FE + [eBkColor];
    Colors[0] := BkColor;

    FE := FE + [eAPDelay];
    Delays[TTDT_AUTOPOP] := AutoPopDelay;

    FE := FE + [eRDelay];
    Delays[TTDT_RESHOW] := ReshowDelay;

    FE := FE + [eIDelay];
    Delays[TTDT_INITIAL] := InitialDelay;
  end;
end;

procedure TMHHint.ReConnect(FI: TFI);
var
  TMP: PMHToolTip;
begin
  {$ifdef F_P}
  with GetManager do
  {$else}
  with GetManager^ do
  {$endif}
  begin
    TMP := FindNeed(FI);
    if not Assigned(TMP) then
      TMP := CreateNeed(FI);
    if Assigned(ToolTip) and HasTool then
      MoveTool(TMP);
    ToolTip := TMP;
  end;
end;

procedure TMHHint.MoveTool(T1: PMHToolTip);
var
  TI: TToolInfo;
  TextL: array[0..255] of Char;
begin
  if T1 = ToolTip then
    Exit;
  with TI do
  begin
    cbSize := SizeOf(TI);
    hWnd := Parent.GetWindowHandle;
    uId := Parent.GetWindowHandle;
    lpszText := @TextL;
  end;

  SendMessage(ToolTip.handle, TTM_GETTOOLINFO, 0, DWord(@TI));
  SendMessage(ToolTip.handle, TTM_DELTOOL, 0, DWORD(@TI));
  ToolTip.Count := ToolTip.Count - 1;
  SendMessage(T1.handle, TTM_ADDTOOL, 0, DWORD(@TI));
  T1.Count := T1.Count - 1;

  HasTool := True;
end;

procedure TMHHint.SetColor(const Index: Integer; const Value: TColor);
var
  FI: TFI;
begin
  if Assigned(ToolTip) then
  begin
    if ToolTip.Count + Byte(not HasTool) = 1 then
    begin
      ToolTip.SetColor(Index, Value);
      Exit;
    end;
    FI := GetFI;
  end;

  case Index of
    0: FI.FE := FI.FE + [eBkColor];
    1: FI.FE := FI.FE + [eTextColor];
  end;
  FI.Colors[Index] := Value;

  ReConnect(FI);
end;

function TMHHint.GetColor(const Index: Integer): TColor;
begin
  if Assigned(ToolTip) then
    Result := ToolTip.GetColor(Index)
  else Result := 0;
end;

procedure TMHHint.SetDelay(const Index, Value: Integer);
var
  FI: TFI;
begin
  if Assigned(ToolTip) then
  begin
    if ToolTip.Count + Byte(not HasTool) = 1 then
    begin
      ToolTip.SetDelay(Index, Value);
      Exit;
    end;
    FI := GetFI;
  end;

  case Index of
    TTDT_AUTOPOP: FI.FE := FI.FE + [eAPDelay]; // Spec
    TTDT_INITIAL: FI.FE := FI.FE + [eIDelay]; // Spec
    TTDT_RESHOW: FI.FE := FI.FE + [eRDelay]; // Spec
  end; //case

  FI.Delays[Index] := Value; //Spec

  ReConnect(FI);
end;

procedure TMHHint.SetText(Value: string);
var
  TI: TToolInfo;
begin
  FillChar(TI,Sizeof(TI),0);
  ProcBegin(TI);

  with TI do
  begin
    uFlags := TTF_SUBCLASS; // Spec
    rect := Parent.ClientRect; // Spec
    lpszText := PChar(Value); // Spec
  end;

  procEnd(TI);

  if HasTool then
  begin
    TI.lpszText := PChar(Value);
    SendMessage(ToolTip.handle, TTM_SETTOOLINFO, 0, DWord(@TI));
  end;

end;

function TMHToolTipManager.AddTip: Integer;
begin
  SetLength(TTT, Length(TTT) + 1);
  TTT[Length(TTT) - 1] := NewMHToolTip(Applet,HintStyle);
  Result := Length(TTT) - 1;
end;

function TMHToolTipManager.FindNeed(FI: TFI): PMHToolTip;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to length(TTT) - 1 do
  begin
    if ((eTextColor in FI.FE) and (not (FI.Colors[1] = TTT[i].TextColor))) or
      ((eBkColor in FI.FE) and (not (FI.Colors[0] = TTT[i].BkColor))) or
      ((eAPDelay in FI.FE) and (not (FI.Delays[TTDT_AUTOPOP] = TTT[i].AutoPopDelay))) or
      ((eIDelay in FI.FE) and (not (FI.Delays[TTDT_INITIAL] = TTT[i].InitialDelay))) or
      ((eRDelay in FI.FE) and (not (FI.Delays[TTDT_RESHOW] = TTT[i].ReshowDelay))) then
      Continue;
    Result := TTT[i];
    Break;
  end;
end;

function TMHToolTipManager.CreateNeed(FI: TFI): PMHToolTip;

begin
  Setlength(TTT, length(TTT) + 1);
  TTT[length(TTT) - 1] := NewMHToolTip(Applet,HintStyle);
  {$ifdef F_P}
  with TTT[length(TTT) - 1] do
  {$else}
  with TTT[length(TTT) - 1]^ do
  {$endif}
  begin
    if (eTextColor in FI.FE) then
      TextColor := FI.Colors[1];
    if (eBkColor in FI.FE) then
      BkColor := FI.Colors[0];
    if (eAPDelay in FI.FE) then
      AutoPopDelay := FI.Delays[TTDT_AUTOPOP];
    if (eIDelay in FI.FE) then
      InitialDelay := FI.Delays[TTDT_INITIAL];
    if (eRDelay in FI.FE) then
      ReshowDelay := FI.Delays[TTDT_RESHOW];
  end;
  Result := TTT[length(TTT) - 1];
end;

procedure TMHHint.ProcBegin(var TI: TToolInfo);
begin
  CreateToolTip;

  with TI do
  begin
    cbSize := SizeOf(TI);
    hWnd := Parent.GetWindowHandle;
    uId := Parent.GetWindowHandle;
    hInst := 0;
  end;
end;

procedure TMHHint.ProcEnd(var TI: TToolInfo);
var
  TextLine: array[0..255] of Char;
begin
  if not HasTool then
  begin
    SendMessage(ToolTip.handle, TTM_ADDTOOL, 0, DWORD(@TI));
    HasTool := True;
    ToolTip.Count := ToolTip.Count + 1;
  end
  else
  begin
    with TI do
    begin
      lpszText := @TextLine;
    end;
    SendMessage(ToolTip.handle, TTM_GETTOOLINFO, 0, DWord(@TI));
  end;
end;

destructor TMHToolTipManager.Destroy;
var
  i: Integer;
begin
  for i := 0 to Length(TTT) - 1 do
    TTT[i].Free;
  SetLength(TTT, 0);
  inherited;
end;

procedure TMHHint.Pop;
begin
  if Assigned(ToolTip) and (HasTool) then
  begin // ^^^^^^^^^^^^ ???
//  CreateToolTip;
    ToolTip.Pop;
  end;
end;

destructor TMHHint.Destroy;
var
  TI: TToolInfo;
begin
  with TI do
  begin
    cbSize := SizeOf(TI);
    hWnd := Parent.GetWindowHandle;
    uId := Parent.GetWindowHandle;
  end;

  SendMessage(ToolTip.handle, TTM_DELTOOL, 0, DWORD(@TI));
  ToolTip.Count := ToolTip.Count - 1;
  Manager.Free;
  inherited;
end;

destructor TMHToolTip.Destroy;
begin
  inherited;
end;

procedure TMHHint.CreateToolTip;
begin
  if not Assigned(ToolTip) then
  begin
    if Length(GetManager.TTT) = 0 then
      GetManager.AddTip;
    ToolTip := GetManager.TTT[0];
  end;
end;

function TMHHint.GetText: string;
var
  TI: TToolInfo;
  TextL: array[0..255] of Char;
begin
  if Assigned(ToolTip) and (HasTool) then
  begin
    // !!!
    with TI do
    begin
    // ????
//      FillChar(TI, SizeOf(TI), 0);
      cbSize := SizeOf(TI);
      hWnd := Parent.GetWindowHandle;
      uId := Parent.GetWindowHandle;
      lpszText := @TextL;
    end;
    SendMessage(ToolTip.handle, TTM_GETTOOLINFO, 0, DWord(@TI));
    Result := TextL; //TI.lpszText;// := PChar(Value);
  end;
end;

function TMHHint.GetManager: PMHToolTipManager;
begin
  if Manager=nil then
    Manager:=NewManager(HintStyle);
  Result:=Manager;
end;

end.
