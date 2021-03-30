
CREATE PROCEDURE dbo.trav_ArCommissionEditRegister_proc
@PrecisionCurrency tinyint = 2
AS
SET NOCOUNT ON
BEGIN TRY

	CREATE TABLE #CalcCommAmts
	(
		[Counter] int, 
		SalesRepId pSalesRep,
		CustId pCustID NULL,
		InvcNum pInvoiceNum,
		InvcDate DateTime,
		BasedOnDtl bit, 
		AmtPmt pDecimal, 
		NetSales pDecimal, 
		AdjNetSales pDecimal, 
		BaseAmt pDecimal, 
		AmtPayOn pDecimal, 
		TotPoss pDecimal, 
		Earned pDecimal DEFAULT (0)
	)

	CREATE TABLE #RepTotals
	(
		SalesRepId pSalesRep, 
		RepAmtInvc pDecimal
	)

	-- get calculated commission info
	EXEC trav_ArCommCalcAmounts_proc @PrecisionCurrency

	-- capture sales rep totals (pull invoice total amounts from each distinct invoice grouping)
	INSERT INTO #RepTotals (SalesRepId, RepAmtInvc) 
	SELECT tmp.SalesRepId, SUM(tmp.AmtInvc) 
	FROM (SELECT c.SalesRepID, c.AmtInvc
			FROM dbo.tblArCommInvc c
			INNER JOIN #CalcCommAmts t ON c.[Counter] = t.[Counter] 
			WHERE c.AmtPrepared <> 0 
			GROUP BY c.SalesRepID, c.CustId, c.InvcNum, c.InvcDate, c.AmtInvc) tmp 
	GROUP BY tmp.SalesRepId


	-- return resultset
	SELECT s.RunCode, s.[Name]
		, c.*
		, t.NetSales, c.AmtLines - c.AmtCogs AS GrossProfit
		, t.BaseAmt AS CommBase, t.TotPoss AS CommPoss, t.Earned AS CommEarned
		, t.Earned + c.AmtAdjust - c.CommPaid AS CommDue, r.RepAmtInvc, tot.TotAmtInvc 
	FROM #CalcCommAmts t 
		INNER JOIN dbo.tblArCommInvc c (NOLOCK) ON c.Counter = t.Counter 
		INNER JOIN dbo.tblArSalesRep s (NOLOCK) ON c.SalesRepID = s.SalesRepID
		INNER JOIN #RepTotals r on c.SalesRepId = r.SalesRepId
		CROSS JOIN (SELECT CAST(SUM(RepAmtInvc) AS float) TotAmtInvc FROM #RepTotals) tot
	Where c.AmtPrepared <> 0

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArCommissionEditRegister_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArCommissionEditRegister_proc';

