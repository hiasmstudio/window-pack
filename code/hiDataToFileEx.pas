unit hiDataToFileEx;

interface

uses Kol,Share,Debug;

type
  TdtProc = function (st:PStream; const Val:PData):TData of object;
  THIDataToFileEx = class(TDebug)
   private
   public
    _prop_Type:TdtProc;
    _prop_DataSize:integer;
    _prop_Signed:boolean;
    _prop_BigEndian:boolean;

    _data_Stream:THI_Event;
    _event_onGet:THI_Event;
    _event_onWrError:THI_Event;
    _event_onRdError:THI_Event;

    procedure Reverse(p:pointer);
    function dtInteger(st:PStream; const Val:PData):TData;
    function dtReal(st:PStream; const Val:PData):TData;
    function dtPString(st:PStream; const Val:PData):TData;
    function dtAnsiString(st:PStream; const Val:PData):TData;
    function dtLines(st:PStream; const Val:PData):TData;
    procedure _work_doPut(var _Data:TData; Index:word);
    procedure _work_doGet(var _Data:TData; Index:word);
    procedure _work_doPosition(var _Data:TData; Index:word);
    procedure _var_Data(var _Data:TData; Index:word);
    procedure _var_Position(var _Data:TData; Index:word);
    procedure _var_Size(var _Data:TData; Index:word);
  end;

implementation

type dw=cardinal;

procedure THIDataToFileEx._work_doPut;
var st:PStream;
begin
   st := ReadStream(_Data,_data_Stream);
   if (st <> nil) and not _isNull(_prop_Type(st,@_Data)) then exit;
   _hi_CreateEvent(_Data,@_event_onWrError);
end;

procedure THIDataToFileEx._work_doGet;
var st:PStream;
begin
   st := ReadStream(_Data,_data_Stream);
   if st <> nil then begin 
     _Data := _prop_Type(st,nil);
     if not _isNull(_Data) then begin 
        _hi_CreateEvent_(_Data,@_event_onGet);
        exit;
     end;
   end;
   _hi_CreateEvent(_Data,@_event_onRdError);
end;

procedure THIDataToFileEx._work_doPosition;
var st:PStream;i:integer;
begin
   st := ReadStream(_Data,_data_Stream);
   if st <> nil then begin
     i := ToInteger(_Data);
     if i<0 then i := 0; 
     st.Position := i;
   end;
end;

procedure THIDataToFileEx._var_Data;
var st:PStream;
begin
   st := ReadStream(_Data,_data_Stream);
   dtNull(_Data);
   if st <> nil then _Data := _prop_Type(st,nil);
end;

procedure THIDataToFileEx._var_Position;
var st:PStream;
begin
   st := ReadStream(_Data,_data_Stream);
   if st <> nil then Share.dtInteger(_Data,st.Position)
   else dtNull(_Data);
end;

procedure THIDataToFileEx._var_Size;
var st:PStream;
begin
   st := ReadStream(_Data,_data_Stream);
   if st <> nil then Share.dtInteger(_Data,st.Size)
   else dtNull(_Data);
end;

procedure THIDataToFileEx.Reverse;
var pb,pe:^byte; b:byte;
begin
   pb := p; pe := pb; inc(pe, _prop_DataSize-1); 
   while dw(pb) < dw(pe) do begin
      b := pb^; pb^ := pe^; pe^ := b;
      inc(pb); dec(pe);
   end;
end;

function THIDataToFileEx.dtInteger;
var i,j:int64;
begin
   dtNull(Result);
   if (_prop_DataSize >= 9)or(_prop_DataSize < 1) then exit;
   if val = nil then begin //чтение из Stream
      i := 0;
      if st.Read(i,_prop_DataSize)<>dw(_prop_DataSize) then exit;
      if _prop_BigEndian then Reverse(@i);
      if _prop_Signed then begin
         j := (int64(1) shl (_prop_DataSize*8));
         if ((j shr 1)and i) <> 0 then dec(i,j);
      end; 
      if (i <= MAXINT)and(i >= -MAXINT-1) then Share.dtInteger(Result,i)
      else Share.dtReal(Result, i);
   end else begin //запись в Stream
      if _prop_DataSize < 5 then i := ToInteger(val^)
      else i := Round(ToReal(val^));
      if _prop_BigEndian then Reverse(@i);
      if st.Write(i,_prop_DataSize)<>dw(_prop_DataSize) then exit;
      Share.dtInteger(Result,_prop_DataSize);
   end;
end;

function THIDataToFileEx.dtReal;
type rx = record 
   case byte of 
      0:(fl:single); 
      1:(db:real); 
      2:(ex:extended); 
   end;
var r:rx;
begin
   dtNull(Result);
   if not(_prop_DataSize in [4,8,10]) then exit; 
   if val = nil then begin //чтение из Stream
      if st.Read(r,_prop_DataSize)<>dw(_prop_DataSize) then exit;
      if _prop_BigEndian then Reverse(@r);
      case _prop_DataSize of
         4: Share.dtReal(Result,r.fl);
         8: Share.dtReal(Result,r.db);
       else Share.dtReal(Result,r.ex);
      end;
   end else begin //запись в Stream
      case _prop_DataSize of
         4: r.fl := ToReal(val^);
         8: r.db := ToReal(val^);
       else r.ex := ToReal(val^);
      end;
      if _prop_BigEndian then Reverse(@r);
      if st.Write(r,_prop_DataSize)<>dw(_prop_DataSize) then exit;
      Share.dtInteger(Result,_prop_DataSize);
   end;
end;

function THIDataToFileEx.dtPString;
var s:string; len:integer;
begin
   _prop_Signed := false;
   if val = nil then begin //чтение из Stream
      Result := dtInteger(st,nil);
      if _isNull(Result) then exit;
      len := ToInteger(Result);
      dtNull(Result);
      if len < 0 then exit;  
      SetLength(s,len);
      if st.Read(s[1],len)<>dw(len) then exit;
      Share.dtString(Result,s);
   end else begin //запись в Stream
      s := ToString(val^);
      len := Length(s);
      Share.dtInteger(Result,len);
      Result := dtInteger(st,@Result);
      if _isNull(Result) then exit;
      if st.Write(s[1],len)<>dw(len) then dtNull(Result);
   end;
end;

function THIDataToFileEx.dtAnsiString;
var S:string;
begin
   dtNull(Result);
   if val = nil then begin 
      if st.Position < st.Size then
         Share.dtString(Result,st.ReadStrZ);
   end else begin 
      S := ToString(val^);
      if st.WriteStrZ(S)=dw(length(S)+1) then 
         Share.dtInteger(Result,length(S)+1);
   end;
end;

function THIDataToFileEx.dtLines;
var S:string;
begin
   dtNull(Result);
   if val = nil then begin 
      if st.Position < st.Size then
         Share.dtString(Result,st.ReadStr);
   end else begin 
      S := ToString(val^);
      if st.WriteStr(S+#13#10)=dw(length(S)+2) then 
         Share.dtInteger(Result,length(S)+2);
   end;
end;

end.
