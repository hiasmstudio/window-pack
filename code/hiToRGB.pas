unit hiToRGB;   { Компонент формирования и разложения цвета по R, G и B составляющим}

interface

uses Kol,Share,Debug,Windows;

type
  THIToRGB = class(TDebug)
   private
    fFrom: TRGB;
   public
    _prop_Color:TColor;
    _data_Color:THI_Event;
    _event_onResult:THI_Event;

    procedure _work_doGetRGB(var _Data:TData; Index:word);
    procedure _var_R(var _Data:TData; Index:word);
    procedure _var_G(var _Data:TData; Index:word);
    procedure _var_B(var _Data:TData; Index:word);
  end;

type
  PColor = ^TColor;

implementation

procedure THIToRGB._work_doGetRGB;
var dr,dg,db:TData;
begin
   fFrom := TRGB(Color2RGB(ReadInteger(_Data, _data_Color, _prop_Color)));
   dtInteger(dr, FFrom.R);
   dtInteger(dg, FFrom.G);
   dr.ldata:= @dg;
   dtInteger(db, FFrom.B);
   dg.ldata:= @db;
   _hi_onEvent_(_event_onResult, dr);   
end;

procedure THIToRGB._var_R;
begin
   dtInteger(_Data, FFrom.R);
end;

procedure THIToRGB._var_G;
begin
   dtInteger(_Data, FFrom.G);
end;

procedure THIToRGB._var_B;
begin
   dtInteger(_Data, FFrom.B);
end;

end.