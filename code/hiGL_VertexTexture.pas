unit hiGL_VertexTexture;

interface

uses Kol,Share,Debug,OpenGL;

type
  THIGL_VertexTexture = class(TDebug)
   private
   public
    _prop_S:real;
    _prop_T:real;

    _data_S:THI_Event;
    _data_T:THI_Event;
    _event_onTexCoord:THI_Event;

    procedure _work_doTexCoord(var _Data:TData; Index:word);
  end;

implementation

procedure THIGL_VertexTexture._work_doTexCoord;
var s,t:real;
begin
   s := ReadReal(_Data,_data_S,_prop_S);
   t := ReadReal(_Data,_data_T,_prop_T);
   glTexCoord2d(s,t);
   _hi_CreateEvent(_Data,@_event_onTexCoord);
end;

end.
