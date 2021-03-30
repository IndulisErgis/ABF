
CREATE PROCEDURE dbo.trav_GlPostToMaster_UpdateAccountDetail_proc
AS
SET NOCOUNT ON
BEGIN TRY

	--construct a temp table for summarizing the journal entries
	CREATE TABLE #JrnlSummary 
	(	AcctId pGlAcct,
		FiscalYear smallint,
		FiscalPeriod smallint,
		DebitAmtFgn pCurrDecimal,
		CreditAmtFgn pCurrDecimal,
		DebitAmt pCurrDecimal,
		CreditAmt pCurrDecimal
	)

	--summarize the journal entries being posted
	INSERT INTO #JrnlSummary (AcctId, FiscalYear, FiscalPeriod, DebitAmtFgn, CreditAmtFgn, DebitAmt, CreditAmt)
	SELECT AcctId, j.[Year], j.[Period], SUM(DebitAmtFgn), SUM(CreditAmtFgn), SUM(DebitAmt), SUM(CreditAmt)
	FROM dbo.tblGlJrnl j
	INNER JOIN #PostJournalList l ON j.EntryNum = l.EntryNum 
	GROUP BY AcctId, [Period], [Year]	
	
	--create missing account detail records
	INSERT INTO dbo.tblGlAcctDtl ([AcctId], [Year], [Period], [Actual], [ActualBase], [Budget], [Forecast], [Balance])
	SELECT s.AcctId, s.FiscalYear, s.FiscalPeriod, 0, 0, 0, 0, 0
	FROM #JrnlSummary s
	LEFT JOIN dbo.tblGlAcctDtl d 
		ON s.AcctId = d.AcctId AND s.FiscalYear = d.[Year] AND s.FiscalPeriod = d.[Period]
	WHERE d.AcctId IS NULL
	
	--update account detail values
	UPDATE dbo.tblGlAcctDtl 
	SET [Actual] = [Actual] + CASE WHEN [BalType] < 0 THEN -(s.[DebitAmtFgn] - s.[CreditAmtFgn]) ELSE (s.[DebitAmtFgn] - s.[CreditAmtFgn]) END
		, [ActualBase] = [ActualBase] + CASE WHEN [BalType] < 0 THEN -(s.[DebitAmt] - s.[CreditAmt]) ELSE (s.[DebitAmt] - s.[CreditAmt]) END
	FROM #JrnlSummary s 
	INNER JOIN dbo.tblGlAcctDtl 
		ON s.AcctId = dbo.tblGlAcctDtl.AcctId 
		AND s.FiscalYear = dbo.tblGlAcctDtl.[Year] 
		AND s.FiscalPeriod = dbo.tblGlAcctDtl.[Period]
	INNER JOIN dbo.tblGlAcctHdr h ON s.AcctId = h.Acctid

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_GlPostToMaster_UpdateAccountDetail_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_GlPostToMaster_UpdateAccountDetail_proc';

