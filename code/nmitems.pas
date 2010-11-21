unit nmitems;

interface

uses
  kol,KOLComObj, ActiveX, Windows;

type
  TNamedItemList = class
  private
   FList:PList;
  public
    constructor Create;
    destructor Destroy; override;
    procedure AddItem(const Name: string; Item: TInterfacedObject); overload;
    procedure AddItem(const Name: string; Item: TComObject); overload;
    function GetItemIUnknown(const Name: string): IUnknown;
    function GetItemITypeInfo(const Name: string): ITypeInfo;
  end;

implementation

uses
  activescp;

type
  TNamedItem = class
  protected
    FTypeInfo: ITypeInfo;
    FUnknown: IUnknown;
    FName: string;
  end;

{ TNamedItemList }

procedure TNamedItemList.AddItem(const Name: string; Item: TInterfacedObject);
var
  I: TNamedItem;
begin
  I := TNamedItem.Create;
  I.FTypeInfo := nil;
  I.FUnknown := Item;
  I.FName := AnsiUpperCase(Name);
  FList.Add(I);
end;

procedure TNamedItemList.AddItem(const Name: string; Item: TComObject);
var
  I: TNamedItem;
begin
  I := TNamedItem.Create;
  if Item is TTypedComObject
    then I.FTypeInfo := TTypedComObjectFactory(Item.Factory).ClassInfo
    else I.FTypeInfo := nil;
  I.FUnknown := Item;
  I.FName := AnsiUpperCase(Name);
  FList.Add(I);
end;

constructor TNamedItemList.Create;
begin
  inherited ;
  FList := NewList;
end;

destructor TNamedItemList.Destroy;
var i:integer;
begin
  for i := 0 to FList.Count-1 do
   TNamedItem(FList.Items[i]).Destroy;
  FList.Free;
  inherited;
end;

function TNamedItemList.GetItemITypeInfo(const Name: string): ITypeInfo;
var
  i: integer;
begin
  Result := nil;
  for i := 0 to FList.Count - 1 do
    with TNamedItem(FList.Items[i]) do
      if FName = AnsiUpperCase(Name) then
        begin
          Result := FTypeInfo;
          exit;
        end;
end;

function TNamedItemList.GetItemIUnknown(const Name: string): IUnknown;
var
  i: integer;
begin
  Result := nil;
  for i := 0 to FList.Count - 1 do
    with TNamedItem(FList.Items[i]) do
      if FName = AnsiUpperCase(Name) then
        begin
          Result := FUnknown;
          exit;
        end;
end;

end.
