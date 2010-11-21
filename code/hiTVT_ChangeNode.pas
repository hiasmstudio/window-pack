unit hiTVT_ChangeNode;

interface

uses Kol,Share,Debug,hiTreeViewTrain;

type
  THITVT_ChangeNode = class(TDebug)
   private
   public
    _prop_TreeView:PITreeViewTrain;

    _data_Data:THI_Event;
    _event_onChangeFailed:THI_Event;
    _event_onChangeNode:THI_Event;

    procedure _work_doChangeNode(var _Data:TData; Index:word);
  end;

implementation

procedure THITVT_ChangeNode._work_doChangeNode;
var err:integer;
    d:TData;
begin
  d := ReadMTData(_Data, _data_Data); 
  err := _prop_TreeView.ChangeNode(d);
  case err of
    CHANGE_ERR_SUCCESS: _hi_onEvent(_event_onChangeNode);
    CHANGE_ERR_ID_NF: _hi_onEvent(_event_onChangeFailed, d); 
  end; 
end;

end.
