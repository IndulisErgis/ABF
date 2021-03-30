
CREATE PROCEDURE [dbo].[ALP_ArCashReceiptPost_OpenInvoice_proc]
AS
Set NoCount ON
BEGIN TRY
--MOD:Finance Charge Enhancements
--MOD:Deposit Invoices
--PET:http://webfront:801/view.php?id=239542
--PET:http://webfront:801/view.php?id=239654
--PET:http://webfront:801/view.php?id=242250

DECLARE @PostRun pPostRun, @WrkStnDate datetime, @CurrBase pCurrency, @MCYn bit, @PrecCurr smallint

--Retrieve global values
SELECT @PostRun = Cast([Value] AS nvarchar) FROM #GlobalValues WHERE [Key] = 'PostRun'
SELECT @WrkStnDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'WrkStnDate'
SELECT @CurrBase = Cast([Value] AS nvarchar) FROM #GlobalValues WHERE [Key] = 'CurrBase'
SELECT @MCYn = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'Multicurr'
SELECT @PrecCurr = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'PrecCurr'

IF @PostRun IS NULL OR @WrkStnDate IS NULL OR @CurrBase IS NULL OR @MCYn IS NULL OR @PrecCurr IS NULL
BEGIN
RAISERROR(90025,16,1)
END

INSERT dbo.ALP_tblArOpenInvoice
( AlpCounter,AlpCustId,AlpInvcNum,AlpSiteID,AlpMailSiteYn,AlpPostRun,AlpTransID,
AlpSubscriberInvcYn)
SELECT openInvc.Counter , h.CustId ,d.InvcNum ,alpDtl.AlpSiteID,
0 ,@PostRun,openInvc.TransId,null
FROM dbo.tblArCashRcptHeader h
INNER JOIN dbo.tblArCashRcptDetail d ON h.RcptHeaderID = d.RcptHeaderID
LEFT OUTER JOIN dbo.ALP_tblArCashRcptDetail alpDtl ON alpDtl.AlpRcptDetailID = d.RcptDetailID
INNER JOIN #PostTransList l ON h.RcptHeaderID = l.TransId
INNER JOIN 
-- MAH 08/24/15 - this can cause duplicate key SQL error, 
--     if user happens to enter more than one detail line having same invcnum, date, amt. 
--     Soultion:   need to add another field to the GROUP BY - possibly the ts field?  
--                 (Needs to be a field that will definitely be unique for each record.)
(SELECT Max([Counter])[Counter], CustId, InvcNum ,TransId,Amt, ts FROM dbo.tblArOpenInvoice
GROUP BY CustId,InvcNum,TransId,Amt, ts ) openInvc ON h.CustId = openInvc.CustId AND d.InvcNum = openInvc.InvcNum
and h.RcptHeaderID =openInvc .TransId and d.PmtAmt =openInvc.Amt

END TRY
BEGIN CATCH
EXEC dbo.trav_RaiseError_proc
END CATCH