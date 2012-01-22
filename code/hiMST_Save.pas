unit hiMST_Save;

interface
     
uses Kol, Share, Debug, hiMTStrTbl;

const
  LFCR = #13#10;
  
type
  THIMST_Save = class(TDebug)
  private
    Stream: PStream;
    _Dlm: Char;    
    procedure SaveToStream(var FS: PStream);
    procedure SetDlm(dlm:string);   
  public
    _prop_MSTControl: IMSTControl;

    _prop_FileName: string;
    _prop_SaveColProp,
    _prop_SaveColumn: boolean;
    _prop_SaveCheckBoxes: boolean;     

    _data_FileName,
    _event_onSave,
    _event_onSaveToStream: THI_Event;
    
    property _prop_Delimiter: string write SetDlm;
    constructor Create;
    destructor Destroy; override;
    procedure _work_doSave(var _Data: TData; Index: word);
    procedure _work_doSaveToStream(var _Data: TData; Index: word);
    procedure _var_Stream(var _Data: TData; Index: word);
    procedure _work_doDelimiter(var _Data: TData; Index: word);
        
  end;

implementation

procedure THIMST_Save.SetDlm;
begin
  if dlm = '' then
    _Dlm := ' '
  else  
    _Dlm := dlm[1];
end;

constructor THIMST_Save.Create;
begin
  inherited;
  Stream := NewMemoryStream; 
end;

destructor THIMST_Save.Destroy;
begin
  Stream.free;
  inherited;
end;

procedure THIMST_Save.SaveToStream;
var
  sControl: PControl;
  i: integer;
  s: string;
  d: PData;
  dt: TData;
begin
  if not Assigned(_prop_MSTControl) then exit;
  sControl := _prop_MSTControl.ctrlpoint;

  s := '';
  dtNull(dt);
  if (_prop_MSTControl.clistcount <> 0) and _prop_SaveColumn then
  begin
    if _prop_SaveColProp then
      for i := 0 to _prop_MSTControl.clistcount - 1 do
        s := s + _prop_MSTControl.clistitems(i) + _Dlm
    else
      for i := 0 to _prop_MSTControl.clistcount - 1 do
        s := s + sControl.LVColText[i] + _Dlm;   
    deleteTail(s, 1);
    s := s + LFCR;
    Fs.Write(s[1], length(s));
  end;

  if sControl.Count <> 0 then
  begin
    for i := 0 to sControl.Count - 1 do
    begin
      dt := _prop_MSTControl.getstring(i);
      d := @dt;
      if _prop_SaveCheckBoxes then
        s := int2str(sControl.LVItemStateImgIdx[i] - 1) + _Dlm
      else   
        s := '';
      while (d <> nil) and not _IsNULL(d^) do
      begin
        s := s + ToString(d^) + _Dlm;
        d := d.ldata;
      end;  
      deleteTail(s, 1);
      s := s + LFCR;
      Fs.Write(s[1], length(s));
    end;
  end
  else
  begin
    s := '';
    Fs.Write(s[1], length(s));    
  end;  
end; 

procedure THIMST_Save._work_doSave;
var
  Strm: PStream;
begin
  Strm := NewWriteFileStream(ReadString(_Data,_data_FileName,_prop_FileName));
  SaveToStream(Strm);
  Free_And_Nil(Strm);
  _hi_onEvent(_event_onSave);
end;

procedure THIMST_Save._work_doSaveToStream;
begin
  Stream.Size := 0;
  SaveToStream(Stream);
  Stream.Position := 0;
  _hi_onEvent(_event_onSaveToStream, Stream);
end;

procedure THIMST_Save._var_Stream;
begin
  dtStream(_Data, Stream);
end;

procedure THIMST_Save._work_doDelimiter;
begin
  SetDlm(ToString(_Data));
end;

end.