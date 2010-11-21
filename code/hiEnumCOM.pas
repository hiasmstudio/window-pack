unit hiEnumCOM;

interface

uses Kol,Share,Windows,Debug;

type
  THIEnumCOM = class(TDebug)
   private
   public
    _prop_OutType: byte;
    _event_onEnumPorts: THI_Event;

    procedure _work_doEnumPorts0(var _Data:TData; Index:word);
    procedure _work_doEnumPorts1(var _Data:TData; Index:word);
    
  end;

implementation

procedure THIEnumCOM._work_doEnumPorts0;
var
  fn: string;
  i: integer;
  sFile: THandle;
begin
  for i := 1 to 256 do
  begin
    fn := '\\.\Com' + Int2Str(i);
    sFile := CreateFile(PChar(fn), GENERIC_READ or GENERIC_WRITE, 0, nil,
                        OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
    if sFile = INVALID_HANDLE_VALUE then Continue;
    _hi_onEvent(_event_onEnumPorts, i);
    CloseHandle(sFile);  
  end;   
end;

procedure THIEnumCOM._work_doEnumPorts1;
var
  fn: string;
  i: integer;
  sFile: THandle;
begin
  for i := 1 to 256 do
  begin
    fn := '\\.\Com' + Int2Str(i);
    sFile := CreateFile(PChar(fn), GENERIC_READ or GENERIC_WRITE, 0, nil,
                        OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
    if sFile = INVALID_HANDLE_VALUE then Continue;
    _hi_onEvent(_event_onEnumPorts, 'Com' + int2str(i));
    CloseHandle(sFile);  
  end;   
end;

end.