CREATE PROCEDURE [dbo].[trav_ArCashReceiptPost_DepositHistory_proc]
AS
Set NoCount ON
BEGIN TRY

DECLARE @PostRun pPostRun, @WrkStnDate datetime

SELECT @PostRun = Cast([Value] AS nvarchar) FROM #GlobalValues WHERE [Key] = 'PostRun'
SELECT @WrkStnDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'WrkStnDate'

IF @PostRun IS NULL OR @WrkStnDate IS NULL 
BEGIN
      RAISERROR(90025,16,1)
END

	BEGIN
		INSERT dbo.tblArHistDeposit 
			(PostRun, TransId,CustId,InvcNum, Amount,DistCode,FiscalPeriod,FiscalYear,CurrencyId,
			[Description],ExchRate,RecType,GLAcctReceivablesDeposit,GLAcctReceivablesDepositContra,PostDate,
			TransDate,[Source],[SourceId],[ProjectName],ProjectDescription,PhaseId,PhaseDescription,TaskId,TaskDescription) 
		SELECT @PostRun, h.RcptHeaderID,h.CustId, d.InvcNum, -(d.PmtAmtFgn + DifferenceFgn),a.DistCode,h.GLPeriod,h.FiscalYear,
			a.CurrencyId,'Deposit payment',a.ExchRate,2,c.GLAcctDepositReceivables,c.GLAcctDepositReceivablesContra,@WrkStnDate,
			h.PmtDate,3, a.SourceId, p.ProjectName, p.[Description], t.PhaseId, s.[Description] AS PhaseDescription, t.TaskId, 
			CASE WHEN t.TaskId IS NULL THEN NULL ELSE t.[Description] END AS TaskDescription
		FROM dbo.tblArCashRcptHeader h 
		INNER JOIN dbo.tblArCashRcptDetail d ON h.RcptHeaderID = d.RcptHeaderID AND d.InvcType=5
		INNER JOIN #PostTransList b on h.RcptHeaderID = b.TransId	
		INNER JOIN (SELECT i.CustId,  i.InvcNum, MIN(SourceApp) SourceApp,MIN( i.DistCode) DistCode,MIN( i.CurrencyId) CurrencyId, 
				MIN( i.ExchRate) ExchRate, MIN(d.SourceId) SourceId
			FROM dbo.tblArOpenInvoice i INNER JOIN dbo.tblArHistDeposit d ON i.PostRun = d.PostRun AND i.TransId = d.TransId 
			WHERE i.RecType =5 AND i.AmtFgn>0
			GROUP BY i.CustId, i.InvcNum) a ON h.CustId = a.CustId AND d.InvcNum = a.InvcNum 
		INNER JOIN dbo.tblArDistCode c ON c.DistCode=a.DistCode 
		INNER JOIN dbo.tblPcProjectDetail t ON a.SourceId = t.Id 
		INNER JOIN dbo.trav_PcProject_view p ON t.ProjectId = p.Id 
		LEFT JOIN dbo.tblPcPhase s ON t.PhaseId = s.PhaseId
		WHERE h.CustId IS NOT NULL 

	END
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArCashReceiptPost_DepositHistory_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArCashReceiptPost_DepositHistory_proc';

