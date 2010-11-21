unit hiDataToFile;

interface

uses Kol,Share,Debug;

type
  TdtProc = function (st:PStream; const Val:PData):TData of object;
  THIDataToFile = class(TDebug)
   private
   public
    _prop_Type:TdtProc;
    _event_onGet:THI_Event;
    _data_Stream:THI_Event;

    function dtByte(st:PStream; const Val:PData):TData;
    function dtWord(st:PStream; const Val:PData):TData;
    function dtCardinal(st:PStream; const Val:PData):TData;
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
  end;

implementation

procedure THIDataToFile._work_doPut;
var st:PStream;
begin
   st := ToStreamEvent(_data_Stream);
   if st <> nil then
     _prop_Type(st,@_Data);
end;

procedure THIDataToFile._var_Data;
var st:PStream;
begin
   st := ToStreamEvent(_data_Stream);
   if st <> nil then
     _Data := _prop_Type(st,nil)
   else dtNull(_Data);
end;

procedure THIDataToFile._var_Position;
var st:PStream;
begin
   st := ToStreamEvent(_data_Stream);
   if st <> nil then
     share.dtInteger(_Data,st.Position)
   else dtNull(_Data);
end;

procedure THIDataToFile._work_doPosition;
var st:PStream;
begin
   st := ToStreamEvent(_data_Stream);
   if st <> nil then
     st.Position := ToInteger(_Data);
end;

procedure THIDataToFile._work_doGet;
var st:PStream;
begin
   st := ToStreamEvent(_data_Stream);
   if st <> nil then
     _hi_CreateEvent(_Data,@_event_onGet,_prop_Type(st,nil));
end;

function THIDataToFile.dtByte;
var b:byte;
begin
   if val = nil then
    begin
      st.read(b,1);
      Share.dtInteger(Result,b);
    end
   else
    begin
      b := ToInteger(val^);
      st.Write(b,1);
    end;
end;

function THIDataToFile.dtWord;
var w:word;
begin
   if val = nil then
    begin
      st.read(w,2);
      Share.dtInteger(Result, w);
    end
   else
    begin
      w := ToInteger(val^);
      st.Write(w,2);
    end;
end;

function THIDataToFile.dtCardinal;
var c:cardinal;
begin
   if val = nil then
    begin
      st.read(c,4);
      Share.dtInteger(Result,c);
    end
   else
    begin
      c := ToInteger(val^);
      st.Write(c,4);
    end;
end;

function THIDataToFile.dtInteger;
var i:integer;
begin
   if val = nil then
    begin
      st.read(i,4);
      Share.dtInteger(Result, i);
    end
   else
    begin
      i := ToInteger(val^);
      st.Write(i,4);
    end;
end;

function THIDataToFile.dtReal;
var r:real;
begin
   if val = nil then
    begin
      st.read(r,sizeof(real));
      Share.dtReal(Result,r);
    end
   else
    begin
      r := ToReal(val^);
      st.Write(r,sizeof(real));
    end;
end;

function THIDataToFile.dtPString;
var
  s:string;
  len:word;
begin
   if val = nil then
    begin
      st.read(len,2);
      SetLength(s,len);
      if len > 0 then
       st.Read(s[1],len);
      Share.dtString(Result,s);
    end
   else
    begin
      s := ToString(val^);
      len := Length(s);
      st.Write(len,2);
      st.Write(s[1],len);
    end;
end;

function THIDataToFile.dtAnsiString;
begin
   if val = nil then
     Share.dtString(Result,st.ReadStrZ)
   else  st.WriteStrZ(ToString(val^));
end;

function THIDataToFile.dtLines;
begin
   if val = nil then
     Share.dtString(Result,st.ReadStr)
   else  st.WriteStr(ToString(val^)+#13#10);
end;

end.
