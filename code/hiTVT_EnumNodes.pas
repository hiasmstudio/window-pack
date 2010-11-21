unit hiTVT_EnumNodes;

interface

uses Kol,Share,Debug,hiTreeViewTrain;

type
  THITVT_EnumNodes = class(TDebug)
   private
      FCurNode:PData;
   public
    _prop_TreeView:PITreeViewTrain;

    _data_ID:THI_Event;
    _event_onStop:THI_Event;
    _event_onEnum:THI_Event;

    procedure _work_doEnum(var _Data:TData; Index:word);
    procedure _var_Node(var _Data:TData; Index:word);
  end;

implementation

procedure THITVT_EnumNodes._work_doEnum;
var id:TData;
    r:cardinal;
      procedure Enum(prn:cardinal);
      var d:TData;
      begin
         if prn > 0 then 
           begin
             FCurNode := PData(_prop_TreeView.Control.TVItemData[prn]);
             d := FCurNode^;
             _hi_onEvent(_event_onEnum, d);
             if _prop_TreeView.Control.TVItemChild[prn] > 0 then 
               Enum(_prop_TreeView.Control.TVItemChild[prn]);
             Enum(_prop_TreeView.Control.TVItemNext[prn]);
           end;
      end;
begin
   id := ReadData(_Data, _data_ID);
   if _isNull(id) then
      r := _prop_TreeView.Control.TVRoot
   else r := _prop_TreeView.Control.TVItemChild[_prop_TreeView.findNode(id)];
   Enum(r);
   _hi_onEvent(_event_onStop);
end;

procedure THITVT_EnumNodes._var_Node;
begin
  dtData(_Data, FCurNode^);
end;

end.
