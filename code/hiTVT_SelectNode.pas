unit hiTVT_SelectNode;

interface

uses Kol,Share,Debug,hiTreeViewTrain;

type
  THITVT_SelectNode = class(TDebug)
   private
   public
    _prop_TreeView:PITreeViewTrain;

    _data_ID:THI_Event;
    _event_onSelectFailed:THI_Event;
    _event_onSelectNode:THI_Event;

    procedure _work_doSelectNode(var _Data:TData; Index:word);
    procedure _var_SelectNode(var _Data:TData; Index:word);
  end;

implementation

procedure THITVT_SelectNode._work_doSelectNode;
var n:cardinal;
    d:TData;
begin
   d := ReadData(_Data, _data_ID); 
   n := _prop_TreeView.findNode(d);;
   if n = 0 then
     _hi_onEvent(_event_onSelectFailed)
   else
     begin
       _prop_TreeView.Control.TVSelected := n;
       _hi_onEvent(_event_onSelectNode);
     end;
end;

procedure THITVT_SelectNode._var_SelectNode;
var n:cardinal;
begin
   n := _prop_TreeView.Control.TVSelected;
   if n = 0 then
     dtNull(_Data)
   else _Data := PData(_prop_TreeView.Control.TVItemData[n])^; 
end;

end.
