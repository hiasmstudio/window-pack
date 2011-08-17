unit hiPNG;

interface

uses Windows, Kol, Share, Debug, KOLPng;

type
  THIPNG = class(TDebug)
   private
    fImage:PPngObject;
    fAlphaBmp: PBitmap;
    procedure AlphaMask;
   public
    _prop_PNG:PStream;
    _prop_Transparent:boolean;
    _prop_TransparentColor:TColor;
    _prop_FileName:string;

    _data_Stream:THI_Event;
    _data_FileName:THI_Event;
    _data_TransparentColor:THI_Event;
    _event_onBitmap:THI_Event;
    _event_onAlphaMask:THI_Event;
    _event_onAlphaBitmap:THI_Event;        

    constructor Create;
    destructor Destroy; override;
    procedure _work_doLoad(var _Data:TData; Index:word);
    procedure _work_doSave(var _Data:TData; Index:word);
    procedure _work_doLoadFromStream(var _Data:TData; Index:word);
    procedure _work_doSaveToStream(var _Data:TData; Index:word);
    procedure _work_doLoadFromBitmap(var _Data:TData; Index:word);
    procedure _work_doBitmap(var _Data:TData; Index:word);
    procedure _work_doAlphaBitmap(var _Data:TData; Index:word);    
    procedure _var_Bitmap(var _Data:TData; Index:word);
    procedure _var_AlphaBitmap(var _Data:TData; Index:word);         
  end;

implementation

constructor THIPNG.Create;
begin
   inherited;
   fImage := NewPngObject;
end;

destructor THIPNG.Destroy;
begin
   fImage.Free;
   fAlphaBmp.free;   
   inherited;
end;

procedure THIPNG._work_doLoad;
var fn:string;
begin
   fn := ReadString(_data,_data_FileName,_prop_FileName);
   if fn = '' then exit;
   fn := ReadFileName( fn );
   if not FileExists(fn) then exit;
   fImage.LoadFromFile(fn);
  AlphaMask;     
end;

procedure THIPNG._work_doSave;
var fn:string;
begin
   fn := ReadString(_data,_data_FileName,_prop_FileName);
   if fn = '' then exit;
   fn := ReadFileName( fn );
   fImage.SaveToFile(fn);
end;

procedure THIPNG._work_doLoadFromStream;
var st:PStream;
begin
   st := ReadStream(_data,_data_Stream,_prop_PNG);
   if st = nil then exit;
   st.Position := 0;
   fImage.LoadFromStream(st);
   AlphaMask;
end;

procedure THIPNG._work_doSaveToStream;
var st:PStream;
begin
   st := ReadStream(_data,_data_Stream,nil);
   if st = nil then exit;
   st.Position := 0;
   fImage.SaveToStream(st);
end;

procedure THIPNG._work_doLoadFromBitmap;
var
  b: PBitmap;
  x, y: integer;
  MS: PColor;
  S: pByteArray;
begin
   b := ReadBitmap(_Data, NULL, nil);
   if (b = nil) or b.Empty then exit; 
   fImage.AssignHandle(b.Handle, _prop_Transparent, ReadInteger(_Data, _data_TransparentColor, _prop_TransparentColor));
   if (b.PixelFormat = pf32bit) and _prop_Transparent then
   begin
     fImage.CreateAlpha;
     for y := 0 to b.Height - 1 do
     begin
       S := fImage.AlphaScanline[y];
       MS := b.Scanline[y];
       for x := 0 to b.Width - 1 do
       begin
         S[x] := (MS^ and $FF000000) shr 24;
         inc(MS);
       end;  
     end;
   end;
   AlphaMask;
end;

procedure THIPNG._work_doBitmap;
begin
   _hi_OnEvent(_event_onBitmap,fImage.Bitmap);
end;

procedure THIPNG._work_doAlphaBitmap;
begin
   _hi_OnEvent(_event_onAlphaBitmap,fAlphaBmp);
end;

procedure THIPNG.AlphaMask;
var
  x, y: integer;
  MS: pByteArray;
  S: PColor;
  fFrom: TRGB;
begin
  if fImage.Empty then exit;
  if Assigned(fAlphaBmp) then fAlphaBmp.free;
  fAlphaBmp := NewDIBBitmap(fImage.Width, fImage.Height, pf32bit);
  fAlphaBmp.Assign(fImage.Bitmap);

  if fImage.AlphaScanline[0] = nil then exit;
  
  fAlphaBmp.PixelFormat := pf32bit;
  for y := 0 to fAlphaBmp.Height - 1 do
  begin
    MS := fImage.AlphaScanline[y];
    S := fAlphaBmp.Scanline[y];
    for x := 0 to fAlphaBmp.Width - 1 do
    begin
      PColor(@fFrom)^ := S^;
      S^ := RGB(ffrom.r*MS[x] div 255, ffrom.g*MS[x] div 255, ffrom.b*MS[x] div 255) + MS[x] shl 24;
      inc(S);
    end;  
  end;
end;

procedure THIPNG._var_Bitmap;
begin
  dtBitmap(_Data, fImage.Bitmap);
end;

procedure THIPNG._var_AlphaBitmap;    
begin
  dtBitmap(_Data, fAlphaBmp);   
end;

end.
