unit hiLZH;

interface

uses Windows,Kol,Share,Debug;

const
  MaxBuf    = 4096;
  F         = 60;
  THRESHOLD = 2;
  N_CHAR    = (256 - THRESHOLD + F);
  T         = (N_CHAR * 2 - 1);
  R         = (T - 1);
  MAX_Freq  = $8000;

type
  PBuff = ^TBuff;
  TBuff = array[1..MaxBuf] of Byte;

  PFreq = ^TFreq;
  TFreq = array[0..T] of word;

  PSon = ^TSon;
  TSon = array[0..Pred(T)] of word;

  PPntr = ^TPntr;
  TPntr = array[0..Pred(T+N_Char)] of integer;

  PTextBuf = ^TTextBuf;
  TTextBuf = array[0..MaxBuf+F-2] of Byte;

  PWordRay = ^TWordRay;
  TWordRay = array[0..MaxBuf] of integer;

  PBWordRay = ^TBWordRay;
  TBWordRay = array[0..MaxBuf+256] of integer;

  TMoveBlock = function (var ABuff; ACount: integer): integer of object;

type
  THILZH = class(TDebug)
   private
    DSize                 : integer;
    fPosition             : integer;
    fOriginal             : integer;
        
    FSource, FDestination : PStream;
    p_len, p_code         : array [0..63]  of Byte;
    d_code, d_len         : array [0..255] of Byte;
    PosnG                 : integer;
    Buf                   : integer;
    PosnP                 : integer;

    GetBuf                : Word; // ???
    
    GetLen                : Byte;
    PutLen                : Byte;
    PutBuf                : integer;
    CodeSize              : integer;
    Match_Position        : integer;
    Match_Length          : integer;
    Text_Buf              : PTextBuf;
    lSon, Dad             : PWordRay;
    rSon                  : PBWordRay;
    Freq                  : PFreq;
    Prnt                  : PPntr;
    Son                   : PSon;
    InBuf, OutBuf         : PBuff;

    FReadData             : TMoveBlock;
    FWriteData            : TMoveBlock;

    procedure InitLZH;
    procedure EndLZH;
    procedure Reconst;
    procedure StartHuff;
    procedure InsertNode(r: integer);
    procedure DeleteNode(p: integer);
    procedure EncodeChar(c: integer);
    function  DecodeChar: integer;
    procedure Update(c: integer);
    procedure EncodePosition(c: integer);
    function  DecodePosition: integer;
    procedure GetBlock(var Target; var Actual_Bytes: integer);
    procedure PutBlock(var Source; NoBytes: integer; var Actual_Bytes: integer);
    function  GetBit: integer;
    function  GetByte: integer;
    procedure PutCode(l: integer; c: integer);
    function  ReadBlockStream(var ABuff; ACount: integer): integer;
    function  WriteBlockStream(var ABuff; ACount: integer): integer;
    procedure LZHPack(APackSize, FProgressInterval: integer);
    procedure LZHUnpack(AUnpackSize, FProgressInterval: integer);
    property  ReadData: TMoveBlock read FReadData write FReadData;
    property  WriteData: TMoveBlock read FWriteData write FWriteData;
    procedure LZHPackStream(ASource, ADestination: PStream; APackCount, FProgressInterval: Integer);
    procedure LZHUnpackStream(ASource, ADestination: PStream; AUnpackCount, FProgressInterval: Integer);
    procedure LZHPackFile(ASource, ADestination: String; FProgressInterval: integer);
    procedure LZHUnpackFile(ASource, ADestination: String; FProgressInterval: integer);

   public
    _prop_FileName:string;
    _prop_NewFileName:string;
    _prop_ProgressInterval:integer;

    _event_onPackUnPackFile:THI_Event;
    _event_onPackUnPackError:THI_Event;    
    _event_onStream:THI_Event;
    _event_onProgressMax:THI_Event;
    _event_onProgress:THI_Event;
    
    _data_FileName:THI_Event;
    _data_NewFileName:THI_Event;
    _data_Stream:THI_Event;
    _data_ProgressInterval:THI_Event;

    procedure _work_doPackFile(var _Data:TData; Index:word);
    procedure _work_doUnpackFile(var _Data:TData; Index:word);
    procedure _work_doCompress(var _Data:TData; Index:word);
    procedure _work_doDeCompress(var _Data:TData; Index:word);
    procedure _var_DestSize(var _Data:TData; Index:word);
    procedure _var_Position(var _Data:TData; Index:word);
    procedure _var_OriginalSize(var _Data:TData; Index:word);        
  end;

