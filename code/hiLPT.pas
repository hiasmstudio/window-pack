unit hiLPT;

interface

uses Kol,Share,Windows,IoPorts,Debug;

type
  TDataLPT = object(TDataIO)
    OldData,OldState:byte;
  end;

  THILPT = class(TDebug)
   private
    Prt:byte;
    procedure Init;
    procedure SetBit(var _Data:TData; X:byte);
   public
    _prop_Format:string;
    _event_onPE:THI_Event;
    _event_onERR:THI_Event;
    _event_onACK:THI_Event;
    _event_onSLCT:THI_Event;
    _event_onBUSY:THI_Event;
    _event_onStatus:THI_Event;
    _event_onDataIn:THI_Event;
    _data_Byte:THI_Event;
    _data_LPT:THI_Event;

    constructor Create;
    destructor Destroy; override;

    procedure _work_doD0(var _Data:TData; Index:word);
    procedure _work_doD1(var _Data:TData; Index:word);
    procedure _work_doD2(var _Data:TData; Index:word);
    procedure _work_doD3(var _Data:TData; Index:word);
    procedure _work_doD4(var _Data:TData; Index:word);
    procedure _work_doD5(var _Data:TData; Index:word);
    procedure _work_doD6(var _Data:TData; Index:word);
    procedure _work_doD7(var _Data:TData; Index:word);
    procedure _work_doPort(var _Data:TData; Index:word);
    procedure _work_doData(var _Data:TData; Index:word);
    procedure _work_doCheck(var _Data:TData; Index:word);
    procedure _work_doDataIn(var _Data:TData; Index:word);
    procedure _work_doControl(var _Data:TData; Index:word);

    procedure _var_Port0(var _Data:TData; Index:word);
    procedure _var_Port1(var _Data:TData; Index:word);
    procedure _var_Port2(var _Data:TData; Index:word);
    procedure _var_PortInfo(var _Data:TData; Index:word);

    property _prop_Port:byte write Prt;
  end;

implementation

const Lpt:array[1..3] of dword =($378,$278,$3BC);

var IO:array[0..3] of TDataLPT;

constructor THILPT.Create;
begin
  inherited;
  InitAdd(Init);
end;

procedure THILPT.Init;
var dt:TData;
begin
  inc(Prt);
  dt := _doData(Prt);
  _work_doPort(dt,0);
end;

procedure THILPT._work_doPort;
var P:byte;
begin
  P := ReadInteger(_Data,_data_LPT,0);
  IO[Prt].ClosePort;
  if P>3 then P := 0;
  if P=0 then exit;
  Prt := P;
  with IO[P] do
   begin
    OpenByte(Lpt[P],3);
    Write(2,0);
    OldData  := Read(0);
    OldState := Read(1);
   end;
end;

destructor THILPT.Destroy;
begin
  IO[Prt].ClosePort;
  inherited;
end;

procedure THILPT.SetBit;
begin
  with IO[Prt] do
   begin
    OldData := OldData or X;
    if not ReadBool(_Data) then
      OldData := OldData xor X;
    Write(0,OldData);
   end;
end;

procedure THILPT._work_doD0;
begin
  SetBit(_Data,$01);
end;

procedure THILPT._work_doD1;
begin
  SetBit(_Data,$02);
end;

procedure THILPT._work_doD2;
begin
  SetBit(_Data,$04);
end;

procedure THILPT._work_doD3;
begin
  SetBit(_Data,$08);
end;

procedure THILPT._work_doD4;
begin
  SetBit(_Data,$10);
end;

procedure THILPT._work_doD5;
begin
  SetBit(_Data,$20);
end;

procedure THILPT._work_doD6;
begin
  SetBit(_Data,$40);
end;

procedure THILPT._work_doD7;
begin
  SetBit(_Data,$80);
end;

procedure THILPT._work_doData;
begin
  with IO[Prt] do
   begin
    OldData := ReadInteger(_Data,_data_Byte,0);
    Write(0,OldData);
   end;
end;

procedure THILPT._work_doDataIn;
begin
  _hi_CreateEvent(_Data,@_event_onDataIn,integer(IO[Prt].read(0)));
end;

procedure THILPT._work_doCheck;
var w:integer;
begin
  with IO[Prt] do
   begin
    w := OldState;
    OldState := Read(1);
    w := (OldState xor w)*$100 + OldState;
    w := w shr 3; if (w and $100)<>0 then _hi_onEvent(_event_onERR, w and $01);
    w := w shr 1; if (w and $100)<>0 then _hi_onEvent(_event_onSLCT,w and $01);
    w := w shr 1; if (w and $100)<>0 then _hi_onEvent(_event_onPE,  w and $01);
    w := w shr 1; if (w and $100)<>0 then _hi_onEvent(_event_onACK, w and $01);
    w := w shr 1; if (w and $100)<>0 then _hi_onEvent(_event_onBUSY,w and $01);
    _hi_CreateEvent(_Data,@_event_onStatus,OldState);
   end;
end;

procedure THILPT._work_doControl;
begin
  IO[Prt].write(2,ReadInteger(_Data,_data_Byte,0) and $EF); //блокирую бит InterruptEnable
end;

procedure THILPT._var_PortInfo;
var i,j,b:byte;
    p,s:string;
    X:TDataIO;
begin
  j := 0;
  s := _prop_Format;
  with X do
   begin
    Clear;
    for i := 1 to 3 do
     begin
      p := 'none';
      OpenByte(Lpt[i],3);
      b := Read(2) xor $0F;
      Write(2,b);
      if b = Read(2)then
       begin
        inc(j);
        p := int2hex(Lpt[i],3);
       end;
      Replace(s,'%'+int2str(i),p);
      Write(2,b xor $0F);
      ClosePort;
     end;
   end;
  Replace(s,'%0',int2str(j));
  dtString(_Data,s);
end;

procedure THILPT._var_Port0;
begin
  dtInteger(_Data,IO[Prt].read(0));
end;

procedure THILPT._var_Port1;
begin
  dtInteger(_Data,IO[Prt].read(1));
end;

procedure THILPT._var_Port2;
begin
  dtInteger(_Data,IO[Prt].read(2));
end;

Initialization //FillChar(IO,3*sizeof(TDataLPT),0);
  IO[0].Clear;
  IO[1].Clear;
  IO[2].Clear;
  IO[3].Clear;

end.
