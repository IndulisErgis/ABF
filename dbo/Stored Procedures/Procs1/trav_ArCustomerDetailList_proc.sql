
CREATE PROCEDURE dbo.trav_ArCustomerDetailList_proc
@FiscalYear smallint = 2008, -- Fiscal Year
@PrintDetail bit = 1, -- Print Detail Y/N
@PrintPaymentMethodDetail bit = 0, -- Print Payment Method Detail Y/N
@ConsolidateBillToCustomer bit = 1 -- Consolidate history for 'Bill-To' customers
AS
SET NOCOUNT ON
BEGIN TRY

	IF @PrintDetail = 1 

	BEGIN
		SELECT c.CustId, CustName, Contact, Addr1, Addr2, City, Region, Country, PostalCode, ShipZone, IntlPrefix, 
			Phone, Fax, Attn, ClassId, SalesRepId1, SalesRepId2, Rep1PctInvc, Rep2PctInvc, TermsCode, PmtMethod, 
			GroupCode, StmtInvcCode, AcctType, PriceCode, DistCode, CalcFinch, CreditLimit, CreditHold, PartialShip, 
			AutoCreditHold, TaxLocId, Taxable, TaxExemptId, CurrencyId, TerrId, CcCompYn, CustLevel, Email, Internet, 
			NewFinch, UnpaidFinch, CurAmtDue, CurAmtDueFgn, BalAge1, BalAge2, BalAge3, BalAge4, UnapplCredit, 
			FirstSaleDate, LastSaleDate, LastSaleAmt, LastSaleInvc, LastPayDate, LastPayAmt, LastPayCheckNum, HighBal, 
			CreditStatus, WebDisplInQtyYn, Phone1, Phone2, AllowCharge, [Status], BillToId,
			CASE WHEN p.CustId IS NULL THEN 0 ELSE 1 END AS PaymentMethodsYn ,c.PONumberRequiredYn, c.TaxCertExpDate
		FROM dbo.tblArCust c INNER JOIN #tmpCustomerList t ON c.CustId = t.CustId
			LEFT JOIN (SELECT p.CustId	FROM dbo.tblArCustPmtMethod p INNER JOIN dbo.tblArPmtMethod t ON p.PmtMethod = t.PmtMethodID 
				WHERE t.PmtType IN (3, 6, 7) GROUP BY p.CustId) p ON c.CustId = p.CustId

		IF @ConsolidateBillToCustomer = 0
		BEGIN
			SELECT c.CustId, c.CurrencyId, o.GlPeriod, o.FiscalYear, SUM(o.Sales) AS Sales, SUM(o.COGS) AS COGS
				, SUM(o.Profit) AS Profit, SUM(o.NumInvc) AS NumInvc, SUM(o.Finch) AS Finch, SUM(o.Pmt) AS Pmt, 
				SUM(o.Disc) AS Disc, SUM(o.NumPmt) AS NumPmt, SUM(o.DaysToPay) AS DaysToPay 
			FROM dbo.tblArCust c INNER JOIN (
				SELECT SoldToId AS CustId, GlPeriod, FiscalYear, -Sales AS Sales, -COGS AS COGS, -Profit AS Profit, -NumInvc AS NumInvc
					, 0 AS Finch, 0 AS Pmt, 0 AS Disc, 0 AS NumPmt, 0 AS DaysToPay 
				FROM dbo.trav_ArCustomerHistoryOffset_view
				UNION ALL
				SELECT CustId, GlPeriod, FiscalYear, Sales, COGS, Profit, NumInvc, Finch, Pmt, Disc, NumPmt, DaysToPay 
				FROM dbo.trav_ArCustomerHistory_view) o ON o.CustId = c.CustId 
			WHERE c.CustId IN (SELECT CustId FROM #tmpCustomerList)
			GROUP BY c.CustId, GlPeriod, FiscalYear, CurrencyId
		END
		ELSE
		BEGIN
			SELECT h.CustId, c.CurrencyId, h.GlPeriod, h.FiscalYear, h.Sales, h.COGS, h.Profit, h.NumInvc, h.Finch, h.Pmt, h.Disc, h.NumPmt, h.DaysToPay 
			FROM dbo.tblArCust c INNER JOIN dbo.trav_ArCustomerHistory_view h ON c.CustId = h.CustId 
			WHERE c.CustId IN (SELECT CustId FROM #tmpCustomerList)
		END

		IF (@PrintPaymentMethodDetail = 1)
		BEGIN
			SELECT p.CustId, p.PmtMethod, p.Descr, p.CcNum, p.CcName, p.CcExpire, p.BankName, p.BankRoutingCode, p.BankAcctNum, t.PmtType 
			FROM dbo.tblArCustPmtMethod p INNER JOIN dbo.tblArPmtMethod t ON p.PmtMethod = t.PmtMethodID 
			WHERE p.CustId IN (SELECT CustId FROM #tmpCustomerList) AND t.PmtType IN (3, 6, 7)
		END
	END
	ELSE
	BEGIN
		SELECT CustId, CustName, Contact, Country, Phone, Fax, ClassId, CreditHold
		FROM dbo.tblArCust
		WHERE CustId IN (SELECT CustId FROM #tmpCustomerList)
	END
	
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArCustomerDetailList_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArCustomerDetailList_proc';

