unit hiImgBtn;

interface

uses Windows,Kol,Share,Win,Messages;

{$I share.inc}

type
  THIImgBtn = class(THIWin)
   private
    hRegion: HRGN;
    BNormal,BSelect,BDown,BEnabled:pbitmap;
    blend: TBlendFunction;
    procedure SetNormal(Value:HBITMAP);
    procedure SetSelect(Value:HBITMAP);
    procedure SetDown(Value:HBITMAP);
    procedure SetBEnabled(Value:HBITMAP);
    function _OnDraw( Sender: PControl; BtnState: Integer ): Boolean;
    procedure _onMouseDown(Sender: PControl; var Mouse: TMouseEventData); override;    
    procedure _onMouseUp(Sender: PControl; var Mouse: TMouseEventData); override;
    procedure _OnClick(Obj:PObj);
   public
    _prop_Split:boolean;
    _event_onClick:THI_Event;

    _prop_Alpha:boolean;
    _prop_AlphaBlendValue:integer;

    constructor Create(Parent: PControl);
    procedure Init; override;
    destructor Destroy; override;
    property _prop_Normal:HBITMAP write SetNormal;
    property _prop_Select:HBITMAP write SetSelect;
    property _prop_Down:HBITMAP write SetDown;
    property _prop_Enable:HBITMAP write SetBEnabled;
    procedure _work_doNormal(var _Data:TData; Index:word);
    procedure _work_doSelect(var _Data:TData; Index:word);
    procedure _work_doDown(var _Data:TData; Index:word);
    procedure _work_doEnable(var _Data:TData; Index:word);
    procedure _var_Normal(var _Data:TData; Index:word);
  end;

implementation

uses hiMainForm;

function _AlphaBlend(hdcDest: HDC; nXOriginDest, nYOriginDest, nWidthDest, nHeightDest: Integer;
                     hdcSrc: HDC; nXOriginSrc, nYOriginSrc, nWidthSrc, nHeightSrc: Integer;
                     blendFunction: TBlendFunction): BOOL; stdcall;
                     external 'msimg32.dll' name 'AlphaBlend';

constructor THIImgBtn.Create;
begin
   inherited Create(Parent);
   BNormal := NewBitmap(0,0);
   BSelect := NewBitmap(0,0);
   BDown := NewBitmap(0,0);
   BEnabled := NewBitmap(0,0);
end;

destructor THIImgBtn.Destroy;
begin
   DeleteObject(hRegion);
   BNormal.Free;
   BSelect.Free;
   BDown.Free;
   BEnabled.Free;
   inherited;
end;

procedure THIImgBtn.Init;
begin
   Control := NewBitBtn(FParent,'',[bboNoCaption],glyphLeft,0,0);
   inherited;
   if _prop_Split and (BNormal<>nil) then
     hRegion := CreateCoolControl(Control.GetWindowHandle, BNormal, BNormal.Pixels[0,0]);
   Control.OnBitBtnDraw := _OnDraw;
   Control.OnClick := _OnClick;
   if _prop_Flat then
     Control.Flat := true;

   if not _prop_Alpha then exit;
   blend.BlendOp := AC_SRC_OVER;
   blend.BlendFlags := 0;
   blend.SourceConstantAlpha := _prop_AlphaBlendValue;
   blend.AlphaFormat := AC_SRC_NO_PREMULT_ALPHA;
   Control.onMouseDown := _onMouseDown;
   Control.onMouseUp   := _onMouseUp;   
end;

procedure THIImgBtn.SetNormal;
begin
   BNormal.Handle := Value;
   if _prop_Alpha then
     BNormal.PixelFormat := pf32bit;
end;

procedure THIImgBtn.SetSelect;
begin
   BSelect.Handle := Value;
   if _prop_Alpha then
     BSelect.PixelFormat := pf32bit;
end;

procedure THIImgBtn.SetDown;
begin
   BDown.Handle := Value;
   if _prop_Alpha then
     BDown.PixelFormat := pf32bit;   
end;

