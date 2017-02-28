unit hiDDEServer;

interface

uses Kol,Share,Debug,DDEML,Windows;

type
  THIDDEServer = class(TDdeConversation)
   private
    FTopicList:PStrList;
    FError:boolean;
    FValue:string;
    FLastTopic:string;
    FLastItem:string;
    FConvList:PList;
    
    function MyCallback(uType,uFmt:cardinal; hConv,hSz1,hSz2,hData:THandle; dwData1,dwData2:DWORD):cardinal;
    procedure SetTopicList(const Value:string);

   public
    _prop_ServiceName:string;

    _data_ChangedTopic:THI_Event;
    _data_ChangedItem:THI_Event;
    _data_ReturnItem:THI_Event;

    _event_onConnect:THI_Event;
    _event_onGetItem:THI_Event;
    _event_onPutItem:THI_Event;
    _event_onExecute:THI_Event;

    constructor Create;
    destructor Destroy; override;

    procedure _work_doStart(var _Data:TData; Index:word);
    procedure _work_doStop(var _Data:TData; Index:word);
    procedure _work_doReturnItem(var _Data:TData; Index:word);
    procedure _work_doSendChanges(var _Data:TData; Index:word);
    procedure _work_doSetError(var _Data:TData; Index:word);

    procedure _var_TopicName(var _Data:TData; Index:word);
    procedure _var_TopicList(var _Data:TData; Index:word);
    procedure _var_TopicIndex(var _Data:TData; Index:word);
    procedure _var_ItemName(var _Data:TData; Index:word);

    procedure _work_doServiceName(var _Data:TData; Index:word);
    procedure _work_doTopicList(var _Data:TData; Index:word);

    property _prop_TopicList:string write SetTopicList;
  end;

implementation

var g_RegisteredServices:PStrList;

constructor THIDDEServer.Create;
begin
  inherited;
  FConv := 0;
  FCallback := MyCallback;
  FTopicList := NewStrList;
  FConvList := NewList;
end;

destructor THIDDEServer.Destroy;
begin
  FConvList.Free;
  FTopicList.Free;
  inherited;
end;

procedure THIDDEServer.SetTopicList;
begin
  FTopicList.Text := Value;
end;

function THIDDEServer.MyCallback(uType,uFmt:cardinal; hConv,hSz1,hSz2,hData:THandle; dwData1,dwData2:DWORD):cardinal;
var s:string; dwLen:DWORD;
begin
  Result := DDE_FNOTPROCESSED;
  case uType of
  XTYP_DISCONNECT:
   begin
     FConvList.Remove(pointer(hConv));
     Result := DDE_FACK;
   end;
  else
   begin
    dwLen := DdeQueryString(g_DdeInstance,hSz1,nil,0,CP_WINANSI)+1; SetLength(s,dwLen);
    DdeQueryString(g_DdeInstance,hSz1,@s[1],dwLen,CP_WINANSI); SetLength(s,dwLen-1);
    if (FTopicList.Count>0) and (FTopicList.IndexOf(s)<0) then Exit else FLastTopic := s;
    case uType of
    XTYP_CONNECT:
     begin
       FError := False; _hi_onEvent(_event_onConnect, FLastTopic);
       if not FError then Result := DDE_FACK;
     end;
    XTYP_CONNECT_CONFIRM:
     begin
       FConvList.Add(pointer(hConv));
       Result := DDE_FACK;
     end;
    XTYP_EXECUTE:
     begin
       if FConvList.IndexOf(pointer(hConv))<0 then Exit;
       dwLen := DdeGetData(hData,nil,0,0); SetLength(s,dwLen);
       DdeGetData(hData,@s[1],dwLen,0);
       FError := False; _hi_onEvent(_event_onExecute, s);
       if not FError then Result := DDE_FACK;
     end;
    XTYP_ADVSTOP:
     begin
       if FConvList.IndexOf(pointer(hConv))<0 then Exit;
       Result := DDE_FACK;
     end;
    else
     begin
      if FConvList.IndexOf(pointer(hConv))<0 then Exit;
      dwLen := DdeQueryString(g_DdeInstance,hSz2,nil,0,CP_WINANSI)+1; SetLength(FLastItem,dwLen);
      DdeQueryString(g_DdeInstance,hSz2,@FLastItem[1],dwLen,CP_WINANSI); SetLength(FLastItem,dwLen-1);
      case uType of
      XTYP_ADVREQ,XTYP_REQUEST:
       begin
         FError := False; _hi_onEvent(_event_onGetItem,FLastItem);
         if not FError then Result := DdeCreateDataHandle(g_DdeInstance,PChar(FValue),Length(FValue){+1},0,hSz2,CF_TEXT,0);
       end;
      XTYP_POKE:
       begin
         dwLen := DdeGetData(hData,nil,0,0); SetLength(s,dwLen);
         DdeGetData(hData,@s[1],dwLen,0);
         FError := False; _hi_onEvent(_event_onPutItem,s);
         if not FError then Result := DDE_FACK;
       end;
      XTYP_ADVSTART:
       begin
         FError := False; _hi_onEvent(_event_onGetItem,FLastItem);
         if not FError then Result := DDE_FACK;
       end;
      end;
     end;
    end;
   end;
  end;
