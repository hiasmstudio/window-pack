unit PrintController;

interface

uses Kol,Share,Debug,hiDocumentTemplate;

type
  TPrintController = class(TDebug)
   protected
    FItem:TDocItem;
    
    procedure InitItem; overload;
    procedure InitItem(var Data:TData); overload;
   public
    _prop_ItemName:string;
    _prop_Document:IDocumentTemplate;

    _data_Object:THI_Event;
    
    procedure _work_doItemName(var _Data:TData; Index:word);
  end;

implementation

procedure TPrintController.InitItem(var Data:TData);
var dt:TData;
begin
  if FItem = nil then
    if _prop_ItemName = '' then
      begin
        dt := ReadData(Data, _data_Object);
        if _IsObject(dt,DocItem_GUID) then
          FItem := TDocItem(ToObject(dt));;
      end
    else FItem := _prop_Document.getItem(_prop_ItemName);
end;

procedure TPrintController.InitItem;
var dt:TData;
begin
  dtNull(dt);
  InitItem(dt);
end;

procedure TPrintController._work_doItemName;
begin
  _prop_ItemName := ToString(_Data);
end;

end.