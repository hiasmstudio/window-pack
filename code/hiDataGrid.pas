unit hiDataGrid;

interface

uses windows,Kol,Share,Win,KOLEdb;

type
  THIDataGrid = class(THIWin)
   private
   public
    _data_Query:THI_Event;

    constructor Create(Parent:PControl);
    procedure _work_doRefresh(var _Data:TData; Index:word);
  end;

implementation

uses hiMSSQL;

function SqlDateTimeStampToDateTime( TS: PSqlDateTimeStamp ): TDateTime;
var ST: TSystemTime;
begin
   ST.wYear := TS.Year;
   ST.wMonth := TS.month;
   ST.wDay := TS.day;
   ST.wHour := TS.hour;
   ST.wMinute := TS.minute;
   ST.wSecond := TS.second;
   ST.wMilliseconds := TS.fraction div 1000000;
   SystemTime2DateTime( ST, Result );
end;

constructor THIDataGrid.Create;
begin
   inherited;

   Control := NewListView(Parent,lvsDetail,[],nil,nil,nil);
end;

procedure THIDataGrid._work_doRefresh;
var qr:PQuery;
    i,n:word;
    dt:TData;
begin
   dt := Readdata(_Data,_data_Query,nil);
   if _isObject(dt,mssqlGUID) then
    begin
       qr := PQuery(ToObject(dt));
//       _debug('ok');
//       QR.First;
//       _debug(QR.ColCount);
       Control.Clear;
       while Control.LVColCount > 0 do
         Control.LVColDelete(0);

       if QR.ColCount > 0 then
        for i := 0 to QR.ColCount-1 do
         Control.LVColAdd(QR.ColNames[i],taleft,Control.Canvas.TextWidth(QR.ColNames[i])+20);
       while not qr.EOF do
        begin
         N := Control.LVItemAdd('');
         for i := 0 to QR.ColCount-1 do
          case QR.Bindings[i].wType of
           DBTYPE_STR,DBTYPE_WSTR:
             begin
               Control.LVItems[N,i] := QR.SField[i];
             end;
           DBTYPE_I4,DBTYPE_I2:
             Control.LVItems[N,i] := Int2Str( QR.IField[i] );
           DBTYPE_R4,DBTYPE_R8:
             Control.LVItems[N,i] := Double2Str( QR.RField[i] );
           DBTYPE_NULL:
             Control.LVItems[N,i] := 'NULL';
           DBTYPE_EMPTY:    
             Control.LVItems[N,i] := 'EMPTY';
           DBTYPE_DATE:
             Control.LVItems[N,i] := '-dt-';
           DBTYPE_DBTIMESTAMP:
             Control.LVItems[N,i] := DateTime2StrShort( SqlDateTimeStampToDateTime(QR.TSField[i]) );
          end;
         QR.Next;
        end;
    end;
end;

end.
