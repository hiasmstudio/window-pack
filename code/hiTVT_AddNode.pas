unit hiTVT_AddNode;

interface

uses Kol,Share,Debug,hiTreeViewTrain;

type
  THITVT_AddNode = class(TDebug)
   private
   public
    _prop_TreeView:PITreeViewTrain;

    _data_Data:THI_Event;
    _event_onAddFailed:THI_Event;
    _event_onAddNode:THI_Event;

    procedure _work_doAddNode(var _Data:TData; Index:word);
  end;

implementation

procedure THITVT_AddNode._work_doAddNode;
var err:integer;
    d:TData;
begin
  d := ReadMTData(_Data, _data_Data); 
  err := _prop_TreeView.AddNode(d);
  case err of
    ADD_ERR_SUCCESS: _hi_onEvent(_event_onAddNode);
    ADD_ERR_PARENT_NF: _hi_onEvent(_event_onAddFailed, d); 
  end;    
end;

end.
