unit ftcg_share;

interface

uses kol, share;

function sign(r:real):integer;
function str_replace(const Str:string; const substr, dest:string):string;
function ProperCase(const Str:string):string;

implementation

function sign(r:real):integer;
begin
  if r < 0 then result := -1 
  else if r > 0 then result := 1
  else result := 0
end;

function str_replace;
var p,q:integer;
begin
   Result := str;
   q := Length(dest);
   p := Pos(substr,Result);
   while p > 0 do
    begin
      Delete(Result,p,length(substr));
      Insert(dest,Result,p);
      inc(p,q);
      p := PosEx(substr,Result,p);
    end;
end;

function ProperCase;
var i: integer;
begin
   Result := AnsiLowerCase(Str);
   for i := 1 to length(Result) do
     if (i = 1) or (Result[i-1] = ' ') then
       if (Result[i] in [ 'a'..'z' ]) or (Result[i] in [ 'à'..'ÿ' ]) then
         Result[i] := char(ord(Result[i]) and not $20)
       else if (Str[i] = '¸') then
         Result[i] := char(ord(Result[i]) and not $10);
end;

end.