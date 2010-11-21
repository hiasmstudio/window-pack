unit hiPlotStream;

interface

uses windows,Kol,Share,Debug,hiPlotter;

type
  THIPlotStream = class(TDebug)
   private
   public
    _prop_Series:TSeries;
    _prop_DataType:byte;
    _prop_ClearSeries:boolean;
    _prop_Step:integer;

    _data_Stream:THI_Event;
    _event_onPlotStream:THI_Event;

    procedure _work_doPlotStream(var _Data:TData; Index:word);
  end;

implementation

procedure THIPlotStream._work_doPlotStream;
var
   st:PStream;
   r:real;
   x:real;
   b:byte;
   w:word;
   s:smallint;
   c:cardinal;
   i:integer;
   sn:single;   
begin
   st := ReadStream(_Data, _data_Stream);
   if(st = nil)or(_prop_Series = nil) then exit;
   if _prop_ClearSeries then
      _prop_Series.Clear;
   x := 0;
   while st.Position < st.size do
     begin
       case _prop_DataType of
         0: begin st.read(b, 1); r := b; end;
         1: begin st.read(w, 2); r := w; end;
         2: begin st.read(s, 2); r := s; end;
         3: begin st.read(c, 4); r := c; end;
         4: begin st.read(i, 4); r := i; end;
         5: begin st.read(sn,4); r := sn; end;
         6: st.read(r, 8);
       end;
       _prop_Series.Add(r, x);
       x := x + _prop_Step;
     end;   
   _prop_Series.Parent.ReDraw;
   _hi_onEvent(_event_onPlotStream);
end;

end.
