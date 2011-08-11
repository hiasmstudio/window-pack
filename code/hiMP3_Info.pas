unit hiMP3_Info;

interface

uses Kol,Share,Debug;

const 
 Genres : array[0..147] of string =  
    ('Blues','Classic Rock','Country','Dance','Disco','Funk','Grunge',  
    'Hip- Hop','Jazz','Metal','New Age','Oldies','Other','Pop','R&B',  
    'Rap','Reggae','Rock','Techno','Industrial','Alternative','Ska',  
    'Death Metal','Pranks','Soundtrack','Euro-Techno','Ambient',  
    'Trip-Hop','Vocal','Jazz+Funk','Fusion','Trance','Classical',  
    'Instrumental','Acid','House','Game','Sound Clip','Gospel','Noise',  
    'Alternative Rock','Bass','Soul','Punk','Space','Meditative','Instrumental Pop',  
    'Instrumental Rock','Ethnic','Gothic','Darkwave','Techno-Industrial','Electronic',  
    'Pop-Folk','Eurodance','Dream','Southern Rock','Comedy','Cult','Gangsta',  
    'Top 40','Christian Rap','Pop/Funk','Jungle','Native US','Cabaret','New Wave',  
    'Psychadelic','Rave','Showtunes','Trailer','Lo-Fi','Tribal','Acid Punk',  
    'Acid Jazz','Polka','Retro','Musical','Rock & Roll','Hard Rock','Folk',  
    'Folk-Rock','National Folk','Swing','Fast Fusion','Bebob','Latin','Revival',  
    'Celtic','Bluegrass','Avantgarde','Gothic Rock','Progressive Rock',  
    'Psychedelic Rock','Symphonic Rock','Slow Rock','Big Band','Chorus',  
    'Easy Listening','Acoustic','Humour','Speech','Chanson','Opera',  
    'Chamber Music','Sonata','Symphony','Booty Bass','Primus','Porn Groove',  
    'Satire','Slow Jam','Club','Tango','Samba','Folklore','Ballad',  
    'Power Ballad','Rhytmic Soul','Freestyle','Duet','Punk Rock','Drum Solo',  
    'Acapella','Euro-House','Dance Hall','Goa','Drum & Bass','Club-House',  
    'Hardcore','Terror','Indie','BritPop','Negerpunk','Polsk Punk','Beat',  
    'Christian Gangsta','Heavy Metal','Black Metal','Crossover','Contemporary C',  
    'Christian Rock','Merengue','Salsa','Thrash Metal','Anime','JPop','SynthPop');

const
  TAG_VERSION_2_2 = 2;                               { Code for ID3v2.2.x tag }
  TAG_VERSION_2_3 = 3;                               { Code for ID3v2.3.x tag }
  TAG_VERSION_2_4 = 4;                               { Code for ID3v2.4.x tag }

type
  { Class TID3v2 }
  PID3v2 = ^TID3v2;
  TID3v2 = class(TDebug)
    private
      { Private declarations }
      FExists: Boolean;
      FVersionID: Byte;
      FSize: Integer;
      FTitle: string;
      FArtist: string;
      FAlbum: string;
      FTrack: Word;
      FTrackString: string;
      FYear: string;
      FGenre: string;
      FComment: string;
      FComposer: string;
      FEncoder: string;
      FCopyright: string;
      FOrigArtist: string;
      FLink: string;
      procedure FSetTitle(const NewTitle: string);
      procedure FSetArtist(const NewArtist: string);
      procedure FSetAlbum(const NewAlbum: string);
      procedure FSetTrack(const NewTrack: Word);
      procedure FSetYear(const NewYear: string);
      procedure FSetGenre(const NewGenre: string);
      procedure FSetComment(const NewComment: string);
      procedure FSetComposer(const NewComposer: string);
      procedure FSetEncoder(const NewEncoder: string);
      procedure FSetCopyright(const NewCopyright: string);
      procedure FSetOrigArtist(const NewOrigArtist: string);
      procedure FSetLink(const NewLink: string);
    public
      { Public declarations }
      constructor Create;                                                { Create object }
      procedure ResetData;                                               { Reset all data }
      function ReadFromFile(const FileName: string): Boolean;            { Load tag }
      property Exists: Boolean read FExists;                             { True if tag found }
      property VersionID: Byte read FVersionID;                          { Version code }
      property Size: Integer read FSize;                                 { Total tag size }
      property Title: string read FTitle write FSetTitle;                { Song title }
      property Artist: string read FArtist write FSetArtist;             { Artist name }
      property Album: string read FAlbum write FSetAlbum;                { Album title }
      property Track: Word read FTrack write FSetTrack;                  { Track number }
      property TrackString: string read FTrackString;                    { Track number (string) }
      property Year: string read FYear write FSetYear;                   { Release year }
      property Genre: string read FGenre write FSetGenre;                { Genre number }
      property Comment: string read FComment write FSetComment;          { Comment }
      property Composer: string read FComposer write FSetComposer;       { Composer }
      property Encoder: string read FEncoder write FSetEncoder;          { Encoder }
      property Copyright: string read FCopyright write FSetCopyright;    { (c) }
      property OrigArtist: string read FOrigArtist write FSetOrigArtist; { OrigArtist }
      property Link: string read FLink write FSetLink;                   { URL link }
  end;

