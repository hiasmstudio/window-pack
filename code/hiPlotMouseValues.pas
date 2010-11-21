unit hiPlotMouseValues;

interface

uses Kol,Share,Debug,hiPlotter;

type
  THIPlotMouseValues = class(TDebug)
   private
    FPlotter:THIPlotter;
    FButton:integer;
    
    procedure ClearEvents;
    procedure SetPlotter(value:THIPlotter);
    
    procedure onMouseDown(param:pointer);
    procedure onMouseUp(param:pointer);
    procedure onMouseMove(param:pointer);
    
    procedure Call(event:THI_Event; var mouse:TMouseEventData);
   public
    _prop_CoordMode:byte;

    _event_onMouseMove:THI_Event;
    _event_onMouseUp:THI_Event;
    _event_onMouseDown:THI_Event;

    destructor Destroy; override;
    procedure _var_Button(var _Data:TData; Index:word);
    property _prop_Grapher:THIPlotter read FPlotter write SetPlotter;
  end;

implementation

destructor THIPlotMouseValues.Destroy;
begin
  ClearEvents;
  inherited;
end;

procedure THIPlotMouseValues.SetPlotter(value:THIPlotter);
begin
  FPlotter := value;
  FPlotter.onMouseUp.add(onMouseUp);
  FPlotter.onMouseDown.add(onMouseDown);
  FPlotter.onMouseMove.add(onMouseMove); 
end;

procedure THIPlotMouseValues.ClearEvents;
begin
  FPlotter.onMouseUp.remove(onMouseUp);
  FPlotter.onMouseDown.remove(onMouseDown);
  FPlotter.onMouseMove.remove(onMouseMove); 
end;

procedure THIPlotMouseValues.Call;
var dt,d:TData;
    f:PData;
begin
   if byte(mouse.button) <> 0 then
     FButton := byte(mouse.button);
     
   if _prop_CoordMode = 0 then
     begin
       dtReal(dt, FPlotter.AbsToGraphX(mouse.x));
       dtReal(d, FPlotter.AbsToGraphY(mouse.y));
     end
   else
     begin
       dtReal(dt, mouse.x);
       dtReal(d, mouse.y);
     end;
   AddMTData(@dt, @d, f);  
   _hi_onEvent(event, dt);
   FreeData(f);
end;

procedure THIPlotMouseValues.onMouseDown(param:pointer);
begin
   Call(_event_onMouseDown, TMouseEventData(param^));
end;

procedure THIPlotMouseValues.onMouseUp(param:pointer);
begin
   Call(_event_onMouseUp, TMouseEventData(param^));
end;

procedure THIPlotMouseValues.onMouseMove(param:pointer);
begin
   Call(_event_onMouseMove, TMouseEventData(param^));
end;

procedure THIPlotMouseValues._var_Button;
begin
   dtInteger(_Data, FButton);
end;

end.
