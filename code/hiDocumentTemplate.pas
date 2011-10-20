unit hiDocumentTemplate;

interface

uses Windows,Kol,Share,Debug,Img_Draw;

type
  TClassDocumentTemplate = class
    public
     List:PList;
     constructor Create(_parent:pointer; _Control:PControl; _ParentClass:TObject);
     destructor Destroy; override;
     function Child:TClassDocumentTemplate;
  end;  
  THiClassDocumentTemplate = TClassDocumentTemplate;
  TDocItem = class(TDebug)
    public
     _prop_Name:string;
     _prop_X:integer;
     _prop_Y:integer;
     _prop_Width:integer;
     _prop_Height:integer;
     
     procedure Draw(dc:HDC; x,y:integer; const Scale:TScale); virtual; abstract; 
  end;
  TIDocumentTemplate = record
    getItem:function(const name:string):TDocItem of object; 
  end;
  IDocumentTemplate = ^TIDocumentTemplate;
  THIDocumentTemplate = class(THIDraw2P)
   private
     FChild:TClassDocumentTemplate;
     DocTpl:TIDocumentTemplate;
     
     procedure InitChild;
     function _getItem(const name:string):TDocItem;
   public
     _prop_Name:string;
     
     _event_onDraw:THI_Event;
     
     OnCreate:function(_parent:pointer; Control:PControl; _ParentClass:TObject):THiClassDocumentTemplate;
     
     constructor Create(_Control:PControl);
     destructor Destroy; override;
     procedure _work_doDraw(var _Data:TData; Index:word);
     function getInterfaceDocumentTemplate:IDocumentTemplate;    
  end;

var DocItem_GUID:integer;

implementation

constructor TClassDocumentTemplate.Create(_parent:pointer; _Control:PControl; _ParentClass:TObject);
begin
   inherited Create;
   List := NewList;
   GenGUID(DocItem_GUID);
end;

destructor TClassDocumentTemplate.Destroy;
begin
   List.Free;
   inherited;
end;

function TClassDocumentTemplate.Child:TClassDocumentTemplate;
begin
  Result := self;
end;                

constructor THIDocumentTemplate.Create(_Control:PControl);
begin
   inherited Create;
end;

destructor THIDocumentTemplate.Destroy; 
begin
   if FChild <> nil then FChild.Destroy;
   inherited;
end;

procedure THIDocumentTemplate.InitChild;
begin
   if FChild = nil then FChild := OnCreate(self, nil, nil);
end;

function THIDocumentTemplate.getInterfaceDocumentTemplate:IDocumentTemplate;
begin
   DocTpl.getItem := _getItem;
   Result := @DocTpl;
end;

function THIDocumentTemplate._getItem(const name:string):TDocItem;
var i:integer;
begin
   InitChild;
   Result := nil;
   for i := 0 to FChild.List.Count-1 do
     if StrIComp(PChar(TDocItem(FChild.List.Items[i])._prop_Name), PChar(name)) = 0 then
      begin
       Result := TDocItem(FChild.List.Items[i]);
       exit;
      end;
   Exit; 
end;

procedure THIDocumentTemplate._work_doDraw;
var dt:TData;
    i:integer;
begin
   InitChild;
   
   dt := _Data;
   if not ImgGetDC(_Data) then exit;
   ReadXY(_Data);

   ImgNewSizeDC;

   dec(x1, GetDeviceCaps(pDC, PHYSICALOFFSETX)); 
   dec(y1, GetDeviceCaps(pDC, PHYSICALOFFSETY)); 

   if fScale.x > 0 then
     x1 := Round(x1 / fScale.x);
   if fScale.y > 0 then
     y1 := Round(y1 / fScale.y);
     
   for i := 0 to FChild.List.Count-1 do
     TDocItem(FChild.List.Items[i]).Draw(pDC, x1, y1, fScale);

   ImgReleaseDC;
   _hi_CreateEvent(_Data,@_event_onDraw,dt);
end;


end.
