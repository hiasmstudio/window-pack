unit hiPortIO;

interface

uses Kol,Share,Debug,IoPorts,Windows;

type
  THIPortIO = class(TDebug)
   private
    FID:PDataIO;
    procedure Init;
   public
    _prop_Port:integer;
    _prop_Count:integer;
    _prop_Index:integer;
    _prop_Type:procedure(P,Cnt:dword) of object;

    _data_Port:THI_Event;
    _data_Data:THI_Event;
    _data_Index:THI_Event;
    _event_onRead:THI_Event;

    constructor Create;
    destructor Destroy; override;
    procedure _work_doRead (var _Data:TData; Index:word);
    procedure _work_doWrite(var _Data:TData; Index:word);
    procedure _work_doPort (var _Data:TData; Index:word);
    procedure dtByte(P,Cnt:dword);
    procedure dtWord(P,Cnt:dword);
    procedure dtDWord(P,Cnt:dword);
  end;

implementation

var IO:PListEx;

constructor THIPortIO.Create;
begin
  inherited;
  InitAdd(Init);
end;

destructor THIPortIO.Destroy;
begin
  FID.ClosePort;
  inherited;
end;

procedure THIPortIO.Init;
var dt:TData;
begin
  dt := _doData(_prop_Port);
  _work_doPort(dt,0);
end;

procedure THIPortIO._work_doPort;
var i,P:integer;
begin
  P := ReadInteger(_Data,_data_Port,0);
  if assigned(FID) then FID.ClosePort;
  i := IO.IndexOf(Pointer(P));
  if i < 0 then
   begin
    New(FID);
    FID.Clear;
    IO.AddObj(Pointer(P),FID);
   end
  else FID := IO.ObjList.Items[i];
  _prop_Type(P,_prop_Count);
end;

procedure THIPortIO.dtByte;
begin
  FID.OpenByte(P,Cnt);
end;

procedure THIPortIO.dtWord;
begin
  FID.OpenWord(P,Cnt);
end;

procedure THIPortIO.dtDWord;
begin
  FID.OpenDWord(P,Cnt);
end;

procedure THIPortIO._work_doRead;
begin
  _hi_CreateEvent(_Data,@_event_onRead,integer(FID.Read(ReadInteger(_Data,_data_Index,_prop_Index))));
end;

procedure THIPortIO._work_doWrite;
var x:integer;
begin
  x := ReadInteger(_Data,_data_Data,0);
  FID.write(ReadInteger(_Data,_data_Index,_prop_Index),x);
end;

initialization IO := NewListEx;

finalization IO.Free;

end.
