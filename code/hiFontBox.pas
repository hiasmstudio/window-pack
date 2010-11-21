unit hiFontBox;

interface

uses Windows,Messages,Kol,Share,Debug,Win,hiBoxDrawManager;

const
  FT_RASTER   = 0;
  FT_VECTOR   = 1;
  FT_TRUETYPE = 2;
  FT_OPENTYPE = 3;
  IMAGE_SIZE  = 16;

type
  THIFontBox = class(THIWin)
    private
      fFontName: String;
      fFontHeight: integer;
      fBoxDrawManager:IBoxDrawManager;    
      ICOpenType, ICTrueType, ICVector, ICRaster: PIcon;
      procedure Kill;
      procedure _onChange(Sender: PObj);
      procedure SetFontName(const Value: String);
      procedure MakeFontList;
      procedure DestroyFontList;
      function  OnMeasureItem( Sender: PObj; Idx: Integer ):Integer;
      function  DrawOnItem(Sender: PObj; DC: HDC; const Rect: TRect; ItemIdx: Integer;
                           DrawAction: TDrawAction; ItemState: TDrawState): Boolean;
      procedure SetInitBoxDrawManager(value:IBoxDrawManager);
    public
      _prop_SelFont:string;
      _data_Font:THI_Event;
      _event_onResult:THI_Event;
      _prop_ItemHeight:integer;
    
      procedure Init;override;
      procedure _work_doSetFont(var _Data:TData; Index:word);
      procedure _work_doReReadFonts(var _Data:TData; Index:word);
      procedure _var_CurrentFont(var _Data:TData; Index:word);
      property _prop_BoxDrawManager:IBoxDrawManager read fBoxDrawManager write SetInitBoxDrawManager; 
  end;

implementation

procedure THIFontBox.Kill;
begin
  DestroyFontList;
  if Assigned(_prop_BoxDrawManager) then
  begin
    IcTruetype.free;
    ICRaster.free;
    IcOpenType.free;
    IcVector.Free;
  end;
end;

procedure THIFontBox.SetFontName;
var  i:Integer;
begin
  i:= Control.IndexOf(Value);
  if i > 0 then
  begin
    fFontName := Value;
    Control.CurIndex := i;
  end
  else
  begin
    fFontName := '???';
    Control.Text := '???';
  end;
end;

procedure THIFontBox.Init;
var  h:Thandle;
     r: real;
begin
  Control := NewComboBox(FParent,[coReadOnly,coSort,coOwnerDrawFixed]);
  if ManFlags and $04 > 0 then 
  begin
    H:=LoadLibrary('fontext.dll');
    if H <> 0 then
    begin
      ICTruetype:= NewIcon;
      ICTruetype.LoadFromResourceID(H, 2, IMAGE_SIZE);
      ICRaster:= NewIcon;
      ICRaster.LoadFromResourceID(H, 3, IMAGE_SIZE);
      ICVector:= NewIcon;
      ICOpenType:= NewIcon;
      if WinVer > WvNT then
      begin
        ICVector.LoadFromResourceID(H, 5, IMAGE_SIZE);
        ICOpentype.LoadFromResourceID(H, 6, IMAGE_SIZE)
      end
      else
      begin
        ICOpentype.LoadFromResourceID(H, 2, IMAGE_SIZE); // prevent dll hell
        ICVector.LoadFromResourceID(H, 3, IMAGE_SIZE);
      end;
    end;
    FreeLibrary(H);
  end;
  if ManFlags and $04 > 0 then
    Control.OnMeasureItem:= OnMeasureItem;
  Control.OnChange:=_onChange;
  Control.Add2AutoFreeEx(Kill);
  inherited;
  r := ((Control.Font.FontHeight * -72) - 36) / ScreenDPI;
  fFontHeight := Integer(Trunc(r));
  if Frac(r) > 0 then
    Inc(fFontHeight);
  if fFontHeight < 11 then fFontHeight := 11;     
  MakeFontList;
  SetFontName(_prop_SelFont);
end;

procedure THIFontBox.SetInitBoxDrawManager;
begin
  if value <> nil then
    fBoxDrawManager := value;
end;

procedure THIFontBox._work_doSetFont;
begin
  SetFontName(ReadString(_Data,_data_Font));
end;

procedure THIFontBox._work_doReReadFonts;
begin
  MakeFontList;
  SetFontName(fFontName);
end;

procedure THIFontBox._onChange;
begin
  fFontName := Control.Items[Control.CurIndex];
  _hi_onEvent(_event_onResult, fFontName);
end;

procedure THIFontBox._var_CurrentFont;
begin
  dtString(_Data,fFontName);
