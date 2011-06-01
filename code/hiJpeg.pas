unit hiJpeg;

interface

{define gdip}

uses
  {$ifdef gdip}
  GDIPOBJ,GDIPUTIL,
  {$else}
  JpegObj,
  {$endif}
  Kol,Share,Debug,Exif;

type
  THIJpeg = class(TDebug)
   private
    exif:TExif;
    {$ifdef gdip}
    Jpg:TGPImage;
    {$else}
    Jpg:pjpeg;
    {$endif}
    procedure SetJpeg(Value:PStream);
   public
    _prop_Quality:integer;
    _data_FileName:THI_Event;
    _data_Stream:THI_Event;
    _data_Quality:THI_Event;
    _event_onBitmap:THI_Event;

    constructor Create;
    destructor Destroy; override;
    procedure _work_doLoad(var _Data:TData; Index:word);
    procedure _work_doSave(var _Data:TData; Index:word);
    procedure _work_doLoadFromStream(var _Data:TData; Index:word);
    procedure _work_doSaveToStream(var _Data:TData; Index:word);
    procedure _work_doLoadFromBitmap(var _Data:TData; Index:word);
    procedure _work_doBitmap(var _Data:TData; Index:word);
    procedure _work_doReadTags(var _Data:TData; Index:word);
    procedure _var_idDescription(var _Data:TData; Index:word);
    procedure _var_idMake(var _Data:TData; Index:word);
    procedure _var_idModel(var _Data:TData; Index:word);
    procedure _var_idOrientation(var _Data:TData; Index:word);
    procedure _var_idDateTime(var _Data:TData; Index:word);
    procedure _var_idCopyright(var _Data:TData; Index:word);
    procedure _var_idUserComments(var _Data:TData; Index:word);
    procedure _var_idExposureTime(var _Data:TData; Index:word);
    procedure _var_idFocalLength(var _Data:TData; Index:word);
    procedure _var_Width(var _Data:TData; Index:word);
    procedure _var_Height(var _Data:TData; Index:word);    
    property _prop_Jpeg:PStream write SetJpeg;
  end;

implementation

constructor THIJpeg.Create;
begin
   inherited;
   {$ifdef gdip}
   jpg := TGPImage.Create;
   {$else}
   jpg := NewJpeg;
   {$endif}
end;

destructor THIJpeg.Destroy;
begin
   jpg.Free;
   if Assigned(exif) then
    exif.Destroy;
   inherited;
end;

procedure THIJpeg._work_doLoad;
var fn:string;
begin
   fn := ReadFileName( ReadString(_data,_data_FileName,'') );
   if FileExists(fn) then
     {$ifdef gdip}
     jpg.FromFile(fn);
     {$else}
     jpg.LoadFromFile(fn);
     {$endif}
end;

procedure THIJpeg._work_doSave;
var fn:string;
    {$ifdef gdip}
    encoderClsid: TGUID;
    {$endif}
begin
   fn := ReadFileName( ReadString(_data,_data_FileName,'') );
   {$ifdef gdip}
   GetEncoderClsid('image/jpeg', encoderClsid);
   jpg.Save(fn,encoderClsid);
   {$else}
   jpg.SaveToFile(fn);
   {$endif}
end;

procedure THIJpeg._work_doLoadFromStream;
var st:PStream;
begin
   st := ReadStream(_data,_data_Stream,nil);
   if st <> nil then
    {$ifdef gdip}
    {$else}
    jpg.LoadFromStream(st);
    {$endif}
end;

procedure THIJpeg._work_doSaveToStream;
var st:PStream;
begin
   st := ReadStream(_data,_data_Stream,nil);
   if st <> nil then
    {$ifdef gdip}
    {$else}
    jpg.SaveToStream(st);
    {$endif}
end;

procedure THIJpeg._work_doLoadFromBitmap;
begin
   {$ifdef gdip}
   {$else}
   jpg.Bitmap := ReadBitmap(_Data,NULL,nil);
   jpg.CompressionQuality := ReadInteger(_Data,_data_Quality,_prop_Quality);
   if jpg.Bitmap <> nil then
    jpg.Compress;
   {$endif}
end;

procedure THIJpeg._work_doBitmap;
begin
   {$ifdef gdip}
   {$else}
   if jpg.Bitmap <> nil then
    begin
     jpg.DIBNeeded;
     _hi_OnEvent(_event_onBitmap,jpg.bitmap);
    end;
   {$endif}
end;

procedure THIJpeg.SetJpeg;
begin
   {$ifdef gdip}

   {$else}
   jpg.LoadFromStream(Value);
   Value.Free;
   {$endif}
end;

procedure THIJpeg._work_doReadTags;
begin
   if not Assigned(exif) then
     exif := TExif.Create;
   exif.ReadFromFile(ReadString(_data,_data_FileName,''));
end;

procedure THIJpeg._var_idDescription;
begin
  dtString(_Data,exif.ImageDesc);
end;

procedure THIJpeg._var_idMake;
begin
  dtString(_Data,exif.Make);
end;

procedure THIJpeg._var_idModel;
begin
  dtString(_Data,exif.Model);
end;

procedure THIJpeg._var_idOrientation;
begin
  dtString(_Data,exif.OrientationDesk);
end;

procedure THIJpeg._var_idDateTime;
begin
  dtString(_Data,exif.DateTime);
end;

procedure THIJpeg._var_idCopyright;
begin
  dtString(_Data,exif.Copyright);
end;

procedure THIJpeg._var_idUserComments;
begin
  dtString(_Data,exif.UserComments);
end;

procedure THIJpeg._var_idExposureTime;
begin
  dtInteger(_Data,exif.ExposureTime);
end;

procedure THIJpeg._var_idFocalLength;
begin
  dtInteger(_Data,exif.FocalLength);
end;

procedure THIJpeg._var_Width;
begin
  {$ifdef gdip}
    dtInteger(_Data,jpg.GetWidth);
  {$else}
    dtInteger(_Data,jpg.Width);
  {$endif}
end;

procedure THIJpeg._var_Height;
begin
  {$ifdef gdip}
    dtInteger(_Data,jpg.GetHeight);
  {$else}
    dtInteger(_Data,jpg.Height);
  {$endif}
end;


{
procedure THIJpeg._var_Jpeg;
begin
   _data.Data_type := data_jpeg;
   _data.idata := integer(jpg);
end;
}
end.
