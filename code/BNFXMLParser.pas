unit BNFXMLParser;

interface

type
  TXMLValues = (TextNode, XMLNode);
  TXMLAttr = record
      Name: string;
      Value: string;
    end;
  PXMLAttr = ^TXMLAttr;

  TXMLNode = class
    private
      function GetAttr(const name:string):string;
    public
      Name:string;
      Value:string;
      Attributes:array of TXMLAttr;
      Nodes:array of TXMLNode;
      Parent:TXMLNode;

      constructor Create;
      destructor Destroy; override;

      procedure clear;

      function getAttrByName(const name:string):PXMLAttr;
      function getNodeByName(const name:string):TXMLNode;

      property attr[const name:string]:string read GetAttr;
      property node[const name:string]:TXMLNode read getNodeByName;
  end;
  
  TXMLDocument = class
    private
    public
      root:TXMLNode;

      function parse(text:string):boolean;
      function serialize:string;
  end;


implementation

constructor TXMLNode.Create;
begin
  inherited;
  Parent := nil;
end;

destructor TXMLNode.Destroy;
begin
  clear;
  inherited;
end;

procedure TXMLNode.clear;
var i:integer;
begin
  for i := 0 to Length(Nodes) - 1 do
    Nodes[i].Destroy;
  SetLength(Attributes, 0);
  SetLength(Nodes, 0);
  name := '';
end;

function TXMLNode.getAttrByName(const name:string):PXMLAttr;
var i:integer;
begin
  for i := 0 to Length(Attributes) - 1 do
    if Attributes[i].Name = name then
      begin
        Result := @Attributes[i];
        Exit;
      end;
  Result := nil;
end;

function TXMLNode.getNodeByName(const name:string):TXMLNode;
var i:integer;
begin
  for i := 0 to Length(Nodes) - 1 do
    if Nodes[i].Name = name then
      begin
        Result := Nodes[i];
        Exit;
      end;
  Result := nil;
end;

function TXMLNode.GetAttr(const name:string):string;
var a:PXMLAttr;
begin
   a := getAttrByName(name);
   if a = nil then
     Result := ''
   else
     Result := a.Value;
end;

//------------------------------------------------------------------------------

function TXMLDocument.parse(text:string):boolean;
label _error;
var node:TXMLNode;
    i,si:integer;
    an,av:string;
begin
   if text[Length(text)] <> '>' then goto _error;

   if root = nil then
      root := TXMLNode.Create;

   root.clear;
   i := 1;
   node := root;
   text := text + #0;
   while i < Length(text) do
     begin
       if text[i] = '<' then
         begin
           inc(i);
           if text[i] = '?' then  // XML header
             begin
               while text[i] <> '>' do
                 inc(i);
               inc(i)
             end
           else if text[i] = '/' then // XML node end
             begin
               inc(i);
               while text[i] <> '>' do inc(i);
               inc(i);
               node := node.Parent;
             end
           else                   // XML node begin
            begin
               si := Length(node.Nodes);
               SetLength(node.Nodes, si+1);
               node.Nodes[si] := TXMLNode.Create;
               node.Nodes[si].Parent := node;
               node := node.Nodes[si];

               // name
               si := i;
               while (text[i] <> '/')and(text[i] <> ' ')and(text[i] <> '>') do
                 inc(i);
               node.Name := copy(text, si, i - si);
               // attr
               while (text[i] <> '/')and(text[i] <> '>') do
                 begin
                   while text[i] = ' ' do inc(i);
                   si := i;
                   while text[i] in [':','a'..'z'] do
                     inc(i);
                   if si <> i then
                     begin
                       an := copy(text, si, i - si);
                       if text[i] <> '=' then goto _error;
                       inc(i);
                       if (text[i] <> '''')and(text[i] <> '"') then goto _error;
                       inc(i);
                       si := i;
                       while (text[i] <> '''')and(text[i] <> '"') do
                         inc(i);
                       av := copy(text, si, i - si);
                       si := Length(node.Attributes);
                       SetLength(node.Attributes, si + 1);
                       node.Attributes[si].Name := an;
                       node.Attributes[si].Value := av;
                       inc(i);
                     end;
                 end;
               // body
               if text[i] = '>' then
                 begin
                   inc(i);
                 end
               else if text[i] = '/' then
                 begin
                   inc(i);
                   if text[i] <> '>' then goto _error;
                   inc(i);
                   node := node.Parent;
                 end;
            end;
         end
       else                       // node value
         begin
            if node <> nil then node.Value := node.Value + text[i];
            inc(i);
         end;
     end;
   Result := true;
   Exit;
_error:
   if root <> nil then root.clear;
   Result := false;
end;

function TXMLDocument.serialize:string;
var n:integer;
  function _serialize(node:TXMLNode; const tab:string):string;
  var i:integer;
  begin
    Result := tab + '<' + node.Name;
    for i := 0 to Length(Node.Attributes) - 1 do
      Result := Result + ' ' + Node.Attributes[i].Name + '="' + node.Attributes[i].Value + '" ';
    if (node.Value = '')and(Length(node.Nodes) = 0) then
      begin
        Result := Result + '/>'#13#10;
      end
    else
      begin
        Result := Result + '>';
        if Length(node.Nodes) > 0 then
          begin
            Result := Result + #13#10;
            for i := 0 to Length(node.Nodes) - 1 do
              Result := Result + _serialize(node.Nodes[i], tab + '  ');
            Result := Result + tab;
          end
        else
          Result := Result + node.Value;
        Result := Result + '</' + node.Name + '>'#13#10;
      end;
  end;
begin
   Result := '';
   for n := 0 to Length(root.Nodes) - 1 do
     Result := Result + _serialize(root.Nodes[n], '') + #13#10;
end;

end.

