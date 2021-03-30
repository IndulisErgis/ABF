
CREATE PROCEDURE dbo.trav_SmBankAccountList_proc 
@FiscalYear smallint = 2008,
@IncludeUnposted bit = 1,
@BrGlYn bit = 1,
@SortBy tinyint = 0 -- 0, Bank Account ID; 1, GL Account;
AS
SET NOCOUNT ON
BEGIN TRY

	CREATE TABLE #AcctBal
	(
		GLAcct pglAcct NOT NULL, 
		GLAcctBal pdecimal NOT NULL
	)

	IF @BrGlYn = 1
	BEGIN
		INSERT #AcctBal (GlAcct, GlAcctBal)
		SELECT bal.AcctId, SUM(bal.Balance) 
		FROM
			(SELECT h.AcctId, ISNULL(SUM(h.Actual), 0) AS Balance FROM dbo.tblGlAcctDtl h 
				WHERE h.[Year] = @FiscalYear	GROUP BY h.AcctId	
								
			UNION ALL
			
			SELECT j.AcctId, SUM(CASE WHEN dh.BalType < 0 THEN -(j.DebitAmtFgn - j.CreditAmtFgn) ELSE (j.DebitAmtFgn - j.CreditAmtFgn) END) AS Balance
				FROM dbo.tblGlJrnl j INNER JOIN tblGlAcctHdr dh ON j.AcctId = dh.AcctId
				WHERE (j.PostedYn = 0) AND (j.[Year] = @FiscalYear) AND j.URG = 1  
				GROUP BY j.AcctId 
				
			UNION ALL
			
			SELECT j.AcctId, SUM(CASE WHEN dh.BalType < 0 THEN -(j.DebitAmtFgn - j.CreditAmtFgn) ELSE (j.DebitAmtFgn - j.CreditAmtFgn) END) AS Balance
				FROM dbo.tblGlJrnl j INNER JOIN tblGlAcctHdr dh ON j.AcctId = dh.AcctId
				WHERE @IncludeUnposted = 1 AND (j.PostedYn = 0) AND (j.[Year] = @FiscalYear) AND j.URG = 0  
				GROUP BY j.AcctId	
				
				) AS bal			 
		 INNER JOIN ( SELECT b.GlCashAcct FROM #tmpBankAccountList t INNER JOIN dbo.tblSmBankAcct b ON t.BankId = b.BankId GROUP BY GlCashAcct) b 
			ON bal.AcctId = b.GlCashAcct 			
		GROUP BY bal.AcctId

	END

	--Set sort BY
	SELECT CASE WHEN @SortBy = 0 THEN b.BankId ELSE b.GlCashAcct END GrpId1, 
		b.BankId, b.[Desc], b.Name, b.Contact, b.Addr1, b.Addr2, b.City, b.Region, b.Country, b.PostalCode, 
		b.IntlPrefix, b.Phone, b.FAX, b.OurAcctNum, b.CurrencyId, b.GlCashAcct, b.Email, b.Internet, 
		b.CheckLayout, b.CheckFormat, b.GLAcctBal, b.LastStmtBal, b.LastStmtDate, b.ReconsImpId, b.AcctType, 
		b.RoutingCode, b.MICR, b.NextCheckNo, b.APPosPay, b.PAPosPay, b.CcExpire, b.VendorId, b.RoutingFraction, 
		b.NextVoucherNo, b.FilingCode, b.FRBRoutingCode, b.SecurityCode, b.SecurityCodePadLength, b.ACHExcludeOffset, 
		b.ACHNextBatchNumber, b.ACHLastPayDate, b.ACHFilePath, b.ACHFileName, b.ACHExecute, t.GlAcctBal ActGlAcctBal
	FROM #tmpBankAccountList l INNER JOIN dbo.tblSmBankAcct b ON l.BankId = b.BankId 
		LEFT JOIN #AcctBal t ON b.GlCashAcct = t.GlAcct

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SmBankAccountList_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SmBankAccountList_proc';