type
  THIMP3_Info = class(TDebug)
   private
    List: PStrList;
    List_v2: PStrList;
    FT: TID3v2;
    Arr: PArray;
    Arr_v2: PArray;    
    function _Get(Var Item:TData; var Val:TData):boolean;
    function _Count: integer;
    function _Get_v2(Var Item:TData; var Val:TData):boolean;
    function _Count_v2: integer;
   public
    _prop_Genre: integer;
    _data_FileName:THI_Event;
    _event_onReadInfo: THI_Event;
    _event_onReadInfoV2: THI_Event;    
    
    constructor Create;
    destructor Destroy; override;
    procedure _work_doReadInfo(var _Data:TData; Index:word);
    procedure _var_Tags(var _Data:TData; Index:word);
    procedure _var_TagsV2(var _Data:TData; Index:word);
  end;

implementation

const
  { ID3v2 tag ID }
  ID3V2_ID = 'ID3';

  { Max. number of supported tag frames }
  ID3V2_FRAME_COUNT = 16;

  { Names of supported tag frames (ID3v2.3.x & ID3v2.4.x) }
  ID3V2_FRAME_NEW: array [1..ID3V2_FRAME_COUNT] of string =
    ('TIT2', 'TPE1', 'TALB', 'TRCK', 'TYER', 'TCON', 'COMM', 'TCOM', 'TENC',
     'TCOP', 'TLAN', 'WXXX', 'TDRC', 'TOPE', 'TIT1', 'TOAL');

  { Names of supported tag frames (ID3v2.2.x) }
  ID3V2_FRAME_OLD: array [1..ID3V2_FRAME_COUNT] of string =
    ('TT2', 'TP1', 'TAL', 'TRK', 'TYE', 'TCO', 'COM', 'TCM', 'TEN',
     'TCR', 'TLA', 'WXX', 'TOR', 'TOA', 'TT1', 'TOT');

  { Max. tag size for saving }
  ID3V2_MAX_SIZE = 4096;

  { Unicode ID }
  UNICODE_ID = #1;

type
  { Frame header (ID3v2.3.x & ID3v2.4.x) }
  FrameHeaderNew = record
    ID: array [1..4] of Char;                                      { Frame ID }
    Size: Integer;                                    { Size excluding header }
    Flags: Word;                                                      { Flags }
  end;

  { Frame header (ID3v2.2.x) }
  FrameHeaderOld = record
    ID: array [1..3] of Char;                                      { Frame ID }
    Size: array [1..3] of Byte;                       { Size excluding header }
  end;

  { ID3v2 header data - for internal use }
  TagInfo = record
    { Real structure of ID3v2 header }
    ID: array [1..3] of Char;                                  { Always "ID3" }
    Version: Byte;                                           { Version number }
    Revision: Byte;                                         { Revision number }
    Flags: Byte;                                               { Flags of tag }
    Size: array [1..4] of Byte;                   { Tag size excluding header }
    { Extended data }
    FileSize: Integer;                                    { File size (bytes) }
    Frame: array [1..ID3V2_FRAME_COUNT] of string;  { Information from frames }
    NeedRewrite: Boolean;                           { Tag should be rewritten }
    PaddingSize: Integer;                              { Padding size (bytes) }
  end;

{ ********************* Auxiliary functions & procedures ******************** }

function Trim(const S: string): string;
var
  I, L: Integer;
