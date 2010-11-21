unit hidbMySQL_Query;

interface

uses Kol,Share,Debug,MySQL;

type
  THIdbMySQL_Query = class(TDebug)
   private
    M:TMatrix;
    Arr:PArray;
    ms:TMySQL;
    oldy:integer;
    BlobStream: PStream;

    procedure MSet(x,y:integer; var Val:TData);
    function MGet(x,y:integer):TData;
    function MRows:integer;
    function MCols:integer;

    function _Get(Var Item:TData; var Val:TData):boolean;
    function _Count:integer;
   public
    _prop_BlobIndex:integer;
    _data_dbHandle:THI_Event;
    _data_QueryText:THI_Event;
    _data_BlobIndex:THI_Event;
    _event_onError:THI_Event;
    _event_onResult:THI_Event;

    constructor Create;
    destructor Destroy; override;
    procedure _work_doQuery(var _Data:TData; Index:word);
    procedure _work_doReadRow(var _Data:TData; Index:word);
    procedure _var_Rows(var _Data:TData; Index:word);
    procedure _var_Fields(var _Data:TData; Index:word);
    procedure _var_RCount(var _Data:TData; Index:word);
    procedure _var_FCount(var _Data:TData; Index:word);
	procedure _var_Blob(var _Data:TData; Index:word);
  end;

implementation

uses hidbMySQL;

constructor THIdbMySQL_Query.Create;
begin
   inherited Create;
   M._Set := MSet;
   M._Get := MGet;
   M._Rows := MRows;
   M._Cols := MCols;
   BlobStream := NewMemoryStream;
end;

destructor THIdbMySQL_Query.Destroy;
begin
   if Arr <> nil then dispose(Arr);
   BlobStream.Free;
   inherited; 
end;

function THIdbMySQL_Query.MRows;
begin
   if ms <> nil then
     Result := ms.RecordCount
   else Result := 0;
end;

function THIdbMySQL_Query.MCols;
begin
   if ms <> nil then
     Result := ms.FieldCount
   else Result := 0;
end;

procedure THIdbMySQL_Query.MSet;
begin
end;

function THIdbMySQL_Query.MGet;
begin
   dtString(Result,'');
   if( ms <> nil )then
    if(x >= 0)and(x < ms.FieldCount)and(y >= 0)and(y < ms.RecordCount)then
     begin
       if y <> oldy then
        begin
          if y < oldy then
           begin
            Ms.FindFirst;
            oldy := 0;
           end;
          repeat
            Ms.FindNext;
            inc(oldy);
          until y = oldy;
        end;
       dtString(Result,ms.Values[x]);
     end;
end;

procedure THIdbMySQL_Query._work_doQuery;
var
   dt:TData;
   text:string;
begin
   dt := ReadData(_Data,_data_dbHandle,nil);
   Ms := TMySQL(ToObject(dt));
   if _IsObject(dt,MySQL_GUID) then
    begin
     text := ReadString(_data,_data_QueryText,'');
     Ms.Query(text);
     Ms.FindFirst;
     OldY := 0;
     _hi_OnEvent(_event_onResult)
    end
   else _hi_OnEvent(_event_onError,0);
end;

procedure THIdbMySQL_Query._var_Rows;
begin
   dtMatrix(_Data,@M);
end;


function THIdbMySQL_Query._Get;
var 
    ind:integer;
begin
    ind := ToIntIndex(Item);
    if(ms <> nil)and(ind >= 0)and(ind < ms.FieldCount)then
       dtString(Val,ms.Fields[ind])
    else dtNull(Val);
    Result := _IsStr(Val);
end;

function THIdbMySQL_Query._Count;
begin
  if ms <> nil then
    Result := ms.FieldCount
  else Result := 0;
end;

procedure THIdbMySQL_Query._var_Fields;
begin
   if Arr = nil then
     Arr := CreateArray(nil,_Get,_Count,nil);
   dtArray(_Data,Arr);
end;

procedure THIdbMySQL_Query._var_RCount;
begin
   if ms <> nil then
    dtInteger(_Data,ms.RecordCount)
   else dtNull(_Data);
end;

procedure THIdbMySQL_Query._var_FCount;
begin
   if ms <> nil then
     dtInteger(_Data,ms.FieldCount)
   else dtNull(_Data);
end;

procedure THIdbMySQL_Query._var_Blob;
var 
   p: PChar;
begin
   if ms <> nil then
    begin
     p := PChar(ms.Blob[ReadInteger(_Data,_data_BlobIndex,_prop_BlobIndex)]);
     if p <> nil then
	  begin 
	   BlobStream.Size := 0;
       BlobStream.Write(p^,ms.BlobSize);
       BlobStream.Position := 0;
       dtStream(_Data,BlobStream);
	   p := nil;
	  end
	 else dtNull(_Data);
    end
   else dtNull(_Data);
end;

procedure THIdbMySQL_Query._work_doReadRow;
begin

end;

end.
