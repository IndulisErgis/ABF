
CREATE PROCEDURE dbo.trav_GlPostToMaster_BuildLog_proc
AS
BEGIN TRY

	--build a log the journal entries being posted
	INSERT INTO #PostToMasterLog([PostRun], [EntryNum], [FiscalYear], [FiscalPeriod]
		, [EntryDate], [GlAccount], [Description], [AllocateYn], [SourceCode], [Reference]
		, [DebitAmount], [CreditAmount], [AmountFgn], [DebitAmountFgn], [CreditAmountFgn]
		, [ExchRate], [CurrencyId], [SourceEntryNum])
	SELECT j.[PostRun], j.[EntryNum], j.[Year], j.[Period]
		, j.[EntryDate], j.[AcctId], j.[Desc], j.[AllocateYn], j.[SourceCode], j.[Reference]
		, j.[DebitAmt], j.[CreditAmt], ABS(j.[DebitAmtFgn] - j.[CreditAmtFgn]), j.[DebitAmtFgn], j.[CreditAmtFgn]
		, j.[ExchRate], j.[CurrencyId]
		, CASE WHEN j.[SourceCode] = 'AL' AND [LinkIdSubLine] <> -1  THEN CAST(j.[Reference] as INT) ELSE j.[EntryNum] END
	FROM dbo.tblGlJrnl j
	INNER JOIN #PostJournalList l on j.EntryNum = l.EntryNum 

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_GlPostToMaster_BuildLog_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_GlPostToMaster_BuildLog_proc';

