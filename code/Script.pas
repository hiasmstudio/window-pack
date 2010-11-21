 unit Script;

interface

{$define _is_hiasm}

{$ifdef _is_hiasm}
 {$i share.inc}
{$endif}

uses kol,{$ifndef _is_hiasm}Element,HConst{$else}Share{$endif};

type
  TRealFuncArg = array of PData;
  TRealFuncBody = function (Args:TRealFuncArg):TData of object;

  TDataArray = array[0..0] of TData;

  TVarsItem = record
        Name:string;
        Value:TData;
        Flag:byte;
      end;
  TVars = class
    public
      Table:array of TVarsItem;
      Count:word;
      FindIndex:word;

      constructor Create;
      destructor Destroy; override;
      function Find(const Name:string):boolean;
      function AddVar(const Name:string; _Flag:Byte):word;
      procedure Clear;
      procedure Delete(Index:smallint);
  end;

  TArgsItem = record
        Name:string;
        Value:PData;
        CallType:byte;
      end;
  TArgs = class
    public
      Table:array of TArgsItem;
      Count:word;
      FindIndex:word;

      constructor Create;
      function Find(const Name:string):boolean;
      function AddVar(const Name:string; CallType:byte):word;
      procedure Clear;
  end;
  TCodeUnit = record
       CmdType:byte;
       Cmd:smallint;
     end;
  TBody = class
    public
     Code:array of TCodeUnit;
     Count:word;

     procedure AddCode(_CmdType:Byte; _Cmd:smallint);
  end;
  TArray = class
    public
     Count:integer;
     Items:array of TData;

     destructor Destroy; override;
     procedure SetSize(FCount:integer);
     procedure SetType(_Type:byte);
  end;
  TFuncItem = record
       Name:string;
       Args:TArgs;
       Body:TBody;
       Vars:TVars;
       Hint:string;
      end;
  TFunc = class
    public
      Items:array of TFuncItem;
      Count:word;
      Vars:TVars;
      Args:TArgs;
      Body:TBody;
      FindIndex:word;
      InFunc:boolean;

      function Find(const Name:string):boolean;
      procedure Add(const _Name:string);
      function AddCode(_CmdType:Byte; _Cmd:smallint):word;
      procedure Clear;
  end;
  TRFuncItem = record
       Name:string;
       Args:TArgs;
       Body:TRealFuncBody;
       Hint:string;
      end;
  TRFunc = class
    public
      Items:array of TRFuncItem;
      Count:word;
      FindIndex:word;

      function Find(const Name:string):boolean;
      procedure Add(const _Name:string; FBody:TRealFuncBody; FArgs:array of string);
  end;
  PFuncItem = ^TFuncItem;
  TStack = class
    private
      Items:array of record
        Value:PData;
        Src:byte; {0 - temp, 1 - other}
      end;
      Count:word;

      FTmpBuf:array[0..2] of PData;
      FBufInd:byte;
    public
      RFunc:PFuncItem;

      constructor Create;
      procedure Push(Value:PData; Source:byte );
      function Pop:PData;
      procedure Clear;
      function LastVar:PData;
      function Temp:PData;
      procedure Flush;
  end;
  TBlockStack = class
    private
      Items:array of record
         LType:word;
         Value:smallint
      end;
      Count:word;
    public
      procedure Push(_Value:smallint;_LType:word );
      function Pop(var _Value:smallint;var _LType:word ):boolean;
      procedure Clear;
  end;
  TDef = class
    public
      Items:array of record
        Name:string;
        Value:TData;
      end;
      Count:word;
      FindIndex:word;

      function Find(const Def:string):boolean;
      function Replace(var TokType:byte):string;
      procedure Add(const Name:string;Value:integer); overload;
      procedure Add(const Name:string;const Value:string); overload;
  end;
  TVarProc = function(const Val:TData):TData of object;
  TOOP_Obj = class
    private
      procedure Add(const Name:string; MType:byte);
    public
      Items:array of record
        Name,Hint:string;
        MType:byte;
        Body:TRealFuncBody;
        Args:TArgs;
      end;
      Count:word;
      FindIndex:word;

      function Find(const Name:string):boolean;
      procedure AddMethod(const Name:string; _Body:TRealFuncBody; FArgs:array of string );
      procedure AddVar(const Name:string; _Var:TRealFuncBody);
      procedure AddProperty(const Name:string; _Proc:TRealFuncBody);
  end;
  TOOPItem = record
    Name,Hint:string;
    Obj:TOOP_Obj;
  end;
  POOPItem = ^TOOPItem;
  TOOP = class
    public
      Items:array of TOOPItem;
      Count:word;
      FindIndex:word;

      function Find(const Name:string):boolean;
      function Add(const Name:string):POOPItem;
      procedure AddItem(Item:POOPItem);
  end;

  
  PVarItem = ^TVarsItem;
  TScript = class
    private
      Vars:TVars;

      Line:string;
      LineIndex:word;
      Lines:PStrList;
      Err:PStrList;
      LPos:word;
      Token,RToken:string;
      TokType:byte;
      MathResult:byte;

      
      BlockStack:TBlockStack;

      procedure ClearAll;

      function ReadLine:boolean;
      function AddError(Error:string; Next:boolean = false):boolean;
      procedure Start;
      function GetToken:boolean;
      procedure PutToken;

      function RunFunc(Stack:TStack):TData;
      procedure ExecOp(Stack:TStack; var Index:word; OpType:word);
      function ExecuteFunction(Stack:TStack; Body:TRealFuncBody; Args:TArgs):TData;
      procedure ExecFunc(Stack:TStack; FReal:byte; FuncIndex:word);
      procedure ExecOop(Stack:TStack; OType:byte; FuncIndex:word);
      function BuildVar( const Code:TCodeUnit ):PVarItem;
      procedure PutVar(Stack:TStack; const Code:TCodeUnit );
      procedure CalcMath(OpType:word;Result,Op1,Op2:PData );
      function CalcCmp(OpType:word;Op1,Op2:PData ):boolean;
      procedure MoveOp(Op1,Op2:PData);

      function Level1:boolean;
      function Level2:boolean; // or
      function Level3:boolean; // and
      function Level3_1:boolean; // is
      function Level4:boolean; // < > = >= <= <>
      function Level5:boolean; // + -
      function Level6:boolean; // / *
      function Level7:boolean; // unar + - not
      function Level8:boolean; // []
      function Level9:boolean; // (

      procedure EndLexem;
      procedure AddFunction;

      procedure CallFunc(Init:boolean = true);
      procedure CallLRFunc(Init:boolean = true);
      procedure CallRFunc(Init:boolean = true);

      procedure CallOOP(OType:byte; Init:boolean = true);
      procedure ReadFuncArgs(Args:TArgs);
      procedure VarInit;
      procedure IfLexem;
      procedure ElseLexem;
      procedure EndIfLexem;
      procedure ForLexem;
      procedure NextLexem;
      procedure BreakLexem;
      procedure ExitDo;
      procedure ExitLexem;
      procedure ReturnLexem;
      procedure DoLexem;
      procedure LoopLexem;
      procedure SelectLexem;
      procedure CaseLexem;
      procedure EndCaseLexem;
      procedure DimLexem(Check:boolean = true);
      procedure ReDimLexem;
      procedure AddrLexem;
      function  CodeName(FuncFind:boolean = true):TCodeUnit;
    public
      Funcs:TFunc;
      LocRFuncs:TRFunc;
      CurFunc:record
         x,y:word;
         Number:smallint;
      end;
      Text:string;
      Oop:TOOP;

      constructor Create;
      destructor Destroy; override;
      procedure Build(List:PStrList;var Error:PStrList);
      procedure BuildFromText(var Err:PStrList);
      function Run(const FuncName:string; _Args:array of PData):TData;

      procedure SaveToStream(Stream:PStream);
      procedure LoadFromStream(Stream:PStream);

      procedure ScriptDebug(List:PStrList);
  end;

var
   Def:TDef;
   RFuncs:TRFunc;
   Types:PStrList;
   GOop:TOOP;

implementation

uses Functions{$ifndef _is_hiasm}, SysUtils{$endif};

const
  TokName = 1;
  TokNumber = 2;
  TokReal = 3;
  TokString = 4;
  TokSymbol = 5;
  TokMath = 6;

  cmdIf    = 1;
  cmdElse  = 2;
  cmdEndIf = 3;
  cmdFor   = 4;
  cmdNext  = 5;
  cmdMath1 = 6; // +
  cmdMath2 = 7; // -
  cmdMath3 = 8; // *
  cmdMath4 = 9; // /
  cmdMath5 = 10; // unar -
  cmdOr    = 11;
  cmdAnd   = 12;
  cmdCmp1  = 13; // >
  cmdCmp2  = 14; // <
  cmdCmp3  = 15; // >=
  cmdCmp4  = 16; // <=
  cmdCmp5  = 17; // <>
  cmdCmp6  = 18; // =
  cmdOp1   = 19; // =
  cmdInc   = 20; // ++
  cmdNot   = 21;
  cmdPop   = 22;
  cmdOp2   = 23; // +=
  cmdOp3   = 24; // -=
  cmdOp4   = 25; // *=
  cmdOp5   = 26; // /=
  cmdCmp7  = 27; // in [..]
  cmdIs    = 28; // +0 - null|+ 1 - int|+ 2 - str|+ 3 - real
  cmdArray = 32; // set array length
  cmdArInd = 33;
  cmdExit  = 34;
  cmdAddr  = 35; //@

  offVar    = 1;
  offArg    = 2;
  offGVar   = 3;
  offOp     = 4;
  offFunc   = 5;
  offLRFunc = 6;
  offRFunc  = 7;
  offOOP    = 8;
  offStack  = 9;
  offGOOP  = 10;

  IS_VAR   = 1;
  IS_CONST = 2;
  IS_LABEL = 4;
  IS_FUNC  = 8;
  IS_ARRAY = 16;

  ByVal = 1;
  ByRef = 2;

procedure TScript.ScriptDebug(List:PStrList);
const OpNames:array[1..34]of string =
    ('If','jmp','EndIf','For','Next','+','-','*','/','-',
     'Or','And','>','<','>=','<=','<>','=','=','Inc','Not','Pop',
     '+=','-=','*=','/=','[..]','Is null','is int','is str','is real',
     'ReDim','[]','Exit');
