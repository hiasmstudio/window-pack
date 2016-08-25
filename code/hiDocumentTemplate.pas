unit hiDocumentTemplate;

interface

uses Windows,Kol,Share,Debug,Img_Draw;

const
  _TEXT         = 'text';
  _IMAGE        = 'image';
  _SHAPE        = 'shape';
  _TABLE        = 'table';
  _GRADIENTRECT = 'gradientrect';

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
     _NameType:string;
     _prop_Name:string;
     _prop_X:integer;
     _prop_Y:integer;
     _prop_Width:integer;
     _prop_Height:integer;

     procedure Draw(dc:HDC; x,y:integer; const Scale:TScale; alpha: boolean=false); virtual; abstract; 
  end;
  TIDocumentTemplate = record
    getItem:function(const name:string):TDocItem of object;
    getItemCount:function():integer of object;
    getItemIdx:function(const idx:integer):TDocItem of object;     
  end;
  IDocumentTemplate = ^TIDocumentTemplate;
  THIDocumentTemplate = class(THIDraw2P)
   private
     FChild:TClassDocumentTemplate;
     DocTpl:TIDocumentTemplate;
     
     procedure InitChild;
     function _getItem(const name:string):TDocItem;
     function _getItemCount():integer;
     function _getItemIdx(const idx:integer):TDocItem;          
   public
     _prop_Name:string;
     _prop_AlphaMode: boolean;     
     _event_onDraw:THI_Event;
     _event_onEnumNamed:THI_Event;     
     
     OnCreate:function(_parent:pointer; Control:PControl; _ParentClass:TObject):THiClassDocumentTemplate;
     
     constructor Create(_Control:PControl);
     destructor Destroy; override;
     procedure _work_doDraw(var _Data:TData; Index:word);
     procedure _work_doDrawName(var _Data:TData; Index:word);     
     procedure _work_doEnumNamed(var _Data:TData; Index:word);     
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
   DocTpl.getItemCount := _getItemCount;
   DocTpl.getItemIdx := _getItemIdx;
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

function THIDocumentTemplate._getItemIdx(const idx:integer):TDocItem;
begin
   InitChild;
   Result := nil;
   if (idx < 0) or (idx >= FChild.List.Count) then exit; 
   Result := TDocItem(FChild.List.Items[idx]);
end;

function THIDocumentTemplate._getItemCount():integer;
begin
   InitChild;
   Result := FChild.List.Count;
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
     TDocItem(FChild.List.Items[i]).Draw(pDC, x1, y1, fScale, _prop_AlphaMode);

   ImgReleaseDC;
   _hi_CreateEvent(_Data,@_event_onDraw,dt);
end;

procedure THIDocumentTemplate._work_doDrawName;
var dt:TData;
    i:integer;
    name:string;
begin
   InitChild;
   
   name := ReadString(_Data, NULL);
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
     if StrIComp(PChar(TDocItem(FChild.List.Items[i])._prop_Name), PChar(name)) = 0 then
       TDocItem(FChild.List.Items[i]).Draw(pDC, x1, y1, fScale, _prop_AlphaMode);

   ImgReleaseDC;
   _hi_CreateEvent(_Data,@_event_onDraw,dt);
end;

procedure THIDocumentTemplate._work_doEnumNamed;
var
  dt: TData;
  mt: PMT;
  i: integer;
  name: string; 
begin
   for i := 0 to FChild.List.Count-1 do
   begin
     name := TDocItem(FChild.List.Items[i])._prop_Name;
	 if name <> '' then
	 begin 
       dtString(dt, name);
       mt := mt_make(dt);
       mt_string(mt, TDocItem(FChild.List.Items[i])._NameType);
       mt_int(mt, TDocItem(FChild.List.Items[i])._prop_X);
       mt_int(mt, TDocItem(FChild.List.Items[i])._prop_Y);
       mt_int(mt, TDocItem(FChild.List.Items[i])._prop_Width);
       mt_int(mt, TDocItem(FChild.List.Items[i])._prop_Height);       
       _hi_onEvent_(_event_onEnumNamed, dt);
       mt_free(mt);
     end;  
   end;  
end;

end.
