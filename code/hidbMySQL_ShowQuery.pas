unit hidbMySQL_ShowQuery;

interface

uses Kol,Share,Debug;

type
  THIdbMySQL_ShowQuery = class(TDebug)
   private
   public

    _data_StringTable:THI_Event;
    _data_Fields:THI_Event;
    _data_Rows:THI_Event;

    procedure _work_doShow(var _Data:TData; Index:word);
  end;

implementation

procedure THIdbMySQL_ShowQuery._work_doShow;
var c:PControl;
    m:PMatrix;
    a:PArray;
    i,j:smallint;
    dt,val:TData;
begin
    m := ReadMatrix(_data_Rows);
    a := ReadArray(_data_Fields);
    c := ReadControl(_data_StringTable,'StringTable');
    if Assigned(m) and Assigned(a) and Assigned(c) then
     begin
       C.Clear;
       while C.LVColCount > 0 do
        C.LVColDelete(C.LVColCount-1);

       i := 0;
       dtInteger(Val,i);
       while a._Get(val,dt) do
        begin
         C.LVColAdd(ToString(dt),taLeft,80);
         inc(i);
         dtInteger(val,i);
        end;

       for j := 0 to m._Rows-1 do
        begin
         C.LVItemAdd('');
         for i := 0 to m._Cols-1 do
          begin
            dt := m._Get(i,j);
            C.LVItems[C.Count-1,i] := ToString(dt);
          end;
        end;
     end;
end;

end.