var i,j:word;
    s:string;
    LItems:array of record
      Name:string;
      Pos:word;
    end;
    LCount:word;
    function ReadVal(const Val:TVarsItem):string;
    begin
       if Val.Name <> '' then
         Result := Val.Name
       else
        case Val.Value.Data_type of
         0: Result := 'NULL';
         1: Result := int2str(Val.Value.idata);
         2: Result := '"' + Val.Value.sdata + '"';
         3: Result := double2str(Val.Value.rdata);
        end;
    end;
    procedure AddL(Index:word);
    var i:byte;
    begin
       if LCount > 0 then
        for i := 0 to LCount-1 do
         if LItems[i].Pos = Index+1 then
           begin
             s := s + LItems[i].Name + ',';
             Exit;
           end;

        inc(LCount);
        SetLength(LItems,LCount);
        LItems[LCount-1].Name := '@' + int2str(LCount);
        LItems[LCount-1].Pos := Index + 1;
        s := s + LItems[LCount-1].Name + ',';
    end;
    procedure CheckL(Index:word);
    var i:byte;
    begin
       if LCount > 0 then
        for i := 0 to LCount-1 do
         if LItems[i].Pos = Index then
          begin
           List.Add( LItems[i].Name + ':' );
           Break;
          end;
    end;
begin
    if Funcs.Count > 1 then
     for i := 1 to Funcs.Count-1 do
      with Funcs.Items[i] do
       begin
         LCount := 0;
         for j := 0 to Body.Count-1 do
          //if Body.Code[j] < offArg then
          with Body.Code[j] do
           if CmdType = offVar then
            if Vars.Table[Cmd].Flag = IS_LABEl then
              AddL(Vars.Table[Cmd].Value.idata);
         List.Add(':::::::::' + Name + ':::::::::');
         s := '     ';
         for j := 0 to Body.Count-1 do
         begin
          CheckL(j);
          with Body.Code[j] do
          case CmdType of
           offVar:
              if Vars.Table[Cmd].Flag = IS_LABEl then
                AddL(Vars.Table[Cmd].Value.idata)
              else s := s + ReadVal(Vars.Table[Cmd]) + ',';
           offArg: s := s + Args.Table[Cmd].Name + ',';
           offGVar: s := s + ReadVal(Self.Vars.Table[Cmd]) + ',';
           offOp:
             begin
               List.Add(s + ' ' +  OpNames[Cmd]);
               s := '     ';
             end;
           offFunc:  s := s + Funcs.Items[cmd].Name;
           offLRFunc: s := s + LocRFuncs.Items[Cmd].Name;
           offRFunc: s := s + RFuncs.Items[Cmd].Name;
           offStack: s := s + '[stack],';
           offOOP:
             begin
               List.Add( s + ' ' + Oop.Items[Cmd].Hint);
               s := '     ';
             end;
          end;
         end;
         CheckL(j);
       end;
end;

constructor TStack.Create;
begin
   inherited Create;
end;

procedure TStack.Push;
begin
   inc(Count);
   SetLength(Items,Count);
   Items[Count-1].Value := Value;
   Items[Count-1].Src := Source;
end;

function TStack.Pop;
begin
   if count = 0 then
     begin
      ShowMessage('Stack failed!');
      exit;
     end;
   dec(Count);
   Result := Items[Count].Value;
   if Items[Count].Src = 0 then
    begin
      if FBufInd = 3 then
        ShowMessage('Stack overfull!');
      FtmpBuf[FBufInd] := Result;
      inc(FBufInd);
    end;
end;

procedure TStack.Clear;
begin
   Count := 0;
   SetLength(items,Count);
   Flush;
end;

function TStack.LastVar;
begin
   Result := Items[ Count-1 ].Value;
end;

function TStack.Temp;
begin
   Push(nil,0);
   new(Result);
   Result.Data_type := 0;
   Items[ Count-1 ].Value := Result;
end;

procedure TStack.Flush;
begin
   while FBufInd > 0 do
    begin
     dec(FBufInd);
     Dispose(FtmpBuf[FBufInd]);
    end;
end;

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
procedure TBlockStack.Push;
begin
   inc(Count);
   SetLength(Items,Count);
   Items[Count-1].Value := _Value;
   Items[Count-1].LType := _LType;
end;

function TBlockStack.Pop;
begin
   if Count > 0 then
    begin
     _Value := Items[Count-1].Value;
     _LType := Items[Count-1].LType;
     dec(Count);
     Result := false;
    end
   else Result := true;
end;

procedure TBlockStack.Clear;
begin
   Count := 0;
   SetLength(Items,Count);
end;

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~`

function TDef.Find;
var i:word;
begin
   if count > 0 then
    for i := 0 to Count-1 do
     if StrIComp( PChar(Items[i].Name),PChar(def) ) = 0 then
      begin
        Result := true;
        FindIndex := i;
        exit;
      end;
    REsult := false;
end;

function TDef.Replace;
begin
  with Items[FindIndex].Value do
   case Data_type of
    0:
      begin
        Result := 'empty';
        TokType := TokName;
      end;
    data_int:
      begin
        Result := int2str(idata);
        TokType := TokNumber;
      end;
    data_str:
      begin
        Result := sdata;
        TokType := TokString;
      end;
    data_real:
      begin
        Result := Double2Str(rdata);
        TokType := TokReal;
      end;
   end
end;

procedure TDef.Add(const Name:string;Value:integer);
begin
   inc(Count);
   SetLength(Items,Count);
   Items[Count-1].Name := Name;
   Items[Count-1].Value.Data_type := data_int;
   Items[Count-1].Value.idata := value;
end;

procedure TDef.Add(const Name:string;const Value:string);
begin
   inc(Count);
   SetLength(Items,Count);
   Items[Count-1].Name := Name;
   Items[Count-1].Value.Data_type := data_str;
   Items[Count-1].Value.sdata := value;
end;

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~`

function TOOP_Obj.Find;
var i:word;
begin
   if Count > 0 then
    for i := 0 to Count-1 do
     if Items[i].Name = Name then
      begin
       FindIndex := i;
       Result := true;
       Exit;
      end;
   Result := false;
end;

procedure TOOP_Obj.Add;
begin
  inc(Count);
  SetLength(Items,count);
  Items[Count-1].Name := LowerCase( Name );
  Items[Count-1].Hint := Name;
  Items[Count-1].MType := MType;
end;

procedure TOOP_Obj.AddMethod;
var i:byte;
begin
  Add(Name,1);
  Items[Count-1].Body := _Body;
  with Items[Count-1] do
   begin
     Args := TArgs.Create;
     if High(FArgs) >= 0 then
     if FArgs[0] <> '' then
      for i := 0 to High(FArgs) do
        if FArgs[i][1] = '@' then
          Args.AddVar( PChar(@FArgs[i][2]),ByRef)
        else Args.AddVar(FArgs[i],ByVal);
   end;
end;

procedure TOOP_Obj.AddVar;
begin
  Add(Name,2);
  Items[Count-1].Body := _var;
end;

procedure TOOP_Obj.AddProperty;
begin
  Add(Name,3);
  Items[Count-1].Body := _Proc;
end;

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function TOOP.Find;
var i:word;
begin
   if Count > 0 then
    for i := 0 to Count-1 do
     if Items[i].Name = Name then
      begin
       FindIndex := i;
       Result := true;
       Exit;
      end;
   Result := false;
end;

function TOOP.Add;
begin
  inc(Count);
  SetLength(Items,Count);
  items[count-1].Name := LowerCase(Name);
  items[count-1].Hint := Name;
  items[count-1].Obj := TOOP_Obj.Create;
  Result := @Items[count-1];
end;

procedure TOOP.AddItem;
begin
  inc(Count);
  SetLength(Items,Count);
  items[count-1] := Item^;
end;

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

constructor TScript.Create;
begin
   inherited Create;

   Funcs := TFunc.Create;
   Funcs.Add('');
   Vars := Funcs.Items[0].Vars;
   Vars.Count := 0;

   Err := NewStrList;
   BlockStack := TBlockStack.Create;

   LocRFuncs := TRFunc.Create;
   Oop := TOOP.Create;
end;

destructor TScript.destroy;
begin
   ClearAll;
   inherited destroy;
end;

procedure WriteByte(Stream:PStream; b:byte);
begin Stream.Write(b,1); end;

procedure WriteWord(Stream:PStream; b:word);
begin Stream.Write(b,2); end;

procedure WriteStr(Stream:PStream; var Str:string);
var l:word;
begin
   l := length(str);
   WriteWord(Stream,l);
   if l > 0 then
    Stream.Write(str[1],l);
end;

procedure WriteData(Stream:PStream; var d:TData);
var i:word;
begin
  WriteByte(Stream,D.Data_type);
  case d.Data_type of
   0:;
   data_int : Stream.Write(d.idata,sizeof(integer));
   data_str : WriteStr(Stream,d.sdata);
   data_real: Stream.Write(d.rdata,sizeof(real));
   5:
     begin
      i := d.idata;
      Stream.Write(i,2);
      if d.idata > 0 then
       for i := 0 to d.idata-1 do
        WriteData(Stream,TDataArray(pointer(d.sdata)^)[i]);
     end;
  end;
end;

procedure ReadStr(Stream:PStream; var Str:string);
var l:word;
begin
   Stream.Read(l,2);
   if l > 0 then
     begin
       SetLength(str,l);
       Stream.Read(str[1],l);
     end;
end;

procedure ReadData(Stream:PStream; var d:TData);
var i:word;
begin
  Stream.Read(D.Data_type,1);
  case d.Data_type of
   0:;
   data_int : Stream.Read(d.idata,sizeof(integer));
   data_str : ReadStr(Stream,d.sdata);
   data_real: Stream.Read(d.rdata,sizeof(real));
   5:
     begin
       Stream.Read(i,2);
       d.idata := i;
       GetMem(pointer(d.sdata),i*SizeOf(TData));
       if i > 0 then
        for i := 0 to d.idata-1 do
         ReadData(Stream,TDataArray(pointer(d.sdata)^)[i]);
     end;
  end;
end;

procedure TScript.SaveToStream;
var i,j:word;
    k:byte;
