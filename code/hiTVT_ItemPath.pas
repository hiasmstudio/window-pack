unit hiTVT_ItemPath;

interface

uses Kol,Share,Debug,hiTreeViewTrain;

type
  THITVT_ItemPath = class(TDebug)
   private
   public
    _prop_TreeView:PITreeViewTrain;
    _prop_Delimiter:string;

    _data_ID:THI_Event;
    _event_onError:THI_Event;
    _event_onItemPath:THI_Event;

    procedure _work_doItemPath(var _Data:TData; Index:word);
  end;

implementation

procedure THITVT_ItemPath._work_doItemPath;
var err:integer;
    d,id:TData;
begin
  id := ReadData(_Data, _data_ID);
  err := _prop_TreeView.ItemPath(d, id, _prop_Delimiter[1]);
  case err of
    IPATH_ERR_SUCCESS: _hi_onEvent(_event_onItemPath, d);
    IPATH_ERR_PARENT_NF: _hi_onEvent(_event_onError);
  end;  
end;

end.