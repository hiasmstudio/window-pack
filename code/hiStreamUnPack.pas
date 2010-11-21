unit hiStreamUnPack;

interface

uses Kol,Share,Debug;

type
  THIStreamUnPack = class(TDebug)
   private
    FObjs:PList;
    FCount:integer;
    Datas:array of TData;
    
    procedure FreeList;
    procedure SetDataCount(const text:string); 
   public
    Stream:THI_Event;
    onUnPack:THI_Event;

    constructor Create;
    destructor Destroy; override;
    procedure doUnPack(var _Data:TData; Index:word);
    procedure _var_DataCount(var _Data:TData; Index:word);
    property _prop_DataCount:string write SetDataCount;
  end;

implementation

constructor THIStreamUnPack.Create;
begin
   inherited;
   FObjs := NewList;
end;

destructor THIStreamUnPack.Destroy;
begin
   FObjs.free;
   inherited;
end;

procedure THIStreamUnPack.SetDataCount;
var lst:PStrList;
begin
   lst := NewStrList;
   lst.Text := text;
   FCount := lst.Count;
   SetLength(Datas, FCount);
   lst.free;
end;

procedure THIStreamUnPack.FreeList;
var i:integer;
begin
   for i := 0 to FObjs.Count-1 do
     PObj(FObjs.Items[i]).free; 
   FObjs.Clear;
end;

procedure THIStreamUnPack.doUnPack;
var st:PStream;
    i,id:integer;
    sd:string;
    rd:real;
    bd:PBitmap;
    b:byte;
    s1:PStream;
begin
   FreeList;
   st := ReadStream(_Data, Stream);
   for i := 0 to FCount-1 do
     begin
       st.read(b, sizeof(b));
       case b of
         data_int:
           begin
             st.read(id, sizeof(id)); 
             dtInteger(Datas[i], id);
           end;
         data_str:
           begin
             st.read(id, sizeof(id)); 
             SetLength(sd, id);
             st.read(sd[1], id);
             dtString(Datas[i], sd);
           end;
         data_real:
           begin
             st.read(rd, sizeof(rd)); 
             dtReal(Datas[i], rd);
           end;
         data_bitmap: 
           begin
             bd := NewBitmap(0,0);
             bd.LoadFromStream(st);
             FObjs.Add(bd);
             dtBitmap(Datas[i], bd);
           end;
         data_stream: 
           begin
             s1 := NewMemoryStream;
             st.read(id, sizeof(id));
             Stream2Stream(s1, st, id);
             FObjs.Add(s1);
             s1.position := 0;
             dtStream(Datas[i], s1);
           end;  
       end;
     end; 
   _hi_onEvent(onUnPack, st);
end;

procedure THIStreamUnPack._var_DataCount;
begin
   _Data := Datas[index];
end;

end.
