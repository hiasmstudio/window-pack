unit hiHTTP_PostBuilder;

interface

uses Kol,Share,Debug;

type
  THIHTTP_PostBuilder = class(TDebug)
   private
   public
    _prop_Content:string;
    _prop_URL:string;
    _prop_Host:string;
    _prop_Referer:string;
    _prop_UserAgent:string;

    _data_Referer:THI_Event;
    _data_Host:THI_Event;
    _data_URL:THI_Event;
    _data_Content:THI_Event;
    _data_Session:THI_Event;
    _data_Cookies:THI_Event;
    _data_UserAgent:THI_Event;
    _event_onBuild:THI_Event;

    procedure _work_doBuild(var _Data:TData; Index:word);
  end;

implementation

procedure THIHTTP_PostBuilder._work_doBuild;
var s,c,u,h,r,ss,cc,su:string;
begin
   c := ReadString(_Data, _data_Content, _prop_Content);
   u := ReadString(_Data, _data_URL, _prop_URL);
   h := ReadString(_Data, _data_Host, _prop_Host);
   r := ReadString(_Data, _data_Referer, _prop_Referer);
   ss := ReadString(_Data, _data_Session);
   cc := ReadString(_Data, _data_Cookies);
   su := ReadString(_data, _data_UserAgent, _prop_UserAgent);
   
   s := 'POST ' + u + ' HTTP/1.1'#13#10 +
        'Host: ' + h + #13#10 +
        'Connection: close' + #13#10 + 
        'Content-Type: application/x-www-form-urlencoded' + #13#10;
   if r <> '' then
     s := s + 'Referer: ' + r + #13#10;
   
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

          
   s := s + 'Content-Length: ' + int2str(length(c)) + #13#10 + #13#10 + c + #13#10;
   _hi_onEvent(_event_onBuild, s);      
end;

end.
