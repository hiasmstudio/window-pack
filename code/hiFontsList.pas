unit HiFontsList;

interface

uses Windows,Messages,kol,Share,Debug;

type
 THiFontsList = class(TDebug)
   private
     ListFonts: PStrList;
     ArrList: PArray;
     function _GetList(var Item:TData; var Val:TData): boolean;
     function _CountList: integer;   
     procedure MakeFontList(FileName:string;CharSet:integer);
   public
    fStrDelimiter:string;
    _prop_NameFilter:string;
    _prop_CharSetFilter:integer;
   
    _data_CharSetFilter: THI_Event;
    _data_NameFilter: THI_Event;
    
    constructor Create;
    destructor Destroy; override;
    procedure _var_FontsArray(var _Data:TData; Index:word);
    procedure _work_doReReadFonts(var _Data:TData; Index:word);                     
    property _prop_StrDelimiter:string read fStrDelimiter write fStrDelimiter;
 end;
implementation

//******************************************************************************

function EnumFontsProc(var EnumLogFont: TEnumLogFontEx; var TextMetric: TNewTextMetric;
                       FontType: Integer; Data: LPARAM): Integer; export; stdcall;
var   FaceName: string;
      FB : THiFontsList;
      CodeStyle : Integer;
begin
  FB  := THiFontsList(Data);
//  FaceName := String(EnumLogFont.elfLogFont.lfFaceName) + ' ' + String(EnumLogFont.elfLogFont.lfFaceName);
  FaceName := String(EnumLogFont.elfFullName) + FB.fStrDelimiter + String(EnumLogFont.elfStyle) + FB.fStrDelimiter + String(EnumLogFont.elfScript);
  CodeStyle := 0;
  if EnumLogFont.elfLogFont.lfWeight >= 700 then CodeStyle := 1;
  if EnumLogFont.elfLogFont.lfItalic    > 0 then CodeStyle := CodeStyle + 2;
  if EnumLogFont.elfLogFont.lfUnderline > 0 then CodeStyle := CodeStyle + 4;
  if EnumLogFont.elfLogFont.lfStrikeOut > 0 then CodeStyle := CodeStyle + 8;
  FaceName := FaceName + FB.fStrDelimiter + int2str(CodeStyle) + FB.fStrDelimiter + int2str(EnumLogFont.elfLogFont.lfCharSet);     
  FB.ListFonts.Add(FaceName);
  Result := 1;
end;

//------------------------------------------------------------------------------

procedure THiFontsList.MakeFontList;
var   DC:HDC;
      lf : TLogFont;
      i : integer;
begin
   DC := GetDC(0);
   lf.lfCharset := CharSet;
   lf.lfFaceName[0] := #0;
   FillChar(lf.lfFaceName, LF_FACESIZE, #0);
   for i:=1 to Length(FileName) do lf.lfFaceName[i-1] := FileName[i];
   EnumFontFamiliesEx(DC,lf,@EnumFontsProc,LongInt(Self),0);
   ReleaseDC(0,DC);
end;

//******************************************************************************

function THiFontsList._GetList;
var   ind: integer;
begin
   Result := false;
   ind := ToIntIndex( Item );
   if (ind < 0) or (ind > ListFonts.Count - 1) then exit;
   dtString(Val, ListFonts.Items[ind]);
   Result := true;
end;

function THiFontsList._CountList;
begin
   Result := ListFonts.Count;
end;

procedure THiFontsList._var_FontsArray;
begin
   dtArray(_Data, ArrList);
end;

procedure THiFontsList._work_doReReadFonts;
begin
   ListFonts.Clear;
   MakeFontList(ReadString(_Data,_data_NameFilter,_prop_NameFilter),ReadInteger(_Data,_data_CharSetFilter,_prop_CharSetFilter));
end;

constructor THiFontsList.Create;
begin
  inherited;
  ListFonts := NewStrList;
  ArrList   := CreateArray( nil, _GetList, _CountList, nil );
end;

destructor THiFontsList.Destroy;
begin
   Dispose(ArrList);
   ListFonts.free;
   inherited;
end;

end.