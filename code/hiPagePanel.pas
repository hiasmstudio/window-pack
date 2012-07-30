unit hiPagePanel;

interface

uses Kol,Share,Debug,Win;

type
  THIPagePanel = class(THIWin)
   private
     function PageIndex:integer;
     procedure _OnChange(Obj:PObj);
   public
     _prop_Caption:string;
     _prop_ImageIndex:integer;

     _event_onChange: THI_Event;
     
     constructor Create(_Control:PControl); overload;
     destructor Destroy; override;
     procedure Init; override;
     
     procedure _work_doCaption(var Data:TData; index:word);   
     procedure _work_doImageIndex(var Data:TData; index:word);    
  end;

implementation

constructor THIPagePanel.Create(_Control:PControl); 
begin
   inherited;
   Control := _Control;
end;

destructor THIPagePanel.Destroy;
begin
   Control :=  nil;
   NoKill := true;
   inherited;
end;

procedure THIPagePanel.Init;
begin
   if _prop_Caption <> '' then
     Control.Parent.TC_Items[PageIndex] := _prop_Caption;
   if _prop_ImageIndex <> -1 then
     Control.Parent.TC_Images[PageIndex] := _prop_ImageIndex;
   Control.Parent.OnSelChange := _OnChange;
end;

function THIPagePanel.PageIndex:integer;
var i:integer;
begin
   Result := -1;
   for i := 0 to Control.Parent.Count-1 do
     if Control.Parent.Pages[i] = Control then
       begin
         Result := i;
         exit;
       end;
end;

procedure THIPagePanel._work_doCaption;
begin
  Control.Parent.TC_Items[PageIndex] := ToString(Data);
end;

procedure THIPagePanel._work_doImageIndex;
begin
  Control.Parent.TC_Images[PageIndex] := ToInteger(Data);
end;

procedure THIPagePanel._OnChange;
begin
  _hi_OnEvent(_event_onChange, Control.Parent.CurIndex);
end;

end.