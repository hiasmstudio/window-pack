unit hiTempFileStream;

interface

uses Kol,Share,windows,Debug;

type
  THITempFileStream = class(TDebug)
   private
    fFileName:string;
    FExtention: string;
    procedure Close;
   public
    _prop_Prefix:string;
    _prop_Stream:PStream;

    _data_Stream:THI_Event;
    _event_onCreate:THI_Event;

    destructor Destroy; override;
    procedure _work_doCreate(var _Data:TData; Index:word);
    procedure _work_doDelete(var _Data:TData; Index:word);
    procedure _work_doExtention(var _Data:TData; Index:word);    
    procedure _var_TempFName(var _Data:TData; Index:word);
    procedure _var_TempFolder(var _Data:TData; Index:word);    
    property _prop_Extention: string write FExtention;
  end;

implementation

destructor THITempFileStream.Destroy;
begin
   Close;
   inherited;
end;

procedure THITempFileStream._work_doCreate;
var   Strm, St: PStream;
      fn: string;
begin
   St := ReadStream(_data, _data_Stream, _prop_Stream);
   if (St = nil) or (St.Size = 0) then exit;
   Close;
   St.Position := 0;
   fn := CreateTempFile( GetTempDir, _prop_Prefix );
   if FExtention <> '' then fFileName := ChangeFileExt(fn, FExtention);
   if FileExists(fn) then DeleteFile(PChar(fn));   
   Strm := NewWriteFileStream(fFileName);
   Stream2Stream(Strm, St, St.Size);
   free_and_nil(Strm);
   if not FileExists(fFileName) then exit; 
   _hi_CreateEvent(_Data,@_event_onCreate,fFileName);
end;

procedure THITempFileStream._work_doDelete;
begin
   Close;
end;

procedure THITempFileStream._work_doExtention;
begin
   FExtention := ToString(_Data);
end;

procedure THITempFileStream.Close;
begin
   if (fFileName <> '') and FileExists(fFileName) then begin 
      DeleteFile(PChar(fFileName));
      fFileName := '';
   end;     
end;

procedure THITempFileStream._var_TempFName;
begin
   dtString(_Data,fFileName);
end;

procedure THITempFileStream._var_TempFolder;
begin
   dtString(_Data, GetTempDir);
end;

end.
