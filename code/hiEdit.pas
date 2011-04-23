unit hiEdit;

interface

uses Kol,Share,Win,Windows,Messages;

type
  Tfunc = function(const s:string; var dt:TData):boolean;
  THIEdit = class(THIWin)
   private
    FOld:string;
    FPos:integer;
    ChangeEvent,Fchange:boolean;

    function NoText(func:Tfunc; var dt:TData):boolean;
    procedure _OnChange(Obj:PObj);
    procedure _OnKeyDown( Sender: PControl; var Key: Longint; Shift: DWORD ); override;
   public
    _prop_DataType:function(var dt:Tdata):boolean of object;
    _prop_Password:boolean;
    _prop_ClearAfterEnter: boolean;
    _prop_Text:string;
    _prop_ReadOnly:boolean;
    _prop_Alignment:byte;
    _prop_MaxLenField:integer;

    _data_Str:THI_Event;
    _event_onEnter:THI_Event;
    _event_onChange:THI_Event;

    constructor Create(Parent:PControl);
    procedure Init; override;

    function Text(var dt:Tdata):boolean;
    function Number(var dt:Tdata):boolean;
    function IntegerNumber(var dt:Tdata):boolean;
    function HexNumber(var dt:Tdata):boolean;
    function FloatNumber(var dt:Tdata):boolean;

    procedure _work_doText(var _Data:TData; Index:word);
    procedure _work_doText2(var _Data:TData; Index:word);
    procedure _work_doPosition(var _Data:TData; Index:word);
    procedure _work_doSelectLength(var _Data:TData; Index:word);
    procedure _work_doSelectText(var _Data:TData; Index:word);
    procedure _work_doSelectAll(var _Data:TData; Index:word);
    procedure _work_doReadOnly(var _Data:TData; Index:word);
    procedure _work_doMaxLenField(var _Data:TData; Index:word);
    procedure _var_Text(var _Data:TData; Index:word);

    //********************* FASTED ***************************
    function _fast_Text:string;
  end;

implementation

constructor THIEdit.Create;
begin
   inherited Create(Parent);
   FOld := '';
   FPos := 0;
end;

procedure THIEdit.Init;
var fl:TEditOptions;
begin
   if _prop_Password then
      fl := [eoPassword]
   else fl := [];

   if _prop_ReadOnly then
    Include(Fl,eoReadonly);

   Control := NewEditbox(FParent,fl);
   Control.TextAlign := TTextAlign(_prop_Alignment);

   inherited;
   Control.Perform(em_LimitText,_prop_MaxLenField, 0);
   Control.OnChange := _OnChange;
   Control.Text := _prop_Text;
   FOld := _prop_Text; 
end;

procedure THIEdit._work_doText;
var p:integer;
begin
   Fchange := false;
   p := Control.SelStart;
   Control.Text := ReadString(_Data,_data_Str,'');
   Control.SelStart := p;
end;

procedure THIEdit._work_doText2;
begin
   ChangeEvent := false;
   _work_doText(_Data,0);
end;

procedure THIEdit._work_doPosition;
begin
   Fchange := false;
   Control.SelStart := ToInteger(_Data);
end;

procedure THIEdit._work_doSelectText;
begin
   Fchange := false;
   Control.Selection := ToString(_Data);
end;

procedure THIEdit._work_doSelectAll;
begin
   Fchange := false;
   Control.SelectAll;
end;

procedure THIEdit._work_doSelectLength;
begin
   Fchange := false;
   Control.SelLength := ToInteger(_Data);
end;

procedure THIEdit._var_Text;
begin
   if not _prop_DataType(_Data) then
      dtNull(_Data);
end;

function isHex(const s:string; var dt:TData):boolean;
var i,N:integer;
begin
   Result := false;
   if s = '' then Exit;
   N := 0;
   for i := 1 to Length(s) do
     case s[i] of
      '0'..'9': N := N shl 4 + ord(s[i]) - 48;
      'a'..'f': N := N shl 4 + ord(s[i]) - 87;
      else Exit;
     end;
   Result := true;
   dtInteger(dt,N);
end;

function isNumeric(const s:string; var dt:TData):boolean;
var i:integer;
begin
   Result := false;
   if s = '' then Exit;
   for i := 1 to Length(s) do
     if not(s[i] in['0'..'9'])then Exit;
   Result := true;
   dtInteger(dt,Str2Int(s));
