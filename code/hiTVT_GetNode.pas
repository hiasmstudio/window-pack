unit hiTVT_GetNode;

interface

uses Kol,Share,Debug,hiTreeViewTrain;

type
  THITVT_GetNode = class(TDebug)
   private
    FData:TData;
   public
    _prop_TreeView:PITreeViewTrain;

    _data_ID:THI_Event;
    _event_onGetFailed:THI_Event;
    _event_onGetNode:THI_Event;

    procedure _work_doGetNode(var _Data:TData; Index:word);
    procedure _var_Node(var _Data:TData; Index:word);
  end;

implementation


procedure THITVT_GetNode._work_doGetNode;
var n:cardinal;
    d:TData;
begin
   d := ReadData(_Data, _data_ID); 
   n := _prop_TreeView.findNode(d);
   if n = 0 then
     _hi_onEvent(_event_onGetFailed, d)
   else
     begin
       dtNull(FData);
       CopyData(@FData, PData(_prop_TreeView.Control.TVItemData[n])); 
       d := FData;
       _hi_onEvent(_event_onGetNode, d);
     end;
end;

procedure THITVT_GetNode._var_Node;
begin
   _Data := FData; 
end;

end.
