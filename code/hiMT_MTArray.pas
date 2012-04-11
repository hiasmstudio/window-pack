unit hiMT_MTArray; { Компонент MT_MTArray (массив MT-потоков) ver 1.30 }

interface

uses Kol,Share,Debug;

type
   ThiMT_MTArray = class(TDebug)
      private
         Arr:PArray;
         FList:PList;
         procedure _Set(var Item:TData; var Val:TData);
         function  _Get(Var Item:TData; var Val:TData):boolean;
         function  _Count:integer;
         procedure _Add(var Val:TData);
      public
         constructor Create;
         destructor Destroy; override;
         procedure _work_doClear(var _Data:TData; Index:word);
         procedure _work_doDelete(var _Data:TData; Index:word);
         procedure _var_Array(var _Data:TData; Index:word);
   end;

implementation

constructor ThiMT_MTArray.Create;
begin
  inherited;
  FList := newlist;
end;

destructor ThiMT_MTArray.Destroy;
var   i:integer;
begin
   for i := 0 to FList.Count-1 do begin 
     FreeData(PData(FList.Items[i]));
     dispose(PData(FList.Items[i]));
   end;
   FList.Free;
   if Arr <> nil then dispose(Arr);
   inherited;
end;

procedure ThiMT_MTArray._Set;
var   ind:integer;
begin
   ind := ToIntIndex(Item);
   if(ind >= 0)and(ind < _Count)then begin
      FreeData(PData(FList.Items[ind]));
      CopyData(PData(FList.Items[ind]),@Val);
      FreeData(@Val);
   end;
end;

procedure ThiMT_MTArray._Add;
var   dt:PData;
begin
   new(dt);
   CopyData(dt,@Val);
   FreeData(@Val);
   FList.Add(dt);
end;

function ThiMT_MTArray._Get;
var   ind:integer;
begin
   ind := ToIntIndex(Item);
   if(ind >= 0)and(ind < _Count)then begin
      Result := true;
      FreeData(@Val);
      dtNull(Val);
      CopyData(@Val, PData(FList.Items[ind]));
   end
   else Result := false;
end;

function ThiMT_MTArray._Count;
begin
   Result := FList.Count;
end;

procedure ThiMT_MTArray._var_Array;
begin
   if Arr = nil then
      Arr := CreateArray(_Set, _Get, _Count, _Add);
   dtArray(_Data,Arr);
end;

procedure ThiMT_MTArray._work_doClear;
var   i:integer;
begin
  for i := 0 to FList.Count-1 do begin 
     FreeData(PData(FList.Items[i]));
     dispose(PData(FList.Items[i]));
  end;
  FList.Clear;
end;

procedure ThiMT_MTArray._work_doDelete;
var
  ind: integer;
begin
  ind := ToIntIndex(_Data);
  if (ind >= 0) and (ind < FList.Count) then
  begin
    FreeData(PData(FList.Items[ind]));
    dispose(PData(FList.Items[ind]));
    FList.Delete(ind);
  end;
end;

end.