begin
  L := Length(S);
  I := 1;
  while (I <= L) and (S[I] <= ' ') do Inc(I);
  if I > L then Result := '' else
  begin
    while S[L] <= ' ' do Dec(L);
    Result := Copy(S, I, L - I + 1);
  end;
end;

function TrimLeft(const S: string): string;
var
  I, L: Integer;
begin
  L := Length(S);
  I := 1;
  while (I <= L) and (S[I] <= ' ') do Inc(I);
  Result := Copy(S, I, Maxint);
end;

function TrimRight(const S: string): string;
var
  I: Integer;
begin
  I := Length(S);
  while (I > 0) and (S[I] <= ' ') do Dec(I);
  Result := Copy(S, 1, I);
end;

function ReadHeader(const FileName: string; var Tag: TagInfo): Boolean;
var
  SourceFile: PStream;
  Transferred: Integer;
begin
  Result := true;
  { Set read-access and open file }
  SourceFile := NewReadFileStream(FileName);
  SourceFile.Position := 0;
  { Read header and get file size }
  Transferred := SourceFile.Read(Tag, 10);
  Tag.FileSize := SourceFile.Size;
  free_and_nil(SourceFile);
  { if transfer is not complete }
  if Transferred < 10 then Result := false;
end;

{ --------------------------------------------------------------------------- }

function GetTagSize(const Tag: TagInfo): Integer;
begin
  { Get total tag size }
  Result :=
    Tag.Size[1] * $200000 +
    Tag.Size[2] * $4000 +
    Tag.Size[3] * $80 +
    Tag.Size[4] + 10;
  if Tag.Flags and $10 = $10 then Inc(Result, 10);
  if Result > Tag.FileSize then Result := 0;
end;

{ --------------------------------------------------------------------------- }

procedure SetTagItem(const ID, Data: string; var Tag: TagInfo);
var
  Iterator: Byte;
  FrameID: string;
begin
  { Set tag item if supported frame found }
  for Iterator := 1 to ID3V2_FRAME_COUNT do
  begin
    if Tag.Version > TAG_VERSION_2_2 then
      FrameID := ID3V2_FRAME_NEW[Iterator]
    else
      FrameID := ID3V2_FRAME_OLD[Iterator];
    if (FrameID = ID) and (length(Data) > 0) and (Data[1] <= UNICODE_ID) then
      Tag.Frame[Iterator] := Data;
  end;
end;

{ --------------------------------------------------------------------------- }

function Swap32(const Figure: Integer): Integer;
var
  ByteArray: array [1..4] of Byte absolute Figure;
begin
  { Swap 4 bytes }
  Result :=
    ByteArray[1] * $1000000 +
    ByteArray[2] * $10000 +
    ByteArray[3] * $100 +
    ByteArray[4];
end;

{ --------------------------------------------------------------------------- }

procedure ReadFramesNew(const FileName: string; var Tag: TagInfo);
var
  Frame: FrameHeaderNew;
  SourceFile: PStream;
  Data: string;
  DataPosition, DataSize: Integer;
begin
  { Get information from frames (ID3v2.3.x & ID3v2.4.x) }
  { Set read-access, open file }
  SourceFile := NewReadFileStream(FileName);
TRY
  SourceFile.Position := 10;
  while (SourceFile.Position < GetTagSize(Tag)) and (SourceFile.Position < SourceFile.Size) do
  begin
    { Read frame header and check frame ID }
    SourceFile.Read(Frame, 10); 
    if not (Frame.ID[1] in ['A'..'Z']) then break;
    { Note data position and determine significant data size }
    DataPosition := SourceFile.Position;
    DataSize := Swap32(Frame.Size);
    { Read frame data and set tag item if frame supported }
    SetLength(Data, DataSize);
    SourceFile.Read(Data[1], DataSize);
    if Frame.Flags and $8000 <> $8000 then
      SetTagItem(Frame.ID, Data, Tag);
    SourceFile.Position := DataPosition + Swap32(Frame.Size);
  end;
FINALLY
  free_and_nil(SourceFile);
END;  
end;

{ --------------------------------------------------------------------------- }

procedure ReadFramesOld(const FileName: string; var Tag: TagInfo);
var
  Frame: FrameHeaderOld;
  SourceFile: PStream;
  Data: string;
  DataPosition, FrameSize, DataSize: Integer;
begin
  { Get information from frames (ID3v2.2.x) }
  { Set read-access, open file }
  SourceFile := NewReadFileStream(FileName);
