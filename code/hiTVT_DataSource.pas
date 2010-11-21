unit hiTVT_DataSource;

interface

uses Kol,Share,Debug,hiTreeViewTrain,DS_client;

type
  THITVT_DataSource = class(TDebug)
   private
     procedure callBackData(var Data: TData);
     procedure SaveTree;
   public
    _prop_TreeView:PITreeViewTrain;
    _prop_DataSource:IDataSource;
    _prop_TableName:string;
    _prop_Columns:string;
    
    _event_onLoad:THI_Event;
    _event_onError:THI_Event;
    
    procedure _work_doLoad(var _Data:TData; Index:word);
    procedure _work_doSave(var _Data:TData; Index:word);
  end;

implementation

procedure THITVT_DataSource.callBackData(var Data: TData);
var err:integer;
    d:TData;
begin
  err := _prop_TreeView.AddNode(Data);
  case err of
    ADD_ERR_SUCCESS: ;
    ADD_ERR_PARENT_NF: _hi_onEvent(_event_onError, 1000); 
  end;
end;

procedure THITVT_DataSource._work_doLoad(var _Data:TData; Index:word);
var  
  sql:string;
  err: TData;
begin
  _prop_TreeView.Control.Clear;

  sql := _prop_Columns;
  replace(sql, #13#10, ',');
  sql := 'SELECT ' + sql + ' FROM ' + _prop_TableName; 
  err := _prop_DataSource.procquery(sql, nil, callBackData);
  if not _IsNull(err) then
    _hi_onEvent(_event_onError, err)
  else
    _hi_onEvent(_event_onLoad);
end;

procedure THITVT_DataSource.SaveTree;
var 
      Control:PControl;
      sql:string;
      
      procedure Save(prn:cardinal);
      var s,p:string;
          d:PData;
      begin
         if prn > 0 then 
           begin
             d := PData(Control.TVItemData[prn]);
             s := 'INSERT INTO ' + _prop_TableName + '(' + sql + ') VALUES(';
             while d <> nil do
              begin
                 if _isInteger(d^) then
                   s := s + int2str(ToInteger(d^)) + ','
                 else
                   begin
                     p := ToString(d^);
                     replace(p, '''', ''''''); 
                     s := s + '''' + p + ''',';
                   end;

                 d := d.ldata;
              end;
             delete(s, length(s), 1);
             _prop_DataSource.procexec(s + ')');
             if Control.TVItemChild[prn] > 0 then 
               Save(Control.TVItemChild[prn]);
             Save(Control.TVItemNext[prn]);
           end;
      end;
begin
   Control := _prop_TreeView.Control;
   sql := _prop_Columns;
   replace(sql, #13#10, ',');
   Save(Control.TVRoot);
end;

procedure THITVT_DataSource._work_doSave(var _Data:TData; Index:word);
var
  err: TData;
begin
  err := _prop_DataSource.procexec('DELETE FROM ' + _prop_TableName);
  if not _IsNull(err) then
    _hi_onEvent(_event_onError, err)
  else
    SaveTree;
end;

end.
