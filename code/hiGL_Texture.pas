unit hiGL_Texture;

interface

uses Kol,Share,Debug,OpenGL;

type
  THIGL_Texture = class(TDebug)
   private
    FW,FH:integer;
    bits:pointer;
    index:integer;
   public
    _prop_UseList:boolean;
    _prop_Index:integer;
    _prop_TexFilter:boolean;

    _data_Bitmap:THI_Event;
    _data_Index:THI_Event;
    _event_onSet:THI_Event;
    _event_onCreate:THI_Event;

    destructor Destroy; override;
    procedure _work_doCreate(var _Data:TData; Index:word);
    procedure _work_doSet(var _Data:TData; Index:word);
  end;

implementation

destructor THIGL_Texture.Destroy;
begin
   if _prop_UseList then
     glDeleteLists(Index,1)
   else if bits <> nil then
    FreeMem(bits,fw*fh*3);
   inherited;
end;

procedure THIGL_Texture._work_doCreate;
type
  TArr = array[0..0] of record r,g,b:byte; end;
  PArr = ^TArr;
var bmp:PBitmap;
    i,j:integer;
    bt:pointer;
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
           {
           if a then
            begin
             if  r + b + g = 3*255 then
               TBits_a(bits^).a := 0;
             inc(Cardinal(bits));
            end;
           }
           inc(cardinal(bt),3);
          end;
    end;
   if _prop_UseList then
    begin
      Index := ReadInteger(_Data, _data_Index, _prop_Index);
      glNewList(Index,GL_COMPILE);
      glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, FW,FH, 0, GL_RGB, GL_UNSIGNED_BYTE, bits);
      FreeMem(bits,fw*fh*3);
      bits := nil;
    end;
    begin
  if _prop_TexFilter then
     begin
     glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
     glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
     end
     else 
     glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
     glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    end;
   if _prop_UseList then
     glEndList;
   _hi_CreateEvent(_Data,@_event_onCreate);
end;

procedure THIGL_Texture._work_doSet;
begin
   if _prop_UseList then
    glCallList(_prop_Index)
   else glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, FW,FH, 0, GL_RGB, GL_UNSIGNED_BYTE, bits);
   _hi_CreateEvent(_Data,@_event_onSet);
end;

end.
