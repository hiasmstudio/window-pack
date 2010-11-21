unit hiTVT_SaveTree;

interface

uses Kol,Share,Debug,hiTreeViewTrain;

type
  THITVT_SaveTree = class(TDebug)
   private
   public
    _prop_TreeView:PITreeViewTrain;
    _prop_Format:procedure(var _Data:TData) of object;
    _prop_FileName:string;
    _prop_Delimiter:string;

    _data_FileName:THI_Event;
    _event_onSaveTree:THI_Event;

    procedure TreeText(var _Data:TData);
    procedure TreeXML(var _Data:TData);
    procedure _work_doSaveTree(var _Data:TData; Index:word);
  end;

implementation

procedure THITVT_SaveTree._work_doSaveTree;
begin
   _prop_Format(_Data);
   _hi_CreateEvent(_Data, @_event_onSaveTree);
end;

procedure THITVT_SaveTree.TreeText;
var   Lst:PStrList;
      Control:PControl;
      d:PData;
      s:string;
      
      procedure Save(prn:cardinal);
      begin
         if prn > 0 then 
           begin
             d := PData(Control.TVItemData[prn]);
             s := '';
             while d <> nil do
              begin
                 if s = '' then
                   s := ToString(d^) 
                 else
                   begin
                     s := s + _prop_Delimiter + ToString(d^);
                     if (_isType(d^) = data_real) and(d.rdata = Round(d.rdata)) then
                       s := s + '.0';  
                   end; 
                 d := d.ldata;
              end;
             Lst.Add(s);
             //Lst.Add(IndexToStr(prn, Control.TVItemText[prn]));
             if Control.TVItemChild[prn] > 0 then 
               begin
                 Lst.Add('(');               
                 Save(Control.TVItemChild[prn]);
                 Lst.Add(')');
               end;
             Save(Control.TVItemNext[prn]);
           end;
      end;
begin
   Control := _prop_TreeView.Control;
   Lst := NewStrList;
   Save(Control.TVRoot);
   Lst.SaveToFile(ReadFileName(ReadString(_Data,_data_FileName,_prop_FileName)));
   Lst.Free;
end;

procedure THITVT_SaveTree.TreeXML;
var   Lst:PStrList;
      Control:PControl;
      d:PData;
      s:string;
      
      procedure Save(prn:cardinal);
      begin
         if prn > 0 then 
           begin
             d := PData(Control.TVItemData[prn]);
             s := '';
             while d <> nil do
              begin
                 if s = '' then
                   s := ToString(d^) 
                 else s := s + _prop_Delimiter + ToString(d^); 
                 d := d.ldata;
              end;
             Lst.Add(s);
             if Control.TVItemChild[prn] > 0 then 
               begin
                 Lst.Add('(');               
                 Save(Control.TVItemChild[prn]);
                 Lst.Add(')');
               end;
             Save(Control.TVItemNext[prn]);
           end;
      end;
begin
   Control := _prop_TreeView.Control;
   Lst := NewStrList;
   Save(Control.TVRoot);
   Lst.SaveToFile(ReadFileName(ReadString(_Data,_data_FileName,_prop_FileName)));
   Lst.Free;
end;

end.
