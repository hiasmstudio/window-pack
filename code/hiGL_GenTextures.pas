unit hiGL_GenTextures;

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
    
type
  THIGL_GenTextures = class(TDebug)
   private
    FW,FH:integer;
    bits:pointer;
    
   public
    _prop_Index:integer;
    _prop_TexFilterMAG:cardinal;
    _prop_TexFilterMIN:cardinal;
    _prop_Anisotropy:integer;
    
    _data_Index:THI_Event;
    _data_Bitmap:THI_Event;
    _data_Anisotropy:THI_Event;
    _event_onGenTextures:THI_Event;
    
    procedure _work_doGenTextures(var _Data:TData; Index:word);
  end;

implementation

procedure glBindTexture; external 'opengl32';
procedure glDeleteTextures; external 'opengl32';

procedure THIGL_GenTextures._work_doGenTextures;

type
  TArr = array[0..0] of record r,g,b:byte; end;
  PArr = ^TArr;
var bmp:PBitmap;
    i,j:integer;
    bt:pointer;
    n: Integer;
begin
   bmp := ReadBitmap(_data,_data_Bitmap,nil);
   if bmp <> nil then
    begin     
     if bits <> nil then
       FreeMem(bits,fw*fh*3);
     fw := bmp.Width;  
     fh := bmp.Height;
     GetMem(bits,fw*fh*3);
     bt := bits;
     bmp.PixelFormat := pf24bit;
     For i := 0 to fw-1 do
      For j := 0 to fh-1 do
        with PArr(bmp.ScanLine[j])^[i] do
          begin
           TRGB(bt^).r := b;
           TRGB(bt^).g := g;
           TRGB(bt^).b := r;
           inc(cardinal(bt),3);
          end;
        end;
      begin
      n := ReadInteger(_Data, _data_Anisotropy,_prop_Anisotropy);
      Index := ReadInteger(_Data,_data_Index,_prop_Index);
      glBindTexture(GL_TEXTURE_2D, Index);
      if n > 0 then glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAX_ANISOTROPY_EXT,n);
      glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,_prop_TexFilterMAG);
      glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,_prop_TexFilterMIN);
      gluBuild2DMipmaps(GL_TEXTURE_2D,3, FW,FH,GL_RGB,GL_UNSIGNED_BYTE,bits);
      FreeMem(bits,fw*fh*3);
      bits := nil;
      _hi_CreateEvent(_Data,@_event_onGenTextures);
      end;
   end;
end.
