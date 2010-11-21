unit hiPictureStream;

interface

{$I share.inc}

uses Kol,Share,{$ifndef F_P}JpegObj,{$endif}KOLPcx,Debug;

type
  THIPictureStream = class(TDebug)
   private
   public
    _prop_FileName:string;
    _prop_Quality:integer;
    _data_FileName:THI_Event;
    _data_Quality:THI_Event;
    _data_Bitmap:THI_Event;
    _event_onLoad:THI_Event;

    procedure _work_doLoad(var _Data:TData; Index:word);
    procedure _work_doSave(var _Data:TData; Index:word);
  end;

implementation

{$ifdef F_P}
procedure SaveBMP(fn:PChar; cq:byte; bdata:pointer; bcount:cardinal); external 'jpeg.dll';
procedure LoadBMP(fn:PChar; var bdata:pointer; var bcount:cardinal); external 'jpeg.dll';
{$endif}

procedure THIPictureStream._work_doLoad;
var
   Fn,ext:string;
   Bmp:PBitmap;
   {$ifndef F_P}
   Jpg:PJpeg;
   {$else}
   st:PStream;
   _dt:pointer;
   size:cardinal;
   {$endif}
   Ico:PIcon;
   pcx:PPCX;
begin
   Fn := ReadString(_Data,_data_FileName,_prop_FileName);
   if FileExists(Fn) then
    begin
     ext := LowerCase(ExtractFileExt(Fn)); 
     if ext = '.bmp' then
       begin
         Bmp := NewBitmap(0,0);
         Bmp.LoadFromFile(Fn);
         _hi_OnEvent(_event_onLoad,bmp);
         Bmp.Free;
       end
     else if ext = '.ico' then
       begin
         Ico := NewIcon;
         Ico.LoadFromFile(Fn);
         Bmp := NewBitmap(0,0);
         Bmp.Handle := Ico.Convert2Bitmap(clWhite);
         _hi_OnEvent(_event_onLoad,bmp);
         Bmp.Free;
         Ico.Free;
       end
     else if ext = '.pcx' then
      begin
         pcx := NewPCX;
         pcx.LoadFromFile(Fn);
         _hi_OnEvent(_event_onLoad,pcx.Bitmap);
         Pcx.Free;
      end
     else if (ext = '.jpg')or(ext = '.jpeg')then
       begin
         {$ifdef F_P}
         Bmp := NewBitmap(0,0);
         LoadBMP(pchar(fn),_dt,size);
         st := newmemorystream;
         st.write(_dt^,size);
         st.position := 0;
         bmp.LoadFromStream(st);
         _hi_OnEvent(_event_onLoad,bmp);
         bmp.free;
         st.free;
         dispose(_dt); //???????????????
         {$else}
         Jpg := NewJpeg;
         Jpg.LoadFromFile(Fn);
         Jpg.DIBNeeded;
         _hi_OnEvent(_event_onLoad,Jpg.Bitmap);
         Jpg.Free;
         {$endif}
       end;
    end;
end;

procedure THIPictureStream._work_doSave;
var Bmp:PBitmap;
    {$ifndef F_P}
    jpg:PJpeg;
    {$else}
    st:PStream;
    {$endif}
    fn,ext:string;
begin
   fn := ReadString(_Data,_data_FileName,_prop_FileName);
   Bmp := ReadBitmap(_Data,_data_Bitmap,nil);
   if Bmp = nil then exit;

   ext := LowerCase(ExtractFileExt(Fn));
   if ext = '.bmp' then
     Bmp.SaveToFile(fn)
   else if(ext = '.jpg')or(ext = '.jpeg')then
     {$ifdef F_P}
     begin
       st := NewMemoryStream;
       Bmp.SavetoStream(st);
       SaveBMP(PChar(fn),ReadInteger(_Data,_data_Quality,_prop_Quality),st.memory,st.Size);
       st.free;
     end
     {$else}
     begin
       Jpg := NewJpeg;
       Jpg.Bitmap := bmp;
       Jpg.CompressionQuality := ReadInteger(_Data,_data_Quality,_prop_Quality);
       Jpg.JPEGNeeded;
       Jpg.SaveToFile(fn);
       Jpg.Bitmap := nil;
       Jpg.Free;
     end;
    {$endif}
end;

end.
