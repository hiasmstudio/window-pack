unit ListEdit;

interface

{$I share.inc}

uses Share, KOL, Windows, Messages, objects;

const
   WM_JUSTFREE = WM_USER + 1;
   WM_EDITFREE = WM_USER + 2;
   WM_DBLCLICK = WM_USER + 3;

type
   {$ifdef F_P}
   TListEdit = class;
   PListEdit = TListEdit;
   TKOLListEdit = PControl;
   TListEdit = class(Tobj)
   {$else}
   PListEdit =^TListEdit;
   TKOLListEdit = PControl;
   TListEdit = object(Tobj)
   {$endif}
   
     EList: PList;
     Enter: boolean;
     LView: PControl;
     TabSave: boolean;
     TabStrt: boolean;
     OldWind: longint;
     NewWind: longint;
     CurEdit: integer;
     OnLineChange:TOnLVColumnClick;
     OnBeforeLineChange:TOnLVColumnClick;
     
     destructor destroy; {$ifdef F_P}override{$else}virtual{$endif};
     procedure SetEvents(LV: PControl);
     procedure NewWndProc(var Msg: TMessage);
     procedure LVPaint;
     procedure LVDblClk;
     procedure LVChange(Store: boolean);
     procedure PostFree(Key: integer);
     procedure EDChar(Sender: PControl; var Key: integer; Sh: Cardinal);
     procedure EDPres(Sender: PControl; var Key: integer; Sh: Cardinal);
   end;

function NewListEdit(AParent: PControl; Style: TListViewStyle; Options: TListViewOptions;
  ImageListSmall, ImageListNormal, ImageListState: PImageList; OnLineChange,OnBeforeLineChange:TOnLVColumnClick): PControl;

implementation

function NewListEdit;
var p: PListEdit;
begin
   Result := NewListView(AParent, Style, Options, ImageListSmall, ImageListNormal, ImageListState);
   Result.CreateWindow;
   {$ifdef F_P}
   p := PListEdit.Create;
   {$else}
   New(p, create);
   {$endif}
   
   AParent.Add2AutoFree(p);
   p.LView := Result;
   p.OnLineChange := OnLineChange;
   p.OnBeforeLineChange := OnBeforeLineChange;
   p.SetEvents(PControl(Result));
end;

destructor TListEdit.destroy;
var i:integer;
begin
   for i := 0 to EList.Count - 1 do
      PControl(EList.Items[i]).Free;
   EList.Free;
   SetWindowLong(LView.Handle, GWL_WNDPROC, OldWind);
   FreeObjectInstance(Pointer(NewWind));
   inherited;
end;

procedure TListEdit.SetEvents;
begin
   EList              := NewList;
   Enter              := False;
   TabStrt            := False;
   OldWind := GetWindowLong(LV.Handle, GWL_WNDPROC);
   NewWind := LongInt(MakeObjectInstance(NewWndProc));
   SetWindowLong(LV.Handle, GWL_WNDPROC, NewWind);
end;

procedure TListEdit.NewWndProc;
var e: boolean;
begin
   e := EList.Count > 0;
   case Msg.Msg of
WM_LBUTTONDOWN:
      begin
         LVChange(True);
         CurEdit := 0;
         //if e then PostMessage(LView.Handle, WM_DBLCLICK, 0, 0);
      end;
WM_LBUTTONDBLCLK:
      begin
         LVDblClk;
      end;
WM_KEYDOWN:
      begin
         if Msg.WParam = 13 then begin
            LVDblClk;
         end else
         if Msg.WParam = 27 then begin
            LVChange(False);
         end else begin
            LVChange(True);
            if e then PostMessage(LView.Handle, WM_DBLCLICK, 0, 0);
         end;
      end;
WM_NCPAINT:
      begin
         LVPaint;
      end;
WM_JUSTFREE:
      begin
         LVChange(Msg.WParam <> 27);
      end;
WM_EDITFREE:
      begin
         LVChange(Msg.WParam <> 27);
         if e then PostMessage(LView.Handle, WM_DBLCLICK, 0, 0);
      end;
WM_DBLCLICK:
      begin
         LVDblClk;
      end;
WM_PRINTCLIENT,
WM_PAINT:
      begin
         LVPaint;
      end;