TRY
  SourceFile.Position := 10;
  while (SourceFile.Position < GetTagSize(Tag)) and (SourceFile.Position < SourceFile.Size) do
  begin
    { Read frame header and check frame ID }
    SourceFile.Read(Frame, 6); 
    if not (Frame.ID[1] in ['A'..'Z']) then break;
    { Note data position and determine significant data size }
    DataPosition := SourceFile.Position;
    FrameSize := Frame.Size[1] shl 16 + Frame.Size[2] shl 8 + Frame.Size[3];
    DataSize := FrameSize;
    { Read frame data and set tag item if frame supported }
    SetLength(Data, DataSize);
    SourceFile.Read(Data[1], DataSize);
    SetTagItem(Frame.ID, Data, Tag);
      SourceFile.Position := DataPosition + FrameSize;
  end;
FINALLY
  free_and_nil(SourceFile);
END;  
end;

{ --------------------------------------------------------------------------- }

function GetANSI(const Source: string): string;
var
  Index: Integer;
  FirstByte, SecondByte: Byte;
  UnicodeChar: WideChar;
begin
  { Convert string from unicode if needed and trim spaces }
  if (Length(Source) > 0) and (Source[1] = UNICODE_ID) then
  begin
    Result := '';
    for Index := 1 to ((Length(Source) - 1) div 2) do
    begin
      FirstByte := Ord(Source[Index * 2]);
      SecondByte := Ord(Source[Index * 2 + 1]);
      UnicodeChar := WideChar(FirstByte or (SecondByte shl 8));
      if UnicodeChar = #0 then break;
      if FirstByte < $FF then Result := Result + UnicodeChar;
    end;
    Result := Trim(Result);
  end
  else
    Result := Trim(Source);
end;

{ --------------------------------------------------------------------------- }

function GetContent(const Content1, Content2: string): string;
begin
  { Get content preferring the first content }
  Result := GetANSI(Content1);
  if Result = '' then Result := GetANSI(Content2);
end;

{ --------------------------------------------------------------------------- }

function ExtractTrack(const TrackString: string): Word;
var
  Track: string;
  Index, Value, Code: Integer;
begin
  { Extract track from string }
  Track := GetANSI(TrackString);
  Index := Pos('/', Track);
  if Index = 0 then Val(Track, Value, Code)
  else Val(Copy(Track, 1, Index - 1), Value, Code);
  if Code = 0 then Result := Value
  else Result := 0;
end;

{ --------------------------------------------------------------------------- }

function ExtractYear(const YearString, DateString: string): string;
begin
  { Extract year from strings }
  Result := GetANSI(YearString);
  if Result = '' then Result := Copy(GetANSI(DateString), 1, 4);
end;

{ --------------------------------------------------------------------------- }

function ExtractGenre(const GenreString: string): string;
var
  i: integer;  
  s: string;
begin 
  { Extract genre from string }
  s := GetANSI(GenreString);

  i := Pos(')', s);  
  if i > 0 then 
    s := CopyEnd(s, i + 1);
      
  Result := '0';
  for i := 0 to High(Genres) do
    if StrEq(Genres[i], s) then
    begin
      Result := int2str(i);
      break;
    end; 
end;

{ --------------------------------------------------------------------------- }

function ExtractText(const SourceString: string; LanguageID: Boolean): string;
var
  Source, Separator: string;
  EncodingID: Char;
begin
  { Extract significant text data from a complex field }
  Source := SourceString;
  Result := '';
  if Length(Source) > 0 then
  begin
    EncodingID := Source[1];
    if EncodingID = UNICODE_ID then Separator := #0#0
    else Separator := #0;
    if LanguageID then  Delete(Source, 1, 4)
    else Delete(Source, 1, 1);
    Delete(Source, 1, Pos(Separator, Source) + Length(Separator) - 1);
    Result := GetANSI(EncodingID + Source);
  end;
end;

{ ********************** Private functions & procedures ********************* }

procedure TID3v2.FSetTitle(const NewTitle: string);
begin
  { Set song title }
  FTitle := Trim(NewTitle);
end;

{ --------------------------------------------------------------------------- }

procedure TID3v2.FSetArtist(const NewArtist: string);
begin
  { Set artist name }
  FArtist := Trim(NewArtist);
end;

{ --------------------------------------------------------------------------- }

