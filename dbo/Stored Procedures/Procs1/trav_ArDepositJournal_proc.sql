--PET: http://problemtrackingsystem.osas.com/view.php?id=265783

CREATE PROCEDURE dbo.trav_ArDepositJournal_proc
@PrintAllInBase bit = 1,
@ReportCurrency pCurrency = Null

AS
SET NOCOUNT ON
BEGIN TRY

	SELECT h.BankID, h.CustId, c.CustName, h.DepositID, 
		ISNULL(Case When p.PmtType = 1 Then Case When @PrintAllInBase = 1 Then d.PmtAmt 
			Else d.PmtAmtFgn End End, 0) AS CashAmt, 
		ISNULL(Case When p.PmtType = 2 Then Case When @PrintAllInBase = 1 Then d.PmtAmt 
  			Else d.PmtAmtFgn End End, 0) AS CheckAmt, 
		Case When @PrintAllInBase = 1 then d.PmtAmt Else d.pmtamtfgn End AS PmtAmt, 
		p.PmtType AS PmtType, h.CheckNum, h.PmtDate,
		ISNULL(Case When p.PmtType = 2 Then Case When @PrintAllInBase = 1 Then d.PmtAmt 
			Else d.PmtAmtFgn End End,0) + ISNULL(Case When p.PmtType = 1 
			Then Case When @PrintAllInBase = 1 Then d.PmtAmt Else d.PmtAmtFgn End End,0) AS CheckCashTot
	FROM #tmpCashReceiptList t INNER JOIN dbo.tblArCashRcptHeader h (NOLOCK)  ON t.RcptHeaderID = h.RcptHeaderID 
			INNER JOIN #tmpBankAccountList b ON h.BankId = b.BankId
			INNER JOIN dbo.tblArPmtMethod p (NOLOCK)  On h.PmtMethodID = p.PmtMethodId
			INNER JOIN dbo.tblArCashRcptDetail d (NOLOCK)  ON h.RcptHeaderID = d.RcptHeaderID
			LEFT JOIN dbo.tblArCust c (NOLOCK)  ON h.CustId = c.CustId 
	WHERE (p.PmtType=1 OR p.PmtType=2) AND (@PrintAllInBase = 1 OR (@PrintAllInBase = 0 AND h.CurrencyId = @ReportCurrency))
	AND (h.OrderState = 0 OR h.OrderState & 4 =4)
	ORDER BY h.BankID

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArDepositJournal_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArDepositJournal_proc';

