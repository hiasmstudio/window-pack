unit hiGentee;

interface

uses Kol,Share,Debug,GenteeShare;

type
  THIGentee = class(TDebug)
   private
     bcode: Tbcode;
     FECount,FDCount:PStrList;
     WP,VP:PStrListEx;
     FError:integer;
     FEList:string;

     procedure SetEvent(const value:string);
     procedure SetData(const value:string);
     procedure SetWP(const value:string);
     procedure SetVP(const value:string);
     procedure SetScript(const value:string);

     procedure Init;
   public
     _prop_ErrorMask:string;
     _prop_PromtMask:string;
     _prop_Code:string;

     _event_EventPoints:array of THI_Event;
     _data_DataPoints:array of THI_Event;

     constructor Create;
     destructor Destroy; override;

     procedure onMessage(mess: pTmess);

     function _on_Event(Index:word; Data:PData):PData;
     function ReadData(Index:word; Data:PData):PData;

     procedure _work_WorkPoints(var Data:TData; Index:word);
     procedure _var_VarPoints(var Data:TData; Index:word);

     property _prop_EventPoints:string write SetEvent;
     property _prop_DataPoints:string write SetData;
     property _prop_WorkPoints:string write SetWP;
     property _prop_VarPoints:string write SetVP;
  end;

implementation

type
  TGateGTProc = packed record
    Code1:byte; //push ebp
    Code2:word; //mov ebp,esp
    Data_1,Data_2,Data_3:byte; //push dword ptr[ebp+0x08]
    Code3:byte; //push
    Index:cardinal;
    Code4:byte; //push
    this:cardinal;
    Code5:byte; //mov eax
    proc:cardinal;
    Code6:word; //call eax
    Code8:byte; //pop ebp
    Code9_1,Code9_2,Code9_3:byte; //ret 0x0004
  end;
  TProc = procedure(Data:pointer); stdcall;

var GateGTProc:TGateGTProc =
   (Code1:$55;
    Code2:$EC8B;
    Data_1:$FF;Data_2:$75;Data_3:$08;
    Code3:$68;Index:$0;
    Code4:$68;this:$0;
    Code5:$B8;proc:$0;
    Code6:$D0FF;
    Code8:$5D;
    Code9_1:$C2;Code9_2:$04;Code9_3:$00);

var Gentee:THIGentee;
    gtMashine:integer;

function exporttogentee( str: PChar ): pointer; stdcall; forward;
function messagefunc( mess: pTmess ): integer; stdcall; forward;

constructor THIGentee.Create;
begin
   inherited;

   if gtMashine = 0 then
     gtMashine := shell_ge_init( GEF_VM, messagefunc, nil, exporttogentee );

   FError := -1;
   InitAdd(Init);
end;

destructor THIGentee.Destroy;
begin
   if gtMashine > 0 then
    begin
      shell_ge_deinit( gtMashine );
      gtMashine := 0;
    end;
   VP.Free;
   WP.Free;
   FECount.Free;
   FDCount.Free;
   inherited;
end;

procedure THIGentee.Init;
begin
   SetScript(_prop_Code);
end;

//_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+

procedure THIGentee.SetEvent;
var i:integer;
begin
   FECount := NewStrList;
   FECount.text := Value;
   SetLength(_event_EventPoints,FECount.Count);

   FError := -1;
   for i := 0 to FECount.Count-1 do
    if FECount.Items[i] = '##onError' then
     FError := i;
end;

procedure THIGentee.SetData;
begin
   FDCount := NewStrList;
   FDCount.text := Value;
   SetLength(_data_DataPoints,FDCount.Count);
end;

procedure THIGentee.SetWP;
begin
   WP := NewStrListEx;
   WP.Text := Value;
end;

procedure THIGentee.SetVP;
begin
   VP := NewStrListEx;
   VP.Text := Value;
end;

function THIGentee._on_Event;
begin
   if Data = nil then
     _hi_OnEvent(_event_EventPoints[Index])
   else _hi_OnEvent(_event_EventPoints[Index],Data^);
   Result := nil;
end;

function THIGentee.ReadData;
begin
  if Data = nil then
   begin
    new(Data);
    dtNull(Data^);
   end;
  _ReadData(Data^,_data_DataPoints[Index]);
  Result := Data;
end;

procedure _gt_onEvent( Index:cardinal; Data:PData ); stdcall;
begin
   Gentee._on_Event(Index,Data);
end;

function _gt_ReadData( Index:cardinal; Data:PData ):PData; stdcall;
begin
   Gentee.ReadData(Index,Data);
   Result := Data;
end;

function _gt_ToInteger( Value:integer ):pointer; stdcall;
var dt:^TData;
begin
    new(dt);
    FillChar(dt^,sizeof(TData),0);
    dtInteger(dt^,Value);
    Result := dt;
end;

function _gt_ToString( Value:PChar ):pointer; stdcall;
var dt:^TData;
begin
    new(dt);
    FillChar(dt^,sizeof(TData),0);
    dtString(dt^,Value);
    Result := dt;
end;

function _gt_ToReal( Value:real ):pointer; stdcall;
var dt:^TData;
begin
    new(dt);
    FillChar(dt^,sizeof(TData),0);
    dtreal(dt^,Value);
    Result := dt;
end;

procedure _gt_FreeData(Data:PData); stdcall;
begin
   dispose(Data);