end;

//From KOLFontComboBox.pas
function THIFontBox.DrawOnItem;
var  xRect : TRect;
     xFont : HFONT;
     ICHandle : HICON;
     FD:  PGraphicTool;
     shift: integer;
begin
  Result := False;
  FD := Pointer( PControl(Sender).ItemData[ItemIdx] );
  xFont := FD.Handle;
  if Assigned(_prop_BoxDrawManager) then
  begin
    if xFont <> 0 then
      Result := _prop_BoxDrawManager.draw(Sender, DC, Rect, ItemIdx, ItemState, false, xFont)
    else
      Result := _prop_BoxDrawManager.draw(Sender, DC, Rect, ItemIdx, ItemState, false, PControl(Sender).Font.Handle);
    ICHandle := 0;
    case FD.Tag of 
      FT_TRUETYPE : ICHandle := ICTruetype.handle;
      FT_OPENTYPE : ICHandle := ICOpentype.handle;
      FT_RASTER   : ICHandle := ICRaster.handle;
      FT_VECTOR   : ICHandle := ICVector.handle;
    end;
    shift := _prop_BoxDrawManager.shift;
    if (odsComboboxEdit in ItemState) then inc(shift);
    DrawIconEx(DC, shift, Rect.Top + (Rect.Bottom - Rect.Top - IMAGE_SIZE) div 2, ICHandle, IMAGE_SIZE, IMAGE_SIZE, 0, 0, DI_NORMAL);
  end
  else
  begin
    xRect := Rect;
    InFlateRect(xRect,-1,-1);
    FillRect(DC, Rect, 0);
    inc(xRect.Left, 20);
    if xFont <> 0 then
      SelectObject(DC,xFont)
    else
      SelectObject(DC,PControl(Sender).Font.Handle);
    DrawText(DC,PChar(PControl(Sender).Items[ItemIdx]),Length(PControl(Sender).Items[ItemIdx]),
             xRect,DT_SINGLELINE or DT_VCENTER or DT_NOPREFIX);
    if (odaSelect in DrawAction) then
      InvertRect(DC,Rect);
  end;
end;

procedure THIFontBox.DestroyFontList;
var  i: Integer;
     FD:  PGraphicTool;
begin
  if Control.Count = 0 then exit; 
  for i := 0 to Control.Count - 1 do
  begin 
    FD := Pointer( Control.ItemData[i] );
    FD.free;
  end;
  Control.Clear;
end;

function EnumFontsProc(var EnumLogFont: TEnumLogFontEx; var TextMetric: TNewTextMetric;
                       FontType: Integer; Data: LPARAM): Integer; export; stdcall;
var  FaceName: string;
     FB : THIFontBox;
     i  : Integer;
     FD:  PGraphicTool;
begin
  FB  := THIFontBox(Data);
  FaceName := String(EnumLogFont.elfLogFont.lfFaceName);
  with EnumLogFont do
  begin
    elfLogFont.lfHeight := -FB.fFontHeight;
    elfLogFont.lfWidth  := 0;
  end;
  if (FB.Control.Count = 0) or (FB.Control.IndexOf(FaceName) < 0) then
  begin
    FD := NewFont;
    if EnumLogFont.elflogfont.lfCharSet = SYMBOL_CHARSET then
      FD.AssignHandle(0)
    else
      FD.AssignHandle(CreateFontIndirect(EnumLogFont.elfLogFont));
    i := FB.Control.Add(FaceName);
    FD.tag := Fonttype;
    case Fonttype of
                      0: FD.tag := FT_VECTOR;
        DEVICE_FONTTYPE: FD.tag := FT_VECTOR;                      
        RASTER_FONTTYPE: FD.tag := FT_RASTER;
      TRUETYPE_FONTTYPE: FD.tag := FT_TRUETYPE;             
    end;
    if (WinVer > WvNT) and (Getbits(TextMetric.ntmFlags,17,18) > 0) then
      FD.tag:=FT_OPENTYPE;

    FB.Control.ItemData[i] := DWORD( FD );
  end;
  Result := 1;
end;

function THIFontBox.OnMeasureItem;
begin
  Result := _prop_ItemHeight;
end;

procedure THIFontBox.MakeFontList;
var  DC:HDC;
begin
  DC := GetDC(0);
TRY
  Control.OnDrawItem := nil;
  DestroyFontList;
  EnumFontFamilies(DC,nil,@EnumFontsProc,LongInt(Self));
  Control.OnDrawItem := DrawOnItem;
FINALLY
  ReleaseDC(0,DC);
END;
end;

end.