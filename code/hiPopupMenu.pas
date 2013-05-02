unit hiPopupMenu;

interface

uses Windows,Kol,Share,Messages,Debug;

type
  THIPopupMenu = class(TDebug)
   private
    PM:PMenu;
    FC:PControl;
    Old:TOnMessage;
    FMenuList: string;
    ListMenuStr: array  of string;

    procedure SetMenu(const Value:string);
    procedure AddMenuItem(const Caption:string);
//    function  _OnDraw( Sender: PObj; DC: HDC; const Rect: TRect; ItemIdx: Integer;
//                           DrawAction: TDrawAction; ItemState: TDrawState ): Boolean;
    function _OnMes( var Msg: TMsg; var Rslt: Integer ): Boolean;
    procedure RefBMP;
    procedure RefBMPall;    

    procedure Init;
   public
    _prop_TranspIcon:boolean;
    _event_onClick:THI_Event;
    _event_onSelectStr:THI_Event;
    _event_onEndPopup:THI_Event;
    _data_Bitmaps:THI_Event;

    property _prop_Menu: string write SetMenu;

    constructor Create(Control:PControl);
    destructor Destroy; override;
    procedure _work_doPopup(var _Data:TData; Index:word);
    procedure _work_doPopupHere(var _Data:TData; Index:word);
    procedure _work_doAddItem(var _Data:TData; Index:word);
    procedure _work_doClear(var _Data:TData; Index:word);
    procedure _var_Handle(var _Data:TData; Index:word);
//    property _prop_Menu:string write SetMenu;
  end;

implementation

constructor THIPopupMenu.Create;
begin
   inherited Create;
   FC := Control;
   old := FC.OnMessage;
//   PM := NewMenu(nil,0,[],nil);
end;

{$ifdef F_P}
var ListMenu: array[0..200] of PChar;
{$endif}

procedure THIPopupMenu.Init;
type TPCharArray = array[0..0] of PChar;
//     PPCharArray = ^TPCharArray;
var i:integer;
    List:PStrList;
   {$ifndef F_P}
   ListMenu: array of PChar;
   {$endif}
    //k:PPCharArray;
begin
   List := NewStrList;
   List.text := FMenuList;
   if List.Count > 0 then
    begin
     SetLength(ListMenuStr,List.Count);
     {$ifndef F_P}
     SetLength(ListMenu,List.Count);
     {$endif}
     //getmem(k,4*10);
     for i := 0 to List.Count-1 do
      begin
       ListMenuStr[i] := List.Items[i];
       ListMenu[i] := PChar(@ListMenuStr[i][1]);
       //k[i] := PChar(ListMenuStr[i]);
      end;
    end;
   if Assigned(PM) then PM.free;
   PM := NewMenu( nil, 0, ListMenu, nil );
   List.free;   
end;


(*
procedure THIPopupMenu.Init;
var   List:PStrList;
      i:integer;
begin
   List := NewStrList;
   List.text := _prop_Menu;
   for i := 0 to List.Count-1 do
      AddmenuItem(List.Items[i]);
   List.Free;
end;
*)

destructor THIPopupMenu.Destroy;
begin
   FC.OnMessage := old;
   PM.Free;
   inherited;
end;

function THIPopupMenu._OnMes;
var   m:PMenu;
begin
   case Msg.message of
      WM_COMMAND: begin
           m := PM.Items[Msg.WParam];
           if m <> nil then begin
              _hi_OnEvent(_event_onSelectStr,PM.Items[PM.IndexOf(m)].Caption);
              _hi_OnEvent(_event_onClick,PM.IndexOf(m));
         end;  
         end;
      end;
   Result := Old(Msg,Rslt);
end;

procedure THIPopupMenu.AddMenuItem;
begin
   if Caption = '-' then
      PM.AddItem('-',nil,[moSeparator])
   else
      PM.AddItem(PChar(Caption),nil,[]);
   Refbmp;
end;

