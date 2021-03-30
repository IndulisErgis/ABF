
CREATE PROCEDURE dbo.trav_ArCommCalcAmounts_proc
@PrecisionCurrency tinyint = 2
AS
SET NOCOUNT ON
BEGIN TRY

	CREATE TABLE #AdjTotals
	(
		[Counter] [int], 
		[AdjNetSales] [pDecimal],
		[AdjAmtPmt] [pDecimal]
	)

	-- build base commission info
	INSERT INTO #CalcCommAmts ([Counter], SalesRepId, CustId, InvcNum, InvcDate, BasedOnDtl, AmtPmt
		, NetSales, AdjNetSales, BaseAmt, AmtPayOn, TotPoss) 
	SELECT c.[Counter], c.SalesRepID, c.CustId, c.InvcNum, c.InvcDate, BasedOnDtl, c.AmtPmt
		, c.AmtInvc AS NetSales, c.AmtInvc AS AdjNetSales
		, ROUND (CASE PctOfDtl 
			WHEN 0 THEN 0 
			WHEN 1 THEN 
				CASE WHEN PayLines <> 0 THEN AmtLines ELSE 0 END 
				+ CASE WHEN PayTax <> 0 THEN AmtTax ELSE 0 END 
				+ CASE WHEN PayFreight <> 0 THEN AmtFreight ELSE 0 END 
				+ CASE WHEN PayMisc <> 0 THEN AmtMisc ELSE 0 END
			WHEN 2 THEN 
				CASE WHEN PayLines <> 0 THEN AmtLines ELSE 0 END 
				+ CASE WHEN PayTax <> 0 THEN AmtTax ELSE 0 END 
				+ CASE WHEN PayFreight <> 0 THEN AmtFreight ELSE 0 END 
				+ CASE WHEN PayMisc <> 0 THEN AmtMisc ELSE 0 END 
				- AmtCogs END * (PctInvc / 100), @PrecisionCurrency) AS BaseAmt
		, (AmtLines + AmtTax + AmtFreight + AmtMisc) AS AmtPayOn
		, ROUND (ROUND(CASE PctOfDtl 
			WHEN 0 THEN 0 
			WHEN 1 THEN 
				CASE WHEN PayLines <> 0 THEN AmtLines ELSE 0 END 
				+ CASE WHEN PayTax <> 0 THEN AmtTax ELSE 0 END 
				+ CASE WHEN PayFreight <> 0 THEN AmtFreight ELSE 0 END 
				+ CASE WHEN PayMisc <> 0 THEN AmtMisc ELSE 0 END 
			WHEN 2 THEN 
				CASE WHEN PayLines <> 0 THEN AmtLines ELSE 0 END 
				+ CASE WHEN PayTax <> 0 THEN AmtTax ELSE 0 END 
				+ CASE WHEN PayFreight <> 0 THEN AmtFreight ELSE 0 END 
				+ CASE WHEN PayMisc <> 0 THEN AmtMisc ELSE 0 END 
				- AmtCogs END * (PctInvc / 100), @PrecisionCurrency) * (c.CommRateDtl / 100), @PrecisionCurrency) AS TotPoss 
	FROM #tmpCommInvcList t INNER JOIN dbo.tblArCommInvc c (NOLOCK) ON t.[Counter] = c.[Counter]

	--Capture an adjusted total invoice amount to properly apply "credits" to "invoices" 
	--	as well as the cumulative total of applied payment (max payment amount) for processing "paid invoices"
	--	group by SalesRepId, CustId, Invoice Number, date and amount to isolate unique trans amounts when using line item commissions
	Insert into #AdjTotals ([Counter], [AdjNetSales], [AdjAmtPmt])
	Select c.[Counter], stot.[SumNetSales], stot.[MaxAmtPmt]
		FROM #CalcCommAmts c
		Inner Join (
			Select SalesRepId, CustId, InvcNum, Sum(NetSales) SumNetSales, Max(AmtPmt) MaxAmtPmt
			From (Select SalesRepId, CustId, InvcNum, NetSales, AmtPmt
				From #CalcCommAmts 
				Group By SalesRepId, CustId, InvcNum, InvcDate, NetSales, AmtPmt
			) tmp 
			Group By SalesRepId, CustId, InvcNum
		) stot On c.SalesRepId = stot.SalesRepId And ISNULL(c.CustId, '') = ISNULL(stot.CustId, '') And c.InvcNum = stot.InvcNum

	-- calculate the earned commission
	UPDATE #CalcCommAmts SET [AdjNetSales] = a.[AdjNetSales]
		, [Earned] = CASE c.[BasedOnDtl]
			WHEN 0 THEN c.[TotPoss] -- Booked Sales
			WHEN 1 THEN -- Paid Invoices
				CASE WHEN c.[TotPoss] = 0 OR a.[AdjNetSales] = 0 OR (a.[AdjNetSales] - a.[AdjAmtPmt]) <= 0
				THEN c.[TotPoss] 
				ELSE ROUND(c.[TotPoss] * (a.[AdjAmtPmt] / a.[AdjNetSales]), @PrecisionCurrency)
				END
		END
	From #CalcCommAmts c Inner Join #AdjTotals a on c.[Counter] = a.[Counter]

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArCommCalcAmounts_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArCommCalcAmounts_proc';

