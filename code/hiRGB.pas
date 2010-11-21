unit hiRGB;

interface

uses Kol,Share,Debug;

type
  THIRGB = class(TDebug)
   private
    FColor:TColor;
   public
    _prop_R:integer;
    _prop_G:integer;
    _prop_B:integer;

    _data_B:THI_Event;
    _data_G:THI_Event;
    _data_R:THI_Event;
    _event_onRGB:THI_Event;

    procedure _work_doRGB(var _Data:TData; Index:word);
    procedure _var_Color(var _Data:TData; Index:word);
  end;

implementation

procedure THIRGB._work_doRGB;
var r,g,b:byte;
begin
   r := ReadInteger(_Data,_data_R,_prop_R);
   g := ReadInteger(_Data,_data_G,_prop_G);
   b := ReadInteger(_Data,_data_B,_prop_B);
   FColor := r + g shl 8 + b shl 16;
   _hi_CreateEvent(_Data,@_event_onRGB,integer(FColor));
end;

procedure THIRGB._var_Color;
begin
   dtInteger(_data,FColor);
end;

end.
