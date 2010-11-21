unit hiHTTP_FileUpload;

interface

uses Kol,Share,Debug;

type
  THIHTTP_FileUpload = class(TDebug)
   private
    FList:PStrList;
    procedure SetText(const Value:string);
   public
    _prop_FileName:string;
    _prop_URL:string;
    _prop_Host:string;
    _prop_Name:string;
    _prop_UserAgent:string;

    _data_Host:THI_Event;
    _data_URL:THI_Event;
    _data_FileName:THI_Event;
    _data_Session:THI_Event;
    _data_VarsValue:THI_Event;
    _data_Cookies:THI_Event;
    _data_UserAgent:THI_Event;
    _event_onBuild:THI_Event;

    destructor Destroy; override;
    procedure _work_doBuild(var _Data:TData; Index:word);
    procedure _work_doVarsList(var _Data:TData; Index:word);
    property _prop_VarsList:string write SetText;
  end;

implementation

destructor THIHTTP_FileUpload.Destroy;
begin
   if assigned(FList) then FList.Free;
   inherited;
end;

procedure THIHTTP_FileUpload.SetText;
begin
  FList := NewStrList;
  FList.Text := Value; 
end;

procedure THIHTTP_FileUpload._work_doVarsList;
begin
  _prop_VarsList := ToString(_Data);
end; 

procedure THIHTTP_FileUpload._work_doBuild;
var s,c,u,h,r,ss,cc,su:string;
    f:PStream;
    l:cardinal;
    i:integer;
    dt:TData;
begin
   c := ReadString(_Data, _data_FileName, _prop_FileName);
   u := ReadString(_Data, _data_URL, _prop_URL);
   h := ReadString(_Data, _data_Host, _prop_Host);
   ss := ReadString(_Data, _data_Session);
   cc := ReadString(_Data, _data_Cookies);   
   su := ReadString(_Data, _data_UserAgent, _prop_UserAgent);
   
   f := NewReadFileStream(c);
   r := '';
   if assigned(FList) then
       for i := 0 to FList.Count-1 do 
         begin
           dtString(dt, FList.Items[i]); 
           _ReadData(dt, _data_VarsValue); 
           r := r + '------------h0M5kYAbf3nwgrDxHe7WKB'#13#10 +
                    'Content-Disposition: form-data; name="' + FList.Items[i] + '"'#13#10 +
                    #13#10 +
                    ToString(dt) + #13#10;
         end;
   
   r := r + '------------h0M5kYAbf3nwgrDxHe7WKB'#13#10 +
        'Content-Disposition: form-data; name="' + _prop_Name + '"; filename="' + ExtractFileName(c) + '"'#13#10 +
        'Content-Type: application/octet-stream'#13#10 +
        #13#10;
         
   l := length(r);       
   SetLength(r, l + f.size);
   f.read(r[l+1], f.size);
   f.free;
   r := r + #13#10'------------h0M5kYAbf3nwgrDxHe7WKB--'#13#10#13#10; 

   s := 'POST ' + u + ' HTTP/1.0'#13#10 +
        'Host: ' + h + #13#10 +
        'Accept: */*'#13#10;
   if (ss <> '')or(cc <> '') then
   begin
     s := s + 'Cookie: ';

	 if ss <> '' then
	 begin
	   s := s + 'PHPSESSID=' + ss;
	   if cc <> '' then s := s + ';';
	 end;
     s := s + cc + #13#10; 
   end;
 
   if su <> '' then
     s := s + 'User-Agent: ' + su + #13#10;
         
//   if r <> '' then
//     s := s + 'Referer: ' + r + #13#10;
   s := s + 'Content-Length: ' + int2str(length(r) - 2) + #13#10 +
        'Content-Type: multipart/form-data; boundary=----------h0M5kYAbf3nwgrDxHe7WKB'#13#10 +
        #13#10 +
        #13#10 +
        r;

   _hi_onEvent(_event_onBuild, s);
end;

end.
