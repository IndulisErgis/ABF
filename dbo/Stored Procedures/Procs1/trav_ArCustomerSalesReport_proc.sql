
CREATE PROCEDURE [dbo].[trav_ArCustomerSalesReport_proc]
@FiscalPeriod smallint,
@FiscalYear smallint,
@PrintItemDetail bit = 0,
@SortBy tinyint = 0
AS
--PET:http://webfront:801/view.php?id=225146
--PET:http://webfront:801/view.php?id=225168
--PET:http://webfront:801/view.php?id=236678&history=1#history
SET NOCOUNT ON
BEGIN TRY
	DECLARE @NumInvcTotal int, @SalesTotal pDecimal, @ProfitTotal pDecimal

	CREATE TABLE #Cust
	(
		CustId pCustId NOT NULL, 
		CustSales pDecimal,
		CustProfit pDecimal,
		CustNumInvc int,
		PRIMARY KEY (CustId)
	)

	CREATE TABLE #ItemDetail
	(
		CustId pCustId NOT NULL, 
		PartId pItemId NOT NULL, 
		PartType tinyint NOT NULL, 
		BaseUnit pUOM NOT NULL, 
		Qty pDecimal, 
		Sales pDecimal, 
		Profit pDecimal, 
		NumInvc int, 
		PRIMARY KEY (CustId, PartId, PartType, BaseUnit)
	)

	--PET:225146, PET:225168
	--capture the invoice totals by customer
	INSERT INTO #Cust (CustId, CustSales, CustProfit, CustNumInvc) 
	SELECT t.CustId
		, Sum(SIGN(TransType) * (TaxSubtotal + NonTaxSubtotal)) 
		, Sum(SIGN(TransType) * (TaxSubtotal + NonTaxSubtotal - TotCost))
		, Sum(CASE WHEN TransType > 0 THEN 1 ELSE 0 END)
	FROM #tmpCustomerList t 
	INNER JOIN dbo.tblArHistHeader h ON t.CustId = h.CustId
	WHERE h.FiscalYear = @FiscalYear AND h.GLPeriod = @FiscalPeriod
		AND h.VoidYn = 0 --exclude voids 
	GROUP BY t.CustId
		
	
	--capture the item detail
	INSERT INTO #ItemDetail (CustId, PartId, PartType, BaseUnit, Qty, Sales, Profit, NumInvc ) 
	SELECT h.CustId, ISNULL(d.PartId, ''), ISNULL(d.PartType, 0), ISNULL(d.BaseUnit, '')
		, SUM(d.Qty), SUM(d.Sales), SUM(d.Sales - d.Cogs)
		, SUM(CASE WHEN TransType > 0 THEN 1 ELSE 0 END)
	FROM dbo.tblArHistHeader h 
	INNER JOIN (SELECT th.PostRun, th.TransId
			, td.PartId, td.PartType, td.UnitsBase AS BaseUnit
			, SUM(td.QtyShipBase * SIGN(th.TransType)) AS Qty
			, SUM(td.PriceExt * SIGN(th.TransType)) AS Sales
			, SUM(td.CostExt * SIGN(th.TransType)) AS Cogs
		FROM #Cust c
		INNER JOIN dbo.tblArHistHeader th on c.CustId = th.CustId
		INNER JOIN dbo.tblArHistDetail td ON th.PostRun = td.PostRun AND th.TransId = td.TransID
		WHERE th.FiscalYear = @FiscalYear AND th.GLPeriod = @FiscalPeriod
			AND th.VoidYn = 0 AND td.EntryNum > 0 AND td.[GrpId] IS NULL --exclude voids, special detail entries and kit components
		GROUP BY th.PostRun, th.TransId, td.PartId, td.PartType, td.UnitsBase
		) d
	ON h.PostRun = d.PostRun AND h.TransId = d.TransId
	GROUP BY h.CustId, ISNULL(d.PartId, ''), ISNULL(d.PartType, 0), ISNULL(d.BaseUnit, '')


	--calculate the report totals
	SELECT @SalesTotal = ISNULL(SUM(CustSales), 0)
		   , @ProfitTotal = ISNULL(SUM(CustProfit), 0)
		   , @NumInvcTotal = ISNULL(SUM(CustNumInvc), 0)
	FROM #Cust


	--return the results
	SELECT CASE @SortBy
			WHEN 0 THEN c.CustId
			WHEN 1 THEN c.CustName
			WHEN 2 THEN c.ClassId
			WHEN 3 THEN c.SalesRepId1
		  END AS GrpId1
		  , @NumInvcTotal AS NumInvcTotal, @SalesTotal AS SalesTotal, @ProfitTotal AS ProfitTotal
		  , c.CustId, c.CustName, c.ClassId, c.SalesRepId1 AS RepId
		  , g.CustSales AS Sales, g.CustProfit AS Profit, g.CustNumInvc AS NumInvc
		  , ISNULL(i.InventoriedSales, 0) AS InventoriedSales, ISNULL(i.InventoriedProfit, 0) AS InventoriedProfit
	FROM #Cust g
	INNER JOIN dbo.tblArCust c ON g.CustId = c.CustId
	LEFT JOIN (SELECT CustId, SUM(Sales) InventoriedSales, SUM(Profit) InventoriedProfit
		FROM #ItemDetail
		WHERE PartType <> 0
		GROUP BY CustId) i ON g.CustId = i.CustId

	--conditionally return the item details
	SELECT CASE @SortBy
			WHEN 0 THEN c.CustId
			WHEN 1 THEN c.CustName
			WHEN 2 THEN c.ClassId
			WHEN 3 THEN c.SalesRepId1
		  END AS GrpId1
		  , @NumInvcTotal AS NumInvcTotal, @SalesTotal AS SalesTotal, @ProfitTotal AS ProfitTotal
		  , c.CustId, d.PartId, d.PartType, d.Qty, d.BaseUnit
		  , d.Sales, d.Profit, d.NumInvc
	FROM #Cust g
	INNER JOIN dbo.tblArCust c ON g.CustId = c.CustId
	INNER JOIN #ItemDetail d ON g.CustId = d.CustId
	WHERE @PrintItemDetail = 1 

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArCustomerSalesReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArCustomerSalesReport_proc';

