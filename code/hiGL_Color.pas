unit hiGL_Color;

interface

uses Kol,Share,Debug,OpenGL;

type
  THIGL_Color = class(TDebug)
   private
   public
    _prop_Color:TColor;
    _prop_Alpha:real;

    _data_Color:THI_Event;
    _data_Alpha:THI_Event;
    _event_onColor:THI_Event;

    procedure _work_doColor(var _Data:TData; Index:word);
  end;

implementation

uses hiGL_Main;

procedure THIGL_Color._work_doColor;
var
  c:TColor;
  a:real;
begin
    c := ReadInteger(_data,_data_Color,_prop_Color);
    a := ReadReal(_data,_data_Alpha,_prop_Alpha);
    if a = 1.0 then
     glColor(c)
    else glColora(c,a);
    _hi_CreateEvent(_Data,@_event_onColor);
end;

end.
