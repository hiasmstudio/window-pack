unit hiGL_Point3D;

interface

uses Kol,Share,Debug,OpenGL;

type
  THIGL_Point3D = class(TDebug)
   private
    Point:array[0..2]of Single;
   public
    _prop_X:real;
    _prop_Y:real;
    _prop_Z:real;

    _data_Z:THI_Event;
    _data_Y:THI_Event;
    _data_X:THI_Event;

    procedure _var_Point3D(var _Data:TData; Index:word);
  end;

implementation

procedure THIGL_Point3D._var_Point3D;
begin
   Point[0] := ReadReal(_Data,_data_X,_prop_X);
   Point[1] := ReadReal(_Data,_data_Y,_prop_Y);
   Point[2] := ReadReal(_Data,_data_Z,_prop_Z);
   _data.Data_type := data_gl_point3d;
   _data.idata := integer(@Point[0]);
end;

end.
