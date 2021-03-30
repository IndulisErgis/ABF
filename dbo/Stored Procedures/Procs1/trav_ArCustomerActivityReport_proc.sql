
CREATE PROCEDURE dbo.trav_ArCustomerActivityReport_proc
@HistoryPeriod smallint = 12,
@FiscalYear smallint = 2008,
@SortBy tinyint = 0 -- 0, Customer ID; 1, Class Code; 2, Sales Rep ID;
AS
SET NOCOUNT ON
BEGIN TRY

	SELECT CASE @SortBy
		WHEN 0 THEN u.CustId
		WHEN 1 THEN u.ClassId
		WHEN 2 THEN u.SalesRepId1
		END AS GrpId1,
		u.CustId, c.SumHistPeriod as Period, c.FiscalYear as [Year], u.CustName, u.ClassId, u.SalesRepId1,
		c.TotSales AS TotalSales, c.NumInvc AS TotalNumInvc,
		CASE WHEN c.NumInvc <> 0 THEN c.TotSales/c.NumInvc ELSE 0 END as TotalAveInvc,
		c.TotSales-c.TotCogs AS TotalGrossProfit, o.TotSales AS GrandTotalSales,
		o.TotSales-o.TotCogs AS GrandTotalGrossProfit,
		o.NumInvc AS GrandTotalNumInvc, 
		CASE WHEN o.TotSales <> 0 THEN c.TotSales/o.TotSales*100 ELSE 0 END as TotalSalesPct,
		CASE WHEN o.TotSales-o.TotCogs <> 0 THEN (c.TotSales-c.TotCogs)/(o.TotSales-o.TotCogs)*100 ELSE 0 END as TotalGrossPct,
		CASE WHEN o.TotSales <> 0 THEN (c.TotSales/o.TotSales * 100) else 0 END TotalAvePct,
		cast(CASE WHEN o.NumInvc <> 0 THEN Round((convert(decimal, c.NumInvc)/convert(decimal, o.NumInvc))*100, 2) 
			ELSE 0 END as float) AS TotalNumInvcPct 
	FROM #tmpCustomerList t INNER JOIN dbo.tblArCust u ON t.CustId = u.CustId 
	INNER JOIN (Select CustId, FiscalYear, SumHistPeriod
	, Sum(SIGN(TransType)*(TaxSubtotal+NonTaxSubtotal)) TotSales
	, Sum(SIGN(TransType)*TotCost) TotCogs
	, Sum(CASE WHEN TransType>0 THEN 1 ELSE 0 END) NumInvc 
	FROM dbo.tblArHistHeader
	WHERE FiscalYear = @FiscalYear AND SumHistPeriod = @HistoryPeriod AND VoidYn = 0
	GROUP BY CustId, FiscalYear, SumHistPeriod ) c	ON u.CustId = c.CustId 
	INNER JOIN (SELECT FiscalYear, SumHistPeriod
		, Sum(SIGN(TransType)*(TaxSubtotal+NonTaxSubtotal)) TotSales
		, Sum(SIGN(TransType)*TotCost) TotCogs
		, Sum(CASE WHEN TransType>0 THEN 1 ELSE 0 END) NumInvc 
		FROM dbo.tblArHistHeader
		WHERE FiscalYear = @FiscalYear AND SumHistPeriod = @HistoryPeriod AND VoidYn = 0
		GROUP BY FiscalYear, SumHistPeriod) o ON c.FiscalYear = o.FiscalYear AND c.SumHistPeriod = o.SumHistPeriod  
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArCustomerActivityReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArCustomerActivityReport_proc';