begin
   WriteWord(Stream,Funcs.Count);
   for i := 0 to Funcs.Count-1 do
    with Funcs.Items[i] do
     begin
        WriteStr(Stream,Name);

        WriteByte(Stream,Args.Count);
        if Args.Count > 0 then
          for j := 0 to Args.Count - 1 do
            WriteByte(Stream,Args.Table[j].CallType);

        if i = 0 then k := 0 else k := 1;
        WriteWord(Stream,Vars.Count);
        if Vars.Count > k then
          for j := k to Vars.Count - 1 do
            WriteData(Stream,Vars.Table[j].Value);

        WriteWord(Stream,Body.Count);
        if Body.Count > 0 then
         Stream.Write(Body.Code[0],Body.Count*sizeof(smallint));
     end;
end;

procedure TScript.LoadFromStream;
var i,j,FCount,VCount:word;
    ACount,k:byte;
begin
   Stream.Read(FCount,2);
   if FCount > 0 then
   for i := 0 to FCount-1 do
    begin
     Funcs.Add('');
     with Funcs.Items[i] do
      begin
        ReadStr(Stream,Name);
        Stream.Read(ACount,1);
        if ACount > 0 then
         begin
           SetLength(Args.Table,ACount);
           Args.Count := ACount;
            for j := 0 to ACount - 1 do
              Stream.Read(Args.Table[j].CallType,1);
         end;

        if i = 0 then k := 0 else k := 1;
        Stream.Read(VCount,2);
        if VCount > k then
         begin
           SetLength(Vars.Table,VCount);
           Vars.Count := VCount;
           for j := k to VCount - 1 do
             ReadData(Stream,Vars.Table[j].Value);
         end;

        Stream.Read(Body.Count,2);
        if Body.Count > 0 then
         begin
           SetLength(Body.Code,Body.Count);
           Stream.Read(Body.Code[0],Body.Count*sizeof(smallint));
         end;
     end;
    end;
end;

function TScript.ReadLine;
begin
   while LineIndex < Lines.Count do
    begin
       Line := Lines.Items[LineIndex] + #1;
       inc(LineIndex);
       if (CurFunc.y = LineIndex) then
        if Funcs.InFunc then
         CurFunc.Number := Funcs.Count-1
        else CurFunc.Number := -1;
       if Line <> #1 then break;
    end;
   Result := LineIndex = Lines.Count;
end;

function TScript.AddError;
begin
   Err.Add('[' + int2str(LineIndex) + ']:' + Error);
   if not Next then
     PutToken;
end;

procedure TScript.PutToken;
begin
   dec(LPos,length(Token));
   if TokType = TokString then
    dec(LPos,2);
   Token := '';
end;