implementation

//------------------------------------------------------------------------------
procedure THILZH.InitLZH;
var   i, k, n: Integer;
begin
   k:= 0;
   for i:= 0 to 63 do begin
      case i of
         1:      p_code[i]:= $20;
         2.. 4:  p_code[i]:= p_code[i-1]+$10;
         5.. 12: p_code[i]:= p_code[i-1]+$08;
         13..24: p_code[i]:= p_code[i-1]+$04;
         25..48: p_code[i]:= p_code[i-1]+$02;
         49..63: p_code[i]:= p_code[i-1]+$01;
         else p_code[i]:= 0;
      end;
      case i of
         1 .. 3: begin p_len[i]:= $4; n:= 16; end;
         4 ..11: begin p_len[i]:= $5; n:= 8; end;
         12..23: begin p_len[i]:= $6; n:= 4; end;
         24..47: begin p_len[i]:= $7; n:= 2; end;
         48..63: begin p_len[i]:= $8; n:= 1; end;
         else begin p_len[i]:= $3; n:= 32; end;
      end;
      FillMemory(@(d_code[k]), n, i);
      inc(k, n);
   end;
   for i:= 0 to 255 do begin
      case i of
         0  .. 31: d_len[i]:=$3; //32
         32 .. 79: d_len[i]:=$4; //48
         80 ..143: d_len[i]:=$5; //64
         144..191: d_len[i]:=$6; //48
         192..239: d_len[i]:=$7; //48
         240..255: d_len[i]:=$8; //16
      end;
   end;
   GetBuf:= 0; GetLen:= 0;
   PutLen:= 0; PutBuf:= 0;
   CodeSize:= 0;
   Match_Position:= 0; Match_Length:= 0;
   PosnG:= 1;
   Buf:= 0;
   PosnP:= 1;
   New(lSon); New(Dad); New(rSon);
   New(Text_Buf); New(Freq); New(Prnt);
   New(Son); New(InBuf); New(OutBuf);
end;

//------------------------------------------------------------------------------
procedure THILZH.EndLZH;
begin
   Dispose(Son);
   Dispose(Prnt);
   Dispose(Freq);
   Dispose(Text_Buf);
   Dispose(rSon);
   Dispose(Dad);
   Dispose(lSon);
   Dispose(OutBuf);
   Dispose(InBuf);
end;

//------------------------------------------------------------------------------
procedure THILZH.LZHPack(APackSize, FProgressInterval: integer);
var   ct: Byte;
      curp, i, len, r, s, last_match_length: integer;
      Got: integer;
