unit base64;

(*
 ================================================================
                    This software is FREEWARE
                    -------------------------
  If this software works, it was surely written by Dirk Claessens
                       <dirkcl@yucom.be>
               <dirk.claessens.dc@belgium.agfa.com>
  (If it does'nt, I don't know anything about it.)
 ================================================================
*)

interface
uses SysUtils;

function StrTobase64( Buf: string ): string;
function Base64ToStr( B64: string ): string;

implementation

const
  Base64Code    = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
                + 'abcdefghijklmnopqrstuvwxyz'
                + '0123456789+/';
  Pad           = '=';

type
  EBase64Error = Exception;

//*****************************************************************************
function StrTobase64( Buf: string ): string;
var
//  B3            : string[3];
  i             : integer;
  x1, x2, x3, x4: byte;
  PadCount      : integer;
begin
  PadCount := 0;

 // we need at least 3 input bytes...
  while length( Buf ) < 3 do
  begin
    Buf := Buf + #0;
    inc( PadCount );
  end;

 // ...and all input must be an even multiple of 3
  while ( length( Buf ) mod 3 ) <> 0 do
  begin
    Buf := Buf + #0; // if not, zero padding is added
    inc( PadCount );
  end;

  Result := '';
  i := 1;

 // process 3-byte blocks or 24 bits
  while i <= length( Buf ) - 2 do
  begin
    // each 3 input bytes are transformed into 4 index values
    // in the range of  0..63, by taking 6 bits each step

    // 6 high bytes of first char
    x1 := ( Ord( Buf[i] ) shr 2 ) and $3F;

    // 2 low bytes of first char + 4 high bytes of second char
    x2 := ( ( Ord( Buf[i] ) shl 4 ) and $3F )
      or Ord( Buf[i + 1] ) shr 4;

    // 4 low bytes of second char + 2 high bytes of third char
    x3 := ( ( Ord( Buf[i + 1] ) shl 2 ) and $3F )
      or Ord( Buf[i + 2] ) shr 6;

    // 6 low bytes of third char
    x4 := Ord( Buf[i + 2] ) and $3F;

    // the index values point into the code array
    Result := Result
      + Base64Code[x1 + 1]
      + Base64Code[x2 + 1]
      + Base64Code[x3 + 1]
      + Base64Code[x4 + 1];
    inc( i, 3 );
  end;

 // if needed, finish by forcing padding chars ('=')
 // at end of string
  if PadCount > 0 then
    for i := Length( Result ) downto 1 do
    begin
      Result[i] := Pad;
      dec( PadCount );
      if PadCount = 0 then BREAK;
    end;

end;

//*****************************************************************************
// helper : given a char, returns the index in code table
function Char2IDx( c: char ): byte;
var
  i             : integer;
begin
  for i := 1 to Length( Base64Code ) do
    if Base64Code[i] = c then
    begin
      Result := pred( i );
      EXIT;
    end;
  Result := Ord( Pad );
end;

//*****************************************************************************
function Base64ToStr( B64: string ): string;
var
  i,
    PadCount    : integer;
  Block         : string[3];
  x1, x2, x3    : byte;
begin

  // input _must_ be at least 4 chars long,
  // or multiple of 4 chars
  if ( Length( B64 ) < 4 )
    or ( Length( B64 ) mod 4 <> 0 ) then
    raise EBase64Error.Create( 'Base64ToStr: illegal input length!' );
  //
    PadCount := 0;
  i := Length( B64 );
  // count padding chars, if any
  while (B64[i] = Pad)
  and (i > 0 ) do
  begin
    inc( PadCount );
    dec( i );
  end;
  //
  Result := '';
  i := 1;
  SetLength( Block, 3 );
  while i <= Length( B64 ) - 3 do
  begin
    // reverse process of above
    x1 := ( Char2Idx( B64[i] ) shl 2 ) or ( Char2IDx( B64[i + 1] ) shr 4 );
    Result := Result + Chr( x1 );
    x2 := ( Char2Idx( B64[i + 1] ) shl 4 ) or ( Char2IDx( B64[i + 2] ) shr 2 );
    Result := Result + Chr( x2 );
    x3 := ( Char2Idx( B64[i + 2] ) shl 6 ) or ( Char2IDx( B64[i + 3] ) );
    Result := Result + Chr( x3 );
    inc( i, 4 );
  end;

  // delete padding, if any
  while PadCount > 0 do
  begin
    Delete( Result, Length( Result ), 1 );
    dec( PadCount );
  end;

end;

end.
