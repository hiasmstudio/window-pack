unit HiTempFontProc;

interface

uses Windows,Messages,kol,Share,Debug;

const
   NOT_FIND = -1;

type
 THiTempFontProc = class(TDebug)
   private
     fFontName:string;
     NamesList: PStrList;
     FilesList: PStrList;
     FontMatrix:PMatrix;
     FInSendMessage:boolean;
     function FindName(Name:string):integer;
     procedure InstallfromStream(St:PStream);
     procedure RemoveFont(FileName:string);
     procedure RemoveAllFonts;
     procedure MX_Set(x,y:integer; var Val:TData);
     function  MX_Get(x,y:integer):TData;
     function _mRows:integer;
     function _mCols:integer;
   public
    fStrDelimiter:string;
    _prop_FileName:string;
    _prop_Prefix:string;
    _prop_FontStream:PStream;
   
    _data_FontStream: THI_Event;
    _data_FileName: THI_Event;
    _data_TempFName: THI_Event;
    _data_Index: THI_Event;
    
    _event_onInstall: THI_Event;

    property _prop_InSendMessage: boolean write FInSendMessage;
    constructor Create;
    destructor Destroy; override;
    procedure _work_doInstall(var _Data:TData; Index:word);
    procedure _work_doInstallfromStream(var _Data:TData; Index:word);
    procedure _work_doUnInstall(var _Data:TData; Index:word);
    procedure _work_doUnInstallByFileName(var _Data:TData; Index:word);    
    procedure _work_doClear(var _Data:TData; Index:word);
    procedure _work_doInSendMessage(var _Data:TData; Index:word);  
    procedure _var_Count(var _Data:TData; Index:word);
    procedure _var_Matrix(var _Data:TData; Index:word);
    procedure _var_FontName(var _Data:TData; Index:word);                
    property _prop_StrDelimiter:string read fStrDelimiter write fStrDelimiter;
 end;
implementation

//******************************************************************************

function StringToWideString(const s: String; codePage: Word): WideString;
var   len: integer;
begin
   Result := '';
   if s = '' then exit;
   len := MultiByteToWideChar(codePage, MB_PRECOMPOSED, PChar(@s[1]), -1, nil, 0);
   SetLength(Result, len - 1);
   if len <= 1 then exit;
   MultiByteToWideChar(CodePage, MB_PRECOMPOSED, PChar(@s[1]), -1, PWideChar(@Result[1]), len);
end;

//******************************************************************************

function GetFontName (FontFileA : string) : String;
type
   TGetFontResourceInfoW = function (FontPath : PWideChar; var BufSize : DWORD;
                           FontName : PWideChar; dwFlags : DWORD) : DWORD; stdcall;
var   GetFontResourceInfoW : TGetFontResourceInfoW;
      FontFileW : PWideChar;
      FontNameW : PWideChar;
      FontNameSize : DWORD;
begin
   Result := '';
   GetFontResourceInfoW := GetProcAddress(GetModuleHandle('gdi32.dll'), 'GetFontResourceInfoW');
   if @GetFontResourceInfoW = nil then Exit;
   FontFileW := PWChar(StringToWideString(FontFileA,3));
   FontNameSize := 0;
   FontNameW := nil;
   GetFontResourceInfoW (FontFileW, FontNameSize, FontNameW, 1);
   GetMem (FontNameW, FontNameSize);
   FontNameW^ := #0;
   GetFontResourceInfoW (FontFileW, FontNameSize, FontNameW, 1);
   Result := FontNameW;
end;

//******************************************************************************

constructor THiTempFontProc.Create;
begin
  inherited;
  NamesList := NewStrList;
  FilesList := NewStrList;
end;

destructor THiTempFontProc.Destroy;
begin
   RemoveAllFonts;
   if FontMatrix <> nil then Dispose(FontMatrix);
   NamesList.free;
   FilesList.free;
   inherited;
end;

procedure THiTempFontProc.RemoveFont;
begin
   if (FileName <> '') and FileExists(FileName) then begin
      RemoveFontResource(PChar(FileName));
      if FInSendMessage then SendMessage(HWND_BROADCAST, WM_FONTCHANGE, 0, 0);
      DeleteFiles(PChar(FileName));
   end;
end;

