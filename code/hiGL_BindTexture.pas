unit hiGL_BindTexture;

interface

uses Kol,Share,Debug,OpenGL;
var
  Texture: Integer;
type
  THIGL_BindTexture = class(TDebug)
   private
   public
    _prop_Index:integer;
    _data_Index:THI_Event;
    _event_onBindTexture:THI_Event;
    procedure _work_doBindTexture(var _Data:TData; Index:word);
    procedure _work_doDeleteTextures(var _Data:TData; Index:word);
  end;

implementation

procedure THIGL_BindTexture._work_doBindTexture;

 begin
   Texture := ReadInteger(_Data,_data_Index,_prop_Index);
   glBindTexture(GL_TEXTURE_2D,Texture);
   _hi_CreateEvent(_Data,@_event_onBindTexture);
 end;
 
procedure THIGL_BindTexture._work_doDeleteTextures;

 begin
   Texture := ReadInteger(_Data,_data_Index,_prop_Index);
   glDeleteTextures(Texture,@Texture);
 end; 

end.
