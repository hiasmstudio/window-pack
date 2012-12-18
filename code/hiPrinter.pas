unit hiPrinter;

interface

uses Kol,Share,Debug,KOLPrintDialogs,KOLPageSetupDialog,KOLPrinters,Windows;

{$I share.inc}

type
  THIPrinter = class(TDebug)
   private
    PageSetupDialog1: TKOLPageSetupDialog;
    PrintDialog1: TKOLPrintDialog;
   public
    _prop_Title:string;
    _prop_PrnFileName:string;    
    
    _data_RichEdit:THI_Event;
    _data_Text:THI_Event;
    _event_onPrint:THI_Event;

    constructor Create;
    destructor Destroy; override;
    procedure _work_doSettings(var _Data:TData; Index:word);
    procedure _work_doPrintDlg(var _Data:TData; Index:word);    
    procedure _work_doPrint(var _Data:TData; Index:word);
    procedure _work_doPrnFileName(var _Data:TData; Index:word);    
    procedure _var_Context(var _Data:TData; Index:word);
    procedure _var_CurDPIX(var _Data:TData; Index:word);
    procedure _var_CurDPIY(var _Data:TData; Index:word);  
  end;

implementation

constructor THIPrinter.Create;
begin
   inherited;
   PageSetupDialog1 := NewPageSetupDialog(Applet.Children[0],[]);
   PrintDialog1 := NewPrintDialog(Applet.Children[0],[pdHelp,pdPrintToFile,pdSelection,pdCollate,pdPageNums]);   
end;

destructor THIPrinter.Destroy;
begin
   PageSetupDialog1.Free;
   inherited;
end;

procedure THIPrinter._work_doPrintDlg;
begin
  PrintDialog1.Options := PrintDialog1.Options + [pdCollate,pdPrintToFile,pdPageNums,pdSelection,pdWarning,pdHelp];
  PrintDialog1.FromPage :=1;
  PrintDialog1.ToPage :=1;
  PrintDialog1.MinPage :=1;
  PrintDialog1.MaxPage :=200;
  PrintDialog1.Advanced := 1;
  if PrintDialog1.Execute then
  begin
    Printer.Assign(PrintDialog1.Info);
    if pdPrintToFile in PrintDialog1.Options then Printer.Output := _prop_PrnFileName;;
    _work_doPrint(_Data, 0);
  end;
end;

procedure THIPrinter._work_doSettings;
begin
  PageSetupDialog1.SetMinMargins(500,500,500,500); //set min margins user can select
  PageSetupDialog1.SetMargins(1500,1500,1500,1500); //set initial margins in dialog
  PageSetupDialog1.Advanced := 1;
  if PageSetupDialog1.Execute then
    begin
      Printer.Assign(PageSetupDialog1.Info);
      Printer.AssignMargins(PageSetupDialog1.GetMargins,mgMillimeters);//assign selected marins to printer
    end;
end;

procedure THIPrinter._work_doPrint;
var re:PControl;
    dt:TData;
    cm:TRect;
begin
   with Printer{$ifndef F_P}^{$endif} do 
    begin
      Title := _prop_Title;
      if System.Assigned(_data_Text.Event) or not System.Assigned(_data_RichEdit.Event) then
       begin
         BeginDoc;
         WriteLn(ReadString(_Data,_data_Text,''));
         _hi_OnEvent(_event_onPrint, integer(Handle));
         EndDoc;
       end
      else 
       begin
         dt := ReadData(_Data,_data_RichEdit,nil);
         if Dt.sdata = 'RichEdit' then 
          begin
            re := pointer(Dt.idata);
            RE_Print(re);
          end;
       end;
    end;
end;

procedure THIPrinter._var_Context;
begin
  dtInteger(_Data,Printer.Handle);
end;

procedure THIPrinter._var_CurDPIX;
begin
   dtInteger(_Data,GetDeviceCaps(Printer.Handle, LOGPIXELSX));
end;

procedure THIPrinter._var_CurDPIY;
begin
   dtInteger(_Data,GetDeviceCaps(Printer.Handle, LOGPIXELSY));
end;

procedure THIPrinter._work_doPrnFileName;
begin
  _prop_PrnFileName := ToString(_Data);
end;

end.