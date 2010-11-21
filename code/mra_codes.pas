unit codes;

interface

const
  cpWin = 01;
  cpAlt = 02;
  cpKoi = 03;

function DetermineCodepage(const st: string): Byte;
function Alt2Win(const st: string): string;
function Win2Alt(const st: string): string;
function Alt2Koi(const st: string): string;
function Koi2Alt(const st: string): string;
function Win2Koi(const st: string): string;
function Koi2Win(const st: string): string;
function X2Y(const st: string; srcCp, dstCp: Byte): string;

implementation

const
  AltSet = ['À'..'ß', 'à'..'ï', 'ğ'..'ÿ'];
  KoiSet = ['Á'..'Ğ', 'Ò'..'Ñ'];
  WinSet = ['à'..'ï', 'ğ'..#255];

  Win2AltTable: array[0..255] of Byte = (
    $00, $01, $02, $03, $04, $05, $06, $07, $08, $20, $0A, $0B, $0C, $0D, $0E, $0F,
    $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $1A, $1B, $1C, $1D, $1E, $1F,
    $20, $21, $22, $23, $24, $25, $26, $27, $28, $29, $2A, $2B, $2C, $2D, $2E, $2F,
    $30, $31, $32, $33, $34, $35, $36, $37, $38, $39, $3A, $3B, $3C, $3D, $3E, $3F,
    $40, $41, $42, $43, $44, $45, $46, $47, $48, $49, $4A, $4B, $4C, $4D, $4E, $4F,
    $50, $51, $52, $53, $54, $55, $56, $57, $58, $59, $5A, $5B, $5C, $5D, $5E, $5F,
    $60, $61, $62, $63, $64, $65, $66, $67, $68, $69, $6A, $6B, $6C, $6D, $6E, $6F,
    $70, $71, $72, $73, $74, $75, $76, $77, $78, $79, $7A, $7B, $7C, $7D, $7E, $7F,
    $80, $81, $82, $83, $84, $85, $86, $87, $88, $89, $8A, $8B, $8C, $8D, $8E, $8F,
    $90, $91, $92, $93, $94, $95, $96, $97, $98, $99, $9A, $9B, $9C, $9D, $9E, $9F,
    $A0, $A1, $A2, $A3, $A4, $A5, $A6, $A7, $A8, $A9, $AA, $22, $AC, $AD, $AE, $AF,
    $B0, $B1, $B2, $B3, $B4, $B5, $B6, $B7, $B8, $FC, $BA, $22, $BC, $BD, $BE, $BF,
    $80, $81, $82, $83, $84, $85, $86, $87, $88, $89, $8A, $8B, $8C, $8D, $8E, $8F,
    $90, $91, $92, $93, $94, $95, $96, $97, $98, $99, $9A, $9B, $9C, $9D, $9E, $9F,
    $A0, $A1, $A2, $A3, $A4, $A5, $A6, $A7, $A8, $A9, $AA, $AB, $AC, $AD, $AE, $AF,
    $E0, $E1, $E2, $E3, $E4, $E5, $E6, $E7, $E8, $E9, $EA, $EB, $EC, $ED, $EE, $EF);

  Alt2WinTable: array[0..255] of Byte = (
    $00, $01, $02, $03, $04, $05, $06, $07, $08, $09, $0A, $0B, $0C, $0D, $0E, $0F,
    $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $1A, $1B, $1C, $1D, $1E, $1F,
    $20, $21, $22, $23, $24, $25, $26, $27, $28, $29, $2A, $2B, $2C, $2D, $2E, $2F,
    $30, $31, $32, $33, $34, $35, $36, $37, $38, $39, $3A, $3B, $3C, $3D, $3E, $3F,
    $40, $41, $42, $43, $44, $45, $46, $47, $48, $49, $4A, $4B, $4C, $4D, $4E, $4F,
    $50, $51, $52, $53, $54, $55, $56, $57, $58, $59, $5A, $5B, $5C, $5D, $5E, $5F,
    $60, $61, $62, $63, $64, $65, $66, $67, $68, $69, $6A, $6B, $6C, $6D, $6E, $6F,
    $70, $71, $72, $73, $74, $75, $76, $77, $78, $79, $7A, $7B, $7C, $7D, $7E, $7F,
    $C0, $C1, $C2, $C3, $C4, $C5, $C6, $C7, $C8, $C9, $CA, $CB, $CC, $CD, $CE, $CF,
    $D0, $D1, $D2, $D3, $D4, $D5, $D6, $D7, $D8, $D9, $DA, $DB, $DC, $DD, $DE, $DF,
    $E0, $E1, $E2, $E3, $E4, $E5, $E6, $E7, $E8, $E9, $EA, $EB, $EC, $ED, $EE, $EF,
    $20, $20, $20, $A6, $A6, $A6, $A6, $2B, $2B, $A6, $A6, $2B, $2B, $2B, $2B, $2B,
    $2B, $2D, $2D, $2B, $2D, $2B, $A6, $A6, $2B, $2B, $2D, $2D, $A6, $2D, $2B, $2D,
    $2D, $2D, $2D, $2B, $2B, $2B, $2B, $2B, $2B, $2B, $2B, $5F, $5F, $5F, $5F, $5F,
    $F0, $F1, $F2, $F3, $F4, $F5, $F6, $F7, $F8, $F9, $FA, $FB, $FC, $FD, $FE, $FF,
    $A8, $B8, $AA, $BA, $AF, $BF, $A1, $A2, $B0, $B7, $B7, $5F, $B9, $A4, $5F, $5F);

  Koi2AltTable: array[0..255] of Byte = (
    $00, $01, $02, $03, $04, $05, $06, $07, $08, $09, $0A, $0B, $0C, $0D, $0E, $0F,
    $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $1A, $1B, $1C, $1D, $1E, $1F,
    $20, $21, $22, $23, $24, $25, $26, $27, $28, $29, $2A, $2B, $2C, $2D, $2E, $2F,
    $30, $31, $32, $33, $34, $35, $36, $37, $38, $39, $3A, $3B, $3C, $3D, $3E, $3F,
    $40, $41, $42, $43, $44, $45, $46, $47, $48, $49, $4A, $4B, $4C, $4D, $4E, $4F,
    $50, $51, $52, $53, $54, $55, $56, $57, $58, $59, $5A, $5B, $5C, $5D, $5E, $5F,
    $60, $61, $62, $63, $64, $65, $66, $67, $68, $69, $6A, $6B, $6C, $6D, $6E, $6F,
    $70, $71, $72, $73, $74, $75, $76, $77, $78, $79, $7A, $7B, $7C, $7D, $7E, $7F,
    $80, $81, $82, $83, $84, $85, $86, $87, $88, $89, $8A, $8B, $8C, $8D, $8E, $8F,
    $90, $91, $92, $93, $94, $95, $96, $97, $98, $99, $9A, $9B, $9C, $9D, $9E, $9F,
    $A0, $A1, $A2, $A5, $A4, $A5, $A6, $A7, $A8, $A9, $AA, $AB, $AC, $AD, $AE, $AF,
    $B0, $B1, $B2, $B3, $B4, $B5, $B6, $B7, $B8, $B9, $BA, $BB, $BC, $BD, $BE, $BF,
    $EE, $A0, $A1, $E6, $A4, $A5, $E4, $A3, $E5, $A8, $A9, $AA, $AB, $AC, $AD, $AE,
    $AF, $EF, $E0, $E1, $E2, $E3, $A6, $A2, $EC, $EB, $A7, $E8, $ED, $E9, $E7, $EA,
    $9E, $80, $81, $96, $84, $85, $94, $83, $95, $88, $89, $8A, $8B, $8C, $8D, $8E,
    $8F, $9F, $90, $91, $92, $93, $86, $82, $9C, $9B, $87, $98, $9D, $99, $97, $FF);

  Alt2KoiTable: array[0..255] of Byte = (
    $00, $01, $02, $03, $04, $05, $06, $07, $08, $09, $0A, $0B, $0C, $0D, $0E, $0F,
    $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $1A, $1B, $1C, $1D, $1E, $1F,
    $20, $21, $22, $23, $24, $25, $26, $27, $28, $29, $2A, $2B, $2C, $2D, $2E, $2F,
    $30, $31, $32, $33, $34, $35, $36, $37, $38, $39, $3A, $3B, $3C, $3D, $3E, $3F,
    $40, $41, $42, $43, $44, $45, $46, $47, $48, $49, $4A, $4B, $4C, $4D, $4E, $4F,
    $50, $51, $52, $53, $54, $55, $56, $57, $58, $59, $5A, $5B, $5C, $5D, $5E, $5F,
    $60, $61, $62, $63, $64, $65, $66, $67, $68, $69, $6A, $6B, $6C, $6D, $6E, $6F,
    $70, $71, $72, $73, $74, $75, $76, $77, $78, $79, $7A, $7B, $7C, $7D, $7E, $7F,
    $E1, $E2, $F7, $E7, $E4, $E5, $F6, $FA, $E9, $EA, $EB, $EC, $ED, $EE, $EF, $F0,
    $F2, $F3, $F4, $F5, $E6, $E8, $E3, $FE, $FB, $FD, $9A, $F9, $F8, $FC, $E0, $F1,
    $C1, $C2, $D7, $C7, $C4, $C5, $D6, $DA, $C9, $CA, $CB, $CC, $CD, $CE, $CF, $D0,
    $B0, $B1, $B2, $B3, $B4, $B5, $B6, $B7, $B8, $B9, $BA, $BB, $BC, $BD, $BE, $BF,
    $C0, $C1, $C2, $C3, $C4, $C5, $C6, $C7, $C8, $C9, $CA, $CB, $CC, $CD, $CE, $CF,
    $D0, $D1, $D2, $D3, $D4, $D5, $D6, $D7, $D8, $D9, $DA, $DB, $DC, $DD, $DE, $DF,
    $D2, $D3, $D4, $D5, $C6, $C8, $C3, $DE, $DB, $DD, $DF, $D9, $D8, $DC, $C0, $D1,
    $85, $A3, $F2, $F3, $F4, $F5, $F6, $F7, $F8, $F9, $FA, $FB, $FC, $FD, $FE, $FF);

function X2Y(const st: string; srcCp, dstCp: Byte): string;
begin
  case srcCp of
    cpWin:
      begin
        case dstCp of
          cpWin:
            begin
              Result := st;
            end;
          cpAlt:
            begin
              Result := Win2Alt(st);
            end;
          cpKoi:
            begin
              Result := Win2Koi(st);
            end;
        end;
      end;
    cpAlt:
      begin
        case dstCp of
          cpWin:
            begin
              Result := Alt2Win(st);
            end;
          cpAlt:
            begin
              Result := st;
            end;
          cpKoi:
            begin
              Result := Alt2Koi(st);
            end;
        end;
      end;
    cpKoi:
      begin
        case dstCp of
          cpWin:
            begin
              Result := Koi2Win(st);
            end;
          cpAlt:
            begin
              Result := Koi2Alt(st);
            end;
          cpKoi:
            begin
              Result := st;
            end;
        end;
      end;
  end;
end;

function Win2Koi(const st: string): string;
begin
  Result := Alt2Koi(Win2Alt(st));
end;

function Koi2Win(const st: string): string;
begin
  Result := Alt2Win(Koi2Alt(st));
end;

function Alt2Win(const st: string): string;
var
  i: Integer;
begin
  SetLength(Result, Length(st));
  for i := 1 to Length(st) do
  begin
    Alt2Win[i] := Char(Alt2WinTable[Byte(st[i])]);
  end;
end;

function Win2Alt(const st: string): string;
var
  i: Integer;
begin
  SetLength(Result, Length(st));
  for i := 1 to Length(st) do
  begin
    Win2Alt[i] := Char(Win2AltTable[Byte(st[i])]);
  end;
end;

function Alt2Koi(const st: string): string;
var
  i: Integer;
begin
  SetLength(Result, Length(st));
  for i := 1 to Length(st) do
  begin
    Alt2Koi[i] := Char(Alt2KoiTable[Byte(st[i])]);
  end;
end;

function Koi2Alt(const st: string): string;
var
  i: Integer;
begin
  SetLength(Result, Length(st));
  for i := 1 to Length(st) do
  begin
    Koi2Alt[i] := Char(Koi2AltTable[Byte(st[i])]);
  end;
end;

function DetermineCodepage(const st: string): Byte;
var
  WinCount, AltCount, KoiCount, i: Integer;
begin
  WinCount := 0;
  AltCount := 0;
  KoiCount := 0;
  for i := 1 to Length(st) do
  begin
    if st[i] in AltSet then Inc(AltCount);
    if st[i] in WinSet then Inc(WinCount);
    if st[i] in KoiSet then Inc(KoiCount);
  end;
  DetermineCodepage := cpAlt;
  if KoiCount > AltCount then
  begin
    DetermineCodepage := cpKoi;
    if WinCount > KoiCount then DetermineCodepage := cpWin;
  end
  else
  begin
    if WinCount > AltCount then DetermineCodepage := cpWin;
  end;
end;

end.