end;

function _gt_ReadInt(Value:pointer):integer; stdcall;
begin
   Result := ToInteger(PData(Value)^);
end;

function _gt_ReadStr(Dest:PChar; Source:PData):PChar; stdcall;
begin
   //StrCopy(Dest,PChar(ToString(Source^)));
   //Result := PChar(@buf);
end;

function _gt_ReadReal(Value:pointer):real; stdcall;
begin
   Result := ToReal(PData(Value)^);
end;

function main_eproc(cls:THIGentee;Index:integer; Data:PData ):PData;stdcall;
begin
   Result := cls._on_Event(Index,Data);
end;

procedure main_dproc(cls:THIGentee;Index:integer; Data:PData );stdcall;
begin
   cls.ReadData(Index,Data);
end;

function MakeGTEvent(Index:cardinal; cls:pointer):pointer;
var g:^TGateGTProc;
begin
   new(g); ///!!!!!!! temporary
   g^ := GateGTProc;
   g.Index := Index;
   g.this := cardinal(cls);
   g.proc := cardinal(@main_eproc);
   Result := g;
end;

function MakeGTData(Index:cardinal; cls:pointer):pointer;
var g:^TGateGTProc;
begin
   new(g); ///!!!!!!! temporary --> FreeData
   g^ := GateGTProc;
   g.Index := Index;
   g.this := cardinal(cls);
   g.proc := cardinal(@main_dproc);
   Result := g;
end;

function exporttogentee( str: PChar ): pointer; stdcall;
var i:integer;
begin
   if StrIComp( str, 'onEvent' ) = 0 then
      result := @_gt_onEvent
   else if StrIComp( str, 'ToInt' ) = 0 then
      result := @_gt_ToInteger
   else if StrIComp( str, 'ToStr' ) = 0 then
      result := @_gt_ToString
   else if StrIComp( str, 'ToReal' ) = 0 then
      result := @_gt_ToReal
   else if StrIComp( str, 'FreeData' ) = 0 then
      result := @_gt_FreeData
   else if StrIComp( str, 'ReadInt' ) = 0 then
      result := @_gt_ReadInt
   else if StrIComp( str, 'copy' ) = 0 then
      result := @_gt_ReadStr
   else if StrIComp( str, 'ReadReal' ) = 0 then
      result := @_gt_ReadReal
   else
    begin
      for i := 0 to Gentee.FECount.Count-1 do
       if StrIComp( PChar(Gentee.FECount.Items[i]), str ) = 0 then
        begin
          result := MakeGTEvent(i,Gentee);
          exit;
        end;
      for i := 0 to Gentee.FDCount.Count-1 do
       if StrIComp( PChar(Gentee.FDCount.Items[i]), str ) = 0 then
        begin
          result := MakeGTData(i,Gentee);
          exit;
        end;
      result := nil;
    end;
end;

function messagefunc( mess: pTmess ): integer; stdcall;
begin
   Gentee.onMessage(Mess);
   Result := 0;
end;

procedure THIGentee.onMessage;
var s:string;
begin
   if mess.iscompile = 1 then
     s := _prop_ErrorMask
   else s := _prop_PromtMask;
   Replace(s,'%l',int2str(mess.line));
   Replace(s,'%p',int2str(mess.pos));
   Replace(s,'%c',int2str(mess.code));
   Replace(s,'%m',mess.text);
   FEList := FEList + s;
end;

procedure THIGentee.SetScript;
var
    progtext, nametext: PChar;
    flgcompile: integer;    
    i:integer;
begin
   Gentee := self;
   if gtMashine <> 0 then
    begin
      progtext := AllocMem( length( Value ) + 1 );
      StrPCopy( progtext, Value );
      
      ge_freebcode( @bcode );
      flgcompile := ge_compile( progtext, '', @bcode, 0, Nil );

      FreeMem( progtext );
      if flgcompile = 1 then
        begin
          ge_load( bcode.data, {GLOAD_ENTRY}GLOAD_MAIN, Nil );
          for i := 0 to WP.Count-1 do
           WP.Objects[i] := ge_getid( PChar(WP.Items[i]) );
          for i := 0 to VP.Count-1 do
           VP.Objects[i] := ge_getid( PChar(VP.Items[i]) );
        end;
    end
   else FEList := 'Gentee.dll not found';
   if FError <> -1 then
     _hi_onEvent(_event_EventPoints[FError],FEList);
   FEList := '';
end;

procedure THIGentee._work_WorkPoints(var Data:TData; Index:word);
var idfunc: cardinal;
    res: cardinal;
begin
   if StrIComp(PChar(WP.Items[Index]),'##SetCode') = 0 then
    begin
      SetScript(ToString(Data));
    end
   else
    begin
     if gtMashine = 0 then exit;

     idfunc := WP.Objects[Index];
     if idfunc <> 0 then
       ge_call( idfunc, @res , @Data );
    end;
end;

procedure THIGentee._var_VarPoints(var Data:TData; Index:word);
var idfunc: cardinal;
    dt:^TData;
begin
   if gtMashine = 0 then exit;

   idfunc := VP.Objects[Index];
   if idfunc <> 0 then
     begin
       ge_call( idfunc, @dt, @Data );
       Data := dt^;
       dispose(dt);
     end
    else dtNull(Data);
end;

end.
