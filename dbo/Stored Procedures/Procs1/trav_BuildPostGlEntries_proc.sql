
CREATE PROCEDURE dbo.trav_BuildPostGlEntries_proc
AS 
BEGIN TRY

		INSERT dbo.tblGlJrnl (PostRun, CompId, EntryDate, TransDate, [Desc], SourceCode, Reference, AcctId, DebitAmt
			, CreditAmt, Period, [Year], LinkID, LinkIDSub, LinkIDSubLine, CurrencyId, ExchRate, DebitAmtFgn, CreditAmtFgn, URG) 
		SELECT  PostRun, CompId, PostDate, TransDate, [Description], SourceCode, Reference, ISNULL(GlAccount,''), DebitAmount, CreditAmount, 
				FiscalPeriod, FiscalYear, LinkID, LinkIDSub, LinkIDSubLine, CurrencyId, ExchRate, DebitAmountFgn, CreditAmountFgn, URG
		FROM  #GlPostLogs

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_BuildPostGlEntries_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_BuildPostGlEntries_proc';

