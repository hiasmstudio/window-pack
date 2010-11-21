unit hiTVT_DeleteNode;

interface

uses Kol,Share,Debug,hiTreeViewTrain;

type
  THITVT_DeleteNode = class(TDebug)
   private
   public
    _prop_TreeView:PITreeViewTrain;

    _data_Data:THI_Event;
    _event_onDeleteFailed:THI_Event;
    _event_onDeleteNode:THI_Event;

    procedure _work_doDeleteNode(var _Data:TData; Index:word);
  end;

implementation

procedure THITVT_DeleteNode._work_doDeleteNode;
var err:integer;
    d:TData;
begin
  d := ReadMTData(_Data, _data_Data); 
  err := _prop_TreeView.DeleteNode(d);
  case err of
    DEL_ERR_SUCCESS: _hi_onEvent(_event_onDeleteNode);
    DEL_ERR_ID_NF: _hi_onEvent(_event_onDeleteFailed, d); 
  end;
end;

end.
