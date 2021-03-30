
CREATE VIEW dbo.trav_ApHistoryCheckSummary_view
AS
	SELECT MAX([Counter]) [Counter], CheckRun, VendorID, CurrencyID, CheckDate, CheckNum,
		Sum(GrossAmtDue-DiscTaken) AS CheckAmt, Sum(GrossAmtDuefgn-DiscTakenfgn) AS CheckAmFgn, 
		Sum(GrossAmtDue) AS SumOfGrossAmtDue, Sum(GrossAmtDueFgn) AS SumOfGrossAmtDueFgn,
		Sum(CASE WHEN DiscTaken<>0 THEN DiscAmt ELSE 0 END) AS SumOfDiscAmt,
		Sum(CASE WHEN DiscTaken <> 0 THEN DiscAmtFgn ELSE 0 END) AS SumOfDiscAmtFgn ,
		MIN(DistCode) DistCode, PmtType, BankId
	FROM tblApCheckHist
	WHERE VoidDate IS NULL AND CheckNum <> ''
	GROUP BY CheckRun,VendorID,CurrencyID,CheckDate,CheckNum,PmtType,BankId
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_ApHistoryCheckSummary_view';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_ApHistoryCheckSummary_view';

