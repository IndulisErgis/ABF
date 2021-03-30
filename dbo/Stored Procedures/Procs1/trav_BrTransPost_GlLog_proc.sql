
CREATE PROCEDURE dbo.trav_BrTransPost_GlLog_proc
AS
BEGIN TRY

	DECLARE @PostRun pPostRun, @CurrBase pCurrency, @WkStnDate datetime, @CompId nvarchar(3)

	SELECT @PostRun = Cast([Value] AS nvarchar(14)) FROM #GlobalValues WHERE [Key] = 'PostRun'
	SELECT @CurrBase = Cast([Value] AS nvarchar(6)) FROM #GlobalValues WHERE [Key] = 'CurrBase'
	SELECT @WkStnDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'WrkStnDate'
	SELECT @CompId = Cast([Value] AS nvarchar(3)) FROM #GlobalValues WHERE [Key] = 'CompId'

	IF @PostRun IS NULL OR @CurrBase IS NULL OR @WkStnDate IS NULL OR @CompId IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END

	INSERT #GlPostLogs(PostRun,FiscalYear,FiscalPeriod,[Grouping],GlAccount,AmountFgn,Reference,[Description],DebitAmount,
		CreditAmount,DebitAmountFgn,CreditAmountFgn,SourceCode,PostDate,TransDate,CurrencyId,ExchRate,CompId,LinkId,LinkIdSub,LinkIdSubLine)
	SELECT @PostRun,h.FiscalYear,h.GlPeriod,104,b.GlCashAcct,SIGN(h.TransType) * h.AmountFgn,h.Reference,SUBSTRING(h.Descr, 1, 30),
		CASE WHEN SIGN(TransType) * Amount > 0 THEN ABS(Amount) ELSE 0 END,
		CASE WHEN SIGN(TransType) * Amount < 0 THEN ABS(Amount) ELSE 0 END,
		CASE WHEN SIGN(TransType) * AmountFgn > 0 THEN ABS(AmountFgn) ELSE 0 END,	
		CASE WHEN SIGN(TransType) * AmountFgn < 0 THEN ABS(AmountFgn) ELSE 0 END,
		'BR', @WkStnDate,h.TransDate,h.CurrencyId,h.ExchRate,@CompId,h.BankID,h.SourceID,h.TransType
	FROM #PostTransList t INNER JOIN dbo.tblBrJrnlHeader h ON t.TransId = h.BankId 
		INNER JOIN dbo.tblSmBankAcct b ON h.BankId = b.BankId
	WHERE (h.VoidYn = 0 OR (h.VoidYn = 1 AND h.VoidReinstateStat IS NULL))
	AND (h.AmountFgn<>0 OR h.Amount <>0)

	INSERT #GlPostLogs(PostRun,FiscalYear,FiscalPeriod,[Grouping],GlAccount,AmountFgn,Reference,[Description],DebitAmount,
		CreditAmount,DebitAmountFgn,CreditAmountFgn,SourceCode,PostDate,TransDate,CurrencyId,ExchRate,CompId,LinkId,LinkIdSub,LinkIdSubLine)
	SELECT @PostRun,h.FiscalYear,h.GlPeriod,105,d.GlAcct, 
		CASE WHEN ISNULL(g.CurrencyId,@CurrBase) <> @CurrBase THEN d.DebitAmtFgn + (d.CreditAmtFgn * -1) 
			ELSE d.DebitAmt + (d.CreditAmt * -1) END,d.Reference,SUBSTRING(d.Descr, 1, 30),
		CASE WHEN DebitAmt + (CreditAmt * -1) > 0 THEN DebitAmt + (CreditAmt * -1) ELSE 0 END,
		CASE WHEN DebitAmt + (CreditAmt * -1) < 0 THEN ABS(DebitAmt + (CreditAmt * -1)) ELSE 0 END,
		CASE WHEN ISNULL(g.CurrencyId,@CurrBase) <> @CurrBase THEN CASE WHEN DebitAmtFgn + (CreditAmtFgn * -1) > 0 
			THEN DebitAmtFgn + (CreditAmtFgn * -1) ELSE 0 END 
			ELSE CASE WHEN DebitAmt + (CreditAmt * -1) > 0 THEN DebitAmt + (CreditAmt * -1) ELSE 0 END END,
		CASE WHEN ISNULL(g.CurrencyId,@CurrBase) <> @CurrBase THEN CASE WHEN DebitAmtFgn + (CreditAmtFgn * -1) < 0 
			THEN ABS(DebitAmtFgn + (CreditAmtFgn * -1)) ELSE 0 END 
			ELSE CASE WHEN DebitAmt + (CreditAmt * -1) < 0 THEN ABS(DebitAmt + (CreditAmt * -1)) ELSE 0 END END,
		'BR', @WkStnDate,TransDate,ISNULL(g.CurrencyId,@CurrBase),
		CASE WHEN ISNULL(g.CurrencyId,@CurrBase) <> @CurrBase THEN d.ExchRate ELSE 1 END,@CompId,h.BankID,h.SourceID,h.TransType
	FROM #PostTransList t INNER JOIN dbo.tblBrJrnlHeader h ON t.TransId = h.BankId 
		INNER JOIN dbo.tblSmBankAcct b ON h.BankId = b.BankId 
		INNER JOIN dbo.tblBrJrnlDetail d ON h.TransId = d.TransId 
		LEFT JOIN dbo.tblGlAcctHdr g ON d.GlAcct = g.AcctId
	WHERE (h.VoidYn = 0 OR (h.VoidYn = 1 AND h.VoidReinstateStat IS NULL))
	AND (d.DebitAmtFgn<>0 OR d.CreditAmtFgn<>0 OR d.CreditAmt <>0 OR d.DebitAmt<> 0)

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_BrTransPost_GlLog_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_BrTransPost_GlLog_proc';

