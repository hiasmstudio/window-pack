unit hiRGN_GetData;

interface

uses Windows,Kol,Share,Debug;

type
  THIRGN_GetData = class(TDebug)
   private
    RLeft,RTop,RWidth,RHeight,RSize,RCount,RRgnSize:integer;
   public
    
    _data_Region:THI_Event;
    _event_onGetData:THI_Event;

    procedure _work_doGetData(var _Data:TData; Index:word);
    procedure _var_Left(var _Data:TData; Index:word);
    procedure _var_Top(var _Data:TData; Index:word);
    procedure _var_Width(var _Data:TData; Index:word);
    procedure _var_Height(var _Data:TData; Index:word);
    procedure _var_Size(var _Data:TData; Index:word);
    procedure _var_Count(var _Data:TData; Index:word);
    procedure _var_RgnSize(var _Data:TData; Index:word);                    
  end;

implementation

procedure THIRGN_GetData._work_doGetData;
var rgn:      HRGN;
    RgnDword: DWORD;
    RgnData:  PRgnData;
begin
    rgn := ReadInteger(_Data, _data_Region);
    RgnDword := GetRegionData(rgn, 0, nil);
    if RgnDword > 0 then
     begin
      GetMem(RgnData, SizeOf(RgnData) * RgnDword);
      GetRegionData(rgn, RgnDword, RgnData);
      RLeft     := RgnData.rdh.rcBound.Left;
      RTop      := RgnData.rdh.rcBound.Top;
      RWidth    := RgnData.rdh.rcBound.Right - Rleft;
      RHeight   := RgnData.rdh.rcBound.Bottom - RTop;
      RSize     := RgnData.rdh.dwSize;
      RCount    := RgnData.rdh.nCount;
      RRgnSize  := RgnData.rdh.nRgnSize;
      FreeMem(RgnData);
      _hi_onEvent(_event_onGetData, integer(rgn));
    end;
end;

procedure THIRGN_GetData._var_Left;
begin
   dtInteger(_Data, RLeft);
end;

procedure THIRGN_GetData._var_Top;
begin
   dtInteger(_Data, RTop);
end;
procedure THIRGN_GetData._var_Width;
begin
   dtInteger(_Data, RWidth);
end;

procedure THIRGN_GetData._var_Height;
begin
   dtInteger(_Data, RHeight);
end;

procedure THIRGN_GetData._var_Size;
begin
   dtInteger(_Data, RSize);
end;

procedure THIRGN_GetData._var_Count;
begin
   dtInteger(_Data, RCount);
end;

procedure THIRGN_GetData._var_RgnSize;
begin
   dtInteger(_Data, RRgnSize);
end;
end.