begin
   InitLZH;
   StartHuff;
   for i:= MaxBuf + 1 TO MaxBuf + 256 do rSon^[i]:= MaxBuf;
   for i:= 0 to MaxBuf do Dad^[i]:= MaxBuf;
   s:=  0;
   r:=  MaxBuf - F;
   FillChar(Text_Buf^[0], r, ' ');
   len:=  0;
   Got:=  1;
   while (len < F) and (Got <> 0) do begin
      GetBlock(ct, Got);
      if Got <> 0 then begin
         Text_Buf^[r + len]:=  ct;
         INC(len);
      end;
   end;
   fOriginal := APackSize; 
   _hi_onEvent(_event_onProgressMax, APackSize);
   curp := 0; 
   for i:= 1 to F do InsertNode(r - i);
   InsertNode(r);
   repeat
      fPosition := curp; 

      if (curp mod FProgressInterval = 0) then _hi_onEvent(_event_onProgress, curp);

      if (match_length > len) then
         match_length:= len;
      if (match_length <= THRESHOLD) then begin
         match_length:= 1;
         EncodeChar(Text_Buf^[r]);
      end else begin
         EncodeChar(255 - THRESHOLD + match_length);
         EncodePosition(match_position);
      end;
      last_match_length:= match_length;
      i:= 0;
      Got:= 1;
      while (i < last_match_length) and (Got <> 0) do begin
         GetBlock(ct, Got);
         inc(curp);
         if Got <> 0 then begin
            DeleteNode(s);
            Text_Buf^[s]:= ct;
            if (s < PRED(F)) then
               Text_Buf^[s + MaxBuf]:= ct;
            s:= Succ(s) and Pred(MaxBuf);
            r:= Succ(r) and Pred(MaxBuf);
            InsertNode(r);
            inc(i);
         end;
      end;
      while (i < last_match_length) do begin
         INC(i);
         DeleteNode(s);
         s:= SUCC(s) AND PRED(MaxBuf);
         r:= SUCC(r) AND PRED(MaxBuf);
         DEC(len);
         if BOOLEAN(len) then InsertNode(r);
      end;
   until (len <= 0);
   if Boolean(putlen) then begin
      ct:= (putbuf SHR 8);
      PutBlock(ct, 1, Got);
      inc(codesize);
   end;
   PutBlock(OutBuf^, 0, Got);
   EndLZH;
   fPosition := APackSize;
   _hi_onEvent(_event_onProgress, APackSize);
end;

//------------------------------------------------------------------------------
procedure THILZH.LZHUnpack(AUnpackSize, FProgressInterval: integer);
var   c2: Byte;
      c : integer;
      i, j, k, r: Integer;
      count: integer;
      Put: integer;
begin
   InitLZH;
   StartHuff;
   r:= MaxBuf - F;
   FillChar(Text_Buf^[0], r,  ' ');
   Count:= 0;
   fOriginal := AUnpackSize; 
   _hi_onEvent(_event_onProgressMax, AUnpackSize);
   while count < AUnpackSize do
   begin
      fPosition := Count;
      if (Count mod FProgressInterval = 0) then _hi_onEvent(_event_onProgress, Count);
      c:= DecodeChar;
      if (c < 256) then begin
         c2:= c and $FF; 
         PutBlock(c2, 1, Put);
         Text_Buf^[r]:= c;
         INC(r);
         r:= r and PRED(MaxBuf);
         INC(count);
      end else begin
         i:= (r - SUCC(DecodePosition)) and PRED(MaxBuf);
         j:= c - 255 + THRESHOLD;
         for k:= 0 to PRED(j) do begin
            c:= Text_Buf^[(i + k) and PRED(MaxBuf)];
            c2:= c and $FF;
            PutBlock(c2, 1, Put);
            Text_Buf^[r]:= c;
            INC(r);
            r:= r and Pred(MaxBuf);
            INC(count);
         end;
      end;
   end;
   PutBlock(OutBuf^, 0, Put);
   EndLZH;
   fPosition := AUnPackSize;
   _hi_onEvent(_event_onProgress, AUnPackSize);
end;