end;

function isFloat(const s:string; var dt:TData):boolean;
var i,j:integer;
begin
   Result := false;
   i := 1;
   if i>Length(s) then Exit;
   if s[i] in['+','-'] then inc(i);j:=i;
   if (i>Length(s))or(not(s[i]in['.','0'..'9'])) then Exit;
   while (i<=Length(s))and(s[i]in['0'..'9']) do inc(i);
   if s[i]='.' then begin
     inc(i);
     while (i<=Length(s))and(s[i]in['0'..'9']) do inc(i);
     if Copy(s,j,i-j)='.' then Exit;
   end;
   while (i<=Length(s))and(s[i]in[' ',#9]) do inc(i);
   if (i<=Length(s))and(s[i]='e') then begin
     inc(i);
     while (i<=Length(s))and(s[i]in[' ',#9]) do inc(i);
     if (i<=Length(s))and(s[i]in['+','-']) then begin
       inc(i);
       while (i<=Length(s))and(s[i]in[' ',#9]) do inc(i);
     end;
     if (i>Length(s))or(not(s[i]in['0'..'9'])) then Exit;
     while(i<=Length(s))and(s[i]in['0'..'9']) do inc(i);
   end;
   if i<=Length(s) then Exit;
   Result := True;
   dtReal(dt, Str2Double(s));
end;

function isInteger(const s:string; var dt:TData):boolean;
begin
   Result := false;
   if s = '' then Exit;
   if s[1] in ['+','-'] then begin
     Result := isNumeric(Copy(s,2,Length(s)-1),dt);
     if s[1] = '-' then dtInteger(dt,-Tointeger(dt));
   end
   else if s[1]='$' then
     Result := isHex(Copy(s,2,Length(s)-1),dt)
   else if (Length(s)>1)and(s[1]='0')and(s[2]='x') then
     Result := isHex(Copy(s,3,Length(s)-2),dt)
   else Result := isNumeric(s,dt);
end;

function THIEdit.NoText;
var s:string;
    st:integer;
begin
   s := Control.Text;
   st := Control.SelStart;
   Result := func(LowerCase(s),dt);
   if Result then
     begin
      FPos := st;
      Fold := s;
      Exit;
     end
   else if not func(LowerCase(s)+'0',dt) then
     begin
      ChangeEvent := false; // Установка Control.Text вызывает _OnChange !!!
      Control.Text := FOld;
      Control.SelStart := FPos;
     end
   else if s = '' then
     begin
      ChangeEvent := false;
      Control.Text := '0';
      FOld := '0';
     end;
end;

function THIEdit.Number;
begin
  Result := NoText(isNumeric, dt);
end;

function THIEdit.IntegerNumber;
begin
  Result := NoText(isInteger, dt);
end;

function THIEdit.HexNumber;
begin
  Result := NoText(isHex, dt);
end;

function THIEdit.FloatNumber;
begin
  Result := NoText(isFloat, dt);
end;

function THIEdit.Text;
begin
   dtString(dt,Control.Text);
   Result := True;
end;

procedure THIEdit._OnChange;
var dt:TData;
begin
   if ChangeEvent then
     if _prop_DataType(dt) then
       _hi_onEvent(_event_onChange,dt);
   ChangeEvent := true;
end;

procedure THIEdit._OnKeyDown;
var dt:TData;
begin
  if Assigned(_event_onEnter.Event) and( Key = 13) then
   begin
     if _prop_DataType(dt) then begin
       Fchange := true;
       _hi_onEvent(_event_onEnter,dt);
       if Fchange and _prop_ClearAfterEnter then begin
         ChangeEvent := false; // Установка Control.Text вызывает _OnChange !!!
         Control.Text := '';
       end;
     end;
     Key := 0;
   end
  else inherited;
end;

function THIEdit._fast_Text:string;
begin
    Result := Control.text;
end;

procedure THIEdit._work_doReadOnly;
begin
  Control.Perform(EM_SETREADONLY, ToInteger(_Data), 0);
end;

procedure THIEdit._work_doMaxLenField;
begin
  _prop_MaxLenField := ToInteger(_Data);
  Control.Perform(em_LimitText, _prop_MaxLenField, 0);
end;

end.
