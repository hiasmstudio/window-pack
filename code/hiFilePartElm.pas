unit hiFilePartElm;

interface

uses Kol, Share, Debug;

type
  THIFilePartElm = class(TDebug)
   private
     FPart: string;
   public
    _prop_Mode: byte;

    _data_FileName: THI_Event;
    _event_onPart: THI_Event;

    procedure _work_doPart0(var _Data: TData; Index: word);  // path name
    procedure _work_doPart1(var _Data: TData; Index: word);  // file name
    procedure _work_doPart2(var _Data: TData; Index: word);  // file name  WOExt
    procedure _work_doPart3(var _Data: TData; Index: word);  // ext name
    procedure _work_doPart4(var _Data: TData; Index: word);  // ext name WOPoint    
    procedure _work_doPart5(var _Data: TData; Index: word);  // short name
    procedure _var_Part(var _Data: TData; Index: word);
  end;

implementation

procedure THIFilePartElm._work_doPart0;  // path name
begin
   FPart := ReadString(_Data, _data_FileName, '');
   if FPart = '' then exit;
   FPart := ExtractFilePath(FPart);
   _hi_CreateEvent(_Data, @_event_onPart, FPart);
end;

procedure THIFilePartElm._work_doPart1;  // file name
begin
   FPart := ReadString(_Data, _data_FileName, '');
   if FPart = '' then exit;
   FPart := ExtractFileName(FPart);
   _hi_CreateEvent(_Data, @_event_onPart, FPart);
end;

procedure THIFilePartElm._work_doPart2;  // file name WOExt
begin
   FPart := ReadString(_Data, _data_FileName, '');
   if FPart = '' then exit;
   FPart := ExtractFileNameWOext(FPart);
   _hi_CreateEvent(_Data, @_event_onPart, FPart);
end;


procedure THIFilePartElm._work_doPart3;  // ext name
begin
   FPart := ReadString(_Data, _data_FileName, '');
   if FPart = '' then exit;
   FPart := ExtractFileExt(FPart);
   _hi_CreateEvent(_Data, @_event_onPart, FPart);
end;

procedure THIFilePartElm._work_doPart4;  // ext name WOPoint
begin
   FPart := ReadString(_Data, _data_FileName, '');
   if FPart = '' then exit;
   FPart := ExtractFileExt(FPart);
   delete(FPart, 1, 1);
   _hi_CreateEvent(_Data, @_event_onPart, FPart);
end;

procedure THIFilePartElm._work_doPart5;  // short name
begin
   FPart := ReadString(_Data, _data_FileName, '');
   if FPart = '' then exit;
   FPart := ExtractShortPathName(FPart);
   _hi_CreateEvent(_Data, @_event_onPart, FPart);
end;

procedure THIFilePartElm._var_Part;
begin
  dtString(_Data, FPart);
end;

end.