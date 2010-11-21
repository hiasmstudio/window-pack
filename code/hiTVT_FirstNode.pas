unit hiTVT_FirstNode;

interface

uses Kol,Share,Debug,hiTreeViewTrain;

type
  THITVT_FirstNode = class(TDebug)
   private
   public
    _prop_TreeView:PITreeViewTrain;

    _data_ID:THI_Event;
    _event_onError:THI_Event;
    _event_onFirstNode:THI_Event;
    _event_onEmpty:THI_Event;

    procedure _work_doFirstNode(var _Data:TData; Index:word);
  end;

implementation

procedure THITVT_FirstNode._work_doFirstNode;
var err:integer;
    d,id:TData;
begin
  id := ReadData(_Data, _data_ID); 
  err := _prop_TreeView.FirstNode(d, id);
  case err of
    FIRST_ERR_SUCCESS: _hi_onEvent(_event_onFirstNode, d);
    FIRST_ERR_PARENT_NF: _hi_onEvent(_event_onError);
    FIRST_ERR_CHILD_NF: _hi_onEvent(_event_onEmpty);  
  end;  
end;

end.
