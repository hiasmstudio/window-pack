unit hiNetworkLocator;

interface

uses Windows,Kol,Share,Debug;

type
  THINetworkLocator = class(TDebug)
   private
    function FillNetLevel(xxx: PNetResource): Word;
    function getResByName(const name:string; xxx: PNetResource):PNetResource;
   public
    _prop_Domain:string;

    _event_onComputer:THI_Event;
    _event_onDomain:THI_Event;

    procedure _work_doBrowse(var _Data:TData; Index:word);
  end;

implementation

function THINetworkLocator.getResByName;
type
  PNRArr = ^TNRArr;
  TNRArr = array[0..59] of TNetResource;
var
  x: PNRArr;
  tnr: TNetResource;
  I: integer;
  err:cardinal;
  EntrReq,
    SizeReq,
    twx: THandle;
  WSName: string;
begin
  Result := nil;
  err := WNetOpenEnum(RESOURCE_GLOBALNET, RESOURCETYPE_ANY,RESOURCEUSAGE_CONTAINER, xxx, twx);
  if err = ERROR_NO_NETWORK then
    Exit;
  if err = NO_ERROR then
  begin
    New(x);
    EntrReq := 1;
    SizeReq := SizeOf(TNetResource) * 59;
    while (twx <> 0)and(Result = nil) and
      (WNetEnumResource(twx, EntrReq, x, SizeReq) <> ERROR_NO_MORE_ITEMS) do
      for i := 0 to EntrReq - 1 do
      begin
        Move(x^[i], tnr, SizeOf(tnr));
        if UpperCase(tnr.lpRemoteName) = name then
          begin
            new(result);
            FillChar(Result^, sizeof(tnr), 0);
            Result^ := tnr;
            break;
          end   
        else //if tnr.dwDisplayType = RESOURCEDISPLAYTYPE_DOMAIN then
         begin 
           Result := getResByName(name, @tnr);
           break;
         end;
      end;
    dispose(x);  
    WNetCloseEnum(twx);
  end;
end;

function THINetworkLocator.FillNetLevel;
type
  PNRArr = ^TNRArr;
  TNRArr = array[0..59] of TNetResource;
var
  x: PNRArr;
  tnr: TNetResource;
  I: integer;
  EntrReq,
    SizeReq,
    twx: THandle;
  WSName: string;
begin
  Result := WNetOpenEnum(RESOURCE_GLOBALNET, RESOURCETYPE_ANY,RESOURCEUSAGE_CONTAINER, xxx, twx);
  if Result = ERROR_NO_NETWORK then
    Exit;
  if Result = NO_ERROR then
  begin
    New(x);
    EntrReq := 1;
    SizeReq := SizeOf(TNetResource) * 59;
    while (twx <> 0) and
      (WNetEnumResource(twx, EntrReq, x, SizeReq) <> ERROR_NO_MORE_ITEMS) do
      for i := 0 to EntrReq - 1 do
      begin
        Move(x^[i], tnr, SizeOf(tnr));
        case tnr.dwDisplayType of
          RESOURCEDISPLAYTYPE_SERVER,RESOURCETYPE_PRINT:
            begin
              _hi_onEvent(_event_onComputer, tnr.lpRemoteName);
            end;
        else
          if tnr.dwDisplayType = RESOURCEDISPLAYTYPE_DOMAIN then 
            _hi_onEvent(_event_onDomain, tnr.lpRemoteName);
          FillNetLevel(@tnr);
        end;
      end;
    dispose(x);  
    WNetCloseEnum(twx);
  end;
end;

procedure THINetworkLocator._work_doBrowse;
var tnr: PNetResource;
begin
  if _prop_Domain <> '' then
    tnr := getResByName(UpperCase(_prop_Domain), nil)
  else tnr := nil;
  FillNetLevel(tnr);
  if tnr <> nil then 
     dispose(tnr);
end;

end.
