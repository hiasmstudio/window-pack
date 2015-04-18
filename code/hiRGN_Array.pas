unit hiRGN_Array;

interface

uses Windows,Kol,Share,Debug;

type
  THIRGN_Array = class(TDebug)
   private
    Arr: PArray;
    ArrRegion: PList;

    procedure _Set(var Item:TData; var Val:TData);
    function _Get(Var Item:TData; var Val:TData):boolean;
    function _Count:integer;
    procedure _Add(var Val:TData);
    procedure _Clear;
   public
    _prop_FileName:string;
    _data_FileName:THI_Event;
    _event_onChange:THI_Event;
    
    constructor Create;
    destructor Destroy; override;
    procedure _work_doAdd(var _Data:TData; Index:word);
    procedure _work_doClear(var _Data:TData; Index:word);
    procedure _work_doDelete(var _Data:TData; Index:word);
    procedure _work_doSave(var _Data:TData; Index:word);
    procedure _work_doLoad(var _Data:TData; Index:word);
    procedure _var_Array(var _Data:TData; Index:word);
    procedure _var_Count(var _Data:TData; Index:word);
    procedure _var_EndIdx(var _Data:TData; Index:word); 
  end;

implementation

procedure THIRGN_Array._Clear;
var ind: integer;
begin
    for ind := 0 to ArrRegion.Count - 1 do
     DeleteObject(HRGN(ArrRegion.Items[ind]));
    ArrRegion.Clear;
end;

constructor THIRGN_Array.Create;
begin
    inherited Create;
    ArrRegion := NewList;
end;

destructor THIRGN_Array.Destroy;
begin
    if ArrRegion.Count > 0 then _Clear;
    ArrRegion.Free;
    inherited;
end;

procedure THIRGN_Array._work_doAdd;
begin
    _Add(_Data);
    _hi_CreateEvent(_Data, @_event_onChange);
end;

procedure THIRGN_Array._work_doClear;
begin
    if ArrRegion.Count > 0 then
     begin
      _Clear;
      _hi_CreateEvent(_Data, @_event_onChange);
     end;
end;

procedure THIRGN_Array._work_doDelete;
var ind: integer;
begin
    ind := ToIntIndex(_Data);
    if (ind < 0) or (ind > ArrRegion.Count - 1) then exit;
    DeleteObject(HRGN(ArrRegion.Items[ind]));
    ArrRegion.Delete(ind);
    _hi_CreateEvent(_Data, @_event_onChange);
end;

procedure THIRGN_Array._work_doLoad;
var fn: string;
    strmfile, strm: PStream;
    data: PRgnData;
    c: cardinal;
begin
    fn := ReadString(_data,_data_FileName,_prop_FileName);
    if FileExists(fn) then
     begin
      if ArrRegion.Count > 0 then _Clear;
      strmfile := NewReadFileStream(fn);
      strm := NewMemoryStream;
      while strmfile.Position < strmfile.Size do
       begin
        strmfile.Read(c, 4);
        Stream2Stream(strm, PStream(strmfile), c);
        // создает регион из данных
        data := GlobalAllocPtr(GPTR, strm.Size);
        strm.Position := 0;
        strm.Read(data^, strm.Size);
        // добавляет регион в список
        ArrRegion.Add(pointer(ExtCreateRegion(nil, strm.Size, data^)));
        GlobalFreePtr(data);
        strm.Size := 0;
       end;
      strm.Free;
      strmfile.Free;
      _hi_CreateEvent(_Data, @_event_onChange);
     end;
end;

procedure THIRGN_Array._work_doSave;
var fn: string;
    strmfile: PStream;
    i: cardinal;
    size: cardinal;
    data: pointer;
    rgn: HRGN;
begin
    if ArrRegion.Count = 0 then exit;
    fn := ReadString(_data,_data_FileName,_prop_FileName);
    strmfile := NewWriteFileStream(fn);
    for i := 0 to ArrRegion.Count - 1 do
     begin
      rgn := HRGN(ArrRegion.Items[i]);
      size := GetRegionData (rgn, SizeOf (RGNDATA), nil);
      data := GlobalAllocPtr(GPTR, size);
      GetRegionData(rgn, size, data);
      PStream(strmfile).Write(size, 4);
      PStream(strmfile).Write(data^, size);
      GlobalFreePtr(data);
     end;
    strmfile.Free;
end;

procedure THIRGN_Array._Set;
var ind: integer;
    rgn: HRGN;
begin
    ind := ToIntIndex(Item);
    if (ind >= 0) and (ind < ArrRegion.Count) then
     begin
      DeleteObject(HRGN(ArrRegion.Items[ind]));
      ArrRegion.Items[ind] := pointer(CreateRectRgn(0, 0, 0, 0));
      rgn := ToInteger(val);
      CombineRgn(HRGN(ArrRegion.Items[ind]), rgn, 0, RGN_COPY);
    end;
end;

procedure THIRGN_Array._Add;
begin
   ArrRegion.Add(pointer(CreateRectRgn(0, 0, 0, 0)));
   CombineRgn(HRGN(ArrRegion.Items[ArrRegion.Count - 1]), ToInteger(val), 0, RGN_COPY);
end;

function THIRGN_Array._Get;
var ind: integer;
begin
    ind := ToIntIndex(Item);
    if (ind >= 0) and (ind < ArrRegion.Count) then
     begin
      Result := true;
      dtInteger(Val,HRGN(ArrRegion.Items[ind]));
     end
    else Result := false;
end;

procedure THIRGN_Array._var_Count;
begin
    dtInteger(_Data, _Count);
end;

procedure THIRGN_Array._var_Array;
begin
    if Arr = nil then Arr := CreateArray(_Set, _Get, _Count, _Add);
    dtArray(_Data,Arr);
end;

function THIRGN_Array._Count;
begin
    Result := ArrRegion.Count;
end;

procedure THIRGN_Array._var_EndIdx;
begin
  dtInteger(_Data, ArrRegion.Count - 1);
end;

end.