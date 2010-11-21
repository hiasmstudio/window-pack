unit hiIcon;

interface

uses Windows,Kol,Share,Debug;

type
  THIIcon = class(TDebug)
   private
    Icon:PIcon;
    FTransparent: TColor;
    procedure SetIcon(value:HICON);
   public
    _data_FileName:THI_Event;
    _event_onBitmap:THI_Event;

    property _prop_Transparent:TColor write FTransparent;

    destructor Destroy; override;
    procedure _work_doTransparent(var _Data:TData; Index:word);
    procedure _work_doLoad(var _Data:TData; Index:word);
    procedure _work_doLoadIcon(var _Data:TData; Index:word);    
    procedure _work_doSave(var _Data:TData; Index:word);
    procedure _work_doBitmap(var _Data:TData; Index:word);
    procedure _work_doLoadFromBitmap(var _Data:TData; Index:word);
    procedure _var_Icon(var _Data:TData; Index:word);
    property _prop_Icon:HICON write SetIcon;
  end;

implementation

destructor THIIcon.Destroy;
begin
  Icon.free;
  inherited;
end;

procedure THIIcon._work_doLoad;
var
  fn:string;
begin
  if Icon = nil then
    Icon := NewIcon;

  fn := ReadFileName(ReadString(_Data,_data_FileName,''));
  Icon.LoadFromFile(fn);
end;

procedure THIIcon._work_doLoadIcon;
begin
  if not _IsIcon(_Data) then exit;
  if Icon = nil then
    Icon := NewIcon
  else
    Icon.Clear;  
  Icon{$ifndef F_P}^{$endif} := ToIcon(_Data){$ifndef F_P}^{$endif};
end;

procedure THIIcon._work_doSave;
begin
  if Icon <> nil then
    Icon.SaveToFile(ReadString(_Data,_data_FileName,''));
end;

procedure THIIcon._work_doBitmap;
var bmp:PBitmap;
begin
  if Icon <> nil then
  begin
    bmp := NewBitmap(0,0);
    bmp.Handle := Icon.Convert2Bitmap(FTransparent);
    _hi_OnEvent(_event_onBitmap,bmp);
    bmp.Free;
  end;
end;

procedure THIIcon._work_doLoadFromBitmap;
var
  bmp,mask,body:PBitmap;
  i,j:integer;
  IconInfo: TIconInfo;
begin
  bmp := ToBitmap(_Data);
  if bmp <> nil then
  begin
     body := NewBitmap(0,0);
     Body.Assign(bmp);
     Mask := NewBitmap(bmp.Width,bmp.Height);
     Mask.Assign(bmp);
     Mask.Convert2Mask(FTransparent);

     for i := 0 to bmp.Width-1 do
       for j := 0 to bmp.Height-1 do
         if Body.Canvas.Pixels[i,j] = FTransparent then
           Body.Canvas.Pixels[i,j] := clBlack;

     if Icon = nil then
       Icon := NewIcon;
     IconInfo.fIcon := true;
     IconInfo.xHotspot := 0;
     IconInfo.yHotspot := 0;
     IconInfo.hbmMask := Mask.Handle;
     IconInfo.hbmColor := Body.Handle;
     Icon.Handle := CreateIconIndirect(IconInfo);
     Mask.Free;
     Body.Free;
  end;
end;

procedure THIIcon._var_Icon;
begin
  if Icon <> nil then
    dtIcon(_Data,Icon)
  else
    dtNull(_Data);
end;

procedure THIIcon.SetIcon;
begin
  Icon := NewIcon;
  Icon.Handle := Value;
end;

procedure THIIcon._work_doTransparent;
begin
  FTransparent := ToInteger(_Data);
end;

end.