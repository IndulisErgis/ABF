
CREATE PROCEDURE [dbo].[trav_ArPmtMethodReport_proc]

@FiscalYear smallint = 2009

AS
SET NOCOUNT ON
BEGIN TRY

	--PET:http://webfront:801/view.php?id=235807
	--PET:http://webfront:801/view.php?id=246412

	SELECT h.PmtMethodId, h.[Desc], h.PmtType, h.CustId, h.BankId, h.GlAcctDebit, d.FiscalYear, 
		d.GlPeriod AS FiscalPeriod, d.Pmt, b.GlCashAcct AS GlAcct
		FROM #tmpPmtMethodList p INNER JOIN dbo.tblArPmtMethod h ON p.PmtMethodId = h.PmtMethodId
			LEFT JOIN 
				(
					SELECT d2.PmtMethodId, d2.FiscalYear, d2.GlPeriod, SUM(d2.PmtAmt) AS Pmt 
					FROM #tmpPmtMethodList p2 
						INNER JOIN dbo.tblArHistPmt d2 ON p2.PmtMethodId = d2.PmtMethodID 
					WHERE d2.FiscalYear = @FiscalYear OR d2.FiscalYear IS NULL GROUP BY d2.PmtMethodId, d2.FiscalYear, d2.GlPeriod) d ON h.PmtMethodId = d.PmtMethodId 
			LEFT JOIN dbo.tblSmBankAcct b  ON h.BankId = b.BankId

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArPmtMethodReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArPmtMethodReport_proc';

