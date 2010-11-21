unit hiActionSkin;

interface

uses Windows,Kol,Share,Debug,Win;

type
  TRectParam = record
    R:TRect;
    Cursor:integer;
  end;
  PRectParam = ^TRectParam;
  TDRectParam = record
    R:TRect;
    Bmp:PBitmap;
    Transp:boolean;
    Color:cardinal;
  end;
  PDRectParam = ^TDRectParam;
  THIActionSkin = class(THIWin)
   private
    RList:PStrListEx;
    DList:PStrListEx;
    OldIndex:integer;
    FDown:integer;

    procedure _OnPaint( Sender: PControl; DC: HDC );
    procedure _onMouseDown(Sender: PControl; var Mouse: TMouseEventData); override;
    procedure _onMouseMove(Sender: PControl; var Mouse: TMouseEventData); override;
    procedure _onMouseUp(Sender: PControl; var Mouse: TMouseEventData); override;
    function Find(X,Y:integer):integer;
   public
    Bmp:PBitmap;
    ABmp:PBitmap;
    DBmp:PBitmap;
    Main:PBitmap;

    //Control:PControl;
    _prop_SkinFile:string;
    _prop_ActiveSkinFile:string;
    _prop_DownSkinFile:string;
    _prop_HandPoint:boolean;

    _event_onRMouseLeave:THI_Event;
    _event_onRMouseEnter:THI_Event;
    _event_onRMouseUp:THI_Event;
    _event_onRMouseDown:THI_Event;

    constructor Create(Parent:PControl);
    destructor Destroy; override;
    procedure Init; override;
    procedure AddRect(const Name:string; X1,Y1,X2,Y2:integer; _Cursor:integer);
    procedure AddDRect(const Name:string; X1,Y1,X2,Y2:integer; _Transp:boolean; _Color:integer);
    procedure _var_ASHandle(var _Data:TData; Index:Word);

    property RectList:PStrListEx read RList;
    property DrawList:PStrListEx read DList;
  end;

var AS_GUID:integer;

implementation

constructor THIActionSkin.Create(Parent:PControl);
begin
   inherited;
   Control := NewPaintbox(Parent);
   SetClassLong(Control.Handle,GCL_STYLE,GetClassLong(Control.GetWindowHandle,GCL_STYLE) and not CS_DBLCLKS);
   OldIndex := -1;
   FDown := -1;
   _prop_MouseCapture := true;
   
   GenGUID(AS_GUID);
end;

destructor THIActionSkin.Destroy;
var i:integer;
begin
   Bmp.Free;
   for i := 0 to RList.Count-1 do
    FreeMem(pointer(RList.Objects[i]));
   RList.Free;
   for i := 0 to DList.Count-1 do
    begin
     PDRectParam(DList.Objects[i]).Bmp.Free;
     FreeMem(pointer(DList.Objects[i]));
    end;
   DList.Free;
   inherited;
end;

procedure THIActionSkin._OnPaint( Sender: PControl; DC: HDC );
begin
  if Main = nil then
    FillRect(dc,Sender.ClientRect,GetSysColorBrush(COLOR_BTNSHADOW))
  else Main.Draw(DC,0,0);
end;

procedure THIActionSkin.Init;
begin
   inherited;
   Control.OnPaint := _OnPaint;
   //Control.OnMouseDown := _onMouseDown;
   //Control.OnMouseUp := _onMouseUp;
   //Control.OnMouseMove := _onMouseMove;
   if FileExists(_prop_SkinFile) then
    begin
      Bmp := NewBitmap(0,0);
      Bmp.LoadFromFile(_prop_SkinFile);
      Main := NewBitmap(0,0);
      Main.Assign(Bmp);
    end;
   if FileExists(_prop_ActiveSkinFile) then
    begin
      ABmp := NewBitmap(0,0);
      ABmp.LoadFromFile(_prop_ActiveSkinFile);
    end;
   if FileExists(_prop_DownSkinFile) then
    begin
      DBmp := NewBitmap(0,0);
      DBmp.LoadFromFile(_prop_DownSkinFile);
    end;
   //Control.Show;

   RList := NewStrListEx;
   DLIst := NewStrListEx;
