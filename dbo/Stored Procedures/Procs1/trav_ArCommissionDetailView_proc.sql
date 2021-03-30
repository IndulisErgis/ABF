
CREATE PROCEDURE [dbo].[trav_ArCommissionDetailView_proc]
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
		RepAmtInvc pDecimal, 
		RepAmtPmt pDecimal, 
		RepAmtCogs pDecimal, 
		RepAmtPayOn pDecimal,
		RepAmtLines pDecimal
	)

	-- get calculated commission info
	EXEC trav_ArCommCalcAmounts_proc @PrecisionCurrency

	-- capture sales rep totals (pull invoice total amounts from first record of multiple detail records)
	INSERT INTO #RepTotals (SalesRepId, RepAmtInvc, RepAmtPmt, RepAmtCogs, RepAmtPayOn, RepAmtLines) 
		SELECT c.SalesRepId, SUM(c.AmtInvc), SUM(c.AmtPmt), SUM(c.AmtCogs), SUM(AmtLines + AmtTax + AmtFreight + AmtMisc) AS RepAmtPayOn, SUM(AmtLines)
		FROM dbo.tblArCommInvc c 
			INNER JOIN (SELECT c2.SalesRepID, MIN(c2.[Counter]) AS [Counter] 
					FROM dbo.tblArCommInvc c2 INNER JOIN #CalcCommAmts t ON c2.[Counter] = t.[Counter]
					GROUP BY c2.SalesRepID, c2.CustId, c2.InvcNum, c2.InvcDate) tmp 
				ON c.SalesRepId = tmp.SalesRepId And c.Counter = tmp.Counter
	GROUP BY c.SalesRepId

	-- return resultset
	SELECT s.RunCode, s.[Name], c.*, c.AmtCogs AS AmtCogs1, c.CompletedDate AS CompletedDate
		, t.NetSales, c.AmtLines - c.AmtCogs AS GrossProfit, t.BaseAmt AS CommBase, t.TotPoss AS CommPoss
		, t.Earned AS CommEarned, t.Earned + c.AmtAdjust - c.CommPaid AS CommDue
		, CASE WHEN PayLines <> 0 THEN 'Yes' ELSE 'No' END AS PayLinesYn
		, CASE WHEN PayTax <> 0 THEN 'Yes' ELSE 'No' END AS PayTaxYn
		, CASE WHEN PayFreight <> 0 THEN 'Yes' ELSE 'No' END AS PayFreightYn
		, CASE WHEN PayMisc <> 0 THEN 'Yes' ELSE 'No' END AS PayMiscYn
		, HoldYn AS TxtHoldYn 
		, r.RepAmtInvc, r.RepAmtPmt, r.RepAmtCogs, r.RepAmtLines - r.RepAmtCogs AS RepGrossProfit
		, tot.TotAmtInvc, tot.TotAmtPmt, tot.TotAmtCogs, tot.TotGrossProfit
	FROM #CalcCommAmts t 
		INNER JOIN dbo.tblArCommInvc c (NOLOCK) ON c.Counter = t.Counter 
		INNER JOIN dbo.tblArSalesRep s (NOLOCK) ON c.SalesRepID = s.SalesRepID
		INNER JOIN #RepTotals r on c.SalesRepId = r.SalesRepId
		CROSS JOIN (SELECT SUM(RepAmtInvc) TotAmtInvc
			, SUM(RepAmtPmt) TotAmtPmt
			, SUM(RepAmtCogs) TotAmtCogs
			, SUM(RepAmtLines - RepAmtCogs) TotGrossProfit 
			FROM #RepTotals) tot

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArCommissionDetailView_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArCommissionDetailView_proc';

