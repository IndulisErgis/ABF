
CREATE PROCEDURE dbo.trav_ApVendorDetailReport_proc
@PrintAllInBase bit = 1,
@ReportCurrency pCurrency = 'USD', --Base currency WHEN @PrintAllInBase = 1
@DetailYn bit = 1,
@FiscalYear smallint = 2008
AS
SET NOCOUNT ON
BEGIN TRY

	IF @DetailYn = 1 
	BEGIN
		SELECT v.VendorID, v.[Name], v.Contact, v.Addr1, v.Addr2, v.City, v.Region, v.Country, v.PostalCode, v.[Status], v.ChkOpt
			, v.IntlPrefix, v.Phone, v.FAX, v.OurAcctNum, v.PayToName, v.PayToAttention, v.PayToAddr1, v.PayToAddr2, v.PayToCity
			, v.PayToRegion, v.PayToCountry, v.PayToPostalCode, v.PayToIntlPrefix, v.PayToPhone, v.Ten99FormCode
			, v.Ten99RecipientID, v.Ten99FieldIndicator, v.Ten99ForeignAddrYN, v.SecondTINNotYN, v.GLAcct, v.PriorityCode
			, v.VendorHoldYN, v.TempYN, v.VendorClass, v.TermsCode, v.DivisionCode, v.DistCode, v.TaxableYN, v.Memo, v.CurrencyId
			, t.[Desc], t.DiscPct, t.DiscDays, t.NetDueDays, v.TaxGrpID, v.Email, v.Internet, v.LastPurchDate, v.LastPurchNum
			, v.LastPmtDate, v.LastCheckNum, v.DfltTransAllocId,v.DefaultPayBankId
			, CASE WHEN @PrintAllInBase = 1 THEN v.GrossDue ELSE v.GrossDueFgn END AS GrossDue
			, CASE WHEN @PrintAllInBase = 1 THEN v.Prepaid ELSE v.PrepaidFgn END AS Prepaid
			, CASE WHEN @PrintAllInBase = 1 THEN v.LastPurchAmt ELSE v.LastPurchAmtFgn END AS LastPurchAmt
			, CASE WHEN @PrintAllInBase = 1 THEN v.LastPmtAmt ELSE v.LastPmtAmtFgn END AS LastPmtAmt
			, v.DeliveryType, v.BankAcctNum, v.RoutingCode, CASE WHEN h.VendorId IS NULL THEN 0 ELSE 1 END AS HistoryYn 
		FROM dbo.tblApVendor v INNER JOIN #tmpVendorList d ON v.VendorId = d.VendorId
			INNER JOIN dbo.tblApTermsCode t ON v.TermsCode = t.TermsCode 
			LEFT JOIN (SELECT VendorId FROM dbo.tblApVendorHistDetail GROUP BY VendorId) h ON v.VendorId = h.VendorId 
		WHERE (@PrintAllInBase = 1 OR v.CurrencyId = @ReportCurrency) 
			
		SELECT h.VendorID, h.FiscalYear, h.GLPeriod
			, CASE WHEN @PrintAllInBase = 1 THEN h.Purch ELSE h.PurchFgn END AS Purchases
			, CASE WHEN @PrintAllInBase = 1 THEN h.Pmt ELSE h.PmtFgn END AS Payments
			, CASE WHEN @PrintAllInBase = 1 THEN h.DiscTaken ELSE h.DiscTakenFgn END AS DiscTaken
			, CASE WHEN @PrintAllInBase = 1 THEN h.DiscLost ELSE h.DiscLostFgn END AS DiscLost
			, CASE WHEN @PrintAllInBase = 1 THEN h.Ten99Pmt ELSE h.Ten99PmtFgn END AS Ten99Payments 
		FROM dbo.tblApVendor v INNER JOIN #tmpVendorList d ON v.VendorId = d.VendorId
			INNER JOIN dbo.tblApVendorHistDetail h ON d.VendorId = h.VendorId
		WHERE (@PrintAllInBase = 1 OR v.CurrencyId = @ReportCurrency) 
			AND h.FiscalYear = @FiscalYear
	END
	ELSE
	BEGIN
		SELECT v.VendorID, v.[Name], v.Contact, v.Country, v.Phone, v.FAX, v.VendorHoldYN 
		FROM dbo.tblApVendor v INNER JOIN #tmpVendorList d ON v.VendorId = d.VendorId
		WHERE (@PrintAllInBase = 1 OR v.CurrencyId = @ReportCurrency) 
	END
	
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApVendorDetailReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApVendorDetailReport_proc';