//------------------------------------------------------------------------------
procedure THILZH.GetBlock(var Target; var Actual_Bytes: integer);
var   Temp: Integer;
begin
   if (PosnG > Buf) or (PosnG + 1 > Succ(Buf)) then begin
      if PosnG > Buf then
         Buf:= FReadData(InBuf^, MaxBuf)
      else begin
         Move(InBuf^[PosnG], InBuf^[1], Buf-PosnG);
         Temp:= FReadData(InBuf^[Buf-PosnG], MaxBuf-(Buf-PosnG));
         Buf:= Buf-PosnG+Temp;
      end;
      if Buf = 0 then begin
         Actual_Bytes:= 0;
         Exit;
      end;
      PosnG:= 1;
   end;
   Move(InBuf^[PosnG], Target, 1);
   inc(PosnG, 1);
   if PosnG > SUCC(Buf) then
      Actual_Bytes:= 1 -(PosnG-SUCC(Buf))
   else
      Actual_Bytes:= 1;
end;

//------------------------------------------------------------------------------
procedure THILZH.PutBlock(var Source; NoBytes: integer; var Actual_Bytes: integer);
begin
   if NoBytes = 0 then begin
      FWriteData(OutBuf^, PRED(PosnP));
      Exit;
   end;
   if (PosnP > MaxBuf) OR (PosnP + NoBytes > SUCC(MaxBuf)) then begin
      FWriteData(OutBuf^, PRED(PosnP));
      PosnP:= 1;
   end;
   Move(Source, OutBuf^[PosnP], NoBytes);
   inc(PosnP, NoBytes);
   Actual_Bytes:= NoBytes;
end;

//------------------------------------------------------------------------------
procedure THILZH.InsertNode(r: integer);
var   tmp, i, p, cmp, c: integer;
      key: PTextBuf;
begin
   cmp:= 1;
   key:= @Text_Buf^[r];
   p:= SUCC(MaxBuf) + key^[0];
   rSon^[r]:= MaxBuf;
   lSon^[r]:= MaxBuf;
   match_length:= 0;
   while match_length < F do begin
      if (cmp >= 0) then begin
         if (rSon^[p] <> MaxBuf) then
            p:= rSon^[p]
         else begin
            rSon^[p]:= r;
            Dad^[r]:= p;
            exit;
         end;
      end else begin
         if (lSon^[p] <> MaxBuf) then
            p:= lSon^[p]
         else begin
            lSon^[p]:= r;
            Dad^[r]:= p;
            exit;
         end;
      end;
      i:= 0;
      cmp:= 0;
      while (i < F) AND (cmp = 0) do begin
         inc(i);
         cmp:= key^[i] - Text_Buf^[p + i];
      end;
      if (i > THRESHOLD) then begin
         tmp:= PRED((r - p) and Pred(MaxBuf));
         if (i > match_length) then begin
            match_position:= tmp;
            match_length:= i;
         end;
         if (match_length < F) AND (i = match_length) then begin
            c:= tmp;
            if (c < match_position) then match_position:= c;
         end;
      end;
   end;
   Dad^[r]:= Dad^[p];
   lSon^[r]:= lSon^[p];
   rSon^[r]:= rSon^[p];
   Dad^[lSon^[p]]:= r;
   Dad^[rSon^[p]]:= r;
   if (rSon^[Dad^[p]] = p) then
      rSon^[Dad^[p]]:= r
   else
      lSon^[Dad^[p]]:= r;
   Dad^[p]:= MaxBuf;
end;

//------------------------------------------------------------------------------
procedure THILZH.DeleteNode(p: integer);
var   q: integer;
begin
   if (Dad^[p] = MaxBuf) then exit;
   if (rSon^[p] = MaxBuf) then
      q:= lSon^[p]
   else
      if (lSon^[p] = MaxBuf) then
         q:= rSon^[p]
      else begin
         q:= lSon^[p];
         if (rSon^[q] <> MaxBuf) then begin
            repeat
               q:= rSon^[q];
            until (rSon^[q] = MaxBuf);
            rSon^[Dad^[q]]:= lSon^[q];
            Dad^[lSon^[q]]:= Dad^[q];
            lSon^[q]:= lSon^[p];
            Dad^[lSon^[p]]:= q;
         end;
         rSon^[q]:= rSon^[p];
         Dad^[rSon^[p]]:= q;
      end;
   Dad^[q]:= Dad^[p];
   if (rSon^[Dad^[p]] = p) then
      rSon^[Dad^[p]]:= q
   else
      lSon^[Dad^[p]]:= q;
   Dad^[p]:= MaxBuf;
