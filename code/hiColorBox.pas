unit hiColorBox;

interface

{$I share.inc}

uses Windows,Kol,Share,LWinList,Messages,hiBoxDrawManager;

const
  FullColor = 47;

  ColorValues: array [0..FullColor - 1] of TColor = (
    clBlack,clMaroon,clGreen,clOlive,clNavy,clPurple,clTeal,clGray,
    clSilver,clRed,clLime,clYellow,clBlue,clFuchsia,clAqua,clWhite,
    clMoneyGreen,clSkyBlue,clCream,clMedGray,clActiveBorder,clActiveCaption,
    clAppWorkSpace,clBackground,clBtnFace,clBtnHighlight,clBtnShadow,    
    clBtnText,clCaptionText,clDefault,clGrayText,clHighlight,clHighlightText,
    clInactiveBorder,clInactiveCaption,clInactiveCaptionText,clInfoBk,
    clInfoText,clMenu,clMenuText,clNone,clScrollBar,cl3DDkShadow,
    cl3DLight,clWindow,clWindowFrame,clWindowText );

  ColorNames: array [0..FullColor - 1] of String = (
    'Black','Maroon','Green','Olive','Navy','Purple','Teal','Gray',
    'Silver','Red','Lime','Yellow','Blue','Fuchsia','Aqua','White',
    'MoneyGreen','SkyBlue','Cream','MedGray','ActiveBorder','ActiveCaption',
    'AppWorkSpace','Background','BtnFace','BtnHighlight','BtnShadow',    
    'BtnText','CaptionText','Default','GrayText','Highlight','HighlightText',
    'InactiveBorder','InactiveCaption','InactiveCaptionText','InfoBk',
    'InfoText','Menu','MenuText','None','ScrollBar','3DDkShadow',
    '3DLight','Window','WindowFrame','WindowText' );

type
  ThiColorBox = class(THILWinList)
    private
      FData: TData;
      ColorRange:integer;
      ColorArr:PArray;
      ColorSize:integer;
      fColors:string;
      fFormatColor:byte;
      fTypeListColors:byte;
      fColorSize:byte;
      fDefColor:TColor;
      fBoxDrawManager:IBoxDrawManager;     
     
      procedure InitList;
      function  _val_arr_get(Var Item:TData; var Val:TData):boolean;
      function  _val_arr_count:integer;
      procedure _OnClick( Sender: PObj );
      function  _OnMeasureItem( Sender: PObj; Idx: Integer ):Integer;
      function  _OnDrawItem( Sender: PObj; DC: HDC; const Rect: TRect; ItemIdx: Integer;
                             DrawAction: TDrawAction; ItemState: TDrawState ): Boolean;
      procedure SetInitBoxDrawManager(value:IBoxDrawManager);

    public
      _prop_ItemHeight:integer;
      property _prop_Colors:string         write fColors;
      property _prop_FormatColor:byte      write fFormatColor;
      property _prop_TypeListColors:byte   write fTypeListColors;
      property _prop_ColorSize:byte        write fColorSize;
      property _prop_DefColor:TColor       read fDefColor write fDefColor;

      destructor Destroy; override;
      procedure Init; override;

      procedure _work_doInitList(var _Data:TData; Index:word);
      procedure _work_doFormatColor(var _Data:TData; Index:word);
      procedure _work_doSelectColor(var _Data:TData; Index:word);
      procedure _work_doSelectName(var _Data:TData; Index:word);
      procedure _var_ColorArray(var _Data:TData; Index:word);
      procedure _var_Index(var _Data:TData; Index:word);     
      procedure _var_CurrentColor(var _Data:TData; Index:word);

      property _prop_BoxDrawManager:IBoxDrawManager read fBoxDrawManager write SetInitBoxDrawManager; 
  end;

implementation

function Hex2Int(st:string):integer;
var  i,ln:integer;
begin
  st := LowerCase(st);
  Result := 0;
  ln := Length(st);
  for i := 1 to ln do
    case st[i] of
      '0'..'9': Result := Result shl 4 + ord(st[i]) - 48;
      'a'..'f': Result := Result shl 4 + ord(st[i]) - 87;
      else break;
    end;
end;

function Trim(s:string; d:string = ' '): string;
var  st :integer;
begin
  if Length(s) > 0 then
  begin
    st := 1;
    while (st <= Length(s))and(s[st] = d[1]) do inc(st);
    delete(s,1,st-1);
    st := Length(s);
    while (st > 0)and(s[st] = d[1]) do dec(st);
    delete(s,st+1,Length(s) - st);
  end;
  Result := s;
end;

