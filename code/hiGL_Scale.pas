unit hiGl_Scale;

interface

uses Kol,Share,Debug,OpenGL;

type
  THIGl_Scale = class(TDebug)
   private
   public
    _prop_X:real;
    _prop_Y:real;
    _prop_Z:real;

    _data_Z:THI_Event;
    _data_Y:THI_Event;
    _data_X:THI_Event;
    _event_onScale:THI_Event;

    procedure _work_doScale(var _Data:TData; Index:word);
  end;

implementation

procedure THIGl_Scale._work_doScale;
begin
   glScalef(
             ReadReal(_Data,_data_X,_prop_X),
             ReadReal(_Data,_data_Y,_prop_Y),
             ReadReal(_Data,_data_Z,_prop_Z));
   _hi_CreateEvent(_Data,@_event_onScale);
end;

end.
