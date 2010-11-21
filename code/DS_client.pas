unit DS_client;

interface

uses Kol, Share, Debug;

type

  TCallBackFields = procedure (list: PStrList)  of object;
  TCallBackData   = procedure (var Data: TData) of object;

  TCallBackRec = record
    callBackFields: TCallBackFields;
    callBackData: TCallBackData;
    firstCall: boolean;
  end;
  PCallBackRec = ^TCallBackRec;

  TIDataSource = record
    procexec:        function (const SQL: string): TData of object;
    procquery:       function (const SQL: string; callBackFields: TCallBackFields; callBackData: TCallBackData): TData of object;
    procqueryscalar: function (const SQL: string; var Data: TData): TData of object;
  end;
  IDataSource = ^TIDataSource;

implementation

end.