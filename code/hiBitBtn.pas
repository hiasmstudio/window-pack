unit hiBitBtn;

interface

uses Windows,Kol,Share,Win,messages;

{$I share.inc}

type
  THIBitBtn = class(THIWin)
   private
     FBmp,FNotEnable:PBitmap;

     procedure Transp;
     procedure SetBitmap(Value:HBITMAP);
     function _OnDraw( Sender: PControl; BtnState: Integer ): Boolean;
     procedure _OnClick(Obj:PObj);
   public
     _event_onClick:THI_Event;
     _prop_Caption:string;
     _prop_Data:TData;
     _prop_Frame:byte;
     _prop_FrameColor:TColor;

    constructor Create(Parent:PControl);
    destructor Destroy; override;
    procedure Init; override;
    procedure _work_doCaption(var _Data:TData; Index:word);
    procedure _work_doBitmap(var _Data:TData; Index:word);
    property _prop_Bitmap:HBITMAP write SetBitmap;
  end;

implementation

constructor THIBitBtn.Create;
begin
  inherited Create(Parent);
  FBmp := NewBitmap(0,0);
end;

destructor THIBitBtn.Destroy;
begin
  FBmp.free;
  inherited;
end;

procedure THIBitBtn.Init;
begin
  Control := NewBitBtn(FParent,_prop_Caption,[],glyphLeft,0,0);
  inherited;
  Control.Flat := _prop_Flat;
  Control.TextShiftX := 1;
  Control.TextShiftY := 1;
  Control.OnBitBtnDraw := _OnDraw;
  Control.OnClick := _OnClick;
end;

procedure THIBitBtn._OnClick;
begin
  _hi_OnEvent_(_event_onClick,_prop_Data);
end;

function THIBitBtn._OnDraw;
var r:TRect;FX,FY,i,j,g:integer;
begin
  r := Control.ClientRect;
  Result := true;
  with Control.Canvas{$ifndef F_P}^{$endif} do begin
    if Control.Flat then begin
      Brush.BrushStyle := bsSolid;
      Brush.Color := Control.Color;
      FillRect(r);
      if BtnState in [1,4] then begin //down, select
        Fx := BDR_SUNKENOUTER;
        if BtnState=4 then Fx := BDR_RAISEDINNER; //select
        DrawEdge(Handle,r,Fx,BF_RECT)
      end else if _prop_Frame=0 then begin
        Pen.PenStyle := psSolid;
        Pen.Color := _prop_FrameColor;
        Rectangle(0,0,Control.Width,Control.Height);
      end
    end else begin
      Fx := DFCS_BUTTONPUSH or DFCS_TRANSPARENT;
      if BtnState=1 then Fx := Fx or DFCS_PUSHED; //down
      DrawFrameControl(Handle,r,DFC_BUTTON,Fx);
    end;
    FX := 3;
    FY := (Control.Height - FBmp.Height) div 2;
    if Control.Caption = '' then
      FX := (Control.Width - FBmp.Width) div 2;
    if BtnState<>1 then begin //!down
      dec(FX); dec(FY);
      dec(r.Top,2);  dec(r.Left,2);
    end;
    if BtnState = 2 then
      begin
        if FNotEnable = nil then
         begin
           FNotEnable := NewBitmap(FBmp.Width, FBmp.Height);
           for i := 0 to FBmp.Width-1 do
            for j := 0 to FBmp.Height-1 do
             if FBmp.Pixels[i,j] = FBmp.Pixels[0,0] then
               FNotEnable.Pixels[i,j] := FBmp.Pixels[i,j] 
             else 
              begin
               g := FBmp.Pixels[i,j];
               g := ((g and $FF) + (g shr 8 and $FF) + (g shr 16 and $FF)) div 3; 
               FNotEnable.Pixels[i,j] := RGB(g,g,g);
              end; 
         end; 
        FNotEnable.Draw(Handle,FX,FY);
      end
    else
      FBmp.Draw(Handle,FX,FY);
    inc(r.Left,FBmp.width+3);
    dec(r.Right,3);
    Brush.BrushStyle := bsClear;
    if BtnState=2 then begin
      Font.Color := clWindow;
      inc(r.Top); inc(r.Left);
      inc(r.Bottom); inc(r.Right);
      DrawText(Control.Caption,r,DT_EXPANDTABS or DT_SINGLELINE or DT_CENTER or DT_VCENTER);
      dec(r.Top);  dec(r.Left);
      dec(r.Bottom); dec(r.Right);
      Font.Color := clBtnShadow;
    end else Font.Color := Control.Font.Color;
    DrawText(Control.Caption, r, DT_EXPANDTABS or DT_SINGLELINE or DT_CENTER or DT_VCENTER);
  end;
end;

procedure THIBitBtn._work_doCaption;
begin
   Control.Caption := ToString(_Data);
end;

procedure THIBitBtn._work_doBitmap;
begin
  FBmp.Assign(ToBitmap(_Data));
  Transp;
  Control.Invalidate;
end;

procedure THIBitBtn.SetBitmap;
begin
  FBmp.Handle := Value;
  Transp;
end;

procedure THIBitBtn.Transp;
var c,d:TColor;
    i,j:word;
begin
  if FBmp.Empty then exit;
  d := clBtnFace; if _prop_Flat then d := _prop_Color;
  c := FBmp.Pixels[0,0];
  for i := 0 to FBmp.Width-1 do
    for j := 0 to FBmp.Height-1 do
      if FBmp.Pixels[i,j] = c then
        FBmp.Pixels[i,j] := d;
end;

end.
