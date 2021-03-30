
CREATE PROCEDURE dbo.trav_BrRecurringAdjustmentsList_proc
@PrintAllInBase bit = 1,
@ReportCurrency pCurrency = 'USD',
@SortBy tinyint = 0 -- 0, Bank Account ID; 1, Recurring Adjustment ID; 2, GL Account;
AS
SET NOCOUNT ON
BEGIN TRY

	SELECT 0 AS RecType,
		CASE @SortBy WHEN 0 THEN h.BankID WHEN 1 THEN h.TransID ELSE b.GlCashAcct END AS SortOrder1,
		CASE @SortBy WHEN 0 THEN h.TransID ELSE h.BankID END  AS SortOrder2,
		CASE @SortBy WHEN 0 THEN b.GLCashAcct WHEN 1 THEN b.GlCashAcct ELSE h.TransID END AS SortOrder3,
		h.BankID, h.TransID, h.SourceID, 0 AS CrAmount,	0 AS DrAmount, d.EntryNum, d.GLAcct,
		CASE WHEN @PrintAllInBase = 1 THEN d.DebitAmt ELSE d.DebitAmtFgn END AS DebitAmt,
		CASE WHEN @PrintAllInBase = 1 THEN d.CreditAmt ELSE d.CreditAmtFgn END AS CreditAmt,
		d.Descr AS DescrDtl, d.Reference AS ReferenceDtl,
		b.GlCashAcct AS GlAcctHdr, h.Descr AS DescrHdr, h.Reference AS ReferenceHdr 
	FROM #tmpAdjustmentList t INNER JOIN dbo.tblBrRecurHeader h ON t.TransId = h.TransId 
		INNER JOIN  dbo.tblSmBankAcct b ON h.BankId = b.BankId 
		LEFT JOIN dbo.tblBrRecurDetail d ON h.TransID = d.TransID
	WHERE @PrintAllInBase = 1 OR h.CurrencyID = @ReportCurrency
	UNION ALL
	SELECT 1 AS RecType,
		CASE @SortBy WHEN 0 THEN h.BankID WHEN 1 THEN h.TransID ELSE b.GlCashAcct END AS SortOrder1,
		CASE @SortBy WHEN 0 THEN h.TransID ELSE h.BankID END  AS SortOrder2,
		CASE @SortBy WHEN 0 THEN b.GlCashAcct WHEN 1 THEN b.GlCashAcct ELSE h.TransID END AS SortOrder3,
		h.BankID, h.TransID, h.SourceID,
		CASE WHEN @PrintAllInBase = 1 THEN 
				CASE WHEN TransType * Amount < 0 THEN ABS(Amount) ELSE 0 END 
			ELSE CASE WHEN TransType * AmountFgn < 0 THEN ABS(AmountFgn) ELSE 0 END END AS CrAmount,
		CASE WHEN @PrintAllInBase = 1 THEN 
				CASE WHEN TransType * Amount >= 0 THEN ABS(Amount) ELSE 0 END 
			ELSE CASE WHEN TransType * AmountFgn >= 0 THEN ABS(AmountFgn) ELSE 0 END END AS DrAmount,
		0 AS EntryNum, NULL AS GLAcct, 0 AS DebitAmt, 0 AS CreditAmt,NULL AS DescrDtl, NULL AS ReferenceDtl,
		b.GlCashAcct AS GlAcctHdr, h.Descr AS DescrHdr, h.Reference AS ReferenceHdr 
	FROM #tmpAdjustmentList t INNER JOIN dbo.tblBrRecurHeader h ON t.TransId = h.TransId 
		INNER JOIN  dbo.tblSmBankAcct b ON h.BankId = b.BankId 
	WHERE @PrintAllInBase = 1 OR h.CurrencyID = @ReportCurrency

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_BrRecurringAdjustmentsList_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_BrRecurringAdjustmentsList_proc';

