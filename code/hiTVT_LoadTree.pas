unit hiTVT_LoadTree;

interface

uses Kol,Share,Debug,hiTreeViewTrain;

type
  THITVT_LoadTree = class(TDebug)
   private
   public
    _prop_TreeView:PITreeViewTrain;
    _prop_Format:procedure(var _Data:TData) of object;
    _prop_FileName:string;
    _prop_Delimiter:string;

    _data_FileName:THI_Event;
    _event_onLoadTree:THI_Event;

    procedure TreeText(var _Data:TData);
    procedure TreeXML(var _Data:TData);
    procedure _work_doLoadTree(var _Data:TData; Index:word);
  end;

implementation

uses hiMT_String;

procedure THITVT_LoadTree._work_doLoadTree;
begin
   _prop_Format(_Data);
   _hi_CreateEvent(_Data, @_event_onLoadTree);
end;

procedure THITVT_LoadTree.TreeText;
var   Lst:PStrList;
      Control:PControl;
      d:TData;
      s:string;
      i:smallint;
      Last,Prn:cardinal;
begin
   Control := _prop_TreeView.Control;
   Lst := NewStrList;
   Lst.LoadFromFile(ReadFileName(ReadString(_Data,_data_FileName,_prop_FileName)));

   Control.Clear;
   Last := 0;
   Prn := 0;
   for i := 0 to Lst.Count-1 do
     begin
      s := Lst.Items[i];
      if s = '(' then
         Prn := Last
      else if s = ')' then
        begin
          last := Prn;
          Prn := Control.TVItemParent[Prn];
        end
      else
        begin
          TextToMT(s, d, _prop_Delimiter);
          _prop_TreeView.AddNodeAt(Prn, d, @last); 
        end;
   end;

   Lst.Free;
end;

procedure THITVT_LoadTree.TreeXML;
begin

end;

end.
