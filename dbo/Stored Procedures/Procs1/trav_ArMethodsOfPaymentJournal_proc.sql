--PET: http://problemtrackingsystem.osas.com/view.php?id=265783
--PET: http://problemtrackingsystem.osas.com/view.php?id=271494

CREATE PROCEDURE dbo.trav_ArMethodsOfPaymentJournal_proc
@PrintAllInBase bit = 1,
@ReportCurrency pCurrency = Null
AS
SET NOCOUNT ON
BEGIN TRY

	SELECT h.PmtMethodId, p.[Desc], p.PmtType, h.CustId
		, CASE	WHEN p.PmtType IN (3, 7) THEN ISNULL(b.GlCashAcct, p.GLAcctDebit) 
				WHEN p.PmtType IN (1, 2, 6) THEN b.GlCashAcct ELSE p.GLAcctDebit END AS GLAcctDebit --ues the bank gl account for Cash, Check and Direct Debit 
		, CASE WHEN h.GlAcct IS NOT NULL THEN h.GlAcct ELSE s.GlAcctReceivables END AS GlAcct, 
		h.DepositID, d.InvcNum, h.RcptHeaderID AS InvTransId, h.PmtDate, h.BankID, h.CheckNum, 
		CASE WHEN @PrintAllInBase = 1 THEN d.PmtAmt ELSE d.PmtAmtFgn END AS PmtAmt, 
		h.CcHolder, h.CcNum, h.CcExpire, h.CcAuth, h.BankName, h.BankRoutingCode, h.BankAcctNum, h.Note
	FROM #tmpCashReceiptList t INNER JOIN dbo.tblArCashRcptHeader h (NOLOCK)  ON t.RcptHeaderID = h.RcptHeaderID
		INNER JOIN dbo.tblArPmtMethod p (NOLOCK)  On h.PmtMethodID = p.PmtMethodId
		INNER JOIN dbo.tblArCashRcptDetail d (NOLOCK)  ON h.RcptHeaderID = d.RcptHeaderID
		LEFT JOIN dbo.tblSmBankAcct b (NOLOCK) on p.BankId = b.BankId
		LEFT JOIN dbo.tblArCust c (NOLOCK)  ON h.CustId = c.CustId 
		LEFT JOIN dbo.tblArDistCode s (NOLOCK) ON d.DistCode = s.DistCode
	WHERE (@PrintAllInBase = 1 OR (@PrintAllInBase = 0 AND h.CurrencyId = @ReportCurrency)) 
	AND (h.OrderState = 0 OR h.OrderState & 4 =4)
	ORDER BY h.PmtMethodId

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArMethodsOfPaymentJournal_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArMethodsOfPaymentJournal_proc';

