unit hiStreamPack;

interface

uses Kol,Share,Debug;

type
  THIStreamPack = class(TDebug)
   private
    st:PStream;
    procedure SetDataCount(const text:string);
   public

    _data_DataCount:array of THI_Event;
    onPack:THI_Event;

    constructor Create;
    destructor Destroy; override;
    procedure doPack(var _Data:TData; Index:word);
    procedure ResultStream(var _Data:TData; Index:word);
    property _prop_DataCount:string write SetDataCount;
  end;

implementation

constructor THIStreamPack.Create;
begin
   inherited;
   st := NewMemoryStream;
end;

destructor THIStreamPack.Destroy;
begin
   st.Free;
   inherited;
end;

procedure THIStreamPack.SetDataCount;
var lst:PStrList;
begin
  lst := NewStrList;
  lst.text := text;
  SetLength(_data_DataCount, lst.Count);
  lst.Free;
end;

procedure THIStreamPack.doPack;
var i,id:integer;
    sd:string;
    rd:real;
    bd:PBitmap;
    dt:TData;
    s1:PStream;
begin
    st.size := 0;
    for i := 0 to High(_data_DataCount) do
      begin
         dt := ReadData(_data, _data_DataCount[i]);
         st.write(dt.data_type, sizeof(dt.data_type));
         case dt.data_type of
           data_int: 
             begin 
               id := ToInteger(dt);
               st.write(id, sizeof(id));
             end;
           data_real:
             begin
               rd := ToReal(dt);
               st.write(rd, sizeof(rd));             
             end;
           data_str:
             begin
               sd := ToString(dt);
               id := Length(sd);
               st.write(id, sizeof(id));
               if id > 0 then
                 st.write(sd[1], id);
             end;
           data_bitmap:
             begin
               bd := ToBitmap(dt);
               bd.saveToStream(st);
             end;
           data_stream:
             begin
               s1 := ToStream(dt);
               s1.Position := 0;
               id := s1.size;
               st.write(id, sizeof(id));
               Stream2Stream(st, s1, s1.size);
             end;
         end;  
      end;
    st.Position := 0;
    _hi_onEvent(onPack, st);  
end;

procedure THIStreamPack.ResultStream;
begin
   dtStream(_Data, st);
end;

end.
