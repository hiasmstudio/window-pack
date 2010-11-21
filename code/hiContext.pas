unit hiContext;

interface

uses Kol,Share;

type
  THIContext = class
   private
   public
    _prop_Info:string;
    _prop_Name:string;
    _prop_Menu:string;
    _prop_FileType:string;

    _event_onCurrentDir:THI_Event;
    _event_onCommand:THI_Event;
    _event_onFileName:THI_Event;
  end;

implementation

begin
 EventOn;
end.
