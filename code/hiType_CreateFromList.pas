unit hiType_CreateFromList;

interface

uses Kol,Share,Debug;

type
  THIType_CreateFromList = class(TDebug)
   private
    fName:string;
    TypeV:PType;
    
    procedure SetName(val:string);
    procedure SetType(s:boolean);
   public
    _prop_DefData:TData;

    _data_VarsList:THI_Event;
    _event_onCreate:THI_Event;

    constructor Create;
    destructor Destroy; override;
    procedure _work_doCreate(var _Data:TData; Index:word);
    procedure _work_doClear(var _Data:TData; Index:word);
    procedure _work_doName(var _Data:TData; Index:word);
    procedure _var_FType(var _Data:TData; Index:word);
    
    property _prop_Name:string read fName write SetName;
    property _prop_StorageType:boolean write SetType;
  end;

implementation

constructor THIType_CreateFromList.Create;
begin
  inherited Create;
end;

destructor THIType_CreateFromList.Destroy;
begin
  TypeV.Free;
  inherited Destroy;
end;

procedure THIType_CreateFromList.SetType;
begin
  if s then TypeV := NewStorageType else TypeV := NewType;
  TypeV.name := #0;
end;

procedure THIType_CreateFromList.SetName;
begin
  fName := LowerCase(val);
end;

procedure THIType_CreateFromList._work_doCreate;
var i:integer;
    nm,itm:string;
    Varsl:PStrList;
    dt:TData;
begin
  Varsl := NewStrList;
  TypeV.Clear;
  TypeV.name := #0;
  Varsl.Text := ReadString(_Data,_data_VarsList,'');
  if Varsl.Count > 0 then begin
    TypeV.name := fname;
    for i := 0 to Varsl.Count-1 do begin
      itm := Varsl.Items[i];
      if pos('=',itm) > 0 then begin
        nm := GetTok(itm,'=');
        if _prop_DefData.data_type <> data_null then dt := _prop_DefData
          else if itm <> '' then dtString(dt,itm) else dtNull(dt);
        TypeV.Add(LowerCase(nm),@dt);
      end else begin
        if _prop_DefData.data_type <> data_null then dt := _prop_DefData else dtNull(dt);
        TypeV.Add(LowerCase(Varsl.Items[i]),@dt);
      end;
    end;
  end;
  Varsl.Free;
  _hi_onEvent(_event_onCreate,TypeV);
end;

procedure THIType_CreateFromList._work_doClear;
begin
  TypeV.Clear;
end;

procedure THIType_CreateFromList._work_doName;
begin
  SetName(ToString(_data));
  if TypeV.name <> #0 then TypeV.name := _prop_name;
end;

procedure THIType_CreateFromList._var_FType;
begin
  dtType(_Data,TypeV);
end;

end.
