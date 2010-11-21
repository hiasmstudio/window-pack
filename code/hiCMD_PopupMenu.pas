unit hiCMD_PopupMenu;

interface

uses Windows,Kol,Share,Debug,hiCommandCenter;

type
  THICMD_PopupMenu = class(TCI_Monitor)
   private
    PM:PMenu;
    cc:ICommandCenter;
    FBack:HBRUSH;
    FSelBack:HBRUSH;
    FFont,FBoldFont:HFONT;
    
//    FC:PControl;
    procedure SetCmd(value:ICommandCenter);  
    procedure _OnMenuItem(Sender:PMenu; ItemIdx:integer);
    function  _MeasureItem(Sender: PObj;  Idx: Integer): Integer;
    function  _DrawItem(Sender: PObj; DC: HDC; const Rect: TRect;
               ItemIdx: Integer; DrawAction: TDrawAction; ItemState: TDrawState): Boolean;
    procedure _onChangeState(obj:pointer; enabled, checked:boolean);
   public
    _prop_Menu:string;

    _event_onAction:THI_Event;
    _event_onRefresh:THI_Event;

    procedure onRefresh; override;

    constructor Create(Control:PControl);
    destructor  Destroy; override;
    procedure _work_doPopupHere(var _Data:TData; Index:word);
    procedure _work_doPopup(var _Data:TData; Index:word);
    property _prop_CommandCenter:ICommandCenter write SetCmd;
  end;

implementation

constructor THICMD_PopupMenu.Create;
begin
   inherited Create;
//   FC:= Control;
   PM := NewMenu(Control, 0, [], _OnMenuItem);
   FBack := CreateSolidBrush(GetSysColor(COLOR_BTNFACE));
   FSelBack := CreateSolidBrush(GetSysColor(29));
   
   FFont := CreateFont(14,5,0,0,FW_NORMAL,0,0,0,DEFAULT_CHARSET,0,0,0,0,'MS Sans Serif');
   FBoldFont := CreateFont(14,5,0,0,FW_BOLD,0,0,0,DEFAULT_CHARSET,0,0,0,0,'MS Sans Serif');
end;

destructor THICMD_PopupMenu.Destroy;
begin
   //PM.free;
   onDestroy(self);
   DeleteObject(FBack);
   DeleteObject(FSelBack);
   DeleteObject(FFont);
   DeleteObject(FBoldFont);
   inherited;
end;

procedure THICMD_PopupMenu.SetCmd;
var
   s:string;
   i,mi:integer;
   cmd:PCommandInfo;
   item:PCI_Item;
   list:PStrList;
   menu:PMenu;
begin
   cc := value;
   cc.AddMonitor(self);
   
   List := NewStrList;
   List.text := _prop_Menu;
   menu := PM;
   mi := -1;
   
  for i := 0 to List.Count-1 do
    begin
      s := List.Items[i];
      if s = '-' then
         menu.AddItem('-',nil,[moSeparator])
      else if s = '(' then
         menu := menu.Items[mi] 
      else if s = ')' then
         menu := menu.Parent
      else
        begin
          cmd := cc.findCmd(s);
          if cmd <> nil then
            begin
              mi := menu.AddItem(PChar(cmd.info),nil,[]);
              menu.Items[mi].Tag := cardinal(cmd);
              new(item);
              item.obj := menu.Items[mi];
              item.onChangeState := _onChangeState;
              cmd.items.Add(item); 
              menu.Items[mi].OnMeasureItem := _MeasureItem;
              menu.Items[mi].OnDrawItem := _DrawItem;
              menu.Items[mi].OwnerDraw := true;
            end
          else
            begin
              mi := menu.AddItem(PChar(s),nil,[]);
              menu.Items[mi].OnDrawItem := _DrawItem;
              menu.Items[mi].OwnerDraw := true;
            end;
        end;  
    end;
  List.Free;
end;

function TextExtent(const Text: string): TSize;
var   DC: HDC;
begin
   DC := CreateCompatibleDC( 0 );
   //SelectObject(DC, GFont.Handle);
   GetTextExtentPoint32( DC, PChar(Text), Length(Text), Result);
   DeleteDC(DC);
end;

function  THICMD_PopupMenu._MeasureItem(Sender: PObj;  Idx: Integer): Integer;
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

function  THICMD_PopupMenu._DrawItem;
var cmd:PCommandInfo;
begin
   cmd := PCommandInfo(PMenu(Sender).Tag);

   if (odsSelected in ItemState) and not (odsDisabled in ItemState) then
      FillRect(DC, Rect, FSelBack)
   else FillRect(DC, Rect, FBack);

   if (cmd <> nil)and(cmd.icon <> -1)then
     cc.IList.Draw(cmd.icon, DC, Rect.Left + 1, Rect.Top + 1);

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

procedure THICMD_PopupMenu._onChangeState;
begin
  PMenu(obj).Enabled := Enabled;
  PMenu(obj).Checked := checked;
end;

procedure THICMD_PopupMenu.onRefresh;
begin
   _hi_onEvent(_event_onRefresh);
end;

procedure THICMD_PopupMenu._OnMenuItem;
var cmd:PCommandInfo;  
begin
  cmd := PCommandInfo(Sender.Items[itemidx].Tag);
  _hi_onEvent(_event_onAction, cmd.name);   
  cc.event(cmd);
end;

procedure THICMD_PopupMenu._work_doPopupHere;
var   pos:TPoint;
begin
   GetCursorPos(pos);
   PM.Popup(pos.x, pos.y);
end;

procedure THICMD_PopupMenu._work_doPopup;
//var   pos:cardinal;
begin
   //pos := Cardinal(ToInteger(_data));
   //TrackPopupMenu(PM.Handle,0,pos and $ffff,pos shr 16,0,FC.Handle,nil);
end;

end.
