
CREATE PROCEDURE dbo.trav_GlCloseGLAccounts_CalculateGainLoss_proc

AS

SET NOCOUNT ON
BEGIN TRY
	

	INSERT INTO #GainLoss(AccountId,CurrencyID,Description,GainLossAmountBase,GainLossAmount)

	SELECT h.AcctId,h.CurrencyID,h.[Desc] Description , -SUM(ISNULL(DebitAmt,0)-ISNULL(CreditAmt,0)) GainLossAmountBase, -SUM(ISNULL(DebitAmt,0)-ISNULL(CreditAmt,0)) GainLossAmount
    FROM tblGlAcctHdr h
	INNER JOIN #AccountList a ON h.AcctId = a.AccountID
	LEFT JOIN tblGlJrnl g ON g.AcctId =a.AccountID   
    WHERE h.[Status] =0
    GROUP BY h.AcctId,h.CurrencyID,h.[Desc]
    HAVING SUM(ISNULL(DebitAmtFgn,0)- ISNULL(CreditAmtFgn,0))=0

	--Gain/Loss amount base =(Sum(Fgn as base)  � Sum(base)) = -1 * GainLossAmountBase.

	UPDATE #GainLoss SET AccountIDGainLoss = CASE WHEN GainLossAmountBase > 0 THEN a.RealGainAcct  ELSE a.RealLossAcct END 
	FROM #GainLoss g
	INNER JOIN #GainLossAccounts a ON g.CurrencyID = a.CurrencyID


	
	

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_GlCloseGLAccounts_CalculateGainLoss_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_GlCloseGLAccounts_CalculateGainLoss_proc';

