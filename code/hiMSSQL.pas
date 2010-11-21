unit hiMSSQL;

interface

uses Kol,Share,KOLEdb,Debug;

type
  THIMSSQL = class(TDebug)
   private
    ds:PDataSource;
    ss:PSession;
    qr:PQuery;
    procedure _onError(Result: HResult);
   public
    _prop_FileName:string;
    _data_FileName:THI_Event;

    procedure _work_doOpen(var _Data:TData; Index:word);
    procedure _work_doClose(var _Data:TData; Index:word);
    procedure _work_doQuery(var _Data:TData; Index:word);
    procedure _work_doExecute(var _Data:TData; Index:word);
    procedure _var_Query(var _Data:TData; Index:word);
  end;

var mssqlGUID:integer;

implementation

procedure THIMSSQL._onError(Result: HResult);
begin

end;

procedure THIMSSQL._work_doOpen;
var fn:string;
begin
  fn := ReadFileName(ReadString(_Data,_data_FileName,_prop_FileName));
  //ds := NewDataSource( 'PROVIDER=SQLOLEDB;DATA SOURCE=127.0.0.1;DATABASE=users;' +
  //                     'USER ID=test;PASSWORD=test;' );
  
  ds := NewDataSource( 'Provider=Microsoft.Jet.OLEDB.4.0;User ID=Admin;' +
  'Data Source=' + fn + ';Mode=Share Deny None;' +
  'Extended Properties="";Locale Identifier=1033;Persist Security Info=False;', _onError);
  //debug(fn);
  ss := NewSession(ds, _onError);
  qr := NewQuery(ss, _onError);
  genGuid(mssqlGUID);
end;

procedure THIMSSQL._work_doClose;
begin
   if ds <> nil then
    begin
      qr.Free;
      ss.Free;
      ds.Free;
      ds := nil;
    end;
end;

procedure THIMSSQL._work_doQuery;
begin
   qr.Text := ToString(_Data);
   qr.Open;
end;

procedure THIMSSQL._work_doExecute;
begin
   qr.Text := ToString(_Data);
   qr.Execute;
end;

procedure THIMSSQL._var_Query;
begin
   dtObject(_Data,mssqlGUID,qr);
end;

end.
