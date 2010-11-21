unit hiCMD_ToolBar;

interface

uses Messages,Windows,Kol,Share,Debug,hiCommandCenter,Win;

type
  THICMD_ToolBar = class(TCI_Monitor)
   private
    TB:PControl;
    imgs:PStrListEx;
    popups:PStrListEx;
    
    FBack:HBRUSH;
    FSelBack:HBRUSH;
    FFont,FBoldFont:HFONT;

    procedure Clear;
    procedure SetToolBar(value:IControlManager);
    procedure _onChangeState(obj:pointer; enabled, checked:boolean);
    procedure _OnClick(Obj:PObj);
    procedure _OnTBDropDown(Obj:PObj);

    procedure _OnMenuItem(Sender:PMenu; ItemIdx:integer);
    function  _MeasureItem(Sender: PObj;  Idx: Integer): Integer;
    function  _DrawItem(Sender: PObj; DC: HDC; const Rect: TRect;
               ItemIdx: Integer; DrawAction: TDrawAction; ItemState: TDrawState): Boolean;
    procedure _onMChangeState(obj:pointer; enabled, checked:boolean);
   public
    _prop_CommandCenter:ICommandCenter;
    _prop_Menu:string;

    _event_onAction:THI_Event;
    _event_onRefresh:THI_Event;

    procedure onRefresh; override;

    destructor destroy; override;
    property _prop_ToolBar:IControlManager write SetToolBar;
  end;

implementation
//TBButtonEnabled
//TBButtonChecked
//check: +caption or -caption

destructor THICMD_ToolBar.destroy;
begin
  onDestroy(self);
  Clear;
  imgs.free;
  popups.free;
  DeleteObject(FBack);
  DeleteObject(FSelBack);
   DeleteObject(FFont);
   DeleteObject(FBoldFont);
  inherited;
end;

procedure THICMD_ToolBar.Clear;
var i:integer;
begin
  for i := 0 to imgs.Count-1 do
    PBitmap(imgs.objects[i]).free;
//  for i := 0 to popups.Count-1 do
//    PMenu(popups.objects[i]).free;
end;

procedure THICMD_ToolBar.SetToolBar;
var
   list:PStrList;
   i,b:integer;
   cap,s:string;
   cmd:PCommandInfo;
   bmp:PBitmap;
   item:PCI_Item;
   menu:PMenu;
   mi:integer;
      
   procedure addMenu(const text:string);
   var item:PCI_Item;
   begin
      if text = '-' then
         menu.AddItem('-',nil,[moSeparator])
      else if text = '(' then
         menu := menu.Items[mi] 
      else if text = ')' then
         menu := menu.Parent
      else
        begin
          cmd := _prop_CommandCenter.findCmd(text);
          if cmd <> nil then
            begin
              mi := menu.AddItem(PChar(cmd.info),nil,[]);
              menu.Items[mi].Tag := cardinal(cmd);
              new(item);
              item.obj := menu.Items[mi];
              item.onChangeState := _onMChangeState;
              cmd.items.Add(item); 
              menu.Items[mi].OnMeasureItem := _MeasureItem;
              menu.Items[mi].OnDrawItem := _DrawItem;
              menu.Items[mi].OwnerDraw := true;
            end
          else
            begin
              mi := menu.AddItem(PChar(text),nil,[]);
              menu.Items[mi].OnDrawItem := _DrawItem;
              menu.Items[mi].OwnerDraw := true;
            end;
        end; 
   end;
