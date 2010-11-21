unit hidbMySQL_Exec;

interface

uses Kol,Share,Debug,MySQL;

type
  THIdbMySQL_Exec = class(TDebug)
   private
    ms:TMySQL;
    Buffer:PChar;
    BufferSize:Integer;
	_BlobData:PStream;
    FText:string;
	FIndex:integer;
   public
    _data_dbHandle:THI_Event;
    _data_QueryText:THI_Event;
    _data_BlobData:THI_Event;
    _event_onError:THI_Event;
    _event_onResult:THI_Event;
    _event_onGetBlob:THI_Event;
    _prop_UseName:boolean;

    constructor Create;
    destructor Destroy; override;
    procedure _work_doExec(var _Data:TData; Index:word);
  end;

implementation

uses hidbMySQL;

constructor THIdbMySQL_Exec.Create;
begin
   inherited Create;
end;

destructor THIdbMySQL_Exec.Destroy;
begin
   inherited; 
end;

function GetBlobName(var str:string;var pos:integer): string;
 var
  c:char;
  i:integer;
 begin
  i := pos;
  repeat
   inc(i);
   c := str[i];
  until ((c=' ')or(c=',')or(c=')')or(c=chr(13)));
  Result := Copy(str,pos+1,i-pos-1);
 end;

procedure THIdbMySQL_Exec._work_doExec;
var
   dt:TData;
   s,n:string;
   i:integer;
begin
   dt := ReadData(_Data,_data_dbHandle,nil);
   ms := TMySQL(ToObject(dt));
   if _IsObject(dt,MySQL_GUID) then
    begin
     FText := ReadString(_data,_data_QueryText,'');
	 FIndex := 0;
     i := PosEx(':',FText,1);
     if i>0 then
      while i>0 do
       begin
		n := GetBlobName(FText,i);
        if _prop_UseName then
         _hi_OnEvent(_event_onGetBlob,n)		
		else
		 _hi_OnEvent(_event_onGetBlob,FIndex);
        Inc(FIndex);
        _BlobData := ReadStream(dt,_data_BlobData,nil);
        _BlobData.Position := 0;
        BufferSize := _BlobData.Size;
        Buffer := AllocMem(BufferSize);
        _BlobData.Read(Buffer^,BufferSize);
        _BlobData.Position := 0;
        s := ms.BlobToString(Buffer,BufferSize);
        FText := Copy(FText,1,i-1) + '''' + s + '''' + Copy(FText,i+Length(n)+1,Length(FText)-i);
        FreeMem(Buffer);
        i := PosEx(':',FText,i+Length(s)+2);
       end;
     _hi_OnEvent(_event_onResult,ms.Execute(FText));
    end else _hi_OnEvent(_event_onError,0);
end;

end.

