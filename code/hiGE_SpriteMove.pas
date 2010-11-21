unit hiGE_SpriteMove;

interface

uses Kol,Share,Debug,hiGE_Scene;

type
  THIGE_SpriteMove = class(TDebug)
   private
   public
    _prop_Sprite:TGE_Object;
    _prop_X:real;
    _prop_Y:real;

    _data_Y:THI_Event;
    _data_X:THI_Event;
    _event_onMove:THI_Event;

    procedure _work_doMove(var _Data:TData; Index:word);
    procedure _var_CurX(var _Data:TData; Index:word);
    procedure _var_CurY(var _Data:TData; Index:word);
    procedure _var_CurKX(var _Data:TData; Index:word);
    procedure _var_CurKY(var _Data:TData; Index:word);
  end;

implementation

procedure THIGE_SpriteMove._work_doMove;
var x,y:real;
begin
  x := ReadReal(_data, _data_X, _prop_X); 
  y := ReadReal(_data, _data_Y, _prop_Y); 
  _prop_Sprite.Move(x, y);
  _hi_onEvent(_event_onMove);
end;

procedure THIGE_SpriteMove._var_CurX;
begin
  dtReal(_Data, _prop_Sprite.X); 
end;

procedure THIGE_SpriteMove._var_CurY;
begin
  dtReal(_Data, _prop_Sprite.Y); 
end;

procedure THIGE_SpriteMove._var_CurKX;
begin
  dtReal(_Data, _prop_Sprite.kX); 
end;

procedure THIGE_SpriteMove._var_CurKY;
begin
  dtReal(_Data, _prop_Sprite.kY); 
end;

end.
