CREATE PROCEDURE dbo.Alp_ArTransPost_History_proc  
AS  
BEGIN TRY  
 
--02.26.2015 RAVI and MAH:- Corrected the assignment of the postrun variable in Alp_tblarhistDetail table.
--02.26.2015 RAVI and MAH:- Removed Join in Alp_tblarhistDetail inserting script below.
--PET:http://webfront:801/view.php?id=225114  
--PET:http://webfront:801/view.php?id=227179  
--PET:http://webfront:801/view.php?id=238831  
  
DECLARE @PostRun pPostRun, @WrkStnDate datetime, @CommByLineItemYn bit  
  
--Retrieve global values  
SELECT @PostRun = Cast([Value] AS nvarchar) FROM #GlobalValues WHERE [Key] = 'PostRun'  
SELECT @WrkStnDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'WrkStnDate'  
SELECT @CommByLineItemYn = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'CommByLineItemYn'  
  
IF @PostRun IS NULL OR @WrkStnDate IS NULL OR @CommByLineItemYn IS NULL  
BEGIN  
RAISERROR(90025,16,1)  
END  
  
  
--append headers  
INSERT INTO dbo.ALP_tblArHistHeader (AlpFromJobYn ,AlpJobNum ,AlpJobNumRmr ,AlpMailSiteYn ,  
AlpPostRun ,AlpRecBillRef ,AlpRep1AmtYn ,AlpRep2AmtYn ,AlpSendToPrintYn,AlpSiteID,  
AlpSubscriberInvcYn,AlpSvcYn,AlpTransId,AlpUploadDate )  
SELECT alpH.AlpFromJobYN ,alpH.AlpJobNum ,alpH.AlpJobNumRmr ,alpH.AlpMailSiteYn,  
@PostRun ,alpH.AlpRecBillRef,alpH.AlpRep1AmtYn ,alpH.AlpRep2AmtYn , alpH.AlpSendToPrintYn ,alpH.AlpSiteID ,  
alpH.AlpSubscriberInvcYN ,alpH.AlpSvcYN ,alpH.AlpTransId ,alpH.AlpUploadDate  
FROM dbo.Alp_tblArTransHeader alpH  
INNER JOIN tblArTransHeader h On alpH.AlpTransId = h.TransId  
INNER JOIN #PostTransList l ON h.TransId = l.TransId  
LEFT JOIN dbo.tblArDistCode dc on h.DistCode = dc.DistCode  
LEFT JOIN #GainLossAccounts t ON h.CurrencyId = t.CurrencyId  
LEFT JOIN (SELECT p.TransId, SUM(p.PmtAmt) TotPmtAmt, SUM(p.PmtAmtFgn) TotPmtAmtFgn, SUM(p.CalcGainLoss) TotPmtGainLoss  
FROM #PostTransList l  
INNER JOIN dbo.tblArTransPmt p ON l.TransId = p.TransId  
GROUP BY p.TransId) pmt ON h.TransId = pmt.TransId  
--rollup applied payments as of posting (posted and unposted)  
  
--append detail  
INSERT INTO dbo.ALP_tblArHistDetail (AlpAlarmID,AlpEntryNum ,AlpPostRun ,AlpRmrItemYn ,AlpSiteID,AlpTransID )  
--SELECT alpD.AlpAlarmID ,alpD.AlpEntryNum ,1,alpD.AlpRmrItemYn ,alpD.AlpSiteID,alpD.AlpTransID  
SELECT alpD.AlpAlarmID ,alpD.AlpEntryNum ,@PostRun  ,alpD.AlpRmrItemYn ,alpD.AlpSiteID,alpD.AlpTransID  
FROM dbo.Alp_tblArTransHeader alpH  
INNER JOIN dbo.tblArTransHeader h ON alph.AlpTransId =h.TransId  
INNER JOIN (SELECT EntryNum, PartId,UnitsSell,TransID FROM dbo.tblArTransDetail  
Group by EntryNum,PartId,UnitsSell,TransID)d ON h.TransId = d.TransID  
INNER JOIN ALP_tblArTransDetail alpD ON alpH.AlpTransId = alpD.AlpTransID and alpD.AlpEntryNum =d.EntryNum 
INNER JOIN #PostTransList l ON h.TransId = l.TransId  
--The below join commented by ravi and mah on 02.26.2015, the reason tblinitemuom table not used anywhere in the query
--LEFT JOIN dbo.tblInItemUom u on d.PartId = u.ItemId AND d.UnitsSell = u.Uom  



  
--SELECT alpD.AlpAlarmID ,alpD.AlpEntryNum ,@PostRun,alpD.AlpRmrItemYn ,alpD.AlpSiteID,alpD.AlpTransID  
--FROM dbo.Alp_tblArTransHeader alpH  
--INNER JOIN dbo.tblArTransHeader h ON alph.AlpTransId =h.TransId  
--INNER JOIN dbo.tblArTransDetail d ON h.TransId = d.TransID  
--INNER JOIN dbo.ALP_tblArTransDetail alpD ON alpH.AlpTransId = alpD.AlpTransID  
--INNER JOIN #PostTransList l ON h.TransId = l.TransId  
--LEFT JOIN dbo.tblInItemUom u on d.PartId = u.ItemId AND d.UnitsSell = u.Uom  
  
  
INSERT INTO dbo.ALP_tblArOpenInvoice (AlpCounter, AlpCustId ,AlpInvcNum ,AlpMailSiteYn,  
AlpPostRun,AlpSiteID ,AlpSubscriberInvcYn ,AlpTransID )  
SELECT openInvc .Counter , openInvc.CustId ,openInvc.InvcNum ,alph.AlpMailSiteYn ,  
@PostRun,alpH.AlpSiteID, alph.AlpSubscriberInvcYN , openInvc.TransId  
FROM tblArOpenInvoice openInvc  
INNER JOIN #PostTransList l ON openInvc.TransId = l.TransId  
INNER JOIN Alp_tblArTransHeader alpH ON alph.AlpTransId =openInvc.TransId  
  
END TRY  
BEGIN CATCH  
EXEC dbo.trav_RaiseError_proc  
END CATCH