unit hiMenuEx;

interface

{$I share.inc}

uses Share,XPMenus;

type
  ThiMenuEx = class(TXPMenu)
   private
   public
      property _prop_Menu        : string  write SetMain;
      property _prop_EndItemRight: boolean write fEndItemRight;
      property _prop_IconByIndex : boolean write fIconByIndex;
end;
   implementation
end.