unit hiRGN_Convertor;

interface

uses Windows,Kol,Share,Debug;

type
  THIRGN_Convertor = class(TDebug)
   private
    FRegion:HRGN;
   public
    _prop_Mode:byte;
       
    _data_Data:THI_Event;
    _event_onResult:THI_Event;
    
    procedure _work_doConvert0(var _Data:TData; Index:word); //RgnToStream
    procedure _work_doConvert1(var _Data:TData; Index:word); //StreamToRgn
  end;

implementation

procedure THIRGN_Convertor._work_doConvert0(var _Data:TData; Index:word);//RgnToStream
var St: PStream;
    data: pointer;
    size: cardinal;
    tmpRGN: HRGN;
begin
    tmpRGN := ReadInteger(_Data,_data_Data);
    size := GetRegionData (tmpRGN, SizeOf(RGNDATA), nil);
    data := GlobalAllocPtr(GPTR, size);
    GetRegionData(tmpRGN, size, data);
    St := NewMemoryStream;
    St.Write(data^, size);
    St.Position := 0;
    GlobalFreePtr(data);
    _hi_onEvent(_event_onResult, St);
    St.Free;
end;

procedure THIRGN_Convertor._work_doConvert1(var _Data:TData; Index:word);//StreamToRgn
var St: PStream;
    len: cardinal;
    data: PRgnData;
begin
    St := ReadStream(_data,_data_Data);
    if St = nil then Exit;
    St.Position := 0;
    len := St.size;
    data := GlobalAllocPtr(GPTR, len);
    St.Read(data^, len);
    DeleteObject(FRegion);
    FRegion := ExtCreateRegion(nil, len, data^);
    GlobalFreePtr(data);
   _hi_onEvent(_event_onResult, integer(FRegion));
end;


end.