end;

//------------------------------------------------------------------------------
function THILZH.GetBit: integer;
var   i: Byte;
      i2: integer;
      Resultat: integer;
begin
   while (GetLen <= 8) do begin
      GetBlock(i, Resultat);
      if Resultat = 1 then
         i2:= i
      else
         i2:= 0;
      GetBuf:= GetBuf or (i2 shl (8 - GetLen));
      inc(GetLen, 8);
   end;
   i2:= GetBuf;
   GetBuf:= GetBuf shl 1;
   dec(GetLen);
   Result:= integer(i2 > $7FFF);
end;

//------------------------------------------------------------------------------
function THILZH.GetByte: integer;
var   j: Byte;
      i, Resultat: integer;
begin
   while (GetLen <= 8) do begin
      GetBlock(j, Resultat);
      if Resultat = 1 then
         i:= j
      else
         i:= 0;
      GetBuf:= GetBuf or (i shl (8 - GetLen));
      inc(GetLen, 8);
   end;
   i:= GetBuf;
   GetBuf:= GetBuf shl 8;
   dec(GetLen, 8);
   Result:= i shr 8;
end;

//------------------------------------------------------------------------------
procedure THILZH.PutCode(l: integer; c: integer);
var   Temp: Byte;
      Got: integer;
begin
   putbuf:= putbuf or (c shr putlen);
   inc(putlen, l);
   if (putlen >= 8) then begin
      Temp:= putbuf shr 8;
      PutBlock(Temp, 1, Got);
      DEC(putlen, 8);
      if (putlen  >= 8) then begin
         Temp:= PutBuf and $FF;
         PutBlock(Temp, 1, Got);
         inc(codesize, 2);
         DEC(putlen, 8);
         putbuf:= c shl (l - putlen);
      end else begin
         putbuf:= putbuf shl 8;
         inc(codesize);
      end;
   end;
end;

//------------------------------------------------------------------------------
procedure THILZH.StartHuff;
var   i, j: integer;
begin
   for i:= 0 to Pred(N_CHAR) do begin
      Freq^[i]:= 1;
      Son^[i]:= i + T;
      Prnt^[i + T]:= i;
   end;
   i:= 0;
   j:= N_CHAR;
   while (j <= R) do begin
      Freq^[j]:= Freq^[i] + Freq^[i + 1];
      Son^[j]:= i;
      Prnt^[i]:= j;
      Prnt^[i + 1]:= j;
      inc(i, 2);
      inc(j);
   end;
   Freq^[T]:= $ffff;
   Prnt^[R]:= 0;
end;

//------------------------------------------------------------------------------
procedure THILZH.Reconst;
var   i, j, k, tmp: integer;
      f, l: integer;
begin
   j:= 0;
   for i:= 0 to PRED(T) do begin
      if (Son^[i] >= T) then begin
         Freq^[j]:= SUCC(Freq^[i]) div 2;
         Son^[j]:= Son^[i];
         INC(j);
      end;
   end;
   i:= 0;
   j:= N_CHAR;
   while (j < T) do begin
      k:= SUCC(i);
      f:= Freq^[i] + Freq^[k];
      Freq^[j]:= f;
      k:= PRED(j);
      while f < Freq^[k] do dec(K);
      inc(k);
      l:= (j - k) shl 1;
      tmp:= SUCC(k);
      move(Freq^[k], Freq^[tmp], l);
      Freq^[k]:= f;
      move(Son^[k], Son^[tmp], l);
      Son^[k]:= i;
      inc(i, 2);
      inc(j);
   end;
   for i:= 0 to pred(T) do begin
      k:= Son^[i];
      if (k >= T) then
         Prnt^[k]:= i
      else begin
         Prnt^[k]:= i;
         Prnt^[SUCC(k)]:= i;
      end;
   end;
