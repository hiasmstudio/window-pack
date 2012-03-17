unit hiPointInRectParam;

interface

uses Kol, Share, Debug;

type
  ThiPointInRectParam = class(TDebug)
   private
   public
    _prop_Parameters: string;
    _prop_Delimiter: string;    
    _prop_Point2AsOffset:boolean;

    _data_X:THI_Event;
    _data_Y:THI_Event;
    _data_Parameters:THI_Event;
    _event_onTrue:THI_Event;
    _event_onFalse:THI_Event;    

    procedure _work_doCheck(var _Data:TData; Index:word);
    procedure _var_TextParam(var _Data:TData; Index:word);    
  end;

implementation
uses hiStr_Enum;

(* <X1>,<Y1>,<X2>,<Y2 *)

type
 TSPoint = record x,y:smallint; end;
 PSPoint = ^TSPoint;

procedure ThiPointInRectParam._work_doCheck;
var
  Result: boolean;
  se: string;
  sp: string;
  x, y, x1, x2, y1, y2, i: integer;
  ParamList: PStrList;    
begin      
  x := ReadInteger(_Data,_data_X);
  y := ReadInteger(_Data,_data_Y);
    
  ParamList := NewStrList;
  ParamList.text := ReadString(_Data, _data_Parameters, _prop_Parameters);
  Result := false;
TRY
  if (_prop_Delimiter = '') or (ParamList.Count = 0) then exit;

  for i := 0 to ParamList.Count - 1 do
  begin
    se := ParamList.Items[i]; 

    (* Coordinate - <X1>,<Y1>,<X2>,<Y2> *)

    if se <> '' then
    begin
      (* X1 *)
      sp := fparse(se, _prop_Delimiter[1]);
      if sp <> '' then x1 := str2int(sp);
      if se <> '' then
      begin
        (* Y1 *)
        sp := fparse(se, _prop_Delimiter[1]);
        if sp <> '' then y1 := str2int(sp);
        if se <> '' then
        begin
          (* X2 *)
          sp := fparse(se, _prop_Delimiter[1]);
          if sp <> '' then x2 := str2int(sp);
          if se <> '' then
          begin
            (* Y2 *)
            sp := fparse(se, _prop_Delimiter[1]);
            if sp <> '' then y2 := str2int(sp);
          end;              
        end;              
      end;             
    end;
    if _prop_Point2AsOffset then
      Result := (x >= x1) and (x <= x1 + x2) and (y >= y1) and (y <= y1 + y2)
    else
      Result := (x >= x1) and (x <= x2) and (y >= y1) and (y <= y2);
    if Result then break;
  end;  
FINALLY
  ParamList.free;
  if Result then
    _hi_CreateEvent(_Data, @_event_onTrue, i)
  else
   _hi_CreateEvent(_Data,@_event_onFalse);
END;    
end;

procedure ThiPointInRectParam._var_TextParam;
var
  dt: TData;
begin
  dtNull(dt);
  dtString(_Data, ReadString(dt, _data_Parameters, _prop_Parameters));
end;

end.
