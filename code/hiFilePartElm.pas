unit hiFilePartElm;

interface

uses Windows, Kol, Share, Debug;

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
    procedure _work_doPart2(var _Data: TData; Index: word);  // file name WOExt
    procedure _work_doPart3(var _Data: TData; Index: word);  // ext name
    procedure _work_doPart4(var _Data: TData; Index: word);  // ext name WOPoint    
    procedure _work_doPart5(var _Data: TData; Index: word);  // short name
    procedure _work_doPart6(var _Data: TData; Index: word);  // path name WOExt
    procedure _work_doPart7(var _Data: TData; Index: word);  // long name   
    procedure _var_Part(var _Data: TData; Index: word);
  end;

implementation

uses hiStr_Enum;

function GetLongPathName(lpszShortName: LPCTSTR; lpszLongName: LPTSTR;
         cchBuffer: DWORD): DWORD; stdcall; external 'kernel32.dll' name 'GetLongPathNameA';

function ShortToLongFileName(FileName: string): string;
begin
  SetLength(Result, MAX_PATH + 1);
  SetLength(Result, GetLongPathName(PChar(FileName), @Result[1], MAX_PATH));
end;

procedure THIFilePartElm._work_doPart0;  // path name
begin
   FPart := ReadString(_Data, _data_FileName, '');
   if FPart = '' then exit;
   if Pos('/', FPart) <> 0 then
   begin
     rparse(FPart, '/');
     FPart := FPart + '/';
   end  
   else       
   begin
     rparse(FPart, '\');
     FPart := FPart + '\';
   end;
//     FPart := ExtractFilePath(FPart);
   _hi_CreateEvent(_Data, @_event_onPart, FPart);
end;

procedure THIFilePartElm._work_doPart1;  // file name
begin
   FPart := ReadString(_Data, _data_FileName, '');
   if FPart = '' then exit;
//   FPart := ExtractFileName(FPart);
   if Pos('/', FPart) <> 0 then
     FPart := rparse(FPart, '/')
   else
     FPart := rparse(FPart, '\');
   _hi_CreateEvent(_Data, @_event_onPart, FPart);
end;

procedure THIFilePartElm._work_doPart2;  // file name WOExt
begin
   FPart := ReadString(_Data, _data_FileName, '');
   if FPart = '' then exit;
//   FPart := ExtractFileNameWOext(FPart);
   if Pos('/', FPart) <> 0 then
     FPart := rparse(FPart, '/')
   else
     FPart := rparse(FPart, '\');
   if Pos('.', FPart) <> 0 then rparse(FPart, '.');
   _hi_CreateEvent(_Data, @_event_onPart, FPart);
end;

procedure THIFilePartElm._work_doPart3;  // ext name
begin
   FPart := ReadString(_Data, _data_FileName, '');
   if FPart = '' then exit;
//   FPart := ExtractFileExt(FPart);
   if Pos('/', FPart) <> 0 then
     FPart := rparse(FPart, '/')
   else
     FPart := rparse(FPart, '\');
   if Pos('.', FPart) <> 0 then
   begin 
     FPart := rparse(FPart, '.');
     FPart := '.' + FPart;
     _hi_CreateEvent(_Data, @_event_onPart, FPart);
   end;
end;

procedure THIFilePartElm._work_doPart4;  // ext name WOPoint
begin
   FPart := ReadString(_Data, _data_FileName, '');
   if FPart = '' then exit;
//   FPart := ExtractFileExt(FPart);
//   delete(FPart, 1, 1);
   if Pos('/', FPart) <> 0 then
     FPart := rparse(FPart, '/')
   else
     FPart := rparse(FPart, '\');

   if Pos('.', FPart) <> 0 then
   begin 
     FPart := rparse(FPart, '.');
     _hi_CreateEvent(_Data, @_event_onPart, FPart);
   end;
end;

procedure THIFilePartElm._work_doPart5;  // short name
begin
   FPart := ReadString(_Data, _data_FileName, '');
   if FPart = '' then exit;
   FPart := ExtractShortPathName(FPart);
   _hi_CreateEvent(_Data, @_event_onPart, FPart);
end;

//=======Добавил nesco & TAD 13.04.2016 ==========
procedure THIFilePartElm._work_doPart6;  // path name WOExt
begin
   FPart := ReadString(_Data, _data_FileName, '');
   if FPart = '' then exit;

   if Pos('/', FPart) <> 0 then
     rparse(FPart, '/')
   else       
     rparse(FPart, '\');
   if Pos('.', FPart) <> 0 then  rparse(FPart, '.');
   _hi_CreateEvent(_Data, @_event_onPart, FPart);
end;
//=========================================

procedure THIFilePartElm._work_doPart7;  // long name
begin
   FPart := ReadString(_Data, _data_FileName, '');
   if FPart = '' then exit;
   FPart := ShortToLongFileName(FPart);
   _hi_CreateEvent(_Data, @_event_onPart, FPart);
end;

procedure THIFilePartElm._var_Part;
begin
  dtString(_Data, FPart);
end;

end.