procedure ThiColorBox._work_doInitList;
begin
  fColors:= ToString(_Data);
  InitList;
end;

procedure ThiColorBox._work_doFormatColor;
begin
  fFormatColor:= ToInteger(_Data);
end;

function RGB2HTML (Color: TColor): string;
var  fFrom: TRGB;
begin
  PColor(@fFrom)^:= Color2RGB(Color);
  Result:= Int2Hex(FFrom.R, 2) + Int2Hex(FFrom.G, 2) + Int2Hex(FFrom.B, 2)
end;

function HTML2RGB (str: string): TColor;
var  hr,hg,hb: byte;
begin
  Result := 0;
  if str[1] <> '#' then exit;
  Delete(str,1,1);
  hr := hex2int(Copy(str,1,2));
  hg := hex2int(Copy(str,3,2));      
  hb := hex2int(Copy(str,5,2));
  Result := hr + hg shl 8 + hb shl 16;
end;

//------------------------   Создание контрола   ----------------------

procedure ThiColorBox.Init;
var  Flags:TComboOptions;
begin
  Flags := [coReadOnly, coOwnerDrawFixed];
  ColorSize:= fColorSize;
  Control := NewComboBox(FParent,Flags);
  Control.OnMeasureItem := _OnMeasureItem;
  Control.OnSelChange   := _OnClick;
  Control.OnDrawItem    := _OnDrawItem;
inherited;
  InitList;
end;

procedure ThiColorBox.SetInitBoxDrawManager;
begin
  if value <> nil then
    fBoxDrawManager := value;
end;

procedure ThiColorBox.InitList;
var  i:integer;
     str:string;
     valid:boolean;
     CList:PStrList;
begin
  Control.Clear;
  if fTypeListColors <> 2 then
  begin
    if fTypeListColors = 0 then ColorRange:= FullColor else ColorRange:= 16; 
    str:= '';
    for i:= 0 to ColorRange - 1 do
      str:= str + ColorNames[i] + #13#10;
    SetStrings(str);
    for i:= 0 to ColorRange - 1 do
      Control.ItemData[i]:= Color2RGB(ColorValues[i]);
  end;
  CList:= NewStrList;
  CList.text:= fColors;
  if CList.Count <> 0 then
    for i:=0 to CList.Count - 1 do
      if CList.Items[i] <> '' then
      begin
        str:= CList.Items[i] + '=';
        Add(Trim(gettok(str,'=')));
        str := Trim(gettok(str,'='));
        if str[1] = '$' then
        begin
            Delete(str,1,1);         
            Control.ItemData[Control.Count - 1]:= hex2int(str);
        end
        else if str[1] = '#' then
          Control.ItemData[Control.Count - 1]:= HTML2RGB(str)             
        else         
          Control.ItemData[Control.Count - 1]:= str2int(str); 
      end;
  CList.free; 
  valid:= false;
  ColorRange:= Control.Count;
  Control.CurIndex := 0;
  for i:= 0 to ColorRange - 1 do 
    if Control.ItemData[i] = dword(Color2RGB(fDefColor)) then
    begin
      valid:= true;
      break;
    end;
  if not valid then exit;
  Control.CurIndex := i;
  Control.Invalidate;
end;
      
destructor ThiColorBox.Destroy;
begin
  if ColorArr <> nil then Dispose(ColorArr);
  FreeData(@FData); 
  inherited Destroy;
end;

procedure ThiColorBox._OnClick;
var  dr,dg,db:TData;
     fFrom: TRGB;
begin
  inherited;
  case _prop_DataType of
    0: _hi_OnEvent(_event_onClick, Control.CurIndex);
    1: begin
         case fFormatColor of
           0: _hi_OnEvent(_event_onClick, integer(Control.ItemData[Control.CurIndex]));
           1: _hi_OnEvent(_event_onClick, RGB2HTML(Control.ItemData[Control.CurIndex]));
           2: _hi_OnEvent(_event_onClick, Int2Hex(Control.ItemData[Control.CurIndex],8));
           3: begin
                fFrom := TRGB(Control.ItemData[Control.CurIndex]);
                dtInteger(dr, FFrom.R);
                dtInteger(dg, FFrom.G);
                dtInteger(db, FFrom.B);
                dr.ldata:= @dg;
                dg.ldata:= @db;
                _hi_onEvent_(_event_onClick, dr);                
              end;
         end;
       end;
  end;
end;

function ThiColorBox._OnMeasureItem;
begin
  Result := _prop_ItemHeight;
end;

//---------------------   Графический обработчик   -----------------------

function ThiColorBox._OnDrawItem;
const
  SHIFT_PICTURE = 6;