end;

//------------------------------------------------------------------------------
procedure THILZH.Update(c: integer);
var   i, j, l, k: integer;
begin
   if (Freq^[R] = MAX_Freq) then Reconst;
   c:= Prnt^[c + T];
   repeat
      INC(Freq^[c]);
      k:= Freq^[c];
      l:= SUCC(C);
      if (k > Freq^[l]) then begin
         while (k > Freq^[l]) do inc(l);
         dec(l);
         Freq^[c]:= Freq^[l];
         Freq^[l]:= k;
         i:= Son^[c];
         Prnt^[i]:= l;
         if (i < T) then Prnt^[SUCC(i)]:= l;
         j:= Son^[l];
         Son^[l]:= i;
         Prnt^[j]:= c;
         if (j < T) then Prnt^[SUCC(j)]:= c;
         Son^[c]:= j;
         c:= l;
      end;
      c:= Prnt^[c];
   until (c = 0);
end;

//------------------------------------------------------------------------------
procedure THILZH.EncodeChar(c: integer);
var   i: integer;
      j, k: integer;
begin
   i:= 0;
   j:= 0;
   k:= Prnt^[c + T];
   repeat
      i:= i shr 1;
      if BOOLEAN(k and 1) then INC(i, $8000);
      INC(j);
      k:= Prnt^[k];
   until (k = R);
   Putcode(j, i);
   Update(c);
end;

//------------------------------------------------------------------------------
procedure THILZH.EncodePosition(c: integer);
var   i, j: integer;
begin
   i:= c shr 6;
   j:= p_code[i];
   Putcode(p_len[i], j shl 8);
   Putcode(6, (c and $3f) shl 10);
end;

//------------------------------------------------------------------------------
function THILZH.DecodeChar: integer;
var   c: integer;
begin
   c:= Son^[R];
   while (c < T) do begin
      c:= c + GetBit;
      c:= Son^[c];
   end;
   c:= c - T;
   Update(c);
   Result:= c;
end;

//------------------------------------------------------------------------------
function THILZH.DecodePosition: integer;
var   i, j, c: integer;
begin
   i:= GetByte;
   c:= d_code[i] shl 6;
   j:= d_len[i];
   dec(j, 2);
   while j <> 0 do begin
      i:= (i shl 1) + GetBit;
      dec(j);
   end;
   Result:= c or i and $3f;
end;

//------------------------------------------------------------------------------
function THILZH.ReadBlockStream(var ABuff; ACount: integer): integer;
begin
   Result:= FSource.Read(ABuff, ACount);
end;

//------------------------------------------------------------------------------
function THILZH.WriteBlockStream(var ABuff; ACount: integer): integer;
begin
   Result:= FDestination.Write(ABuff, ACount);
end;

//------------------------------------------------------------------------------
procedure THILZH.LZHPackStream(ASource, ADestination: PStream; APackCount, FProgressInterval: Integer);
begin
   FSource:= ASource;
   FDestination:=ADestination;
   ReadData:= ReadBlockStream;
   WriteData:= WriteBlockStream;
   LZHPack(APackCount, FProgressInterval);
end;

//------------------------------------------------------------------------------
procedure THILZH.LZHUnpackStream(ASource, ADestination: PStream; AUnpackCount, FProgressInterval: Integer);
begin
   FSource:= ASource;
   FDestination:=ADestination;
   ReadData:= ReadBlockStream;
   WriteData:= WriteBlockStream;
   LZHUnpack(AUnpackCount, FProgressInterval);
end;

//------------------------------------------------------------------------------
procedure THILZH.LZHPackFile(ASource, ADestination: String; FProgressInterval: integer);
var   SourceStream, DestinationStream: PStream;
      L: integer;
