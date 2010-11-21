unit hiGL_GTools;

interface

uses Windows,Kol,Share,Debug,OpenGL;

type
  THIGL_GTools = class(TDebug)
   private
   public
    _prop_ClearColor:boolean;
    _prop_ClearDepth:boolean;
    _prop_ClearStencil:boolean;
    _event_onEvent:THI_Event;

    procedure _work_doClear(var _Data:TData; Index:word);
    procedure _work_doPushMatrix(var _Data:TData; Index:word);
    procedure _work_doPopMatrix(var _Data:TData; Index:word);
    procedure _work_doPushAttrib(var _Data:TData; Index:word);
    procedure _work_doPopAttrib(var _Data:TData; Index:word);
  end;

implementation

procedure THIGL_GTools._work_doClear;
var flg:cardinal;
begin
  flg := 0;
  if _prop_ClearColor then
    flg := flg or GL_COLOR_BUFFER_BIT;
  if _prop_ClearDepth then
    flg := flg or GL_DEPTH_BUFFER_BIT;
  if _prop_ClearStencil then
    flg := flg or GL_STENCIL_BUFFER_BIT;    
  glClear(flg);
  _hi_CreateEvent(_Data,@_event_onEvent);
end;

procedure THIGL_GTools._work_doPushMatrix;
begin
   glPushMatrix;
   _hi_CreateEvent(_Data,@_event_onEvent);
end;

procedure THIGL_GTools._work_doPopMatrix;
begin
   glPopMatrix;
   _hi_CreateEvent(_Data,@_event_onEvent);
end;

procedure THIGL_GTools._work_doPushAttrib;
begin
   glPushAttrib(GL_ALL_ATTRIB_BITS);
   _hi_CreateEvent(_Data,@_event_onEvent);
end;

procedure THIGL_GTools._work_doPopAttrib;
begin
   glPopAttrib;
   _hi_CreateEvent(_Data,@_event_onEvent);
end;

end.
