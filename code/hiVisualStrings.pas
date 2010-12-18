unit hiVisualStrings;

interface

uses Kol, Share, Debug;

type
  THIVisualStrings = class(TDebug)
   private
   public
    _prop_Lines:string;
    _prop_Width:integer;
    _prop_Height:integer;
    _prop_Font:TFontRec;
    _event_onText:THI_Event;

    procedure _work_doText(var _Data:TData; Index:word);    
    procedure _var_Text(var _Data:TData; Index:word);
  end;

implementation

procedure THIVisualStrings._work_doText;
begin
  _hi_CreateEvent(_Data, @_event_onText, _prop_Lines); 
end;

procedure THIVisualStrings._var_Text;
begin
  dtString(_Data, _prop_Lines);
end;

end.