unit hiPopupMenuEx;

interface

{$I share.inc}

uses Share,XPMenus;

type
  ThiPopupMenuEx = class(TXPMenu)
   private
   public
      _prop_EndItemRight: boolean;
      property _prop_Menu        : string  write SetPopUp;
      property _prop_IconByIndex : boolean write fIconByIndex;
end;
   implementation
end.