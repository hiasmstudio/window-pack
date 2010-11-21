unit hiPaintBox;

interface

{$I share.inc}

uses Windows,Share,Win,Kol;

type
  THIPaintBox = class(THIWin)
   private
    Bmp:PBitmap;

    procedure _OnClick( Sender: PObj );
    procedure _OnResize( Sender: PObj );override;
    procedure _OnPaint( Sender: PControl; DC: HDC );
    procedure Clear;
   public
    _prop_Color:TColor;
    _prop_ClearBeforeDraw:boolean;
    _event_onBeforeDraw:THI_Event;
    _event_onClick:THI_Event;

    constructor Create(Parent:PControl);
    destructor Destroy; override;
    procedure Init; override;
    procedure _work_doClear(var _Data:TData; Index:word);
    procedure _work_doRefresh(var _Data:TData; Index:word);
    procedure _work_doColor(var _Data:TData; Index:word);
    procedure _var_Bitmap(var _Data:TData; Index:word);
    procedure _var_Width(var _Data:TData; Index:word);
    procedure _var_Height(var _Data:TData; Index:word);
  end;

implementation

constructor THIPaintBox.Create;
begin
  inherited Create(Parent);
  Bmp := NewBitmap(0,0);
end;

destructor THIPaintBox.Destroy;
begin
  Bmp.Free;
  inherited;
end;

procedure THIPaintBox.Init;
begin
  Control := NewPaintbox(FParent);
  inherited;
  Control.OnClick := _OnClick;
  Control.OnPaint := _OnPaint;
  _OnResize(Control);
  Clear;
end;

procedure THIPaintBox._OnResize;
begin
  Bmp.Width := control.Width;
  Bmp.Height := Control.Height;
  inherited;
end;

procedure THIPaintBox._work_doColor;
begin
  _prop_Color := ToInteger(_Data);
end;

procedure THIPaintBox._work_doClear;
begin
  Clear;
end;

procedure THIPaintBox._work_doRefresh;
begin
  Control.Invalidate;
end;

procedure THIPaintBox._var_Bitmap;
begin
   dtBitmap(_data,Bmp);
end;

procedure THIPaintBox._var_Width;
begin
   dtInteger(_Data,Bmp.Width)
end;

procedure THIPaintBox._var_Height;
begin
   dtInteger(_Data,Bmp.Height)
end;

procedure THIPaintBox._OnClick;
begin
  _hi_OnEvent(_event_onClick);
end;

procedure THIPaintBox._OnPaint;
begin
  if _prop_ClearBeforeDraw then
    Clear;
  _hi_OnEvent(_event_onBeforeDraw);
  Bmp.Draw(DC,0,0);
end;

procedure THIPaintBox.Clear;
begin
  Bmp.BkColor := _prop_Color;
  Bmp.Canvas.Brush.BrushStyle := bsSolid;
  Bmp.Canvas.FillRect(Bmp.BoundsRect);
end;

end.
