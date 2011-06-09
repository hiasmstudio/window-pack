unit hiToolBar;

interface

{$I share.inc}

uses Windows,Kol,Share,Win;

type
  THIToolBar = class(THIWin)
   private
    {$ifdef F_P}
    Cap:array[0..50] of PChar;
    Tips:array[0..50] of PChar;
    {$endif}
    Btns:array of string;
    BCount:word;
    Bmp:PBitmap;

    procedure SetBtns(Value:PStrListEx);
    procedure _OnClick(Obj:PObj);
    procedure _OnTBDropDown(Obj:PObj);    
   public
    _prop_Caption:byte;
    _prop_Flat:boolean;
    _prop_Wrapable:boolean;

    _event_onClick:THI_Event;
    _event_onTBDropDown:THI_Event;    

    destructor Destroy; override; 
    procedure Init; override;
    procedure _work_doEnable(var _Data:TData; Index:word);
    procedure _work_doDisable(var _Data:TData; Index:word);
    property _prop_Buttons:PStrListEx write SetBtns;
  end;

implementation

destructor THIToolBar.Destroy;
begin
   Bmp.free;
   inherited;
end;

procedure THIToolBar.Init;
var
   Fl:TToolbarOptions;
{$ifndef F_P}
   Cap:array of PChar;
   Tips:array of PChar;
{$endif}
   Indx:array of integer;
   i,cnt,p:integer;
begin
   Fl := [];
   if _prop_Flat then
     Include(Fl,tboFlat);

   if _prop_Caption = 1 then
     Include(Fl,tboTextBottom)
   else Include(Fl,tboTextRight);

   if _prop_Wrapable then
     Include(Fl,tboWrapable);

   if _prop_Ctl3D = 1 then
     Include(Fl,tbo3DBorder);
   _prop_Ctl3D  := 1; 

   Include(Fl,tboTransparent);

   cnt := BCount;
   if cnt > 0 then
   begin
    {$ifndef F_P}
     SetLength(Cap,cnt);
     SetLength(Tips,cnt);
    {$endif}
     SetLength(Indx,cnt);
     for i := 0 to cnt-1 do
     begin
       p := Pos('=',Btns[i]);
       //if Pos('=',Btns[i]) > 0 then
       if p > 0 then
       begin
         Btns[i][p] := #0;
         Cap[i] := PChar(@Btns[i][1]);
         Tips[i] := PChar(@Btns[i][p+1]);
       end
       else
       begin
         if Btns[i] = '' then
           Cap[i] := ''
         else Cap[i] := PChar(@Btns[i][1]);
           Tips[i] := nil;
       end;
       Indx[i] := i;
     end;
   end;
   if bmp = nil then bmp := NewBitmap(0,0);
   Control := NewToolbar(FParent,_prop_Align,Fl,Bmp.Handle,Cap,Indx);
   Control.Style := Control.Style and not TBSTYLE_TRANSPARENT;
   Control.OnTBDropDown := _OnTBDropDown;
   Control.OnClick := _OnClick;
   Control.TBSetTooltips(Control.TBIndex2Item(0),Tips);
   inherited;
end;

procedure THIToolBar._work_doEnable;
var ind:integer;
begin
   ind := ToInteger(_Data);
   if(ind >=0 )and(ind < Control.TBButtonCount)then
     Control.TBButtonEnabled[ind] := true;
end;

procedure THIToolBar._work_doDisable;
var ind:integer;
begin
   ind := ToInteger(_Data);
   if(ind >=0 )and(ind < Control.TBButtonCount)then
     Control.TBButtonEnabled[ind] := false;
end;

procedure THIToolBar._OnClick;
begin
   if not Control.RightClick then
     _hi_OnEvent(_event_onClick,Control.CurIndex);
end;

procedure THIToolBar._OnTBDropDown(Obj:PObj);
var
  pos: TPoint;
  r: TRect;
  dtidx, dtpos: TData;
begin
  r := Control.TBButtonRect[Control.CurItem];
  pos.x := r.left;
  pos.y := r.bottom;
  pos := Control.Client2Screen(pos);
  dtInteger(dtidx, Control.CurItem mod 100);
  dtInteger(dtpos, pos.y shl 16 + pos.x);
  dtidx.ldata := @dtpos;
  _hi_onEvent_(_event_onTBDropDown, dtidx); 
end;

procedure THIToolBar.SetBtns;
var i:integer;
    tmp:PBitmap;
    r:TRect;
begin
   BCount := Value.Count;
   SetLength(Btns,BCount);
   tmp := NewBitmap(0,0);

   for i := 0 to Value.Count-1 do
     if Value.Objects[i] <> 0 then
     begin
       tmp.Handle := Value.Objects[i];
       Break;
     end;

   Bmp := NewBitmap(tmp.Width*Value.count,tmp.Height);

   for i := 0 to Value.Count-1 do
   begin
     Btns[i] := Value.Items[i];
     if i <> 0 then
       tmp.Handle := Value.Objects[i];
     with Tmp{$ifndef F_P}^{$endif} do
       if Width > 0 then
       begin
         r.left := i*Width;
         r.Right := R.Left + Width;
         r.Top := 0;
         r.Bottom := Height;
         BmpTransparent(tmp);
         Bmp.CopyRect(r,tmp,BoundsRect);
       end;
   end;
   tmp.free;
   Value.free;
end;

end.
