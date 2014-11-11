unit hiRGN_File;

interface

uses Windows,Kol,Share,Debug;

type
  THIRGN_File = class(TDebug)
   private
    FRegion:HRGN;
   public
    _prop_FileName:string;
    _data_FileName:THI_Event;
    _data_Region:THI_Event;
    _event_onLoad:THI_Event;
    _event_onSave:THI_Event;
    
    destructor Destroy; override;
    procedure _work_doLoad(var _Data:TData; Index:word);
    procedure _work_doClear(var _Data:TData; Index:word);
    procedure _work_doSave(var _Data:TData; Index:word);
    procedure _var_Result(var _Data:TData; Index:word);
                   
  end;

implementation

destructor THIRGN_File.Destroy;
begin
   DeleteObject(FRegion);
   inherited;
end;

procedure THIRGN_File._work_doLoad;
var  s: PStream;
     fn: string;
     data: PRgnData;
begin
  fn := ReadString(_Data,_data_FileName,_prop_FileName);
  if FileExists(fn) then begin
   DeleteObject(FRegion);
   s := NewReadFileStream(fn);
   data := GlobalAllocPtr(GPTR, s.size);
   s.Read(data^, s.Size);
   FRegion := ExtCreateRegion(nil, s.Size, data^);
   GlobalFreePtr(data);
   s.Free;
  _hi_onEvent(_event_onLoad, integer(FRegion));
 end;
end;

procedure THIRGN_File._work_doSave;
var  s: PStream;
     fn: string;
     size: cardinal;
     data: pointer;
     tmpRGN: HRGN;
begin
   tmpRGN := ReadInteger(_Data,_data_Region);
   if tmpRGN = 0 then exit;
   fn := ReadString(_Data,_data_FileName,_prop_FileName);
   s := NewWriteFileStream(fn);
   size := GetRegionData (tmpRGN, SizeOf(RGNDATA), nil);
   data := GlobalAllocPtr(GPTR, size);
   GetRegionData(tmpRGN, size, data);
   s.Write(data^, size);
   GlobalFreePtr(data);
   s.Free;
   if FRegion <> 0 then
    begin
     DeleteObject(FRegion);
     FRegion := 0;
   end;
end;

procedure THIRGN_File._work_doClear;
begin
   DeleteObject(FRegion);
   FRegion := 0;
end;

procedure THIRGN_File._var_Result;
begin
   dtInteger(_Data, FRegion);
end;
end.