end; 

procedure THIDDEServer._work_doStart;
var i:integer; hszService:THandle;
begin
  i := g_RegisteredServices.IndexOf(_prop_ServiceName);
  g_RegisteredServices.Add(_prop_ServiceName);
  if i<0 then begin 
    hszService := DdeCreateStringHandle(g_DdeInstance,PChar(_prop_ServiceName),CP_WINANSI); 
    DdeNameService(g_DdeInstance,hszService,0,DNS_REGISTER+DNS_FILTERON);
    DdeFreeStringHandle(g_DdeInstance,hszService);
  end;
end;

procedure THIDDEServer._work_doStop;
var i:integer; hszService:THandle;
begin
  i := g_RegisteredServices.IndexOf(_prop_ServiceName);
  if i>=0 then g_RegisteredServices.Delete(i);
  i := g_RegisteredServices.IndexOf(_prop_ServiceName);
  if i<0 then begin 
    hszService := DdeCreateStringHandle(g_DdeInstance,PChar(_prop_ServiceName),CP_WINANSI); 
    DdeNameService(g_DdeInstance,hszService,0,DNS_UNREGISTER);
    DdeFreeStringHandle(g_DdeInstance,hszService);
  end;  
end;

procedure THIDDEServer._work_doReturnItem;
begin
  FValue := ReadString(_Data,_data_ReturnItem);
end;

procedure THIDDEServer._work_doSendChanges;
var hszTopic,hszItem:THandle; s:string;
begin
  s := ReadString(_Data,_data_ChangedItem,'');
  if s='' then hszItem := 0 else
    hszItem := DdeCreateStringHandle(g_DdeInstance,PChar(s),CP_WINANSI); 
  s := ReadString(_Data,_data_ChangedTopic,'');
  if (s='') and (FTopicList.Count=1) then s := FTopicList.Items[0]; 
  if s='' then hszTopic := 0 else
    hszTopic := DdeCreateStringHandle(g_DdeInstance,PChar(s),CP_WINANSI); 
  DdePostAdvise(g_DdeInstance,hszTopic,hszItem);
  if hszTopic<>0 then DdeFreeStringHandle(g_DdeInstance,hszTopic);
  if hszItem<>0 then DdeFreeStringHandle(g_DdeInstance,hszItem);
end;

procedure THIDDEServer._work_doSetError;
begin
  FError := True;
end;

procedure THIDDEServer._var_TopicName;
begin
  dtString(_Data, FLastTopic);
end;

procedure THIDDEServer._var_TopicIndex;
begin
  dtInteger(_Data, FTopicList.IndexOf(FLastTopic));
end;

procedure THIDDEServer._var_ItemName;
begin
  dtString(_Data, FLastItem);
end;

procedure THIDDEServer._var_TopicList;
begin
  dtString(_Data, FTopicList.Text);
end;

procedure THIDDEServer._work_doServiceName;
begin
  _prop_ServiceName := ToString(_Data);
end;

procedure THIDDEServer._work_doTopicList;
begin
  FTopicList.Text := ToString(_Data);
end;

initialization
  g_RegisteredServices := NewStrList;

finalization
  g_RegisteredServices.Free;
  
end.