procedure TID3v2.FSetAlbum(const NewAlbum: string);
begin
  { Set album title }
  FAlbum := Trim(NewAlbum);
end;

{ --------------------------------------------------------------------------- }

procedure TID3v2.FSetTrack(const NewTrack: Word);
begin
  { Set track number }
  FTrack := NewTrack;
end;

{ --------------------------------------------------------------------------- }

procedure TID3v2.FSetYear(const NewYear: string);
begin
  { Set release year }
  FYear := Trim(NewYear);
end;

{ --------------------------------------------------------------------------- }

procedure TID3v2.FSetGenre(const NewGenre: string);
begin
  { Set genre name }
  FGenre := Trim(NewGenre);
end;

{ --------------------------------------------------------------------------- }

procedure TID3v2.FSetComment(const NewComment: string);
begin
  { Set comment }
  FComment := Trim(NewComment);
end;

{ --------------------------------------------------------------------------- }

procedure TID3v2.FSetComposer(const NewComposer: string);
begin
  { Set composer name }
  FComposer := Trim(NewComposer);
end;

{ --------------------------------------------------------------------------- }

procedure TID3v2.FSetEncoder(const NewEncoder: string);
begin
  { Set encoder name }
  FEncoder := Trim(NewEncoder);
end;

{ --------------------------------------------------------------------------- }

procedure TID3v2.FSetCopyright(const NewCopyright: string);
begin
  { Set copyright information }
  FCopyright := Trim(NewCopyright);
end;

{ --------------------------------------------------------------------------- }

procedure TID3v2.FSetOrigArtist(const NewOrigArtist: string);
begin
  { Set language }
  FOrigArtist := Trim(NewOrigArtist);
end;

{ --------------------------------------------------------------------------- }

procedure TID3v2.FSetLink(const NewLink: string);
begin
  { Set URL link }
  FLink := Trim(NewLink);
end;

{ ********************** Public functions & procedures ********************** }

constructor TID3v2.Create;
begin
  { Create object }
  inherited;
  ResetData;
end;

{ --------------------------------------------------------------------------- }

procedure TID3v2.ResetData;
begin
  { Reset all variables }
  FExists := false;
  FVersionID := 0;
  FSize := 0;
  FTitle := '';
  FArtist := '';
  FAlbum := '';
  FTrack := 0;
  FTrackString := '';
  FYear := '';
  FGenre := '';
  FComment := '';
  FComposer := '';
  FEncoder := '';
  FCopyright := '';
  FOrigArtist := '';
  FLink := '';
end;

{ --------------------------------------------------------------------------- }

function TID3v2.ReadFromFile(const FileName: string): Boolean;
var
  Tag: TagInfo;
begin
  { Reset data and load header from file to variable }
  ResetData;
  Result := ReadHeader(FileName, Tag);
  { Process data if loaded and header valid }
  if (Result) and (Tag.ID = ID3V2_ID) then
  begin
    FExists := true;
    { Fill properties with header data }
    FVersionID := Tag.Version;
    FSize := GetTagSize(Tag);
    { Get information from frames if version supported }
    if (FVersionID in [TAG_VERSION_2_2..TAG_VERSION_2_4]) and (FSize > 0) then
    begin
      if FVersionID > TAG_VERSION_2_2 then
        ReadFramesNew(FileName, Tag)
      else
        ReadFramesOld(FileName, Tag);
      FTitle := GetContent(Tag.Frame[1], Tag.Frame[15]);
      FArtist := GetContent(Tag.Frame[2], Tag.Frame[14]);
      FAlbum := GetContent(Tag.Frame[3], Tag.Frame[16]);
      FTrack := ExtractTrack(Tag.Frame[4]);
      FTrackString := GetANSI(Tag.Frame[4]);
      FYear := ExtractYear(Tag.Frame[5], Tag.Frame[13]);
      FGenre := ExtractGenre(Tag.Frame[6]);
      FComment := ExtractText(Tag.Frame[7], true);
      FComposer := GetANSI(Tag.Frame[8]);
      FEncoder := GetANSI(Tag.Frame[9]);
      FCopyright := GetANSI(Tag.Frame[10]);
      FOrigArtist := GetANSI(Tag.Frame[14]);
      FLink := ExtractText(Tag.Frame[12], false);
    end;
  end;
end;

{ --------------------------------------------------------------------------- }

