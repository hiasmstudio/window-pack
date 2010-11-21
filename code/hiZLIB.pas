unit hiZLIB;

interface

{$I share.inc}

uses Kol,Share,{$ifndef F_P}KolZLib,{$endif}Debug;

type
  THIZLIB = class(TDebug)
   private
    procedure _OnProgress(Sender: PStream);
   public
    _data_Stream:THI_Event;
    _event_onStream:THI_Event;

    procedure _work_doCompress(var _Data:TData; Index:word);
    procedure _work_doDeCompress(var _Data:TData; Index:word);
  end;

implementation

procedure THIZLIB._OnProgress;
begin

end;

{$ifdef F_P}

function CompressBuf(const InBuf: Pointer; InBytes: Integer; out OutBuf: Pointer; out OutBytes: Integer): Boolean; external 'zlib.dll';
function DecompressBuf(const InBuf: Pointer; InBytes: Integer; OutEstimate: Integer; out OutBuf: Pointer; out OutBytes: Integer): Boolean; external 'zlib.dll';

procedure THIZLIB._work_doCompress;
var
  st,dest:PStream;
  s:integer;
  out_buf:pointer;
begin
   st := ReadStream(_data,_data_Stream,nil);
   if st <> nil then
    begin
     dest := NewMemoryStream;
     s := st.Size;
     dest.Write(s,4);
     CompressBuf(st.Memory,st.Size,out_buf,s);
     dest.Write(out_buf^,s);
     dest.Position := 0;
     _hi_OnEvent(_event_onStream,dest);
     dest.Free;
    end;
end;

procedure THIZLIB._work_doDeCompress;
var st,dest,new_st:PStream;
    s,es:integer;
    out_buf:pointer;
begin
   st := ReadStream(_data,_data_Stream,nil);
   if (st <> nil) and (st.size >= 12) then
    begin
     st.Position := 0;
     st.Read(s,4);
     es := s;
     dest := NewMemoryStream;
     new_st:= NewMemoryStream;
     stream2stream(new_st,st,st.Size-4);
     DecompressBuf(new_st.Memory,new_st.Size,es,out_buf,s);
//     DecompressBuf(pointer(integer(st.Memory) + 4),st.Size-4,es,out_buf,s); // убрано
     dest.write(out_buf^,s);
     dest.Position := 0;
     _hi_OnEvent(_event_onStream,dest);
     dest.Free;
     new_st.free;
   end;
end;
{$else}
procedure THIZLIB._work_doCompress;
var
  st,dest,zip:PStream;
  s:integer;
begin
   st := ReadStream(_data,_data_Stream,nil);
   if st <> nil then
    begin
     dest := NewMemoryStream;
     st.Position := 0;

     s := st.Size;
     dest.Write(s,4);
     if not NewZLibCStream(zip,clMax,dest,nil) then
      ;
     Stream2Stream(zip,st,st.Size);
     zip.Free;
     dest.Position := 0;

     _hi_OnEvent(_event_onStream,dest);
     dest.Free;
    end;
end;

procedure THIZLIB._work_doDeCompress;
var st,dest,new_st:PStream;
    s:integer;
begin
   st := ReadStream(_data,_data_Stream,nil);
   if (st <> nil) and (st.size >= 12) then
    begin
     st.Position := 0;
     st.Read(s,4);
     dest := NewMemoryStream;
     if not NewZLibDStream(new_st,st,_OnProgress) then
       ;
     Stream2Stream(dest,new_st,s);
     new_st.Free;
     //dest := new_st;
     dest.Position := 0;

     _hi_OnEvent(_event_onStream,dest);
     dest.Free;
    end;
end;
{$endif}
end.
