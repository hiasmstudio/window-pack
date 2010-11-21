// Основа кода
// Author      : Jan Horn
// Email       : jhorn@global.co.za
// Website     : http://home.global.co.za/~jhorn
// Version     : 1.01
// Date        : 1 May 2001
 
unit hiGL_GenTexturesTga;

interface

uses kol,Share,Debug,OpenGL;

procedure glBindTexture(Target, Texture: integer); stdcall;
procedure glDeleteTextures(n: GLsizei; textures: PGLuint); stdcall;

const
    GL_TEXTURE_MAX_ANISOTROPY_EXT = $84FE;
    glLinear = GL_LINEAR;
    glNearest = GL_NEAREST;
    glNearestMipMapNearest = GL_NEAREST_MIPMAP_NEAREST;
    glLinearMipMapNearest = GL_LINEAR_MIPMAP_NEAREST;
    glNearestMipMapLinear = GL_NEAREST_MIPMAP_LINEAR;
    glLinearMipMapLinear = GL_LINEAR_MIPMAP_LINEAR;
    
var
   GL_X:integer;
   TGAFile   : File;
   bytesRead : Integer;
   image     : Pointer;
   Width, Height : Integer;
   ColorDepth    : Integer;
   ImageSize     : Integer;
   I : Integer;
   Front: ^Byte;
   Back: ^Byte;
   Temp: Byte;
   Error: string;
    
type
  THIGL_GenTexturesTga = class(TDebug)
   private
    
   public
    _prop_Index:Integer;
    _prop_TexFilterMAG:cardinal;
    _prop_TexFilterMIN:cardinal;
    _prop_Anisotropy:integer;
    
    _data_FileName:THI_Event;
    _data_Index:THI_Event;
    _data_Anisotropy:THI_Event;
    _event_onGenTextures:THI_Event;
    _event_onError:THI_Event;
    
    procedure _work_doGenTexturesTga(var _Data:TData; Index:word);
  end;

implementation
procedure glBindTexture; external 'opengl32';
procedure glDeleteTextures; external 'opengl32';

procedure SwapRGB(data : Pointer; Size : Integer);
asm
  mov ebx, eax
  mov ecx, size
@@loop :
  mov al,[ebx+0]
  mov ah,[ebx+2]
  mov [ebx+2],al
  mov [ebx+0],ah
  add ebx,3
  dec ecx
  jnz @@loop
end;

{------------------------------------------------------------------}
{  Loads 24 and 32bpp (alpha channel) TGA textures                 }
{------------------------------------------------------------------}
function LoadTGATexture(Filename: String): Boolean;
var
  TGAHeader : packed record   // Header type for TGA images
    FileType     : Byte;
    ColorMapType : Byte;
    ImageType    : Byte;
    ColorMapSpec : Array[0..4] of Byte;
    OrigX  : Array [0..1] of Byte;
    OrigY  : Array [0..1] of Byte;
    Width  : Array [0..1] of Byte;
    Height : Array [0..1] of Byte;
    BPP    : Byte;
    ImageInfo : Byte;
  end;

begin
  GetMem(Image, 0);
  AssignFile(TGAFile, Filename);
  Reset(TGAFile, 1);
  // Read in the bitmap file header
  BlockRead(TGAFile, TGAHeader, SizeOf(TGAHeader));
  // Only support uncompressed images
  if (TGAHeader.ImageType <> 2) then  { TGA_RGB }
   begin
     CloseFile(tgaFile);
     Error := 'compressed  TGA not supported';
     exit;
   end;
  // Don't support colormapped files
  if TGAHeader.ColorMapType <> 0 then
   begin
     CloseFile(TGAFile);
     exit;
   end;
  // Get the width, height, and color depth
  Width  := TGAHeader.Width[0]  + TGAHeader.Width[1]  * 256;
  Height := TGAHeader.Height[0] + TGAHeader.Height[1] * 256;
  ColorDepth := TGAHeader.BPP;
  ImageSize  := Width*Height*(ColorDepth div 8);
  if ColorDepth < 24 then
   begin
     CloseFile(TGAFile);
     exit;
   end;
  GetMem(Image, ImageSize);
  BlockRead(TGAFile, image^, ImageSize, bytesRead);
  if bytesRead <> ImageSize then
   begin
     CloseFile(TGAFile);
     exit;
   end;
 
  // TGAs are stored BGR and not RGB, so swap the R and B bytes.
  // 32 bit TGA files have alpha channel and gets loaded differently
  if TGAHeader.BPP = 24 then
  begin
    for I :=0 to Width * Height - 1 do
    begin
      Front := Pointer(Integer(Image) + I*3);
      Back := Pointer(Integer(Image) + I*3 + 2);
      Temp := Front^;
      Front^ := Back^;
      Back^ := Temp;
    end;
    GL_X := GL_RGB;
  end
  else
  begin
    for I :=0 to Width * Height - 1 do
    begin
      Front := Pointer(Integer(Image) + I*4);
      Back := Pointer(Integer(Image) + I*4 + 2);
      Temp := Front^;
      Front^ := Back^;
      Back^ := Temp;
    end;
    GL_X := GL_RGBA;
  end;
end;

procedure THIGL_GenTexturesTga._work_doGenTexturesTga;
var
  filename : string;
  n: Integer;
begin
  Index := ReadInteger(_Data,_data_Index,_prop_Index);
  filename := ReadFileName( ReadString(_data,_data_FileName,'') );
  if copy(Uppercase(filename), length(filename)-3, 4) <> '.TGA' then  exit;
  if not FileExists(filename) then 
  begin ShowMessage('Incorrect way to a file   ' + filename); exit;  end;
     LoadTGATexture(Filename);
       begin
         n := ReadInteger(_Data, _data_Anisotropy,_prop_Anisotropy);
         Index := ReadInteger(_Data,_data_Index,_prop_Index);
         glBindTexture(GL_TEXTURE_2D, Index);
         if n > 0 then glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAX_ANISOTROPY_EXT,n);
         glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,_prop_TexFilterMAG);
         glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,_prop_TexFilterMIN);
         gluBuild2DMipmaps(GL_TEXTURE_2D, GL_X, Width, Height, GL_X, GL_UNSIGNED_BYTE, Image);
         FreeMem(Image);
        _hi_CreateEvent(_Data,@_event_onGenTextures);
        _hi_onEvent(_event_onError,Error);    
      end;
   end;
end.
