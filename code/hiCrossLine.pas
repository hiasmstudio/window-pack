unit hiCrossLine;

interface

uses kol,Share,Debug;

type
 THICrossLine = class(TDebug)
   private
    _ResX,_ResY:real;
   public
    _data_AX1:THI_Event;
    _data_AY1:THI_Event;
    _data_AX2:THI_Event;
    _data_AY2:THI_Event;
    _data_BX1:THI_Event;
    _data_BY1:THI_Event;
    _data_BX2:THI_Event;
    _data_BY2:THI_Event;
    _prop_AX1:real;
    _prop_AY1:real;
    _prop_AX2:real;
    _prop_AY2:real;
    _prop_ResultType:byte;    
    _event_onIntercross:THI_Event;
    procedure _work_doIntercross(var _Data:TData; Index:word);
    procedure _var_ResultX(var _Data:TData; Index:word);
    procedure _var_ResultY(var _Data:TData; Index:word);
 end;

implementation

procedure THICrossLine._work_doIntercross;
var
  _AX1,_AY1,_AX2,_AY2,_BX1,_BY1,_BX2,_BY2,Dat1,Dat2,Dat3,Dat4,Dat5,Dat6,Dat7:real;
  Res:integer;
begin
  _AX1:= ReadReal(_Data,_data_AX1,_prop_AX1);
  _AY1:= ReadReal(_Data,_data_AY1,_prop_AY1);
  _AX2:= ReadReal(_Data,_data_AX2,_prop_AX2);
  _AY2:= ReadReal(_Data,_data_AY2,_prop_AY2);
  _BX1:= ReadReal(_Data,_data_BX1,0);
  _BY1:= ReadReal(_Data,_data_BY1,0);
  _BX2:= ReadReal(_Data,_data_BX2,0);
  _BY2:= ReadReal(_Data,_data_BY2,0);
  Dat1:=_AX2-_AX1;
  Dat2:=_AY2-_AY1;
  Dat3:=_BX2-_BX1;
  Dat4:=_BY2-_BY1;
   if (((_BY1-_AY1)*Dat1-(_BX1-_AX1)*Dat2)*((_BY2-_AY1)*Dat1-(_BX2-_AX1)*Dat2)>0)
   or (((_AY1-_BY1)*Dat3-(_AX1-_BX1)*Dat4)*((_AY2-_BY1)*Dat3-(_AX2-_BX1)*Dat4)>0) then
    begin
     Res:=0;
     _ResX:=0;
     _ResY:=0;
    end
   else
    begin
     Res:=1;
     Dat5:=Dat1*Dat4-Dat2*Dat3;
     Dat6:=_AY1*Dat1-_AX1*Dat2;
     Dat7:=_BY1*Dat3-_BX1*Dat4;
      if Dat5<>0 then
       begin
        _ResX:=(Dat3*Dat6-Dat1*Dat7)/Dat5;
        _ResY:=(Dat4*Dat6-Dat2*Dat7)/Dat5;
       end;
    end;
   _hi_CreateEvent(_Data, @_event_onIntercross,Res);
end;

procedure THICrossLine._var_ResultX;
begin
  if _prop_ResultType = 0 then
    dtInteger(_Data,integer(Round(_ResX)))
  else  dtReal(_Data,_ResX);
end;

procedure THICrossLine._var_ResultY;
begin
  if _prop_ResultType = 0 then
    dtInteger(_Data,integer(Round(_ResY)))
  else dtReal(_Data,_ResY);
end;

end.