procedure THIPopupMenu.RefBMP;
var   dt,Ind:TData;
      bmp:PBitmap;
      arr:PArray;
      i,j:integer;
      c:TColor;
begin
   Arr := ReadArray(_data_Bitmaps);
   if Arr = nil then exit;
   Ind := _DoData(PM.Count-1);
   Arr._Get(Ind,dt);
   bmp := PBitmap(dt.idata);
   if (_IsBitmap(dt)) and (bmp <> nil) and not bmp.Empty then begin
//      BmpTransparent(bmp);
      if _prop_TranspIcon then begin
         c := Bmp.Pixels[0,0];
         for i := 0 to Bmp.Width-1 do
            for j := 0 to Bmp.Height-1 do
               if Bmp.Pixels[i,j] = c then
//                  Bmp.Pixels[i,j] := clMenu;
                 Bmp.Pixels[i,j] := clNone;
      end;
      PM.Items[PM.Count-1].BitmapItem := CopyImage(bmp.Handle,IMAGE_BITMAP,0,0,LR_CREATEDIBSECTION);
   end;
end;

procedure THIPopupMenu.RefBMPall;
var   dt,Ind:TData;
      bmp:PBitmap;
      arr:PArray;
      i,j,k:integer;
      c:TColor;
begin
   Arr := ReadArray(_data_Bitmaps);
   if Arr = nil then exit;

   for k := 0 to min(Arr._Count - 1, PM.Count - 1) do
   begin 
     Ind := _DoData(k);
     Arr._Get(Ind,dt);
     bmp := PBitmap(dt.idata);
     if (_IsBitmap(dt)) and (bmp <> nil) and not bmp.Empty then
     begin
       if _prop_TranspIcon then
       begin
         c := Bmp.Pixels[0,0];
         for i := 0 to Bmp.Width-1 do
           for j := 0 to Bmp.Height-1 do
             if Bmp.Pixels[i,j] = c then
//               Bmp.Pixels[i,j] := clMenu;
               Bmp.Pixels[i,j] := clNone;
        end;
        PM.Items[k].BitmapItem := CopyImage(bmp.Handle,IMAGE_BITMAP,0,0,LR_CREATEDIBSECTION);
   end;
   end;
end;

procedure THIPopupMenu.SetMenu;
begin
  FMenuList := Value;
  Init;  
  FC.OnMessage := _OnMes;
end;

(*
function THIPopupMenu._OnDraw;
var bmp:PBitmap;
begin   // debug('ok');
   bmp := NewBitmap(0,0);
   bmp.Handle := Pm.ItemBitmap[ItemIdx];
   bmp.Draw(dc,1,Rect.Top);
   //with PM.Items[PM.Count-1]^ do
   // TextOut(dc,Rect.Left + 18,Rect.Top,PChar(Caption),Length(Caption));
   bmp.Handle := 0;
   bmp.Free;
   Result := true;
end;

*)

procedure THIPopupMenu._work_doPopup;
var   pos:cardinal;
begin
   pos := Cardinal(ToInteger(_data));
   RefBMPall;
   TrackPopupMenu(PM.Handle,0,pos and $ffff,pos shr 16,0,FC.Handle,nil);
   _hi_OnEvent(_event_onEndPopup);
end;

procedure THIPopupMenu._work_doAddItem;
begin
   AddMenuItem(ToString(_Data));
end;

procedure THIPopupMenu._work_doClear;
begin
   if Assigned(PM) then PM.Free;
   PM := NewMenu(nil,200,[],nil);
end;

procedure THIPopupMenu._work_doPopupHere;
var   pos:TPoint;
begin
   GetCursorPos(pos);
   SetForegroundWindow( FC.Handle );
   RefBMPall;
   with pos do
      TrackPopupMenu(PM.Handle,0,x,y,0,FC.Handle,nil);
   _hi_OnEvent(_event_onEndPopup);
end;

procedure THIPopupMenu._var_Handle;
begin
   dtInteger(_Data,PM.ItemHandle[0]);
end;

end.