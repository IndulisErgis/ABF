
CREATE PROCEDURE [dbo].[trav_ApPaymentHistoryReport_proc]
@PaymentDateFrom Datetime = '1/1/1900',
@PaymentDateThru Datetime = '12/31/2199',
@FiscalYear smallint,
@FiscalPeriod smallint,
@PaymentCutoff smallint,
@PrintAllInBase bit,
@CurrencyID  nvarchar(10) = 'USD'

AS
SET NOCOUNT ON
BEGIN TRY

	IF (@PrintAllInBase <> 0)
	BEGIN
		SELECT h.VendorId, h.InvoiceNum, h.CheckDate, h.CheckNum, h.GlPeriod, h.FiscalYear
			, h.BankId AS BankAccount, h.BankId, b.Name AS BankName
			, ISNULL(CASE WHEN h.DiscTaken <> 0 THEN h.DiscAmt ELSE 0 END, 0) AS DiscountAmt
			, ISNULL(h.GrossAmtDue, 0) AS GrossAmtDue, h.PmtType, h.InvoiceDate
			, ISNULL(h.InvoiceNum, '') + ISNULL(CAST(h.InvoiceDate AS nvarchar(20)), '') AS InvoiceNumDate
			, ISNULL(h.CheckNum, '') + ISNULL(CAST(h.CheckDate AS nvarchar(20)), '') AS CheckNumDate
			, CASE WHEN ISNULL(h.PayToName, '') = '' THEN v.[Name] ELSE h.PayToName END AS PayToName
			, ISNULL(h.GrossAmtDue, 0) - ISNULL(CASE WHEN h.DiscTaken <> 0 THEN h.DiscAmt ELSE 0 END, 0) AS NetPaid
			, ISNULL(CASE WHEN h.DiscTaken <> 0 THEN h.DiscAmt ELSE 0 END, 0) * (CASE h.PmtType WHEN 9 THEN 0 ELSE 1 END) AS CheckDiscountAmt
			, ISNULL(h.GrossAmtDue,0) * (CASE h.PmtType WHEN 9 THEN 0 ELSE 1 END) AS CheckGrossAmtDue
			, (ISNULL(h.GrossAmtDue, 0) - ISNULL(CASE WHEN h.DiscTaken <> 0 THEN h.DiscAmt ELSE 0 END, 0)) 
				* (CASE h.PmtType WHEN 9 THEN 0 ELSE 1 END) AS CheckNetPaid
			, ISNULL(CASE WHEN h.DiscTaken <> 0 THEN h.DiscAmt ELSE 0 END, 0) * (CASE h.PmtType WHEN 9 THEN 1 ELSE 0 END) AS VoidDiscountAmt
			, ISNULL(h.GrossAmtDue, 0) * (CASE h.PmtType WHEN 9 THEN 1 ELSE 0 END) AS VoidGrossAmtDue
			, (ISNULL(h.GrossAmtDue, 0) - ISNULL(CASE WHEN h.DiscTaken <> 0 THEN h.DiscAmt ELSE 0 END, 0)) 
				* (CASE h.PmtType WHEN 9 THEN 1 ELSE 0 END) AS VoidNetPaid				 
		FROM dbo.tblApCheckHist h 
			LEFT JOIN dbo.tblApVendor v ON h.VendorID = v.VendorID
			LEFT JOIN  dbo.tblSmBankAcct b ON h.BankID = b.BankID 			
			INNER JOIN #tmpVendorList t ON h.Counter = t.Counter 
		WHERE ((h.CheckDate BETWEEN @PaymentDateFrom AND @PaymentDateThru AND @PaymentCutoff = 0) 
				OR (((h.FiscalYear * 1000) + h.GlPeriod = (ISNULL(@FiscalYear, 0) * 1000) + (ISNULL(@FiscalPeriod, 0)) 
				OR (ISNULL(@FiscalYear, 0) + ISNULL(@FiscalPeriod, 0) = 0)) AND @PaymentCutoff = 1))
	END

	ELSE
	BEGIN
		SELECT h.VendorId, h.InvoiceNum, h.CheckDate, h.CheckNum, h.GlPeriod, h.FiscalYear
			, h.BankId AS BankAccount, h.BankId, b.Name AS BankName
			, ISNULL(CASE WHEN h.DiscTakenFgn <> 0 THEN h.DiscAmtFgn ELSE 0 END, 0) AS DiscountAmt
			, ISNULL(h.GrossAmtDueFgn, 0) AS GrossAmtDue, h.PmtType, h.InvoiceDate
			, ISNULL(h.InvoiceNum, '') + ISNULL(CAST(h.InvoiceDate AS nvarchar(20)), '') AS InvoiceNumDate
			, ISNULL(h.CheckNum, '') + ISNULL(CAST(h.CheckDate AS nvarchar(20)), '') AS CheckNumDate
			, CASE WHEN ISNULL(h.PayToName, '') = '' THEN v.[Name] ELSE h.PayToName END AS PayToName
			, ISNULL(h.GrossAmtDueFgn, 0) - ISNULL(CASE WHEN h.DiscTakenFgn <> 0 THEN h.DiscAmtFgn ELSE 0 END, 0) AS NetPaid
			, ISNULL(CASE WHEN h.DiscTakenFgn <> 0 THEN h.DiscAmtFgn ELSE 0 END, 0)	* (CASE h.PmtType WHEN 9 THEN 0 ELSE 1 END) AS CheckDiscountAmt
			, ISNULL(h.GrossAmtDueFgn, 0) * (CASE h.PmtType WHEN 9 THEN 0 ELSE 1 END) AS CheckGrossAmtDue
			, (ISNULL(h.GrossAmtDueFgn, 0) - ISNULL(CASE WHEN h.DiscTakenFgn <> 0 THEN h.DiscAmtFgn ELSE 0 END, 0)) 
				* (CASE h.PmtType WHEN 9 THEN 0 ELSE 1 END) AS CheckNetPaid
			, ISNULL(CASE WHEN h.DiscTakenFgn <> 0 THEN h.DiscAmtFgn ELSE 0 END, 0) * (CASE h.PmtType WHEN 9 THEN 1 ELSE 0 END) AS VoidDiscountAmt
			, ISNULL(h.GrossAmtDueFgn, 0) * (CASE h.PmtType WHEN 9 THEN 1 ELSE 0 END) AS VoidGrossAmtDue
			, (ISNULL(h.GrossAmtDueFgn, 0) - ISNULL(CASE WHEN h.DiscTakenFgn <> 0 THEN h.DiscAmtFgn ELSE 0 END, 0)) 
				* (CASE h.PmtType WHEN 9 THEN 1 ELSE 0 END) AS VoidNetPaid 				
		FROM  dbo.tblApCheckHist h  
			LEFT JOIN dbo.tblApVendor v ON h.VendorID = v.VendorID
			LEFT JOIN dbo.tblSmBankAcct b ON h.BankID = b.BankID 		
			INNER JOIN #tmpVendorList t ON h.Counter = t.Counter 		
		WHERE h.CurrencyId = @CurrencyID 
			AND ((h.CheckDate BETWEEN @PaymentDateFrom AND @PaymentDateThru AND @PaymentCutoff = 0) 
				OR (((h.FiscalYear * 1000) + h.GlPeriod = (ISNULL(@FiscalYear, 0) * 1000) + (ISNULL(@FiscalPeriod, 0)) 
				OR (ISNULL(@FiscalYear, 0) + ISNULL(@FiscalPeriod, 0) = 0)) AND @PaymentCutoff = 1))
	END

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApPaymentHistoryReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApPaymentHistoryReport_proc';

