unit hiPlotDiffSeries;

interface

uses Kol,Share,Debug,hiPlotter,hiFastMathParse;

type
  THIPlotDiffSeries = class(TDebug)
   private
    FResult:TSeries;
    FMath:THIFastMathParse;
      
    procedure SetResultSeries(value:TSeries);
    
    procedure _onResult(var _Data:TData; Index:word);
    procedure _arg1(var _Data:TData; Index:word);
    procedure _arg2(var _Data:TData; Index:word);
   public
    _prop_Series1:TSeries;
    _prop_Series2:TSeries;
    _prop_Mask:string;

    _event_onDiff:THI_Event;

    constructor Create;
    destructor Destroy; override;
    procedure _work_doDiff(var _Data:TData; Index:word);
    property _prop_ResultSeries:TSeries read FResult write SetResultSeries;
  end;

implementation

constructor THIPlotDiffSeries.Create;
begin
   inherited;
   FMath := THIFastMathParse.Create;
   FMath._prop_ResultType := 1;
   FMath._prop_DataCount := 2;
   FMath._event_onResult.Event := _onResult;
   FMath.X[0].Event := _arg1;
   FMath.X[1].Event := _arg2;
end;

destructor THIPlotDiffSeries.Destroy;
begin
   FMath.Destroy;
   inherited;
end;

procedure THIPlotDiffSeries._work_doDiff;
var i:integer;
begin
   FResult.Clear;
   for i := 0 to _prop_Series1.Count-1 do
     FMath._work_doCalc(_Data, 0);
end;

procedure THIPlotDiffSeries._onResult;
begin
   FResult.Add(ToReal(_Data), _prop_Series1.Values[FResult.Count].x);
end;

procedure THIPlotDiffSeries._arg1;
begin
   dtReal(_Data, _prop_Series1.Values[FResult.Count].y);
end;

procedure THIPlotDiffSeries._arg2;
begin
   dtReal(_Data, _prop_Series2.Values[FResult.Count].y);
end;

procedure THIPlotDiffSeries.SetResultSeries(value:TSeries);
begin
   FMath._prop_MathStr := _prop_Mask;
   FResult := value;
end;

end.
