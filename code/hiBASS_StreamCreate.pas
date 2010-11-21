unit hiBASS_StreamCreate;

interface

uses Kol,Share,Debug,bass;

type
  THIBASS_StreamCreate = class(TDebug)
   private
    FHandle:HSTREAM;
   public
    _prop_Freq:integer;
    _prop_Channels:integer;
    _prop_Flags:cardinal;
    _prop_Name:string;
    _prop_DataType:byte;

    _data_Data:THI_Event;
    _event_onError:THI_Event;
    _event_onCreate:THI_Event;

    procedure _work_doCreate(var _Data:TData; Index:word);
    procedure _work_doDestroy(var _Data:TData; Index:word);
    function getInterfaceBassHandle:pointer;
    function ReadWord:word;
  end;

implementation

function THIBASS_StreamCreate.getInterfaceBassHandle:pointer;
begin
   Result := @FHandle;
end;

function MakeSine(handle: HSTREAM; buffer: Pointer; length: DWORD; user: DWORD): DWORD; stdcall;
var
  buf: ^WORD;
  i, len: Integer;
begin
  buf := buffer;
  len := length div 2;
  for i := 0 to len - 1 do 
   begin
     buf^ := THIBASS_StreamCreate(user).ReadWord;
     Inc(buf);
   end;
  Result := length;
end;

function THIBASS_StreamCreate.ReadWord;
var st:PStream;
begin
   if _prop_DataType = 0 then
     Result := ToIntegerEvent(_data_Data)
   else 
    begin
       st := ToStreamEvent(_data_Data);
       if st.position < st.size then
         st.read(Result, sizeof(Result))
       else result := 0;
    end;
end;

procedure THIBASS_StreamCreate._work_doCreate;
begin
  FHandle := BASS_StreamCreate(_prop_Freq, _prop_Channels, _prop_Flags, @MakeSine, self);
  if FHandle = 0 then
     _hi_onEvent(_event_onError, BASS_ErrorGetCode())
  else _hi_onEvent(_event_onCreate);
end;

procedure THIBASS_StreamCreate._work_doDestroy;
begin
  BASS_StreamFree(FHandle);
  FHandle := 0;
end;

end.
