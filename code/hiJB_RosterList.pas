unit hiJB_RosterList;

interface

uses Kol,Share,Debug,JabberClient;

type
  THIJB_RosterList = class(TDebug)
   private
     client:TJabberClient;
     
     procedure SetClient(value:TJabberClient);
     procedure _OnRosterList(client:TJabberClient; const from:string; const list:TRosterList);
     procedure _OnStatus(client:TJabberClient; const from, status:string);
   public
    _event_onState:THI_Event;
    _event_onContact:THI_Event;

    property _prop_Jabber:TJabberClient read client write SetClient;
  end;

implementation

procedure THIJB_RosterList.SetClient(value:TJabberClient);
begin
  client := value;
  client.OnRosterList := _OnRosterList;
  client.OnStatus := _OnStatus;
end;

procedure THIJB_RosterList._OnRosterList(client:TJabberClient; const from:string; const list:TRosterList);
var i:integer;
    dt:TData;
    mt:PMT;
    s:string;
begin
   for i := 0 to length(list)-1 do
     begin
       mt := mt_make(dt);
       if list[i].name ='' then
         begin
           s := list[i].jid;
           dtString(dt, GetTok(s, '@'));
         end
       else
         dtString(dt, list[i].name);
       mt_string(mt, list[i].jid); 
       mt_int(mt, integer(list[i].subscription));
       _hi_onEvent(_event_onContact, dt);
       mt_free(mt);
     end;
end;

procedure THIJB_RosterList._OnStatus(client:TJabberClient; const from, status:string);
var i:byte;
    dt:TData;
    mt:PMT;
begin
   if status = '' then
     i := 1
   else if status = 'away' then
     i := 2
   else if status = 'chat' then
     i := 3
   else if status = 'dnd' then
     i := 4
   else if status = 'xa' then
     i := 5;

   mt := mt_make(dt);
   dtString(dt, from);
   mt_int(mt, i);
   _hi_onEvent(_event_onState, dt);
   mt_free(mt);
end;

end.