procedure THIImgBtn.SetBEnabled;
begin
   BEnabled.Handle := Value;
   if _prop_Alpha then   
     BEnabled.PixelFormat := pf32bit;
end;

function THIImgBtn._OnDraw;
begin
  Result := true;
  with Control.Canvas{$ifndef F_P}^{$endif} do
    if _prop_Alpha then
      case BtnState of
        0,3:     //normal;
          if (BNormal <> nil) and not BNormal.Empty then
            _AlphaBlend(Handle, 0, 0, BNormal.width, BNormal.Height, BNormal.Canvas.Handle, 0, 0, BNormal.width, BNormal.Height, blend);
        1:
          if (BDown <> nil) and not BDown.Empty then
            _AlphaBlend(Handle, 0, 0, BDown.width, BDown.Height, BDown.Canvas.Handle, 0, 0, BDown.width, BDown.Height, blend)
          else if (BNormal <> nil) and not BNormal.Empty then 
            _AlphaBlend(Handle, 0, 0, BNormal.width, BNormal.Height, BNormal.Canvas.Handle, 0, 0, BNormal.width, BNormal.Height, blend);
        2:
          if (BEnabled <> nil) and not BEnabled.Empty then
            _AlphaBlend(Handle, 0, 0, BEnabled.width, BEnabled.Height, BEnabled.Canvas.Handle, 0, 0, BEnabled.width, BEnabled.Height, blend);
        4:
          if (BSelect <> nil) and not BSelect.Empty then
            _AlphaBlend(Handle, 0, 0, BSelect.width, BSelect.Height, BSelect.Canvas.Handle, 0, 0, BSelect.width, BSelect.Height, blend)
          else if (BNormal <> nil) and not BNormal.Empty then 
            _AlphaBlend(Handle, 0, 0, BNormal.width, BNormal.Height, BNormal.Canvas.Handle, 0, 0, BNormal.width, BNormal.Height, blend);
      end
    else
      case BtnState of
        0,3:     //normal;
          if (BNormal <> nil) and not BNormal.Empty then
            BNormal.Draw(Handle,0,0);
        1:
          if (BDown <> nil) and not BDown.Empty then
            BDown.Draw(Handle,0,0)
          else if (BNormal <> nil)and not BNormal.Empty then 
            BNormal.Draw(Handle,0,0);
        2:
          if (BEnabled <> nil) and not BEnabled.Empty then
            BEnabled.Draw(Handle,0,0);
        4:
          if (BSelect <> nil) and not BSelect.Empty then
            BSelect.Draw(Handle,0,0)
          else if (BNormal <> nil) and not BNormal.Empty then 
            BNormal.Draw(Handle,0,0);
      end;
end;

procedure THIImgBtn._OnClick;
begin
   _hi_OnEvent(_event_onClick);
end;

procedure THIImgBtn._onMouseDown;
begin
   InvalidateRect(Control.Handle, nil, true);
   inherited;
end;

procedure THIImgBtn._onMouseUp;
begin
   InvalidateRect(Control.Handle, nil, true);
   inherited;
end;

procedure THIImgBtn._work_doNormal;
begin
  BNormal.Assign(ToBitmap(_Data));
  if _prop_Alpha then
    BNormal.PixelFormat := pf32bit;
  Control.Invalidate;
end;

procedure THIImgBtn._work_doSelect;
begin
  BSelect.Assign(ToBitmap(_Data));
  if _prop_Alpha then
    BSelect.PixelFormat := pf32bit;
  Control.Invalidate;
end;

procedure THIImgBtn._work_doDown;
begin
  BDown.Assign(ToBitmap(_Data));
  if _prop_Alpha then
    BDown.PixelFormat := pf32bit;  
  Control.Invalidate;
end;

procedure THIImgBtn._work_doEnable;
begin
  BEnabled.Assign(ToBitmap(_Data));
  if _prop_Alpha then   
    BEnabled.PixelFormat := pf32bit;  
  Control.Invalidate;
end;

procedure THIImgBtn._var_Normal;
begin
  if (BNormal = nil) then exit;
  dtBitmap(_data, BNormal);
end;

end.