function TScript.GetToken;
begin
   Token := '';
   RToken := '';
   TokType := 0;
   Result := false;
   repeat
   case Line[LPos] of
     ' ',#9: inc(LPos);
     'a'..'z','A'..'Z','_','а'..'я','А'..'Я':
       begin
         repeat
           RToken := RToken + Line[LPos];
           inc(LPos);
         until not(Line[LPos] in ['a'..'z','A'..'Z','_','а'..'я','А'..'Я','0'..'9']);
         Token := LowerCase(RToken);
         if Def.Find(Token) then
           Token := Def.Replace(TokType)
         else TokType := TokName;
       end;
     '0'..'9':
       begin
         repeat
           Token := Token + Line[LPos];
           inc(LPos);
         until not(Line[LPos] in ['0'..'9']);
         if (Line[LPos] = '.')and(Line[LPos+1] <> '.') then
          begin
           repeat
            Token := Token + Line[LPos];
            inc(LPos);
           until not(Line[LPos] in ['0'..'9']);
           if Token[Length(Token)] = '.' then
             AddError('Syntax error. Please write correct real number.',false);
           TokType := TokReal;
          end
         else TokType := TokNumber;
       end;
     '''': while Line[LPos] <> #1 do inc(LPos);
     '"':
       begin
         inc(LPos);
         while (Line[LPos] <> #1) do
          begin
           if Line[LPos] = '"' then
            if Line[LPos-1] = '\' then
             delete(Token,Length(Token),1)
            else Break;
           Token := Token + Line[LPos];
           inc(LPos);
          end;
         TokType := TokString;
         if Line[LPos] = #1 then
           AddError('Lexem " not found',true)
         else inc(LPos);
       end;
     '.':
       if Line[LPos+1] = '.' then
        begin
          Token := '..';
          TokType := TokSymbol;
          inc(LPos,2);
        end
       else
        begin
          Token := '.';
          TokType := TokSymbol;
          inc(LPos);
        end;
     '(',')','[',']','=',',',':',';':
        begin Token := Line[LPos]; inc(LPos); TokType := TokSymbol; end;
     '+','-','/','*':
        begin
          Token := Line[LPos];
          inc(LPos);
          if Line[LPos] = '=' then
            begin
               Token := Token + Line[LPos];
               inc(LPos);
               TokType := TokSymbol
            end
          else TokType := TokMath;
        end;
     '>','<':
        begin
          Token := Line[LPos];
          inc(LPos);
            if Line[LPos] = '=' then
             begin
                Token := Token + Line[LPos];
                inc(LPos);
             end
            else if ( Token = '<' )and(Line[LPos] = '>')then
             begin
                Token := '<>';
                inc(LPos);
             end;
          TokType := TokMath;
        end;
     '@':
        begin
          TokType := TokName;
          Token := '@';
          inc(LPos);
        end;
     '#':
        begin
          TokType := TokString;
          inc(LPos);
          Token := '';
          while (Line[LPos] in ['0'..'9'])and(Line[LPos] <> #1) do
           begin
             Token := Token + Line[LPos];
             inc(LPos);
           end;
          if Token = '' then
           Token := #0
          else Token := chr(str2int(Token));
        end;
     #1: begin ReadLine; LPos := 1; end;
     #2: Result := true;
     else
      begin
       AddError('Symbol ' + Line[LPos] + ' don''t support');
       inc(LPos);
      end;
   end;
   until (TokType <> 0)or(Result);
end;

function TScript.Level1;
begin
  GetToken;
  MathResult := 0;
  Result := Level2;
  PutToken;
end;

function TScript.Level2;
begin
  Result := Level3;
  while (Token = 'or') do
   begin
    GetToken;
    Result := Level3;
    Funcs.AddCode(offOp,cmdOr);
   end;
end;

function TScript.Level3;
begin
  Result := Level3_1;
  while (Token = 'and') do
   begin
    GetToken;
    Result := Level3_1;
    Funcs.AddCode(offOp,cmdAnd);
   end;
end;

function TScript.Level3_1;
var op:byte;
begin
  Result := Level4;
  while (Token = 'is') do
   begin
    if GetToken then exit;
    if Token = 'integer' then
       op := 1
    else if Token = 'string' then
       op := 2
    else if Token = 'real' then
       op := 3
    else if Token = 'null' then
       op := 0;
    Funcs.AddCode(offOp,cmdIs + op);
    if GetToken then exit;
   end;
end;

function TScript.Level4;
var op:byte;
begin
  Result := Level5;
  while (Token = '=')or(Token = '<')or(Token = '>')or
        (Token = '<>')or(Token = '<=')or(Token = '>=')do
   begin
    if Token = '=' then
      op := cmdCmp6
    else if Token = '>' then
      op := cmdCmp1
    else if Token = '<' then
      op := cmdCmp2
    else if Token = '>=' then
      op := cmdCmp3
    else if Token = '<=' then
      op := cmdCmp4
    else if Token = '<>' then
      op := cmdCmp5;
    GetToken;
    Result := Level5;
    Funcs.AddCode(offOp,op);
   end;
end;

function TScript.Level5;
var
  op:byte;
  Var1,var2:PVarItem;
begin
  Result := Level6;
  while (Token = '-')or(Token = '+') do
   begin
    if Token = '+' then op := cmdMath1 else op := cmdMath2;
    GetToken;
    Result := Level6;

    with Funcs.Body do
      begin            //offOp
       if Code[ Count-1 ].CmdType = offGVar then
         Var2 := BuildVar(Code[ Count-1 ])
       else Var2 := nil;
       if Code[ Count-2 ].CmdType = offGVar then
         Var1 := BuildVar(Code[ Count-2 ])
       else Var2 := nil;
      end;

    if(Var1 <> nil)and(Var2 <> nil)and(Var1.Flag = IS_CONST)and(Var2.Flag = IS_CONST) then
      begin
         CalcMath(op,@Var1.Value,@Var1.Value,@Var2.Value);
         dec(Funcs.Vars.Count);
         dec(Funcs.Body.Count);
      end
    else  Funcs.AddCode(offOp,op);

   end;
end;

function TScript.Level6;
var op:byte;
    Var1,var2:PVarItem;
begin
  Result := Level7;
  while (Token = '/')or(Token = '*')do
   begin
    if Token = '*' then op := cmdMath3 else op := cmdMath4;
    GetToken;
    Result := Level7;

    with Funcs.Body do
      begin
       if Code[ Count-1 ].CmdType = offGVar then
         Var2 := BuildVar(Code[ Count-1 ])
       else Var2 := nil;
       if Code[ Count-2 ].CmdType = offGVar then
         Var1 := BuildVar(Code[ Count-2 ])
       else Var2 := nil;
      end;

    if(Var1 <> nil)and(Var2 <> nil)and(Var1.Flag = IS_CONST)and(Var2.Flag = IS_CONST) then
      begin
         CalcMath(op,@Var1.Value,@Var1.Value,@Var2.Value);
         dec(Funcs.Vars.Count);
         dec(Funcs.Body.Count);
      end
    else  Funcs.AddCode(offOp,op);
   end;
end;

function TScript.Level7;
var op:byte;
    Var1:PVarItem;
begin
  op := 0;
  if ((Token = '-')or(Token = '+')or(Token = 'not'))and(TokType <> tokString)then
   begin
    if Token = '-' then
      op := cmdMath5
    else if Token = 'not' then
      op := cmdNot;
    GetToken;
   end;
  Result := Level8;
  if op <> 0 then
    begin
     with Funcs.Body do
       var1 := BuildVar( Code[Count-1]);

     if Var1.Flag = IS_CONST then
          case Var1.Value.Data_type of
           0:;
           data_int: Var1.Value.idata := -Var1.Value.idata;
           data_str:;
           data_real: Var1.Value.rdata := -Var1.Value.rdata;
          end
     else Funcs.AddCode(offOp,op);
    end;
end;

function TScript.Level8;
var
    Var1:PVarItem;
    Old:byte;
begin
  Result := Level9;
  while (Token = '[')do
   begin
    GetToken;
    Old := MathResult;
    Result := Level2;
    Funcs.AddCode(offOp,cmdArInd);
    if Token <> ']' then
       begin
         Result := false;
         AddError('Lexem ] not found!');
         Exit;
       end;
    MathResult := Old;
    if GetToken then exit;
   end;
end;

function TScript.Level9;
var ind:TCodeUnit;
    tmpMath:byte;
begin
  Result := true;
  if Token = '(' then
   begin
     GetToken;
     Result := Level2;
     if Token <> ')' then
       begin
         Result := false;
         AddError('Lexem ) not found!');
         Exit;
       end;
   end
  else if Token = '@' then
   begin
     AddrLexem;
     MathResult := MathResult or IS_CONST;
   end
  else if TokType = TokName then
     begin
       ind := CodeName;
       if ind.CmdType in [offFunc,offRFunc,offLRFunc,offoop,offGOOp] then
        begin
          MathResult := MathResult or IS_FUNC;
          tmpMath := MathResult;
          case ind.CmdType of
           offFunc  : CallFunc(false);
           offRFunc : CallRFunc(false);
           offLRFunc: CallLRFunc(false);
           offOOP,offGOOP: CallOOP(ind.CmdType,false);
          end;
          MathResult := tmpMath;
        end
       else
        begin
         MathResult := MathResult or IS_VAR;
         Funcs.AddCode(ind.CmdType,ind.Cmd);
        end;
     end
  else if TokType = TokNumber then
     with Funcs.Vars.Table[Funcs.Vars.AddVar('',IS_CONST)] do
      begin
         Value.Data_type := data_int;
         Value.idata := str2int(Token);
         Funcs.AddCode(offVar,Funcs.Vars.Count-1);
         MathResult := MathResult or IS_CONST;
      end
  else if TokType = TokReal then
     with Funcs.Vars.Table[Funcs.Vars.AddVar('',IS_CONST)] do
      begin
         Value.Data_type := data_real;
         Value.rdata := Str2Double(Token);
         Funcs.AddCode(offVar,Funcs.Vars.Count-1);
         MathResult := MathResult or IS_CONST;
      end
  else if TokType = TokString then
     with Funcs.Vars.Table[Funcs.Vars.AddVar('',IS_CONST)] do
      begin
         Value.Data_type := data_str;
         Value.sdata := Token;
         Funcs.AddCode(offVar,Funcs.Vars.Count-1);
         MathResult := MathResult or IS_CONST;
         //_debug('str'+Token);
      end;
  GetToken;
end;

procedure TScript.EndLexem;
var noput:boolean;
begin
   noput := GetToken;
   if Token = 'if' then
      begin
        EndIfLexem;
        exit;
      end
   else if token = 'select' then
    begin
       EndCaseLexem;
       exit;
    end
   else if token = 'function' then
    begin
      {  /// Решить!
      if GetToken then exit;
      if(token <> 'function')and(token <> 'dim')then
       begin
        PutToken;
        Token := 'function';
       end;
      PutToken;
      }
      Funcs.InFunc := false;
      exit;
    end
   else if not noput then PutToken;

   with BlockStack do
    if (Count > 0)and(Items[Count-1].LType = 1) then
      begin
        EndIfLexem;
        exit;
      end;

   if BlockStack.Count > 0 then
        AddError('Key word ENDIF or NEXT not found')
   else BlockStack.Clear;
   Funcs.InFunc := false;
end;

procedure TScript.AddFunction;
var CallType:byte;
begin
   if Funcs.InFunc then
     begin
       AddError('Key word END not found');
       Funcs.InFunc := false;
       Exit;
     end;

   if GetToken then exit;

   if Funcs.Find(Token) then
     begin
       AddError('Function exists');
       Exit;
     end;
   Funcs.Add(RToken);
   if GetToken then exit;
   if Token <> '(' then
     begin
       AddError('Syntax error: (');
       Exit;
     end;
   repeat
    if GetToken then exit;

    if Token = 'byval' then
       begin
         CallType := ByVal;
         if GetToken then exit;
       end
    else if Token = 'byref' then
       begin
         CallType := ByRef;
         if GetToken then exit;
       end
    else CallType := ByVal;

    if TokType = TokName then
     begin
       Funcs.Args.AddVar(Token,CallType);
       if GetToken then exit;
     end
    else  if Token <> ')' then
       AddError('Variable not found');
    if (Token <> ',')and(Token <> ')') then
      begin
       AddError('Lexem ) not found');
       Exit;
     end

   until Token = ')';
   Funcs.InFunc := true;
end;

procedure TScript.ReadFuncArgs;
var
  i,j:byte;
begin
    if GetToken then exit;
    j := 0;
    if Token <> '(' then
       PutToken
    else j := 1;

    if Args.Count > 0 then
     begin
      for i := 0 to Args.Count-1 do
       begin
        Level1;
        if ( Args.Table[i].CallType = ByRef )and(MathResult <> IS_VAR)then
         begin
          AddError('Argument ' + Args.Table[i].Name + ' mark as ByRef');
          Exit;
         end;

        if GetToken then exit;
        if(i < Args.Count-1)and( Token <> ',') then
         begin
          AddError('Lexem , not found!');
          Exit;
         end;
       end;
     end
    else if j = 1 then
      if GetToken then exit;

   if j = 0 then
    begin
      if Token = ')' then
        AddError('Lexem ( not found!')
      else if Args.Count > 0 then PutToken;
    end
   else if Token <> ')' then
     AddError('Lexem ) not found!');
end;

procedure TScript.CallFunc;
var
  Ind:word;
begin
   Ind := Funcs.FindIndex;
   ReadFuncArgs(Funcs.Items[Ind].Args);
   Funcs.AddCode( offFunc,Ind );
   if Init then
    Funcs.AddCode( offOp,cmdPop );
end;

procedure TScript.CallLRFunc;
var
  Ind:word;
begin
   Ind := LocRFuncs.FindIndex;
   ReadFuncArgs(LocRFuncs.Items[Ind].Args);
   Funcs.AddCode( offLRFunc,Ind );
   if Init then
    Funcs.AddCode( offOp,cmdPop );
end;

procedure TScript.CallRFunc;
var
  Ind:word;
begin
   Ind := RFuncs.FindIndex;
   ReadFuncArgs(RFuncs.Items[Ind].Args);
   Funcs.AddCode( offRFunc,Ind );
   if Init then
    Funcs.AddCode( offOp,cmdPop );
end;

procedure TScript.CallOOP;
var
  Ind,FieldInd:word;
  _Oop:TOOP;
begin
   case OType of
    offOOP : _oop := oop;
    offGOOP: _oop := GOop;
   end;

   Ind := _oop.FindIndex;
   if GetToken then exit;
   if Token <> '.' then exit;
   if GetToken then exit;

   if _oop.Items[ind].Obj.Find(Token) then
    begin
      FieldInd := _oop.Items[ind].Obj.FindIndex;
      with _oop.Items[ind].Obj do
       case Items[FieldInd].MType of
        1:
         begin
           ReadFuncArgs(Items[FieldInd].Args);
           Funcs.AddCode( offStack,byte(Init) );
           Funcs.AddCode( offStack,FieldInd );
           Funcs.AddCode( OType,Ind );
         end;
        2:
         begin
           Funcs.AddCode( offStack,FieldInd );
           Funcs.AddCode( OType,Ind );
           //VarInit;
         end;
        3:
         begin

           if Init then
            begin
             if GetToken then exit;
             if Token = '=' then
              begin
               Level1;
               if MathResult = 0 then
                 AddError('Expression expected')
               else
                begin
                  if GetToken then exit;
                  if Token <> ';' then PutToken;
                end;
              end
             else AddError('Token = not found');
            end;

           Funcs.AddCode( offStack,byte(Init) );
           Funcs.AddCode( offStack,FieldInd );
           Funcs.AddCode( OType,Ind );

         end;
       end;
    end
   else AddError('Field ' + token + ' not found')
end;

procedure TScript.VarInit;
var// ind:word;
    op:byte;
begin
   if GetToken then exit;
   //ind := Funcs.Body.Code[Funcs.Body.Count-1];
   while Token = '['do
    begin
       {
       if Funcs.Vars.Table[ind].Flag <> IS_ARRAY then
         begin
          AddError('Varriable '+Funcs.Vars.Table[ind].Name+' is not array!');
          Exit;
         end;
       }
       Level1;
       Funcs.AddCode(offOp,cmdArInd);
       if GetToken then exit;
       if Token <> ']' then
         begin
          AddError('Lexem ] not found!');
          Exit;
         end;
       if GetToken then exit;
    end;

   if Token = '=' then
     op := cmdOp1
   else if Token = '+=' then
     op := cmdOp2
   else if Token = '-=' then
     op := cmdOp3
   else if Token = '*=' then
     op := cmdOp4
   else if Token = '/=' then
     op := cmdOp5
   else
    begin
      AddError('Lexem = not found!',true);
      Exit;
    end;
   Level1;
   if MathResult = 0 then
     AddError('Expression expected');
   Funcs.AddCode(offOp,op);
   if GetToken then exit;
   if Token <> ';' then PutToken;
end;

procedure TScript.IfLexem;
var ind:word;
begin
   Level1;
   if GetToken then exit;
   if Token <> 'then' then
    begin
      AddError('Key word THEN not found!');
      Exit;
    end;
   ind := funcs.Vars.AddVar('',IS_LABEL);
   Funcs.AddCode(offVar,ind);
   Funcs.AddCode(offOp,cmdIf);
   BlockStack.Push(0,1);
   BlockStack.Push(ind,1);
end;

procedure TScript.ElseLexem;
var ind:smallint;
    LType:word;
    exit_label:smallint;
begin
   if BlockStack.Pop(ind,LType) or(LType <> 1) then
    begin
      AddError('Key word IF not found!');
      Exit;
    end;
   BlockStack.Pop(exit_label,LType);
   if Ind = 0 then
       begin
        AddError('Section ELSE to be used!');
        Exit;
       end;

   if exit_label = 0 then
     exit_label := funcs.Vars.AddVar('',IS_LABEL);

   Funcs.AddCode(offVar,exit_label);
   Funcs.Vars.Table[ind].Value.idata := Funcs.AddCode(offOp,cmdElse);

   if GetToken then exit;
   if Token = 'if' then
    begin
      Level1;
      if GetToken then exit;
      if Token <> 'then' then
       begin
        AddError('Key word THEN not found!');
        Exit;
       end;
      ind := funcs.Vars.AddVar('',IS_LABEL);
      Funcs.AddCode(offVar,exit_label);
      Funcs.AddCode(offOp,cmdIf);
    end
   else
    begin
      PutToken;
      ind := 0;
    end;

   BlockStack.Push(exit_label,1);
   BlockStack.Push(ind,1);
end;

procedure TScript.EndIfLexem;
var ind,exit_label:smallint;
    LType:word;
begin
   if BlockStack.Pop(ind,LType) or(LType <> 1) then
    begin
      AddError('Key word IF not found!');
      Exit;
    end;
   BlockStack.Pop(exit_label,LType);
   with Funcs.Vars.Table[ind].Value do
    begin
      if exit_label = 0 then
        idata := Funcs.Body.Count-1
      else
        Funcs.Vars.Table[exit_label].Value.idata := Funcs.Body.Count-1;
    end;
end;

procedure TScript.ForLexem;
var
  label_if,label_goto:word;
  ind:TCodeUnit;
  Step_label:smallint;
begin
   if GetToken then exit;
   if TokType <> TokName then
    begin
      AddError('Variable not found!');
      Exit;
    end;
   ind := CodeName(false);
   Funcs.AddCode( offVar,ind.Cmd );
   //if MathResult <> IS_VAR then
   // AddError('Variable not found!');

   if GetToken then exit;
   if Token <> '=' then
    begin
      AddError('Lexem = not found!');
      Exit;
    end;
   Level1;
   if GetToken then exit;
   if Token <> 'to' then
    begin
      AddError('Key word TO not found!');
      Exit;
    end;
   Funcs.AddCode( offOp,cmdOp1 );

   label_goto := funcs.Vars.AddVar('',IS_LABEL);  // return label
   Funcs.Vars.Table[label_goto].Value.idata := Funcs.Body.Count-1;

   Funcs.AddCode( offVar,ind.Cmd );
   Level1;
   Funcs.AddCode( offOp,cmdCmp4 ); // <=

   label_if := funcs.Vars.AddVar('',IS_LABEL);
   Funcs.AddCode(offVar,label_if);
   Funcs.AddCode(offOp,cmdIf);

   Step_label := -1;
   if GetToken then exit;
    if Token = 'step' then
      begin
        Level1;
        if (MathResult = IS_VAR)or(MathResult = IS_CONST) then
          Step_label := Funcs.Body.Code[Funcs.Body.Count-1].Cmd
        else AddError('Step expresion my be VAR or CONST');
      end
    else PutToken;

   BlockStack.Push(Step_label,2);
   BlockStack.Push(label_goto,2);
   BlockStack.Push(label_if,2);
   BlockStack.Push(ind.Cmd,2);
end;

procedure TScript.NextLexem;
var
  ind,label_if,label_goto,Step_label:smallint;
  Ltype:word;
begin
   if BlockStack.Pop(ind,LType) or (LType <> 2) then
    begin
      AddError('Key word FOR not found!');
      Exit;
    end;
   BlockStack.Pop(label_if,LType);
   BlockStack.Pop(label_goto,LType);
   BlockStack.Pop(Step_label,LType);
   //GetToken;  // next i
   Funcs.AddCode( offVar,ind );
   if Step_label = -1 then
     Funcs.AddCode( offOp,cmdInc )
   else
    begin
     Funcs.AddCode(offVar,Step_label);
     Funcs.AddCode(offOp, cmdOp2)
    end;

   Funcs.AddCode( offVar, label_goto );
   Funcs.AddCode( offOp, cmdElse );

   Funcs.Vars.Table[label_if].Value.idata := Funcs.Body.Count-1;
end;

procedure TScript.BreakLexem;
var
  label_if,i:smallint;
begin
   label_if := -1;
   if BlockStack.Count > 0 then
    for i := BlockStack.Count - 1 downto 0 do
     if BlockStack.Items[i].LType = 2 then
      begin
         label_if := BlockStack.Items[i-1].Value;
         break;
      end;
   if label_if = -1 then
    begin
      AddError('Key word FOR not found!',true);
      Exit;
    end;
   Funcs.AddCode( offVar, label_if );
   Funcs.AddCode( offOp,cmdElse );
end;

procedure TScript.ExitDo;
var
  label_if,i:smallint;
begin
   label_if := -1;
   if BlockStack.Count > 0 then
    for i := BlockStack.Count - 1 downto 0 do
     if BlockStack.Items[i].LType = 3 then
      begin
         label_if := BlockStack.Items[i].Value;
         break;
      end;
   if label_if = -1 then
    begin
      AddError('Key word DO not found!',true);
      Exit;
    end;
   Funcs.AddCode( offVar, label_if );
   Funcs.AddCode( offOp, cmdElse );
end;

procedure TScript.ExitLexem;
begin
  if GetToken then exit;
  if Token = 'for' then
     BreakLexem
  else if Token = 'do' then
     ExitDo
  else if Token = '' then

  else
   begin
      PutToken;
      Funcs.AddCode(offOp, cmdExit);
   end;
end;

procedure TScript.ReturnLexem;
var sk:boolean;
begin
  if GetToken then exit;
  sk := Token = '(';
  if not sk then
   PutToken;

  Funcs.AddCode(offVar,0);

  Level1;
  if MathResult = 0 then
   begin
     AddError('Expression expected');
     Exit;
   end
  else Funcs.AddCode(offOp, cmdOp1);
  Funcs.AddCode(offOp,cmdExit);

  if sk then
   begin
     if GetToken then exit;
     if Token <> ')' then
      AddError('Lexem ) not found');
   end;
  if GetToken then exit;
  if Token <> ';' then PutToken;
end;

procedure TScript.DoLexem;
var OpType:byte;
    label_do,label_exit:smallint;
begin
   if GetToken then exit;
   if Token = 'while' then
     OpType := 1
   else if Token = 'until' then
     OpType := 2
   else OpType := 0;

   label_do := funcs.Vars.AddVar('',IS_LABEL);  // return label
   Funcs.Vars.Table[label_do].Value.idata := Funcs.Body.Count-1;

   label_exit := funcs.Vars.AddVar('',IS_LABEL);
   if OpType = 0 then
      PutToken
   else
    begin
      Level1;
      if OpType = 2 then
        Funcs.AddCode(offOp,cmdNot);

      Funcs.AddCode(offVar, label_exit);
      Funcs.AddCode(offOp,cmdIf);
    end;

   BlockStack.Push(OpType,3);
   BlockStack.Push(label_do,3);
   BlockStack.Push(label_exit,3);
end;

procedure TScript.LoopLexem;
var OpType,LType:word;
    label_do,label_exit,DoOpType:smallint;
begin
   if GetToken then exit;
   if Token = 'while' then
     OpType := 1
   else if Token = 'until' then
     OpType := 2
   else OpType := 0;

   if OpType = 0 then
      PutToken
   else
     begin
       Level1;
       if OpType = 1 then
         Funcs.AddCode(offOp, cmdNot);
     end;

   if BlockStack.Pop(label_exit,LType) or (LType <> 3) then
    begin
      AddError('Key word DO not found!');
      Exit;
    end;
   BlockStack.Pop(label_do,LType);
   BlockStack.Pop(DoOpType,LType);

   if (DoOpType > 0)and(OpType <> 0)then
    begin
      AddError('Syntax error! Use LOOP witchout UNTIL or WHILE');
      Exit;
    end;

   Funcs.AddCode(offVar,label_do);
   if OpType = 0 then
     Funcs.AddCode(offOp, cmdElse)
   else Funcs.AddCode(offOp, cmdIf);

   Funcs.Vars.Table[label_exit].Value.idata := Funcs.Body.Count-1;
end;

procedure TScript.SelectLexem;
var ind:word;
begin
   if GetToken then exit;
   if Token <> 'case' then
     PutToken;

   ind := Funcs.Vars.AddVar('',IS_VAR);
   Funcs.AddCode(offVar, ind);
   Level1;
   if MathResult = IS_VAR then
    with Funcs.Body do
     begin
      ind := Code[Count-1].Cmd;
      Code[Count-2] := Code[Count-1];
      dec(Count,2);
      dec(Funcs.Vars.Count);
     end
   else
    begin
       Funcs.AddCode(offOp,cmdOp1);
    end;

   BlockStack.Push(-1,4);  // if
   BlockStack.Push(ind,4); // main var
   BlockStack.Push(Funcs.Vars.AddVar('',IS_LABEL),4); // exit case
   if GetToken then exit;
   if Token <> 'case' then
    begin
      AddError('Key word CASE not found!');
      Exit;
    end;
   CaseLexem;
end;

procedure TScript.CaseLexem;
var ind,label_exit,label_if:smallint;
   LType:word;
   procedure CalcMath;
   begin
     Level1;
     if GetToken then exit;
     if Token = '..' then
      begin
        Level1;
        Funcs.AddCode(offVar,ind);
        Funcs.AddCode(offOp,cmdCmp7);
      end
     else
      begin
        PutToken;
        Funcs.AddCode(offVar,ind);
        Funcs.AddCode(offOp,cmdCmp6);
      end;
   end;
begin
   if BlockStack.Pop(label_exit,LType) or (LType <> 4) then
    begin
     AddError('Key word SELECT [CASE] not found!',true);
     // защита от ошибки
     label_exit := Funcs.Vars.AddVar('',IS_LABEL);
    end;

   BlockStack.Pop(ind,LType);
   BlockStack.Pop(label_if,LType);
   if label_if <> -1 then
    begin
      Funcs.AddCode(offVar,label_exit);
      Funcs.AddCode(offOp,cmdElse);
      Funcs.Vars.Table[label_if].Value.idata := Funcs.Body.Count-1;
    end;

   if GetToken then exit;
   if Token = 'else' then
    begin
      label_if := -1;
    end
   else
    begin
     PutToken;
     CalcMath;

     if GetToken then exit;
     if Token = ',' then
       while Token = ',' do
        begin
          CalcMath;

          Funcs.AddCode(offOp, cmdOr);
          if GetToken then exit;
        end;
     if Token <> ':' then PutToken;

     label_if := Funcs.Vars.AddVar('',IS_LABEL);
     Funcs.AddCode(offVar,label_if);
     Funcs.AddCode(offOp, cmdIf);
    end;

   BlockStack.Push(label_if,4);
   BlockStack.Push(ind,LType);
   BlockStack.Push(label_exit,4);
end;

procedure TScript.EndCaseLexem;
var ind,label_exit,label_if:smallint;
   LType:word;
begin
   if BlockStack.Pop(label_exit,LType) or (LType <> 4) then
    begin
      AddError('Key word SELECT [CASE] not found!');
      Exit;
    end;
   BlockStack.Pop(ind,LType);
   BlockStack.Pop(label_if,LType);

   if label_if <> -1 then
    Funcs.Vars.Table[label_if].Value.idata := Funcs.Body.Count-1;

   Funcs.Vars.Table[label_exit].Value.idata := Funcs.Body.Count-1;
end;

procedure SetDataType(var _var:TData; DType:byte);
begin
  if _Var.Data_type = 5 then
     TArray(_Var.idata).SetType(DType)
  else _Var.Data_type := DType;
end;

procedure FreeData_(var _var:TData);
begin
  if _Var.Data_type = 5 then
     TArray(_Var.idata).Destroy
  else ;
  _Var.Data_type := 0;
end;

procedure TScript.DimLexem;
var p,level:byte;
    ind,cind:word;
    Var1:PVarItem;
    procedure InitArr(var Arr:TData; Size:integer; Level:byte);
    var i:byte;
    begin
       // Set length
       Arr.Data_type := 5;
       if Level = 0 then
        begin
         Arr.idata := integer(TArray.Create);
         TArray(Arr.idata).SetSize(Size);
        end
       else
        for i := 0 to TArray(Arr.idata).Count-1 do
         InitArr( TArray(Arr.idata).Items[i] ,Size,Level-1 );
    end;
begin
  repeat
     if GetToken then exit;

     if TokType <> TokName then
      begin
       AddError('Variable name not found');
       Exit;
      end;

     if Check then
      begin
       if Funcs.Vars.Find(Token) then
        begin
         AddError('Variable with name:' + Token + ' exists');
         Exit;
        end;
       ind := Funcs.Vars.AddVar(Token,IS_VAR);
      end
     else if Funcs.Vars.Find(Token) then
      Ind := Funcs.Vars.FindIndex
     else if Vars.Find(Token) then
      Ind := Vars.FindIndex;

     if GetToken then exit;

     if Token = '[' then
      begin
        with Funcs.Vars.Table[ind] do
         begin
           Flag := IS_ARRAY;
         end;

     level := 0;
     while Token = '[' do
      begin
        Level1;
        if GetToken then exit;
        if Token <> ']' then
         begin
          AddError('Lexem ] not found');
          Exit;
         end;

        if MathResult <> IS_CONST then
          AddError('Const ecpected',true)
        else
         begin
           with Funcs.Body do
            begin
              Var1 := BuildVar(Code[Count-1]);
              dec(Count);
              dec(Funcs.Vars.Count);
            end;
           if Var1^.Value.idata <= 0 then
             AddError('Array index not correct',true)
           else
            with Funcs.Vars.Table[ind] do              // Create array
             InitArr(Value,Var1^.Value.idata,Level);
         end;

        if GetToken then exit;
        inc(Level);
      end;
    end;

     if Token = 'as' then
      begin
        if GetToken then exit;

        p := pos(Token,'integer,string ,real');
        if p = 0 then
         begin
          AddError('variable type:' + Token + ' not found');
          Exit;
         end;
        with Funcs.Vars.Table[ind] do
         case p div 8 of
          0: SetDataType(Value,data_int);
          1: SetDataType(Value,data_str);
          2: SetDataType(Value,data_real);
         end;
        if GetToken then exit;
      end;

     if Token = '=' then
      begin
         Level1;
         if MathResult = IS_CONST then
          begin
           with Funcs.Body do
            cind := Code[Count-1].Cmd;
           MoveOp(@Funcs.Vars.Table[ind].Value,@Funcs.Vars.Table[cind].Value);
           dec(Funcs.Vars.Count);
          end;
         If GetToken then exit;
      end;

  until Token <> ',';
  PutToken;
end;

procedure TScript.ReDimLexem;
var //Level:byte;
    U:TCodeUnit;
begin
   if GetToken then exit;

   U := CodeName(false);
   if not u.CmdType in [offVar,offGVar] then
    begin
     AddError('ReDim variable is not array');
     exit;
    end;
   Funcs.AddCode(U.CmdType,u.Cmd);

   if GetToken then exit;
   //level := 0;
   while Token = '[' do
    begin
      Level1;
      if GetToken then exit;
      if Token <> ']' then
       begin
        AddError('Lexem ] not found');
        Exit;
       end;
      Funcs.AddCode(offOp,cmdArray);
      if GetToken then exit;
      //inc(Level);
    end;
   PutToken;
end;

procedure TScript.AddrLexem;
begin
   if GetToken then exit;
   if Funcs.Find(Token) then
    begin
      Funcs.AddCode(offStack,Funcs.FindIndex);
      Funcs.AddCode(offOp,cmdAddr);
    end
   else AddError('Function name not found');
end;

function TScript.CodeName;
begin
    if FuncFind and Funcs.Find(Token) then
      begin
       Result.CmdType := offFunc;
       Result.Cmd := Funcs.FindIndex;
      end
    else if FuncFind and LocRFuncs.Find(Token) then
      begin
       Result.CmdType := offLRFunc;
       Result.Cmd := LocRFuncs.FindIndex;
      end
    else if FuncFind and RFuncs.Find(Token) then
      begin
       Result.CmdType := offRFunc;
       Result.Cmd := RFuncs.FindIndex;
      end
    else if Vars.Find(Token) then
      begin
       Result.CmdType := offGVar;
       Result.Cmd := Vars.FindIndex;
      end
    else if Funcs.Vars.Find(Token) then
      begin
       Result.CmdType := offVar;
       Result.Cmd := Funcs.Vars.FindIndex;
      end
    else if Funcs.Args.Find(Token) then
      begin
       Result.CmdType := offArg;
       Result.Cmd := Funcs.Args.FindIndex;
      end
    else if Oop.Find(Token) then
      begin
       Result.CmdType := offOOP;
       Result.Cmd := Oop.FindIndex;
      end
    else if GOop.Find(Token) then
      begin
       Result.CmdType := offGOOP;
       Result.Cmd := GOop.FindIndex;
      end
    else
      begin
       Result.CmdType := offVar;
       Result.Cmd := Funcs.Vars.AddVar(Token,IS_VAR);
      end;
end;

procedure TScript.Start;
var p:TCodeUnit;
begin
   if ReadLine then exit;
   while not GetToken do
    case TokType of
      TokName:
       if(Token <> 'dim')and (Token <> 'function' ) and not Funcs.InFunc then
        begin
          if AddError('Syntax error',true) then exit;
        end
       else
        begin
          if Token = 'function' then
             AddFunction
          else if Token = 'end' then
             EndLexem
          else if Token = 'return' then
             ReturnLexem
          else if Token = 'if' then
             IfLexem
          else if Token = 'else' then
             ElseLexem
          else if Token = 'for' then
             ForLexem
          else if Token = 'next' then
             NextLexem
          else if Token = 'break' then
             BreakLexem
          else if Token = 'exit' then
             ExitLexem
          else if Token = 'do' then
             DoLexem
          else if Token = 'loop' then
             LoopLexem
          else if Token = 'select' then
             SelectLexem
          else if Token = 'case' then
             CaseLexem
          else if Token = 'dim' then
             DimLexem
          else if Token = 'redim' then
             ReDimLexem
          else
           begin
             p := CodeName;
             case p.CmdType of
              offRFunc : CallRFunc;
              offLRFunc:CallLRFunc;
              offFunc:  CallFunc;
              offOop,offGOOP:   CallOOP(p.CmdType);
              else
               begin
                 Funcs.AddCode(p.CmdType,p.Cmd);
                 VarInit;
               end;
             end;
           end;
        end;
      else if AddError('Syntax error',true) then exit;
    end;
   if BlockStack.Count > 0 then
     AddError('Key word END IF or NEXT not found');
   if Funcs.InFunc then
     AddError('Key word END not found');
end;

procedure TScript.ClearAll;
begin
   Funcs.Clear;
   BlockStack.Clear;
   Funcs.Vars := Vars;
   Funcs.Body := Funcs.Items[0].Body;
   Funcs.Items[0].Vars.Clear;
end;

procedure TScript.Build;
begin
   LineIndex := 0;
   Line := '';
   Lines := List;
   Err.Clear;
   LPos := 1;
   ClearAll;
   List.Add(#2);
   Start;

   Error := Err;
end;

procedure TScript.BuildFromText;
var Lst:PStrList;
begin
   Lst := NewStrList;
   Lst.Text := Text;
   Build(Lst,Err);
   Lst.Free;
end;

procedure TScript.MoveOp;
var i:integer;
begin
   if Op1.Data_type = 5 then
     FreeData_(Op1^);

   if Op2.Data_type = 5 then
     begin
       Op1.idata := integer(TArray.Create);
       TArray(Op1.idata).SetSize(TArray(Op2.idata).Count);
       for i := 0 to TArray(Op1.idata).Count-1 do
        MoveOp( @TArray(Op1.idata).Items[i],@TArray(Op2.idata).Items[i])
     end
   else Op1^ := Op2^;
end;

procedure TScript.CalcMath;
var
   Val:integer;
   ValR:real;
   s:string;
begin
   Result.Data_type := Op1.Data_type;
   with Result^ do
   case op1^.Data_type of
    0: MoveOp(Result,Op2);
    data_int:
      begin
        case Op2.Data_type of
          0: val := 0;
          data_int: val := Op2.idata;
          data_str: Val := str2int(Op2.sdata);
          data_real:Val := Round(Op2.rdata);
        end;
        case Optype of
          cmdMath1: idata := Op1.idata + val;
          cmdMath2: idata := Op1.idata - val;
          cmdMath3: idata := Op1.idata * val;
          cmdMath4: if val <> 0 then idata := Op1.idata div val;
        end;
      end;
    data_str:
        case Optype of
          cmdMath1:
             case Op2.Data_type of
              0:  sdata := Op1.sdata;
              data_int: sdata := Op1.sdata + int2str(Op2.idata);
              data_str: sdata := Op1.sdata + Op2.sdata;
              data_real: sdata := Op1.sdata + Double2Str(Op2.idata);
             end;
          cmdMath2: sdata := Op1.sdata;
          cmdMath3:
            if Op2.Data_type = data_int then
             begin
               s := '';
               if Op2.idata > 1 then
                 for val := 1 to Op2.idata do s := s +  Op1.sdata;
               sdata := s;
             end
            else sdata := Op1.sdata;
          cmdMath4: sdata := Op1.sdata;
        end;
    data_real:
      begin
        case Op2.Data_type of
          0: valR := 0;
          data_int: ValR := Op2.idata;
          data_str: ValR := Str2Double(Op2.sdata);
          data_real:ValR := Op2.rdata;
        end;
        case Optype of
          cmdMath1: rdata := Op1.rdata + ValR;
          cmdMath2: rdata := Op1.rdata - ValR;
          cmdMath3: rdata := Op1.rdata * ValR;
          cmdMath4: rdata := Op1.rdata / ValR;
        end;
      end;
   end;
end;

function TScript.CalcCmp;
begin
    if Op1.Data_type <> Op2.Data_type then
       Result := false
    else
     case OpType of
      cmdCmp1:
       case Op1.Data_type of
        0: Result := true;
        data_int: Result := Op1.idata > Op2.idata;
        data_str: Result := Length( Op1.sdata ) > Length( Op2.sdata );
        data_real: Result := Op1.rdata > Op2.rdata;
       end;
      cmdCmp2:
       case Op1.Data_type of
        0: Result := true;
        data_int: Result := Op1.idata < Op2.idata;
        data_str: Result := Length( Op1.sdata ) < Length( Op2.sdata );
        data_real: Result := Op1.rdata < Op2.rdata;
       end;
      cmdCmp3:
       case Op1.Data_type of
        0: Result := true;
        data_int: Result := Op1.idata >= Op2.idata;
        data_str: Result := Length( Op1.sdata ) >= Length( Op2.sdata );
        data_real: Result := Op1.rdata >= Op2.rdata;
       end;
      cmdCmp4:
       case Op1.Data_type of
        0: Result := true;
        data_int: Result := Op1.idata <= Op2.idata;
        data_str: Result := Length( Op1.sdata ) <= Length( Op2.sdata );
        data_real: Result := Op1.rdata <= Op2.rdata;
       end;
      cmdCmp5:
       case Op1.Data_type of
        0: Result := true;
        data_int: Result := Op1.idata <> Op2.idata;
        data_str: Result := Op1.sdata <> Op2.sdata;
        data_real: Result := Op1.rdata <> Op2.rdata;
       end;
      cmdCmp6:
       case Op1.Data_type of
        0: Result := true;
        data_int: Result := Op1.idata = Op2.idata;
        data_str: Result := Op1.sdata = Op2.sdata;
        data_real: Result := Op1.rdata = Op2.rdata;
       end;
     end;
end;

function DataToBool(Op:PData):boolean;
begin
   case Op.Data_type of
     0: Result := false;
     data_int: Result := Op.idata <> 0;
     data_str: Result := Op.sdata <> '';
     data_real:Result := Op.rdata <> 0;
   end;
end;

procedure TScript.ExecOp;
var
  Op1,Op2,Op3:PData;
  Temp:PData;
  Ind:integer;
begin
   case OpType of
     cmdOp1:
       begin
          Op2 := Stack.Pop;
          Op1 := Stack.Pop;
          MoveOp(Op1,Op2);
       end;
     cmdOp2..cmdOp5:
       begin
          Op2 := Stack.Pop;
          Op1 := Stack.Pop;
          CalcMath(cmdMath1 + OpType - cmdOp2,Op1,Op1,Op2);
       end;
     cmdMath1..cmdMath4:
       begin
          Op2 := Stack.Pop;
          Op1 := Stack.Pop;
          Temp := Stack.Temp;
          CalcMath(opType,Temp,Op1,Op2);
       end;
     cmdMath5:
       begin
          Op1 := Stack.Pop;
          Temp := Stack.Temp;
          Temp.Data_type := Op1.Data_type;
          with Temp^ do
           case Op1.Data_type of
            0:;
            data_int: idata := -Op1.idata;
            data_str:;
            data_real: rdata := -Op1.rdata;
           end;
       end;
     cmdCmp1..cmdCmp6:
      begin
          Op2 := Stack.Pop;
          Op1 := Stack.Pop;
          Temp := Stack.Temp;
          with Temp^ do
           begin
            Data_type := data_int;
            idata := integer(CalcCmp(OpType,Op1,Op2));
           end;
      end;
     cmdCmp7:
      begin
          Op3 := Stack.Pop;
          Op2 := Stack.Pop;
          Op1 := Stack.Pop;
          Temp := Stack.Temp;
          with Temp^ do
           begin
             Data_type := data_int;
             if (Op1.Data_type = data_int)and(Op2.Data_type = data_int)
                and(Op3.Data_type = data_int)then
               idata := integer( (Op1.idata <= Op3.idata)and(Op3.idata <= Op2.idata))
             else if (Op1.Data_type = data_real)and(Op2.Data_type = data_real)
                and(Op3.Data_type = data_real)then
               idata := integer( (Op1.rdata <= Op3.rdata)and(Op3.rdata <= Op2.rdata))
             else idata := 0;
           end;
      end;
     cmdOr,cmdAnd:
      begin
          Op2 := Stack.Pop;
          Op1 := Stack.Pop;
          Temp := Stack.Temp;
          with Temp^ do
           begin
            Data_type := data_int;
            if OpType = cmdOr then
             idata := integer(DataToBool(Op1) or DataToBool(Op2))
            else idata := integer(DataToBool(Op1) and DataToBool(Op2));
           end;
      end;
     cmdNot:
      begin
        Op1 := Stack.Pop;
        Temp := Stack.Temp;
        with Temp^ do
         begin
          Data_type := data_int;
          case Op1.Data_type of
           0: idata := 1;
           data_int:  if Op1.idata = 0 then idata := 1 else idata := 0;
           data_str:  if Op1.sdata = '' then idata := 1 else idata := 0;
           data_real: if Op1.rdata = 0 then idata := 1 else idata := 0;
          end;
         end;
      end;
     cmdIf:
       begin
          Op2 := Stack.Pop;
          Op1 := Stack.Pop;
          Temp := nil;
          case Op1.Data_type of
            0:;
            data_int:  if Op1.idata <> 0 then Temp := pointer(1);
            data_str:  if Op1.sdata <> '' then Temp := pointer(1);
            data_real: if Op1.rdata <> 0 then Temp := pointer(1);
          end;
          if Temp = nil then
            Index := Op2.idata;
       end;
     cmdElse: Index := Stack.Pop.idata;
     cmdInc:
       begin
         Op1 := Stack.Pop;
         inc(Op1.idata);
       end;
     cmdPop: Stack.Pop;
     cmdIs..cmdIs+3:
       begin
         Op1 := Stack.Pop;
         Temp := Stack.Temp;
         with Temp^ do
          begin
            Data_type := data_int;
            idata := integer(Op1.Data_type = (OpType-cmdIs));
          end;
       end;
     cmdArray:
      begin
          Op2 := Stack.Pop;
          Op1 := Stack.Pop;
          if Op1.data_type <> 5 then
           begin
             Op1.idata := integer(TArray.Create);
             Op1.data_type := 5;end;
          TArray(Op1.idata).SetSize(ToInteger(Op2));
      end;
     cmdArInd:
      begin
          Op2 := Stack.Pop;
          Op1 := Stack.Pop;
          case Op1.Data_type of
           0,data_int,data_real: Stack.Temp.data_type := data_null;
           data_str:
              begin
                Temp := Stack.Temp;
                Temp.Data_type := data_str;
                if Op2.idata <= length(Op1.sdata) then
                  Temp.sdata := Op1.sdata[Op2.idata];
                //pointer(Temp.sdata) := @Op1.sdata[Op2.idata];
              end;
           5:
             begin
              Ind := ToInteger(Op2);
              if(Ind >= 0)and( Ind  < TArray(Op1.idata).Count ) then
               Stack.Push(@TArray(Op1.idata).Items[Ind],1)
              else
               begin
                ShowMessage('Array Index overful');
                Stack.Temp.data_type := data_null;
               end;
             end;
          end;
      end;
     cmdExit: Index := Stack.RFunc.Body.Count;
     cmdAddr:
      begin
         Op1 := Stack.Pop;
         with  Stack.Temp^ do
          begin
            data_type := data_str;
            sdata := Funcs.Items[integer(op1)].Name;
          end;
      end;
   end;
   Stack.Flush;
end;

function TScript.BuildVar;
begin
   with Code do
    case cmdType of
     offVar :  Result := @Funcs.Vars.Table[cmd];
     offArg :  Result := @Funcs.Args.Table[cmd];
     offGVar:  Result := @Vars.Table[cmd];
    end;
end;

procedure TScript.PutVar;
begin
   with Code do
    case cmdType of
     offVar : Stack.Push(@Stack.RFunc^.Vars.Table[cmd].Value,1);
     offArg : Stack.Push(Stack.RFunc^.Args.Table[cmd].Value,1);
     offGVar: Stack.Push(@Vars.Table[cmd].Value,1);
    end;
end;

function TScript.ExecuteFunction;
var i:smallint;
    Arg:PData;
    TmpArg:TRealFuncArg;
    tmpRFunc:pointer;
begin
           SetLength(TmpArg,Args.Count);
            for i := Args.Count-1 downto 0 do
              begin
               Arg := Stack.Pop;
               if Args.Table[i].CallType = ByVal then
                 begin
                   new(TmpArg[i]);
                   TmpArg[i].Data_type := 0;
                   MoveOp( TmpArg[i], Arg );
                   //Stack.Flush;
                 end
               else TmpArg[i] := Arg;
              end;
           Result := Body(TmpArg);
            for i := 0 to Args.Count-1 do
              if Args.Table[i].CallType = ByVal then
                begin
                  if TmpArg[i].Data_type = 5 then
                    FreeData_(TmpArg[i]^);
                  Dispose(TmpArg[i]);
                end;
end;

procedure TScript.ExecFunc;
var i:word;
    Arg:PData;
    TmpArg:TRealFuncArg;
    tmpRFunc:pointer;
    dt:TData;
begin
     case FReal of
      0:
       with RFuncs.Items[FuncIndex] do
         dt := ExecuteFunction(Stack,Body,Args);
      1:
       with LocRFuncs.Items[FuncIndex] do
         dt := ExecuteFunction(Stack,Body,Args);
      2:
        with Funcs.Items[FuncIndex] do
         begin
            tmpRFunc := Stack.RFunc;
            with Funcs.Items[FuncIndex] do
             if Args.Count > 0 then
              for i := Args.Count-1 downto 0 do
               begin
                 Arg := Stack.Pop;
                 with Args.Table[i] do
                  if CallType = ByVal then
                   begin
                    New(Value);
                    Value.Data_type := 0;
                    MoveOp(Value,Arg);
                    ///// интересно зачем????
                    //Stack.Flush;
                    /////
                   end
                  else Value := Arg;
               end;
            Stack.RFunc := @Funcs.Items[FuncIndex];
            dt := RunFunc(Stack);
            Stack.RFunc := tmpRFunc;
            if Args.Count > 0 then
             for i := 0 to Args.Count-1 do
              if Args.Table[i].CallType = ByVal then
                begin
                  if Args.Table[i].Value.Data_type = 5 then
                    FreeData_( Args.Table[i].Value^ );
                  Dispose(Args.Table[i].Value);
                end;
         end;
      end;
     Stack.Temp^ := dt;
end;

procedure TScript.ExecOop;
var
 ind:word;
 dt:TData;
 tmp:TRealFuncArg;
 p:boolean;
 _Oop:TOOP;
begin
   case OType of
    offOOP : _oop := oop;
    offGOOP: _oop := GOop;
   end;

    ind := integer(stack.Pop);
    with _Oop.Items[FuncIndex].Obj.Items[ind] do
     case MType of
      1:
        begin
          p := boolean(stack.Pop);
          dt := ExecuteFunction(Stack,Body,Args);
          if not p then
            Stack.Temp^ := dt;
        end;
      2: ;
      3:
        if  boolean(stack.Pop) then
         begin
           SetLength(tmp,1);
           Tmp[0] := Stack.Pop;
           Body(Tmp);
         end
        else Stack.Temp^ := Body(nil);
     end;
end;

function TScript.RunFunc;
var Index:word;
begin
   Index := 0;
   while Index < Stack.RFunc.Body.Count do
    with Stack.RFunc.Body.Code[Index] do
     begin
      case CmdType of
       offVar,offArg,offGVar: PutVar( Stack,Stack.RFunc.Body.Code[Index] );
       offOp  : ExecOp(Stack,Index, Cmd);
       offFunc: ExecFunc(Stack,2,Cmd);
       offLRFunc: ExecFunc(Stack,1,Cmd);
       offRFunc:  ExecFunc(Stack,0,Cmd);
       offOop,offGOOP:  ExecOop(Stack,CmdType,Cmd);
       offStack:  Stack.push( pointer(Cmd), 2 );
      end;
      inc(Index);
     end;
   Result := Stack.RFunc.Vars.Table[0].Value;
end;

function TScript.Run;
var
  i:smallint;
  Stack:TStack;
begin
   if err.Count > 0 then exit;

   if Funcs.Find(FuncName) then
    with Funcs.Items[Funcs.FindIndex].Args do
     begin
       Stack := TStack.Create;
       Stack.RFunc := @Funcs.Items[Funcs.FindIndex];
       for i := 0 to Count-1 do
        with Table[i] do
         if CallType = ByVal then
           begin
             new(Value);
             //FillChar(value^,sizeof(TData),0);
             Value^ := _Args[i]^;
             //_debug(int2str(value.data_type) + ':' + Value.sdata);
           end
         else Value := _Args[i];

       Result := RunFunc(Stack);
       for i := 0 to Count-1 do
        if Table[i].CallType = ByVal then
         Dispose(Table[i].Value);
       Stack.Destroy;
     end;
end;

////////////////////////////////////////////////////////////

constructor TVars.Create;
begin
   inherited Create;
end;

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ~~~~~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

destructor TVars.destroy;
var i:integer;
begin
   for i := 0 to Count-1 do
    FreeData_(Table[i].Value);
   inherited Destroy;
end;

function TVars.Find;
var i:word;
begin
   if Count > 0 then
    for i := 0 to Count-1 do
     if(Table[i].Name <> '')and( Table[i].Name = Name ) then
       begin
         Result := true;
         FindIndex := i;
         Exit;
       end;
   Result := false;
end;

procedure TVars.Delete;
begin
end;

function TVars.AddVar;
begin
   inc(Count);
   SetLength(Table,Count);
   Result := Count-1;
   Table[Result].Name := Name;
   Table[Result].Flag := _Flag;
   FillChar(Table[Result].Value,sizeof(TData),0);
   if _Flag = IS_LABEL then
     Table[Result].Value.Data_type := data_int;
end;

procedure TVars.Clear;
begin
   Count := 0;
   SetLength(Table,Count);
end;

////////////////////////////////////////////////////////////

constructor TArgs.Create;
begin
   inherited Create;
end;

function TArgs.Find;
var i:word;
begin
   if Count > 0 then
    for i := 0 to Count-1 do
     if(Table[i].Name <> '')and( Table[i].Name = Name ) then
       begin
         Result := true;
         FindIndex := i;
         Exit;
       end;
   Result := false;
end;

function TArgs.AddVar;
begin
   inc(Count);
   SetLength(Table,Count);
   Result := Count-1;
   Table[Result].Name := Name;
   Table[Result].CallType := CallType;
end;

procedure TArgs.Clear;
begin
   Count := 0;
   SetLength(Table,Count);
end;

////////////////////////////////////////////////////////////

procedure TBody.AddCode;
begin
  inc(Count);
  SetLength(Code,Count);
  Code[Count-1].CmdType := _CmdType;
  Code[Count-1].Cmd := _Cmd;
end;

////////////////////////////////////////////////////////////

procedure TArray.SetSize;
var i:integer;
begin
   FCount := max(0,FCount);
   if FCount < Count then
    for i := FCount to Count-1 do
     FreeData_(Items[i]);
   Count := FCount;
   SetLength(Items,Count);
end;

procedure TArray.SetType;
var i:integer;
begin
  for i := 0 to Count-1 do
   SetDataType(Items[i],_Type);
end;

destructor TArray.Destroy;
var i:integer;
begin
  for i := 0 to Count-1 do
   FreeData_(Items[i]);
  SetLength(Items,0);
  inherited;
end;

////////////////////////////////////////////////////////////

function TFunc.Find;
var i:word;
begin
   if Count > 0 then
    for i := 0 to Count-1 do
     if StrIComp( PChar(Items[i].Name),PChar( Name) ) = 0 then
      begin
        Result := true;
        FindIndex := i;
        Exit;
      end;
   Result := false;
end;

procedure TFunc.Add;
begin
   inc(Count);
   SetLength(Items,Count);
   with Items[Count-1] do
    begin
      Name := LowerCase( _Name );
      Hint := _Name;
      Body := TBody.Create;
      Vars := TVars.Create;
      Args := TArgs.Create;
    end;
   Vars := Items[Count-1].Vars;
   Args := Items[Count-1].Args;
   Body := Items[Count-1].Body;
   Vars.AddVar('result',IS_VAR);
end;

function TFunc.AddCode;
begin
   Body.AddCode(_CmdType,_Cmd);
   Result := Body.Count-1;
end;

procedure TFunc.Clear;
var i:integer;
begin
   if count = 0 then exit;

   if Count > 1 then
   for i := 1 to Count-1 do
    begin
      Items[i].Args.Destroy;
      Items[i].Body.Destroy;
      Items[i].Vars.Destroy;
    end;
   Count := 1;
   SetLength(Items,Count);
   InFunc := false;
end;

procedure ClearVar(Arr:PData);
var i:word;
begin
   if Arr.Data_type <> 5 then
     begin
        Arr.idata := 0;
        Arr.sdata := '';
        Arr.rdata := 0.0;
     end
   else
    for i := 0 to Arr.idata-1 do
     ClearVar(@TDataArray(pointer(Arr.sdata)^)[i]);
end;

///////////////////////////////////////////////////////////////

function TRFunc.Find;
var i:word;
begin
   if Count > 0 then
    for i := 0 to Count-1 do
     if Items[i].Name = Name then
      begin
        Result := true;
        FindIndex := i;
        Exit;
      end;
   Result := false;
end;

procedure TRFunc.Add;
var i:byte;
begin
   inc(Count);
   SetLength(Items,Count);
   with Items[Count-1] do
    begin
     Name := LowerCase(_Name);
     Hint := _Name;
     Body := FBody;
     Args := TArgs.Create;
     if High(FArgs) >= 0 then
     if FArgs[0] <> '' then
      for i := 0 to High(FArgs) do
        if FArgs[i][1] = '@' then
          begin
            delete(FArgs[i],1,1);
            Args.AddVar( FArgs[i],ByRef)
          end
        else Args.AddVar(FArgs[i],ByVal);
    end;
end;

initialization

   Def := TDef.Create;
   RFuncs := TRFunc.Create;
   GOop := TOOP.Create;
   Types := NewStrList;
   {$ifdef F_P}
   with Types do
   {$else}
   with Types^ do
   {$endif}
    begin
      Add('integer');
      Add('string');
      Add('real');
    end;
   TFunctions.Create;

end.