WM_USER+100:
      if Assigned(OnLineChange) then
        OnLineChange(LView, Msg.wParam);
   end;
   Msg.Result := CallWindowProc(Pointer(OldWind), LView.Handle, Msg.Msg, Msg.wParam, Msg.lParam);
end;

procedure TListEdit.LVPaint;
var i: integer;
    r: TRect;
    l: integer;
    e: PControl;
begin
  {$ifdef F_P}
  with LView do
  {$else}
  with LView^ do
  {$endif}
  begin
   l := LVItemRect(LVCurItem, lvipBounds).Left;
   for i := 0 to EList.Count - 1 do begin
      r := LVItemRect(LVCurItem, lvipBounds);
      r.Left  := l;
      r.Right := l + LVColWidth[i];
      Dec(r.Top);
      Inc(r.Bottom);
      e := EList.Items[i];
      e.BoundsRect := r;
      l := l + LVColWidth[i];
   end;
 end;
end;

procedure TListEdit.LVDblClk;
var i: integer;
    e: PControl;
    r: TRect;
    l: integer;
    a: PControl;
    p: TPoint;
begin
  {$ifdef F_P}
  with LView do
  {$else}
  with LView^ do
  {$endif}
  begin
   if EList.Count <> 0 then LVChange(True);
   if enter then exit;
   enter := true;
   if Assigned(OnBeforeLineChange) then
     OnBeforeLineChange(LView, LVCurItem);
   l := LVItemRect(LVCurItem, lvipBounds).Left;
   a := nil;
   GetCursorPos(p);
   p := Screen2Client(p);
   for i := 0 to LVColCount - 1 do begin
      r := LVItemRect(LVCurItem, lvipBounds);
      r.Left  := l;
      r.Right := l + LVColWidth[i];
      Dec(r.Top);
      Inc(r.Bottom);
      e := NewEditBox(LView, []);
      e.CreateWindow;
      if a = nil then a := e;
      EList.Add(e);
      e.BoundsRect := r;
      l := l + LVColWidth[i];
      e.DoubleBuffered := True;
      e.Tabstop        := True;
      e.Text           := LVItems[LVCurItem, i];
      e.OnKeyDown      := EDChar;
      e.OnKeyUp        := EDPres;
      e.Show;
      if (CurEdit <>  0) then
      if (EList.Count = CurEdit) then a := e else else
      if (r.Left <= p.x) and (r.Right >= p.x) then
          a := e;
   end;
   if a <> nil then a.Focused := True;
   TabSave := TabStop;
   TabStop := False;
   TabStrt := True;
   enter := false;
end;
end;

procedure TListEdit.LVChange;
var e: PControl;
    i: integer;
    //o: boolean;
    //c: Char;
begin
  {$ifdef F_P}
  with LView do
  {$else}
  with LView^ do
  {$endif}
  begin
   if enter then exit;
   enter := true;
   //o := True;
   for i := 0 to EList.Count - 1 do begin
      e := EList.Items[i];
      if Store then
        LVItems[LVCurItem, i] := e.Text;
      if e.Focused then CurEdit := i + 1;
      e.Free;
      //o := False;
   end;
   if (EList.Count > 0) then
    PostMessage(Handle, WM_USER+100, LVCurItem, 0);
   EList.Clear;
   enter := false;
   if TabStrt then TabStop := TabSave;
   LView.Focused := True;
  end;
end;

procedure TListEdit.PostFree;
begin
  {$ifdef F_P}
  with LView do
  {$else}
  with LView^ do
  {$endif}
  begin
   if Key <> 27 then
      PostMessage(Handle, WM_EDITFREE, key, 0)
                else
      PostMessage(Handle, WM_JUSTFREE, key, 0);
   if (Key <> 13) and
      (Key <> 27) then begin
      PostMessage(Handle, wm_keydown, Key, 0);
      PostMessage(Handle, wm_keyup, Key, 0);
   end;
end;
end;

procedure TListEdit.EDChar;
begin
   case key of
 13,
 27,
 38,
 40: PostFree(key);
   end;
end;

procedure TListEdit.EDPres;
begin
   case key of
 38,
 40: key := 0;
   end;
end;

end.