var  ARect,cbRect: TRect;
begin
  Result:= False;
  with PControl(Sender){$ifndef F_P}^{$endif} do
  begin
    cbRect:= Rect;
    if Assigned(_prop_BoxDrawManager) then
      Result := _prop_BoxDrawManager.draw(Sender, DC, Rect, ItemIdx, ItemState, false, Font.Handle)
    else
    begin
      Canvas.Brush.Color := Color;
      FillRect(DC,cbRect,Canvas.Brush.Handle);
      if (odsSelected in ItemState) and not (odsComboboxEdit in ItemState) then
        Canvas.Brush.Color := clHighLight      
      else
        Canvas.Brush.Color:= Color;
      FillRect(DC,cbRect,Canvas.Brush.Handle);
      ARect:= Rect;
      ARect.Left:= ARect.Left + fColorSize*2 + Canvas.TextExtent('W').cx;
      if (odsComboboxEdit in ItemState) then
        ARect.Left:= ARect.Left - 2;
      SetBkMode(DC, Windows.TRANSPARENT);
      if (odsSelected in ItemState) and not (odsComboboxEdit in ItemState) then
        SetTextColor(DC,Color2RGB(clHighlightText))
      else
        SetTextColor(DC,Color2RGB(Font.Color));
      DrawText(DC, PChar(Items[ItemIdx]), -1, ARect, DT_SINGLELINE or DT_VCENTER or DT_NOPREFIX);
    end;
    with cbRect do
    begin
      Top:= Top + (Bottom - Top - fColorSize) div 2;
      Bottom:= Top + fColorSize;
      if Assigned(_prop_BoxDrawManager) then
      begin
        Left:= _prop_BoxDrawManager.shift;
        Right:= Left + fColorSize;       
      end
      else
      begin
        Left:= SHIFT_PICTURE;
        Right:= Left + fColorSize*2;
      end;   
      if (odsComboboxEdit in ItemState) then inc(Left);
    end;
    Canvas.Brush.Color := Color2RGB(clBlack);
    FillRect(DC,cbRect, Canvas.Brush.Handle);
    Canvas.Brush.Color := ItemData[ItemIdx];
    FillRect(DC, MakeRect(cbRect.Left+1,cbRect.Top+1,cbRect.Right-1,cbRect.Bottom-1), Canvas.Brush.Handle);
  end;
end;

//------------------   Доступ к массиву цветов   --------------------

procedure ThiColorBox._var_ColorArray;
begin
  if ColorArr = nil then
    ColorArr := CreateArray(nil,_val_arr_get,_val_arr_count,nil);
  dtArray(_Data, ColorArr);
end;

function ThiColorBox._val_arr_get;
var  ind:integer;
begin
  ind := ToIntIndex(Item);
  Result := (ind >=0) and (ind < Control.Count);
  if Result then
    dtInteger(Val,Control.ItemData[ind]);
end;

function ThiColorBox._val_arr_count;
begin
  Result := Control.Count;
end;

procedure ThiColorBox._var_Index;
begin
  dtInteger(_Data, Control.CurIndex);
end;

procedure ThiColorBox._var_CurrentColor;
var  dr,dg,db:TData;
     fFrom: TRGB;
begin
  case fFormatColor of
    0: dtInteger(_Data, integer(Control.ItemData[Control.CurIndex]));
    1: dtString(_Data, RGB2HTML(Control.ItemData[Control.CurIndex]));
    2: dtString(_Data, Int2Hex(Control.ItemData[Control.CurIndex],8)); 
    3: begin
         fFrom := TRGB(Control.ItemData[Control.CurIndex]);
         FreeData(@FData);
         dtNull(FData);
         dtInteger(dr,FFrom.R);
         dtInteger(dg,FFrom.G);
         dtInteger(db,FFrom.B);
         dr.ldata := @dg;
         dg.ldata := @db;
         CopyData(@FData,@dr);
         _Data := FData;
       end;
  end;
end;

procedure ThiColorBox._work_doSelectColor;
var  Clr: TColor;
     i:integer;
     valid:boolean;
begin
  Clr:= ToInteger(_Data);
  valid:= false;
  for i:= 0 to ColorRange - 1 do 
    if Control.ItemData[i] = dword(Color2RGB(Clr)) then
    begin
      valid:= true;
      break;
    end;
  if not valid then exit;
  Control.CurIndex := i;
end;

procedure ThiColorBox._work_doSelectName;
var  Clr: string;
begin
  Clr:= ToString(_Data);
  Replace(Clr,'cl','');
  Control.Perform(CB_SELECTSTRING,-1,LongInt(PChar(Clr)));
end;

end.