constructor THIMP3_Info.Create;
begin
  inherited;
  FT := TID3v2.Create;  
end;

destructor THIMP3_Info.Destroy;
begin
   List.free;
   List_v2.free;
   FT.free;
   if Arr <> nil then dispose(Arr);   
   if Arr_v2 <> nil then dispose(Arr_v2);
   inherited;
end;    

procedure THIMP3_Info._work_doReadInfo;
var
  Buffer: array [1..128] of Char;
  FS: PStream;
  FileName: string;
  dt: TData;
  mt: PMT;
  i: integer; 
begin
  FileName := ReadString(_Data,_data_FileName,'');
  if not Assigned(List) then
    List := NewStrList
  else
    List.Clear;
  if not Assigned(List_v2) then
    List_v2 := NewStrList
  else
    List_v2.Clear;
    
  FS := NewReadFileStream(FileName);
  try
    FS.Seek(-128,spEnd);
    FS.Read(Buffer, 128);
    if Copy(Buffer, 1, 3) = 'TAG' then
    begin
      {Title  } List.Add( Copy(Buffer, 4,  30) );
      {Artist } List.Add( Copy(Buffer, 34, 30) );
      {Album  } List.Add( Copy(Buffer, 64, 30) );
      {Year   } List.Add( Copy(Buffer, 94, 4) );
      {Comment} List.Add( Copy(Buffer, 98, 30) );
      if _prop_Genre = 0 then
      {Genre  } List.Add( int2str(Ord(Buffer[128])) )
      else  
      {Genre  } List.Add( Genres[Ord(Buffer[128])] );
      {Track  } List.Add( int2str(Ord(Buffer[127])) );
      dtString(dt, List.Items[0]);
      mt := mt_make(dt);
      for i := 1 to List.Count - 1 do
        mt_string(mt, List.Items[i]);
      _hi_onEvent(_event_onReadInfo, dt);
      mt_free(mt);         
    end;
  finally
    FS.Free;
  end;

  if FT.ReadFromFile(FileName) then
  begin
    {Title     } List_v2.Add( FT.FTitle );
    {Artist    } List_v2.Add( FT.FArtist );
    {Album     } List_v2.Add( FT.FAlbum );
    {Year      } List_v2.Add( FT.FYear );
    {Comment   } List_v2.Add( FT.FComment );
    if _prop_Genre = 0 then
    {Genre     } List_v2.Add( FT.FGenre )
    else  
    {Genre     } List_v2.Add( Genres[str2int(FT.FGenre)] );
    {Track     } List_v2.Add( int2str(FT.FTrack) );
    {Composer  } List_v2.Add( FT.FComposer );
    {OrigArtist} List_v2.Add( FT.FOrigArtist );
    {Copyright } List_v2.Add( FT.FCopyright );
    {URL       } List_v2.Add( FT.FLink );
    {Encoder   } List_v2.Add( FT.FEncoder );
    dtString(dt, List_v2.Items[0]);
    mt := mt_make(dt);
    for i := 1 to List_v2.Count - 1 do
    mt_string(mt, List_v2.Items[i]);
    _hi_onEvent(_event_onReadInfoV2, dt);
    mt_free(mt);         
  end;
end;

function THIMP3_Info._Get;
var
  ind:integer;
begin
  ind := ToIntIndex(Item);
  if(ind >= 0)and(ind < List.Count)then
  begin
    Result := true;
    dtString(Val,List.Items[ind]);
  end
  else
    Result := false;
end;

function THIMP3_Info._Count;
begin
  Result := List.Count;
end;

function THIMP3_Info._Get_v2;
var
  ind:integer;
begin
  ind := ToIntIndex(Item);
  if(ind >= 0)and(ind < List_v2.Count)then
  begin
    Result := true;
    dtString(Val,List_v2.Items[ind]);
  end
  else
    Result := false;
end;

function THIMP3_Info._Count_v2;
begin
  Result := List_v2.Count;
end;

procedure THIMP3_Info._var_Tags;
begin
  if Arr = nil then
    Arr := CreateArray(nil, _Get, _Count, nil);
  dtArray(_Data, Arr);
end;

procedure THIMP3_Info._var_TagsV2;
begin
  if Arr_v2 = nil then
    Arr_v2 := CreateArray(nil, _Get_v2, _Count_v2, nil);
  dtArray(_Data, Arr_v2);
end;

end.