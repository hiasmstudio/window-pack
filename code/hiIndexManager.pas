unit hiIndexManager;

interface
     
uses Messages,Windows,Kol,Share,Debug;

const
   SKIP = -1;

type
  TIIndexManager = record
    outidx:function(inidx:integer): integer of object;
    addControl:procedure(obj:PControl) of object;
    removeControl:procedure(obj:PControl) of object;
  end;
  IIndexManager = ^TIIndexManager;

  THIIndexManager = class(TDebug)
   private
     im:TIIndexManager;
     Items:PStrListEx;
     FArr:PArray;
     FList:PList;

     function outidx(inidx:integer): integer;
     procedure addControl(obj:PControl);
     procedure removeControl(obj:PControl);
     
     procedure _arr_set(var Item:TData; var Val:TData);
     function  _arr_get(Var Item:TData; var Val:TData):boolean;
     function  _arr_count:integer;
     procedure _arr_add(var Item:TData);
   public
     _prop_Name:string;

     constructor Create;
     destructor Destroy;override;
     function getInterfaceIndex:IIndexManager;
     procedure SetIdx(Value:PStrListEx);
     procedure _work_doClear(var _Data:TData; index:word);
     procedure _work_doDelete(var _Data:TData; index:word);
     procedure _var_Indexes(var _Data:TData; index:word);
     property _prop_Index: PStrListEx write SetIdx;
  end;

implementation

procedure THIIndexManager.SetIdx;
begin
  Items := Value;
end;

constructor THIIndexManager.Create;
begin
   inherited;
   im.outidx := outidx;
   im.addControl := addControl;
   im.removeControl := removeControl;   
   FList := NewList;   
end;

destructor THIIndexManager.Destroy;
begin
   if FArr <> nil then dispose(FArr);
   FList.Free;   
   Items.Free;
   inherited;
end;

function THIIndexManager.getInterfaceIndex;
begin
   Result := @im;
end;

function THIIndexManager.outidx;
begin
   Result := SKIP;
   if not Assigned(Items) then exit;
   if (inidx >= 0) and (inidx < Items.Count) then Result := integer(Items.Objects[inidx])
end;

procedure THIIndexManager.addControl;
begin
  FList.Add(obj);
end;

procedure THIIndexManager.removeControl;
begin
  FList.Remove(obj);
end;

procedure THIIndexManager._var_Indexes(var _Data:TData; index:word);
begin
   if FArr = nil then
    begin
      FArr := CreateArray(_arr_set,_arr_get,_arr_count,_arr_add);
      if not Assigned(Items) then
        Items := NewStrListEx;
    end;
   dtArray(_Data,FArr);
end;

procedure THIIndexManager._arr_set(var Item:TData; var Val:TData);
var i:integer;
begin
  i := ToInteger(Item);
  if (i >= 0) and (i < Items.Count) then 
    Items.Objects[i] := ToInteger(Val);
  if FList.Count <> 0 then
    for i := 0 to FList.Count - 1 do
      PControl(FList.Items[i]).Invalidate;
end;

function  THIIndexManager._arr_get(Var Item:TData; var Val:TData):boolean;
var i:integer;
begin
  i := ToInteger(Item);
  if (i >= 0) and (i < Items.Count) then 
    dtInteger(Val, integer(Items.Objects[i]))
  else dtNull(val);
  Result := _IsInteger(Val);
end;

function  THIIndexManager._arr_count:integer;
begin
  Result := Items.Count;
end;

procedure THIIndexManager._arr_add(var Item:TData);
begin
   Items.AddObject('auto', ToInteger(Item));
end;

procedure THIIndexManager._work_doClear;
begin
  if not Assigned(Items) then exit;
  Items.Clear;
end;

procedure THIIndexManager._work_doDelete;
var
  i: integer;
begin
  i := ToInteger(_Data);
  if Assigned(Items) and (i >= 0) and (i < Items.Count) then
    Items.Delete(i);
end;

end.