program PostOffice;

uses
  Windows,
  SysUtils,
  Dialogs,
  Forms,
  LDApp,
  LDAppID in '..\..\..\..\Business Objects\LDAppID.pas',
  Resource_RPO in '..\..\..\..\Business Objects\Resource_RPO.pas',
  LDConsts,
  LDUtils,
  Business_Custom in '..\..\..\..\Business Objects\Business_Custom.pas' {LDBusiness: TDataModule},
  PostOffice_Constants in '..\..\PostOffice_Constants.pas',
  Business_PostOffice in '..\..\Business Objects\Business_PostOffice.pas' {f: TDataModule},
  Form_Splash in '..\..\Form_Splash.pas' {LDSplashForm},
  Form_Main in '..\..\Form_Main.pas' {LDMainForm},
  CustomDevice in '..\..\Devices\CustomDevice.pas' {LDDevice: TDataModule},
  CustomDocument in '..\..\Documents\CustomDocument.pas' {LDDocument: TDataModule},
  PO_Document in '..\..\Documents\PO\PO_Document.pas' {LDPODocument: TDataModule},
  PO_RPO_Constants in 'PO_RPO_Constants.pas',
  PrintDevice in '..\..\Devices\PRINT\PrintDevice.pas' {LDPrintDevice: TDataModule},
  EDIDevice in '..\..\Devices\EDI\EDIDevice.pas' {LDEDIDevice: TDataModule},
  EDIClasses in '..\..\Classes\EDI\EDIClasses.pas',
  EDIClassesPO_RPO in '..\..\Classes\EDI\PO_RPO\EDIClassesPO_RPO.pas',
  EmailDevice in '..\..\Devices\EMAIL\EmailDevice.pas' {LDEmailDevice: TDataModule},
  EmailClasses in '..\..\Classes\Email\EmailClasses.pas',
  PDFClasses in '..\..\Classes\PDF\PDFClasses.pas',
  EDIAckDevice in '..\..\Devices\EDI_ACK\EDIAckDevice.pas' {LDEDIAckDevice: TDataModule},
  EDIAck855Device in '..\..\Devices\EDI_ACK\EDI_ACK_855\EDIAck855Device.pas' {LDEDIAck855Device: TDataModule},
  W2kFax in '..\..\Classes\Fax\W2kFax.pas',
  FaxDevice in '..\..\Devices\FAX\FaxDevice.pas' {LDFaxDevice: TDataModule},
  Forecast_Document in '..\..\Documents\Forecast\Forecast_Document.pas' {LDForecastDocument: TDataModule},
  EDIClassesForecast in '..\..\Classes\EDI\Forecast\EDIClassesForecast.pas',
  StoreMemo_Document in '..\..\Documents\StoreMemo\StoreMemo_Document.pas' {LDStoreMemoDocument: TDataModule},
  RPO_Document in '..\..\Documents\RPO\RPO_Document.pas' {LDRPODocument: TDataModule},
  LDPassword in '..\..\LDPassword.pas',
  StoreMemo_Constants in 'StoreMemo_Constants.pas',
  overdue_rpo_document in '..\..\Documents\OVERDUE_RPO\overdue_rpo_document.pas' {LDRPOOverdueDocument: TDataModule},
  AWIErrorReport in '..\..\Documents\AWIErrorReport\AWIErrorReport.pas' {LDAWIErrorReport: TDataModule},
  FAXCOMLib_TLB in '..\..\Devices\FAX\FAXCOMLib_TLB.pas',
  FTPDevice in '..\..\Devices\FTP\FTPDevice.pas' {LDFTPDevice: TDataModule},
  FTPDailyAuditReport in '..\..\Documents\FTPDailyAuditReport\FTPDailyAuditReport.pas' {LDFTPDailyAuditReport: TDataModule},
  FTPCheckDevice in '..\..\Devices\FTP_CHECK\FTPCheckDevice.pas' {LDFTPCheckDevice: TDataModule},
  FTPCheck in '..\..\Documents\FTPCheck\FTPCheck.pas' {LDFTPDailyCheck: TDataModule},
  RACNotification in '..\..\Documents\RACNotification\RACNotification.pas' {LDRACNotification: TDataModule},
  MyFax in '..\..\Devices\MyFax.pas',
  superobject in '..\..\SuperObject\superobject.pas',
  supertypes in '..\..\SuperObject\supertypes.pas',
  SPCopyUpload in 'SPCopyUpload.pas',
  Resource_BO in '..\..\Business Objects\Resource_BO.pas';

{$R *.RES}
Var
  TestRec : Integer;
  I: Integer;
  Terminated: Boolean = False;
  
procedure CtrlHandler(Code: DWORD); stdcall;
begin
if Code = CTRL_C_EVENT then
  Terminated := True;
end;
Procedure WriteToLog(const S: String);
Var F:TextFile;
  Procedure InsertDateOnFileName(Var LogFileName: String);
  begin
  if Pos('-',LogFileName) <= 0 then
    LogFileName := ExtractFilePath(ParamStr(0)) + 'LOGS\' + Copy(LogFileName,1, pos('.log',LogFileName))+FormatDateTime('yyyy-mmm-dd', Now)+'.log';
  end;
begin
if not WriteLog then Exit;
InsertDateOnFileName(LogFileName);
AssignFile(F,LogFileName);
Try
  if FileExists(LogFileName) then Append(F)
                             else Rewrite(F);
  WriteLn(F, DateTimeToStr(now)+' : '+S);
  Flush(F);
  CloseFile(F);