begin
   _prop_CommandCenter.AddMonitor(self);

   Tb := value.ctrlpoint;
   
   List := NewStrList;
   List.text := _prop_Menu;
   
   imgs := NewStrListEx;
   popups := NewStrListEx;

   FBack := CreateSolidBrush(GetSysColor(COLOR_BTNFACE));
   FSelBack := CreateSolidBrush(GetSysColor(29));
   FFont := CreateFont(14,5,0,0,FW_NORMAL,0,0,0,DEFAULT_CHARSET,0,0,0,0,'MS Sans Serif');
   FBoldFont := CreateFont(14,5,0,0,FW_BOLD,0,0,0,DEFAULT_CHARSET,0,0,0,0,'MS Sans Serif');
   
   menu := nil;
   for i := 0 to List.Count-1 do
     begin
        cap := list.Items[i];
        if menu <> nil then
          begin
            AddMenu(cap);
            continue;
          end;
          
        if cap = '-' then
          begin
            s := '-';
            tb.TBAddButtons([PChar(s)], [-1]);
            continue;
          end
        else if cap = '(' then
          begin
            menu := NewMenu(tb.Parent, 0, [], _OnMenuItem);
            popups.addObject(list.Items[i-1], cardinal(menu));
            continue;
          end;
                 
        cmd := _prop_CommandCenter.findCmd(cap);
        if cmd <> nil then
          begin            
            bmp := NewBitmap(_prop_CommandCenter.IList.ImgWidth,_prop_CommandCenter.IList.ImgHeight);
            bmp.Canvas.pen.PenStyle := psClear;
            bmp.Canvas.Brush.Color := clBtnFace;
            bmp.Canvas.Rectangle(0,0,17,17);
            _prop_CommandCenter.IList.Draw(cmd.icon, bmp.canvas.handle, 0, 0);
            bmp.Pixels[1,1] := bmp.Pixels[1,1]; // костыль очередной
            tb.TBAddBitmap(bmp.handle);
            
            cap := ' ';
            if(i+1 < list.Count)and(list.Items[i+1] = '(')then 
              cap := '^' + cap;
            if cmd.flags and FLG_CHECK > 0 then
              cap := '-' + cap;
              
            b := tb.TBAddButtons([PChar(cap)], [imgs.Count]);
              
            tb.TBSetTooltips(b, [PChar(cmd.info)]);
            imgs.AddObject(cmd.name, cardinal(bmp));

            new(item);
            item.obj := pointer(b);
            item.onChangeState := _onChangeState;
            cmd.items.Add(item); 
          end;
     end;
   List.Free;
   tb.OnTBDropDown := _OnTBDropDown;
   tb.OnClick := _OnClick;
end;

procedure THICMD_ToolBar._OnClick(Obj:PObj);
var
  cmd:PCommandInfo;
begin
   if not tb.RightClick and (tb.CurItem <> -1) then
     begin
        cmd := _prop_CommandCenter.findCmd(imgs.Items[tb.TBButtonImage[tb.CurIndex]]); 
        _hi_OnEvent(_event_onAction, cmd.name);
        _prop_CommandCenter.event(cmd);
     end;
end;

procedure THICMD_ToolBar._OnMenuItem;
var cmd:PCommandInfo;  
begin
  cmd := PCommandInfo(Sender.Items[itemidx].Tag);
  _hi_onEvent(_event_onAction, cmd.name);   
  _prop_CommandCenter.event(cmd);
end;

function TextExtent(const Text: string): TSize;
var   DC: HDC;
begin
   DC := CreateCompatibleDC( 0 );
   GetTextExtentPoint32( DC, PChar(Text), Length(Text), Result);
   DeleteDC(DC);
end;

function  THICMD_ToolBar._MeasureItem(Sender: PObj;  Idx: Integer): Integer;
var t:integer;
begin
  with TextExtent(PMenu(Sender).Caption) do
    begin
      if PMenu(Sender).parent = nil then
        t := 0
      else t := 16;
      Result := cY + 2 + (cX + t) shl 16;
    end;
end;

function  THICMD_ToolBar._DrawItem;
var cmd:PCommandInfo;
begin
   cmd := PCommandInfo(PMenu(Sender).Tag);

   if (odsSelected in ItemState) and not (odsDisabled in ItemState) then
      FillRect(DC, Rect, FSelBack)
   else FillRect(DC, Rect, FBack);

   if (cmd <> nil)and(cmd.icon <> -1)then
     _prop_CommandCenter.IList.Draw(cmd.icon, DC, Rect.Left + 1, Rect.Top + 1);

   SetBkMode(DC, TRANSPARENT);
   if (odsDisabled in ItemState) then
     SetTextColor(DC, GetSysColor(COLOR_BTNSHADOW))
   else SelectObject(DC, clBlack);
   if (odsChecked in ItemState) then
     SelectObject(DC, FBoldFont)
   else SelectObject(DC, FFont);
   TextOut(DC, Rect.Left + 24, Rect.Top + 1, PChar(PMenu(Sender).Caption), length(PMenu(Sender).Caption));
   Result := true; 
end;

procedure THICMD_ToolBar._onMChangeState;
begin
  PMenu(obj).Enabled := Enabled;
  PMenu(obj).Checked := checked;
end;

procedure THICMD_ToolBar.onRefresh;
begin
   _hi_onEvent(_event_onRefresh);
end;

procedure THICMD_ToolBar._OnTBDropDown(Obj:PObj);
var c:string;
    i:integer;
    pos:TPoint;
    r:TRect;
begin
  r := tb.TBButtonRect[tb.CurItem];
  c := imgs.Items[tb.TBButtonImage[tb.CurIndex]]; 
  i := popups.indexof(c);
  pos.x := r.left;
  pos.y := r.bottom;
  pos := tb.Client2Screen(pos);
  PMenu(popups.objects[i]).popup(pos.x, pos.y);
end;

procedure THICMD_ToolBar._onChangeState;
begin
  tb.TBButtonEnabled[integer(obj)] := Enabled;
  tb.TBButtonChecked[integer(obj)] := checked;
end;

end.