end;

function THIActionSkin.Find;
type PRect = ^TRect;
begin
   for Result := 0 to RList.Count-1 do
    if PtInRect(PRectParam(RList.Objects[Result]).r,MakePoint(X,Y)) then
      Exit;
   Result := -1;
end;

procedure THIActionSkin._onMouseDown;
var i:integer;
begin
   inherited;
   i := Find(Mouse.X,Mouse.Y);
   if i <> -1 then
    begin
      _hi_OnEvent(_event_onRMouseDown,RList.Items[i]);
      if DBmp <> nil then
       with PRectParam(RList.Objects[i]).r do
        BitBlt(Control.Canvas.Handle,left,top,right-left,bottom-top,DBmp.Canvas.Handle,left,top,SRCCOPY);
      FDown := i;
    end;
end;

procedure THIActionSkin._onMouseMove;
var i:integer;
begin
   inherited;
   i := Find(Mouse.X,Mouse.Y);

   if GetKeyState(1) >= 0 then
    FDown := -1;

   if (i <> OldIndex) then
    begin

     if (Bmp <> nil)and(oldIndex <> -1) then
      with PRectParam(RList.Objects[oldIndex]).r do
       BitBlt(Control.Canvas.Handle,left,top,right-left,bottom-top,Bmp.Canvas.Handle,left,top,SRCCOPY);

     if (OldIndex = -1)or(i <> -1) then
      begin
        if (FDown = -1)or(FDown = i) then _hi_OnEvent(_event_onRMouseEnter,RList.Items[i]);
        if _prop_HandPoint then
         Control.Cursor := crHandPoint
        else Control.Cursor := PRectParam(RList.Objects[i]).Cursor;

        if (FDown = -1)or((FDown = i)and(DBmp = nil)) then
         begin
          if ABmp <> nil then
           with PRectParam(RList.Objects[i]).r do
            BitBlt(Control.Canvas.Handle,left,top,right-left,bottom-top,ABmp.Canvas.Handle,left,top,SRCCOPY);
         end
        else
         if (DBmp <> nil)and(FDown = i) then
          with PRectParam(RList.Objects[i]).r do
           BitBlt(Control.Canvas.Handle,left,top,right-left,bottom-top,DBmp.Canvas.Handle,left,top,SRCCOPY);

      end
     else
      begin
        _hi_OnEvent(_event_onRMouseLeave,RList.Items[OldIndex]);
        Control.Cursor := crDefault;
      end;
    end;
   OldIndex := i;
end;

procedure THIActionSkin._onMouseUp;
var i:integer;
begin
   inherited;
   i := Find(Mouse.X,Mouse.Y);
   if (i <> -1)and(i = FDown) then
    begin
     if ABmp <> nil then
      with PRectParam(RList.Objects[oldIndex]).r do
       BitBlt(Control.Canvas.Handle,left,top,right-left,bottom-top,ABmp.Canvas.Handle,left,top,SRCCOPY);
     _hi_OnEvent(_event_onRMouseUp,RList.Items[i]);
    end;
   FDown := -1;
end;

procedure THIActionSkin.AddRect;
var r:PRectParam;
begin
   new(r);
   with r^ do
    begin
      r.Left := X1;
      r.Top := Y1;
      r.Right := X2;
      r.Bottom := Y2;
      Cursor := _Cursor;
    end;
   RList.Add(Name);
   RList.Objects[RList.Count-1] := cardinal(r);
end;

procedure THIActionSkin.AddDRect;
var r:PDRectParam;
begin
   new(r);
   with r^ do
    begin
      r.Left := X1;
      r.Top := Y1;
      r.Right := X2;
      r.Bottom := Y2;
      Transp := _Transp;
      Bmp := NewBitmap(X2-X1,Y2-Y1);
      //Bmp.PixelFormat := pf24bit;
      Color := _Color;
    end;
   DList.Add(Name);
   DList.Objects[DList.Count-1] := cardinal(r);
end;

procedure THIActionSkin._var_ASHandle;
begin
   dtObject(_Data,AS_GUID,Self);
end;

end.