begin
   SourceStream:= NewReadFileStream(ASource);
   DestinationStream:= NewWriteFileStream(ADestination); DestinationStream.Size:= 0;
   L:= SourceStream.Size; DestinationStream.Write(L, SizeOf(L));
   LZHPackStream(SourceStream, DestinationStream, L, FProgressInterval);
   SourceStream.Free; DestinationStream.Free;
end;

//------------------------------------------------------------------------------
procedure THILZH.LZHUnpackFile(ASource, ADestination: String; FProgressInterval: integer);
var   SourceStream, DestinationStream: PStream;
      L: integer;
begin
   SourceStream:= NewReadFileStream(ASource);
   DestinationStream:= NewWriteFileStream(ADestination); DestinationStream.Size:= 0;
   SourceStream.Read(L, SizeOf(L));
   LZHUnpackStream(SourceStream, DestinationStream, L, FProgressInterval);
   SourceStream.Free; DestinationStream.Free;
end;

//---------------------- Рабочие методы компонента -----------------------------

procedure THILZH._work_doPackFile;
var   sfile, dfile:string;
begin
   sfile:=ReadString(_Data,_data_FileName,_prop_FileName);
   dfile:=ReadString(_Data,_data_NewFileName,_prop_NewFileName);
   if (FileExists(sfile)) then begin
      LZHPackFile(sfile,dfile,ReadInteger(_Data, _data_ProgressInterval, _prop_ProgressInterval));
      if (FileExists(dfile)) then begin
         DSize := FileSize(dfile);
         _hi_CreateEvent(_Data,@_event_onPackUnPackFile,DSize);
      end      
      else
         _hi_CreateEvent(_Data,@_event_onPackUnPackError);      
   end;
end;

procedure THILZH._work_doUnpackFile;
var   sfile, dfile:string;
begin
   sfile:=ReadString(_Data,_data_FileName,_prop_FileName);
   dfile:=ReadString(_Data,_data_NewFileName,_prop_NewFileName);
   if (FileExists(sfile)) then begin
      LZHUnpackFile(sfile,dfile,ReadInteger(_Data, _data_ProgressInterval, _prop_ProgressInterval));
      if (FileExists(dfile)) then begin
         DSize := FileSize(dfile);
         _hi_CreateEvent(_Data,@_event_onPackUnPackFile,DSize);
      end
      else
         _hi_CreateEvent(_Data,@_event_onPackUnPackError);      
   end;
end;

procedure THILZH._work_doCompress;
var   st, dest:PStream;
      s:integer;
begin
   st := ReadStream(_data,_data_Stream,nil);
   if st = nil then exit;
   dest := NewMemoryStream;
   s := st.Size;
   dest.Write(s, SizeOf(s));
   st.Position:= 0;
   LZHPackStream(st, dest, s, ReadInteger(_Data, _data_ProgressInterval, _prop_ProgressInterval));
   dest.Position := 0;
   DSize := dest.Size;
   _hi_onEvent(_event_onStream,dest);
   dest.Free;
end;

procedure THILZH._work_doDeCompress;
var   st, dest:PStream;
      s:integer;
begin
   st := ReadStream(_data,_data_Stream,nil);
   if st = nil then exit;
   dest := NewMemoryStream;
   st.Position:= 0;
   st.Read(s, SizeOf(s));
   LZHUnpackStream(st,dest,s, ReadInteger(_Data, _data_ProgressInterval, _prop_ProgressInterval));
   dest.Position := 0;
   DSize := dest.Size;
   _hi_onEvent(_event_onStream,dest);
   dest.Free;
end;

procedure THILZH._var_DestSize;
begin
   dtInteger(_data,DSize);
end;

procedure THILZH._var_Position;
begin
   dtInteger(_data,fPosition);
end;

procedure THILZH._var_OriginalSize;
begin
   dtInteger(_data,fOriginal);
end;

end.