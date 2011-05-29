unit hiType_Save;

interface

uses Kol,Share,Debug;

//{$define TYPES_XML_ENABLED} //mega-beta

type
  THIType_Save = class(TDebug)
   private
    st:PStream;
    
    procedure Type2Stream(typ:PType; lst:PStream);
    {$ifdef TYPES_XML_ENABLED}procedure Type2XML(typ:PType; lst:PStream);{$endif}
   public
    _prop_FileName:string;
    _prop_StreamFormat:byte;

    _data_GType:THI_Event;
    _data_FileName:THI_Event;
    
    _event_onError:THI_Event;
    _event_onSave:THI_Event;

    constructor Create;
    destructor Destroy; override;
    procedure _work_doSave(var _Data:TData; Index:word);
    procedure _work_doClear(var _Data:TData; Index:word);
    procedure _var_ResStream(var _Data:TData; Index:word);
  end;

implementation

function MT_Length(dt:PData):byte;
begin
  Result := 0;
  if dt <> nil then
    repeat
      inc(Result);
      dt := dt.ldata;
    until dt = nil;
end;

procedure THIType_Save.Type2Stream;
var i:integer;
    id:byte;
    sd:string;
    dt:TData;
 
 procedure WInd(sst:PStream; typ:PType);
 var i:byte;
 begin
   i := data_types;
   sst.write(i,sizeof(i));
   i := byte(typ^ is TStorageType); //get class type
   sst.write(i, sizeof(i)); //write class type
   i := length(typ.name);
   sst.write(i,sizeof(i));
   sst.write(typ.name[1],i);
 end;
 
 procedure WVar(sst:PStream; dat:PData);
 var id:integer;
     rd:real;
     sd:string;
     bd:PBitmap;
     s1:PStream;
     tp:PType;
 begin
   case dat.data_type of
    data_int: 
      begin 
       id := ToInteger(dat^);
       sst.write(id,sizeof(id));
      end;
    data_real:
      begin
       rd := ToReal(dat^);
       sst.write(rd,sizeof(rd));             
      end;
    data_str:
      begin
       sd := ToString(dat^);
       id := Length(sd);
       sst.write(id, sizeof(id));
       if id > 0 then sst.write(sd[1],id);
      end;
    data_bitmap:
      begin
       bd := ToBitmap(dat^);
       if bd <> nil then bd.saveToStream(sst);
      end;
    data_stream:
      begin
       s1 := ToStream(dat^);
       if s1 <> nil then id := s1.size else id := 0;
       sst.write(id, sizeof(id));
       if id > 0 then begin
         s1.Position := 0;
         Stream2Stream(sst,s1,s1.size);
       end;
      end;
    data_types:
      begin
       s1 := NewMemoryStream;
       tp := ToTypes(dat^);
       Type2Stream(tp,s1);
       s1.position := 0;
       id := s1.size;
       sst.write(id, sizeof(id));
       Stream2Stream(sst,s1,s1.size);
       s1.Free;
      end;
   end;
   if (dat.data_type <> data_null) and (dat.ldata <> nil) then begin
     lst.write(dat.ldata.data_type, sizeof(dat.ldata.data_type));
     WVar(sst,dat.ldata); //Write MT-Thread
   end;
 end;
begin
  lst.size := 0;
  if typ <> nil then begin
    WInd(lst,typ);
    for i := 0 to typ.count-1 do begin
      sd := typ.NameOf[i];
      
      dt := typ.data[i]^;
      id := MT_Length(@dt);
      lst.write(id,sizeof(id));

      id := length(sd);
      lst.write(id,sizeof(id));
      lst.write(sd[1],id);
      
      lst.write(dt.data_type, sizeof(dt.data_type));
      WVar(lst,@dt);  
    end;
  end else CallTypeError('',_event_onError,TYPE_ERR_INVALID_TYPE);
end;

{$ifdef TYPES_XML_ENABLED}
procedure THIType_Save.Type2XML;
var list:string;

 function ReplaceSign(s:string):string;
 begin
   Replace(s,'&','&amp;');
   Replace(s,'<','&lt;');
   Replace(s,'>','&gt;');
   Result := s;
 end;
    
 procedure WVar(typ:PType; list:PStrList; offset:string);
 var s,str:string;
     i,n:integer;
     dt:PData;
     tp:PType;
 begin
   for i := 0 to typ.count-1 do begin
     dt := typ.data[i];
     s := ReplaceSign(typ.NameOf[i]);
     n := list.Add(offset + '<' + s + '>');
     case dt.data_type of
       data_types:
         begin
           while dt <> nil do begin
             if dt.data_type = data_types then begin
               tp := ToTypes(dt^);
               str := ReplaceSign(tp.name);
               list.add(offset + #9 + '<' + str + '>');
               WVar(tp,list,offset + #9 + #9);
               list.add(offset + #9 + '</' + str + '>');
               dt := dt.ldata;
             end; //TO DO: else OnError
           end;
           list.add(offset + '</' + s + '>');
         end;
     else
       list.items[n] := list.items[n] + ReplaceSign(ToString(dt^)) + '</' + s + '>';
     end;
   end;
 end;
 
begin
  if typ <> nil then begin
    list := NewStrList;
    s := ReplaceSign(typ.name);
    list.add('<' + s + ' ');
    WVar(typ,list,#9);
    list.add('</' + s + '>');
    s := list.Text;
    list.Free;
    lst.Write(s[1],length(s));
  end;
end;
{$endif}

constructor THIType_Save.Create;
begin
  inherited;
  st := NewMemoryStream;
end;

destructor THIType_Save.Destroy;
begin
  st.Free;
  inherited;
end;

procedure THIType_Save._work_doClear;
begin
  st.size := 0;
end;

procedure THIType_Save._work_doSave;
var typ:PType;
    fn,s:string;
    s1:PStream;
    i:integer;
    list:PStrList;
begin
  st.size := 0;
  typ := ReadType(_Data,_data_GType);
  fn := ReadString(_Data,_data_FileName,_prop_FileName);
  if _prop_StreamFormat = 0 then begin
    if fn = '' then begin
      Type2Stream(typ,st);
      st.Position := 0;
      _hi_onEvent(_event_onSave,st);
    end else begin
      s1 := NewWriteFileStream(fn);
      Type2Stream(typ,s1);
      s1.Free;
      _hi_OnEvent(_event_onSave);
    end;
  end else if _prop_streamFormat = 1 then begin
    list := NewStrList;
    if typ <> nil then begin
      list.text := '[' + int2str(integer(typ^ is TStorageType)) + typ.name + ']';
      for i := 0 to typ.count-1 do 
        list.add(typ.NameOf[i] + '=' + ToString(typ.data[i]^));
    end else CallTypeError('',_event_onError,TYPE_ERR_INVALID_TYPE);
    if fn = '' then begin
      if list.text <> '' then begin
        s := list.text;
        st.write(s[1],length(s));
      end;
      list.Free;
      _hi_onEvent(_event_onSave,st);
    end else begin
      list.SaveToFile(fn);
      list.Free;
      _hi_onEvent(_event_onSave);
    end;
  end{$ifdef TYPES_XML_ENABLED} else begin
    if fn = '' then begin
      Type2XML(typ,st);
      st.Position := 0;
      _hi_onEvent(_event_onSave,st);
    end else begin
      s1 := NewWriteFileStream(fn);
      Type2XML(typ,s1);
      s1.Free;
      _hi_OnEvent(_event_onSave);
    end;  
  end{$endif};
end;

procedure THIType_Save._var_ResStream;
begin
  dtStream(_Data,st);
end;

end.
