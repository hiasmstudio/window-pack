unit PlotSeries;

interface

uses Kol,Share,Debug,hiPlotter;

type
  TPlotSeries = class(TDebug)
   protected
    FSeries:TSeries;
    FGrapher:THIPlotter;
    ArrX,ArrY:PArray;
    
    procedure SetGrapher(value:THIPlotter); virtual;
    procedure _SetX(var Item:TData; var Val:TData);
    function _GetX(Var Item:TData; var Val:TData):boolean;
    procedure _AddX(var Val:TData);
    procedure _SetY(var Item:TData; var Val:TData);
    function _GetY(Var Item:TData; var Val:TData):boolean;
    procedure _AddY(var Val:TData);
    function _Count:integer;
   public
    _prop_Color:TColor;
    _prop_Size:integer;
    _prop_MaxValues:integer;
    _prop_Step:real;
    
    _prop_Name:string;

    _data_ValueX:THI_Event;
    _data_ValueY:THI_Event;

    _event_onAdd:THI_Event;

    destructor Destroy; override;
    procedure _work_doAdd(var _Data:TData; Index:word);
    procedure _work_doClear(var _Data:TData; Index:word);
    procedure _work_doShow(var _Data:TData; Index:word);
    procedure _work_doMaxValues(var _Data:TData; Index:word);
    procedure _work_doColor(var _Data:TData; Index:word);
    procedure _var_MinX(var _Data:TData; Index:word);
    procedure _var_MaxX(var _Data:TData; Index:word);
    procedure _var_MinY(var _Data:TData; Index:word);
    procedure _var_MaxY(var _Data:TData; Index:word);
    procedure _var_ValuesX(var _Data:TData; Index:word);
    procedure _var_ValuesY(var _Data:TData; Index:word);
    
    property getInterfacePlotSeries:TSeries read FSeries;
    property _prop_Grapher:THIPlotter read FGrapher write SetGrapher;
  end;

implementation

destructor TPlotSeries.Destroy;
begin
   if FSeries.Parent <> nil then
      FSeries.Parent.RemoveSeries(FSeries)
   else FSeries.Destroy;

   if ArrX <> nil then dispose(ArrX);
   if ArrY <> nil then dispose(ArrY);
   
   inherited;
end;

procedure TPlotSeries.SetGrapher(value:THIPlotter);
begin
   FGrapher := value;
   FGrapher.AddSeries(FSeries);
   with FSeries do
     begin
       Color := _prop_Color;
       Size := _prop_Size; 
       MaxValues := _prop_MaxValues;
     end;
end;

procedure TPlotSeries._work_doAdd;
var y,x:real;
begin
   y := ReadReal(_Data, _data_ValueY);
   x := ReadReal(_Data, _data_ValueX);
   if _prop_Step <> 0 then
     if FSeries.Count = 0 then
       x := 0
     else
       x := FSeries.Values[FSeries.Count-1].x + _prop_Step;  
   FSeries.Add(y, x);
   FGrapher.ReDraw;
   
   _hi_onEvent(_event_onAdd);
end;

procedure TPlotSeries._work_doClear;
begin
   FSeries.Clear;
end;

procedure TPlotSeries._work_doShow;
begin
   FSeries.Show(ReadBool(_data));
   FGrapher.ReDraw;
end;

procedure TPlotSeries._work_doMaxValues;
begin
   with FSeries do begin
     MaxValues := ToInteger(_Data);
     if Count > MaxValues then begin
       Count := MaxValues;
       SetLength(Values,Count);
     end; 
   end;
end;

procedure TPlotSeries._work_doColor;
begin
   FSeries.Color := ToInteger(_Data);
end;

procedure TPlotSeries._var_MinY;
begin
  dtReal(_Data, FSeries.graphMinY);
end;

procedure TPlotSeries._var_MaxY;
begin
  dtReal(_Data, FSeries.graphMaxY);
end;

procedure TPlotSeries._var_MinX;
begin
  dtReal(_Data, FSeries.graphMinX);
end;

procedure TPlotSeries._var_MaxX;
begin
  dtReal(_Data, FSeries.graphMaxX);
end;

procedure TPlotSeries._SetX(var Item:TData; var Val:TData);
begin
  FSeries.Values[ToInteger(Item)].x := ToReal(Val);
end;

function TPlotSeries._GetX(Var Item:TData; var Val:TData):boolean;
begin
  dtReal(val, FSeries.Values[ToInteger(Item)].x);
  Result := true;
end;

procedure TPlotSeries._AddX(var Val:TData);
begin
  FSeries.Add(0, ToReal(Val));
end;

procedure TPlotSeries._SetY(var Item:TData; var Val:TData);
begin
  FSeries.Values[ToInteger(Item)].y := ToReal(Val);
end;

function TPlotSeries._GetY(Var Item:TData; var Val:TData):boolean;
begin
  dtReal(val, FSeries.Values[ToInteger(Item)].y);
  Result := true;
end;

procedure TPlotSeries._AddY(var Val:TData);
begin
  _work_doAdd(val, 0);
end;

function TPlotSeries._Count:integer;
begin
  Result := FSeries.Count;
end;

procedure TPlotSeries._var_ValuesX;
begin
   if ArrX = nil then ArrX := CreateArray(_SetX, _GetX, _Count, _AddX);
   dtArray(_Data,ArrX);
end;

procedure TPlotSeries._var_ValuesY;
begin
   if ArrY = nil then ArrY := CreateArray(_SetY, _GetY, _Count, _AddY);
   dtArray(_Data,ArrY);
end;

end.