Except
  on e:Exception do
    LogFileName := e.message;
  end;
end;

begin
  if not IsRunning(ExtractFileName(ParamStr(0))) then
  begin
    Application.Initialize();
    LDApplication.Initialize(SApplicationPostOfficeID, amServer);

    Application.CreateForm(TLDMainForm, LDMainForm);
  Application.CreateForm(TLDPostOffice, LDPostOffice);
  Application.CreateForm(TLDFTPDailyAuditReport, LDFTPDailyAuditReport);
  Application.CreateForm(TLDFTPDailyCheck, LDFTPDailyCheck);
  Application.CreateForm(TLDRACNotification, LDRACNotification);
  LDPostOffice.Open;

    RegisterMedia(SMediaCodePrint,     TLDPrintDevice);
    RegisterMedia(SMediaCodeEmail,     TLDEmailDevice);
    RegisterMedia(SMediaCodeFax,       TLDFaxDevice);
    RegisterMedia(SMediaCodeData,      TLDDataDevice);
    RegisterMedia(SMediaCodeEDI,       TLDEDIDevice);
    RegisterMedia(SMediaCodeEDIAck855, TLDEDIAck855Device);
    RegisterMedia(SMediaCodeFTP,       TLDFTPDevice);
    RegisterMedia(SMediaCodeFTP2,      TLDFTPDevice);
    RegisterMedia(SMediaCodeFTPCheck,  TLDFTPCheckDevice);
    RegisterMedia(SMediaCodeFTP2Check,  TLDFTPCheckDevice);

    //Register all types of Documents
    RegisterDocument(SDocumentCodePO,         TLDPODocument);
    RegisterDocument(SDocumentCodeRPOMerch,   TLDRPODocument);
    RegisterDocument(SDocumentCodeRPOCustom,  TLDRPODocument);
    RegisterDocument(SDocumentCodeStoreMemo,  TLDStoreMemoDocument);
    RegisterDocument(SDocumentCodeRPOOverdue, TLDRPOOverdueDocument);
    RegisterDocument(SDocumentAWIErrorList,   TLDAWIErrorReport);
    RegisterDocument(SDocumentCodeFTPReport,  TLDFTPDailyAuditReport);
    RegisterDocument(SDocumentCodeFTP2Report, TLDFTPDailyAuditReport);
    RegisterDocument(SDocumentCodeFTPCheck,   TLDFTPDailyCheck);
    RegisterDocument(SDocumentCodeFTP2Check,  TLDFTPDailyCheck);
    RegisterDocument(SDocumentCodeRACReport,  TLDRACNotification);
    SPostOfficeDocuments := 'Documents: PO, RPO, Store Memo, RPO Overdue, AWI Error List, FTP Report, RAC Report.';

    if LDApplication.Environment <> SEnvironmentPROD then
    begin
      RegisterDocument(SDocumentCodeForecast,  TLDForecastDocument);
      SPostOfficeDocuments := 'Documents: PO, RPO, Forecast, Store Memo, RPO Overdue, AWI Error List, FTP Report, RAC Report.';
    end;

    LogFileName  := 'PostOffice.log';

    WriteLog := false;
    TelusCloudFax := true; // new default // sidney
    TelusFaxPrefix := '1';
    FaxDaysToRetrieve := 30; // new default // sidney
    QueueIdToForce := 0; // Usually it should never force a Queue ID
    LDMainForm.Title:= SPostOfficeTitle + SPostOfficeDocuments + SPostOfficeBusy;
    For I:= 0 to ParamCount do begin
      if (UpperCase(Trim(ParamStr(I))) = 'USE_LOG') then begin
        WriteLog := true;
        LDMainForm.Title:= LDMainForm.Title + ' - LOG';
      end;
      if (UpperCase(Trim(ParamStr(I))) = 'TELUSCLOUDFAX') then begin
        TelusCloudFax := true;
        LDMainForm.Title:= LDMainForm.Title + ' - TelusCloudFax';
      end;
      if (UpperCase(Trim(ParamStr(I))) = 'FAXDAYSTORETRIEVE') then begin
        if ParamCount>=(I+1) then begin
          FaxDaysToRetrieve := StrToIntDef(ParamStr(I+1),1);
          LDMainForm.Title:= LDMainForm.Title + ' - FaxDays:'+IntToStr(FaxDaysToRetrieve);
        end;
      end;
      if (UpperCase(Trim(ParamStr(I))) = 'TELUSFAXPREFIX') then begin
        if ParamCount>=(I+1) then begin
          TelusFaxPrefix := ParamStr(I+1);
          LDMainForm.Title:= LDMainForm.Title + ' - FaxPrefix:'+TelusFaxPrefix;
        end;
      end;
      if (UpperCase(Trim(ParamStr(I))) = 'QUEUEID') then begin
        if ParamCount>=(I+1) then begin
          QueueIDToForce := StrToIntDef(ParamStr(I+1),1);
          LDMainForm.Title:= LDMainForm.Title + ' - Queue ID to Force:'+IntToStr(QueueIDToForce);
        end;
      end;
    end;
//  LDPostOffice.Open;

    SetConsoleCtrlHandler(@CtrlHandler, True);
    while not Terminated do
    begin
      try
        LDPostOffice.Start;
      except
        on E: Exception do
          WriteToLog('ERROR in the main loop at the DPR file: '+ E.Message);
      end;

      Sleep(200); // prevents CPU spinning
    end;

    // Application.Run();
  end
  else
    ShowMessage('An instance of the application is already running!');

end.
