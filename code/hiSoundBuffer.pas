unit hiSoundBuffer;

interface

uses Windows,Kol,Share,Debug;

type
  THISoundBuffer = class(TDebug)
   private
    buf:PStream;
   public
    _prop_Size:integer;

    _data_SoundStream:THI_Event;
    _event_onAdd:THI_Event;

    constructor Create;
    destructor Destroy; override;
    procedure _work_doAdd(var _Data:TData; Index:word);
    procedure _var_Stream(var _Data:TData; Index:word);
    procedure _var_FullState(var _Data:TData; Index:word);
  end;

implementation

constructor THISoundBuffer.Create;
begin
   inherited;
   buf := NewMemoryStream; 
end;

destructor THISoundBuffer.Destroy;
begin
   buf.free;
   inherited;
end;

procedure THISoundBuffer._work_doAdd;
var st:PStream;
    p:integer;
begin
   st := ReadStream(_Data, _data_SoundStream);
   if st <> nil then
    begin
     if buf.position > _prop_Size then
      begin
        p := buf.size - buf.position; 
        CopyMemory(buf.memory, pointer( integer(buf.memory) + buf.position), p);
        buf.size := p; 
        buf.position := 0;
      end
     else if buf.size > _prop_Size*2 then
       exit;
     st.position := 0;
     p := buf.position;
     buf.position := buf.size; 
     Stream2Stream(buf, st, st.size);
     buf.position := p; 
    end;
end;

procedure THISoundBuffer._var_Stream;
begin
   dtStream(_Data, buf);
end;

procedure THISoundBuffer._var_FullState;
begin
  dtInteger(_Data, Round(((buf.size-buf.position)/(buf.size+1))*100));
end;

end.
