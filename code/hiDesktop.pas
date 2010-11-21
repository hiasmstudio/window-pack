unit hiDesktop;

interface

{$I share.inc}

uses Share,Windows,Kol,{$ifndef F_P}JpegObj,{$endif}Debug,ActiveX,KOLComObj;
 
const
 STRETCH = 0;
 CENTER  = 1;
 TILE    = 2;

type
  THIDesktop = class(TDebug)
   private
    fStyle: byte;
    procedure SetWallpaper(const FileName:string);
   public
    _prop_FileName:string;
    _data_FileName:THI_Event;

    property _prop_Style:byte write fStyle;
    procedure _work_doFromFile(var _Data:TData; Index:word);
    procedure _work_doFromStream(var _Data:TData; Index:word);
    procedure _work_doStyle(var _Data:TData; Index:word);
    procedure _var_FileName(var _Data:TData; Index:word);
    procedure _var_Style(var _Data:TData; Index:word);         
  end;

implementation

procedure THIDesktop.SetWallpaper;
var hk:HKey;
begin
  hk := RegKeyOpenWrite(HKEY_CURRENT_USER,'Control Panel\Desktop');     
  RegKeySetStr(hk,'Wallpaper', filename);
  case fStyle of 
  STRETCH :
   begin
     RegKeySetStr(hk,'TileWallpaper', '0');
     RegKeySetStr(hk,'WallpaperStyle', '2');
   end;
  CENTER :
   begin
     RegKeySetStr(hk,'TileWallpaper', '0');
     RegKeySetStr(hk,'WallpaperStyle', '1');
   end;
  TILE :
   begin
     RegKeySetStr(hk,'TileWallpaper', '1');
     RegKeySetStr(hk,'WallpaperStyle', '0');
   end;
  end;
  SystemParametersInfo(SPI_SETDESKWALLPAPER, 0, PChar(filename), SPIF_SENDWININICHANGE );
  RegCloseKey(hk);
end;

{$ifdef F_P}
procedure LoadBMP(fn:PChar; var bdata:pointer; var bcount:cardinal); external 'jpeg.dll';
{$endif}

procedure THIDesktop._work_doFromFile;
var fn,ext:string;
    tempfn:string;
    {$ifndef F_P}
    jpg:PJpeg;
    {$else}
    st:PStream;
    _dt:pointer;
    size:cardinal;
    {$endif}
begin
   fn := ReadString(_data,_data_FileName,_prop_FileName);
   if not FileExists(fn) then exit;
   ext := LowerCase(ExtractFileExt(fn));
   if ext = '.bmp' then
     SetWallpaper(fn)
   else if (ext = '.jpg')or(ext = '.jpeg')then
    begin
     tempfn := GetTempDir + '~temp.bmp'; 
     if FileExists(tempfn) then DeleteFiles(PChar(tempfn));
     {$ifdef F_P}
     LoadBMP(pchar(fn),_dt, size);
     st := NewWriteFileStream(tempfn);
     st.write(_dt^,size);
     free_and_nil(st);
     {$else}
     Jpg := NewJpeg;
     Jpg.LoadFromFile(fn);
     Jpg.DIBNeeded;
     Jpg.Bitmap.SaveToFile(tempfn);
     jpg.Free;
     {$endif}
     SetWallpaper(tempfn);
    end;
end;

procedure THIDesktop._work_doFromStream;
var bmp:PBitmap;
    tempfn:string;
begin
  if (_Data.Data_type = data_bitmap)and(_Data.idata <> 0) then
   begin
     tempfn := GetTempDir + '~temp.bmp';
     if FileExists(tempfn) then DeleteFiles(PChar(tempfn));
     bmp := PBitmap(_Data.idata);
     bmp.SaveToFile(tempfn);
     SetWallpaper(tempfn);
   end;
end;

procedure THIDesktop._work_doStyle;
begin
  fStyle := ToInteger(_Data);
end;

procedure THIDesktop._var_FileName;
var hk:HKey;
begin
  hk := RegKeyOpenRead(HKEY_CURRENT_USER,'Control Panel\Desktop');
  dtString(_Data, RegKeyGetStr(hk,'Wallpaper'));
  RegCloseKey(hk);  
end;

procedure THIDesktop._var_Style;
var hk:HKey;
begin
  hk := RegKeyOpenRead(HKEY_CURRENT_USER,'Control Panel\Desktop');
  if (RegKeyGetStr(hk,'TileWallpaper') = '1') and (RegKeyGetStr(hk,'WallpaperStyle') = '0') then
    dtInteger(_Data, TILE)
  else if (RegKeyGetStr(hk,'TileWallpaper') = '0') and (RegKeyGetStr(hk,'WallpaperStyle') = '2') then    
    dtInteger(_Data, STRETCH)
  else if (RegKeyGetStr(hk,'TileWallpaper') = '0') and (RegKeyGetStr(hk,'WallpaperStyle') = '1') then
    dtInteger(_Data, CENTER)
  else     
    dtInteger(_Data, STRETCH);
  RegCloseKey(hk);
end;

end.