procedure THiTempFontProc.RemoveAllFonts;
begin
   fFontName := '';
   if NamesList.Count = 0 then exit; 
   repeat
      RemoveFont(FilesList.Items[FilesList.Count-1]);
      FilesList.Delete(FilesList.Count-1);
      NamesList.Delete(NamesList.Count-1);      
   until FilesList.Count <= 0;
end;

procedure THiTempFontProc._work_doUnInstallByFileName;
begin
   RemoveFont(ReadString(_Data,_data_TempFName));
end;

procedure THiTempFontProc._work_doUnInstall;
var   idx: integer;
begin
   idx := ReadInteger(_Data,_data_Index);
   if (idx < 0) or (idx > FilesList.Count - 1) then exit; 
   RemoveFont(FilesList.Items[idx]);
   FilesList.Delete(idx);      
   NamesList.Delete(idx);
end;

function THiTempFontProc.FindName;
var   i: integer;
begin
   Result := NOT_FIND;
   for i:=0 to NamesList.Count - 1 do
      if NamesList.Items[i] = Name then begin
         Result := i;
         exit;
      end;
end;

procedure THiTempFontProc.InstallfromStream;
var   FontStream: PStream;
      sfnt:integer;
      FN,FF: string;
      idx: integer;
begin
   fFontName := '';
   if (St = nil) or (St.Size = 0) or (WinVer < wvNT) then exit;
   St.Position := 0;
   FF := CreateTempFile( GetTempDir, _prop_Prefix);
   FontStream := NewWriteFileStream(FF);
   Stream2Stream(FontStream, St, St.Size);
   free_and_nil(FontStream);
   if not FileExists(FF) then exit;  
   sfnt := AddFontResource(PChar(FF));
   if sfnt <> 0 then begin 
      FN := GetFontName(FF);
      idx := FindName(FN);
      if idx <> NOT_FIND then begin
         if FileExists(FN) then DeleteFiles(PChar(FN));
         RemoveFont(FF);
         fFontName := NamesList.Items[idx];
         sfnt := -1;
      end else begin      
         if FInSendMessage then SendMessage(HWND_BROADCAST, WM_FONTCHANGE, 0, 0);
         NamesList.Add(FN);
         FilesList.Add(FF);
      end;         
   end else begin
      if FileExists(FN) then DeleteFiles(PChar(FN));
      RemoveFont(FF);
   end;      
   _hi_onEvent(_event_onInstall, sfnt);
end;

procedure THiTempFontProc._work_doInstall;
var   len: dword;
      fn: pchar;
      s, s1: string;
      FontStream: PStream;
begin
   s1 := ReadString(_Data, _data_FileName, _prop_FileName); 
   len := GetFullPathName(@s1[1],0,nil,fn);
   setlength(s,len-1);
   GetFullPathName(@s1[1], len, @s[1], fn);
   FontStream := NewReadFileStream(s);
   InstallfromStream(FontStream);
   free_and_nil(FontStream);
end;

procedure THiTempFontProc._work_doInstallfromStream;
var   FontStream: PStream;
begin
   FontStream := ReadStream(_data, _data_FontStream, _prop_FontStream);
   InstallfromStream(FontStream);
end;

procedure THiTempFontProc._work_doClear;
begin
   RemoveAllFonts;
end;

procedure THiTempFontProc._var_Matrix;
begin
   if not Assigned(FontMatrix) then begin
      New(FontMatrix);
      FontMatrix._Set  := MX_Set;
      FontMatrix._Get  := MX_Get;
      FontMatrix._Rows := _mRows;
      FontMatrix._Cols := _mCols;
   end;
   dtMatrix(_Data, FontMatrix);
end;

function THiTempFontProc.MX_Get;
begin
   if (x >= 0) and (y >= 0) and (y < NamesList.Count) and (x < 2) then
      case x of
        0: dtString(Result,FilesList.Items[y]);
        1: dtString(Result,NamesList.Items[y]);
      end
   else dtNull(Result);
end;

procedure THiTempFontProc.MX_Set;
begin
end;

function THiTempFontProc._mRows;
begin
  Result := NamesList.Count;
end;

function THiTempFontProc._mCols;
begin
  Result := 2;
end;

procedure THiTempFontProc._var_Count;
begin
   dtInteger(_Data, NamesList.Count);
end;

procedure THiTempFontProc._var_FontName;
begin
   dtString(_Data, fFontName);
end;

procedure THiTempFontProc._work_doInSendMessage;
begin
   FInSendMessage := ReadBool(_Data);
end;

end.