unit hiUpDown; { Компонент UpDown (Счетчик) ver 2.00 }

interface

uses Windows,Messages,Kol,Share,Win;

{$I share.inc}

type
   TUpDownDirection = (updNone, updUp, updDown);
   TOnChangingEx = procedure(Sender: PControl; var Allow: Boolean; NewValue: SmallInt; Direction: TUpDownDirection) of object;

   TUDACCEL = packed record
      nSec: UINT;
      nInc: integer;
   end;

   THIUpDown = class(THIWin)
   private
      acc: TUDAccel;
      FOrientation:byte;
      FOnChangingEx: TOnChangingEx;
      FMin: Integer;
      FMax: Integer;
      procedure SetPosition(const Value: Integer);
      function  GetPosition: Integer;
      procedure SetOnChangingEx(const Value: TOnChangingEx);
   protected
      property Pos: Integer read GetPosition write SetPosition;
      property OnChangingEx: TOnChangingEx read FOnChangingEx write SetOnChangingEx;
   public
      _prop_Position:integer;
      _event_onPosition:THI_Event;

      property _prop_Min: Integer write FMin;
      property _prop_Max: Integer write FMax;
      property _prop_Step:integer write acc.nInc;
      property _prop_Kind:byte write FOrientation;

      procedure Init; override;
      procedure _work_doPosition(var _Data:TData; Index:word);
      procedure _work_doMax(var _Data:TData; Index:word);
      procedure _work_doMin(var _Data:TData; Index:word);
      procedure _var_Position(var _Data:TData; Index:word);
   end;

implementation

var UD_GUID:integer=0;

const
   UDN_FIRST = 0 - 721;

   UD_MAXVAL = $7FFF;
   UD_MINVAL = -UD_MAXVAL;

   UDS_WRAP        = $0001;
   UDS_SETBUDDYINT = $0002;
   UDS_ALIGNRIGHT  = $0004;
   UDS_ALIGNLEFT   = $0008;
   UDS_AUTOBUDDY   = $0010;
   UDS_ARROWKEYS   = $0020;
   UDS_HORZ        = $0040;
   UDS_NOTHOUSANDS = $0080;
   UDS_HOTTRACK    = $0100;

   UDM_SETRANGE    = WM_USER + 101;
   UDM_GETRANGE    = WM_USER + 102;
   UDM_SETPOS      = WM_USER + 103;
   UDM_GETPOS      = WM_USER + 104;
   UDM_SETBUDDY    = WM_USER + 105;
   UDM_GETBUDDY    = WM_USER + 106;
   UDM_SETACCEL    = WM_USER + 107;
   UDM_GETACCEL    = WM_USER + 108;
   UDM_SETBASE     = WM_USER + 109;
   UDM_GETBASE     = WM_USER + 110;
   UDM_SETRANGE32  = WM_USER + 111;
   UDM_GETRANGE32  = WM_USER + 112;
   UDM_SETPOS32    = WM_USER + 113;
   UDM_GETPOS32    = WM_USER + 114;
   UDN_DELTAPOS    = UDN_FIRST - 1;

type
   NM_UPDOWN = packed record
      hdr: TNMHDR;
      iPos: Integer;
      iDelta: Integer;
   end;
   TNMUpDown = NM_UPDOWN;
   PNMUpDown = ^TNMUpDown;

function WndProcUpDown(Sender: PControl; var Msg: TMsg; var Rslt: Integer): Boolean;
var   UD: THIUpDown;
      NMUpDown: PNMUpDown;
      Allow: Boolean;
      Direction: TUpDownDirection;
      NewValue: Integer;
begin
   Result := False;
   if (Msg.message<>WM_NOTIFY)or(Msg.lParam=0) then exit;
   NMUpDown := PNMUpDown(Msg.lParam);
   if NMUpDown.hdr.code<>UDN_DELTAPOS then exit;
   UD := THIUpDown(Sender.tag);
   if (UD = nil)or(UD.Guid <> UD_GUID) then exit;
   with UD do begin
      if @FOnChangingEx=nil then exit;
      if NMUpDown.iDelta = 0 then Direction := updNone
      else if NMUpDown.iDelta < 0 then Direction := updDown
      else Direction := updUp;
      NewValue := NMUpDown.iPos + NMUpDown.iDelta;
      if NewValue > FMax then NewValue := FMax;
      if NewValue < FMin then NewValue := FMin;
      Allow := True;
      FOnChangingEx(Sender, Allow, NewValue, Direction);
      Rslt := ord(not Allow);
      Result := true;
   end;
end;

function WndProcUpDownParent(Sender: PControl; var Msg: TMsg; var Rslt: Integer): Boolean;
var   UD: THIUpDown;
begin
   Result := FALSE;
   if ((Msg.message<>WM_HSCROLL)and(Msg.message<>WM_VSCROLL))or(Msg.lParam=0) then exit;
   Sender := Pointer( GetProp( Msg.lParam, ID_SELF ) );
   if Sender = nil then exit;
   UD := THIUpDown(Sender.Tag);
   if (UD = nil)or(UD.Guid <> UD_GUID) then exit;
   with UD do if LoWord(Msg.wParam) <> SB_ENDSCROLL then
      _hi_onEvent(_event_onPosition, Pos);
end;

procedure THIUpDown.Init;
var  stl:dword;
begin
   GenGuid(UD_GUID);
   Guid := UD_GUID;
   DoInitCommonControls(ICC_UPDOWN_CLASS);
   stl := WS_CHILD or WS_VISIBLE or UDS_SETBUDDYINT;
   if FOrientation=0 then inc(stl,UDS_HORZ);
   Control := _NewCommonControl(FParent, 'msctls_updown32',  stl, False, nil);
   Control.GetWindowHandle;
   inherited;
   Control.tag := dword(Self);
   //Control.AttachProc(WndProcUpDown);
   FParent.AttachProc(WndProcUpDownParent);
   Control.Perform(UDM_SETRANGE32, FMIN, FMAX);
   Pos := _prop_Position;
   Control.Perform(UDM_SETACCEL, 1, LongInt(@acc));
end;

procedure THIUpDown._work_doPosition;
begin
   Pos := ToInteger(_Data);
   _hi_CreateEvent(_Data,@_event_onPosition,integer(Pos));
end;

procedure THIUpDown._work_doMax;
begin
   FMax := ToInteger(_Data);
   Control.Perform(UDM_SETRANGE32, FMIN, FMAX);
end;

procedure THIUpDown._work_doMin;
begin
   FMin := ToInteger(_Data);
   Control.Perform(UDM_SETRANGE32, FMIN, FMAX);
end;

procedure THIUpDown._var_Position;
begin
   dtInteger(_Data, Pos);
end;

procedure THIUpDown.SetPosition;
begin
   Control.Perform(UDM_SETPOS32, 0, Value);
end;

function THIUpDown.GetPosition;
begin
   Result := Control.Perform(UDM_GETPOS32, 0, 0);
end;

procedure THIUpDown.SetOnChangingEx;
begin
   FOnChangingEx := Value;
   Control.AttachProc(WndProcUpDown);
end;

end.
