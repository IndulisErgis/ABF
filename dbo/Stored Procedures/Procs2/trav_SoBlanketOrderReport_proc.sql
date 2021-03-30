
CREATE PROCEDURE [dbo].[trav_SoBlanketOrderReport_proc]
-- the following should come from the pick screen or be retrieved in report sp (not needed anywhere else on the report except to retrieve the data)
@ExchRate pDecimal = 1,
@ReportCurrency pCurrency = 'USD',
@PrintAllInBaseCurrency bit = 1,
@WksDate datetime,
@SortBy bit

AS
SET NOCOUNT ON
BEGIN TRY
-- use a temp table to accumulate totals for each blanket
CREATE TABLE #Totals
(
	BlanketRef int NOT NULL, 
	TotalType tinyint NOT NULL, -- 0 = Ordered, 1 = Posted, 2 = Released, 3 = Pending
	SubTotal pDecimal DEFAULT(0), 
	Freight pDecimal DEFAULT(0), 
	Misc pDecimal DEFAULT(0)
)


-- Capture the 'Ordered' values from the header
--  Dollar amount type blankets use a fixed ContractAmount
--   so offset it by the freight and misc to calculate the subtotal
INSERT INTO #Totals(BlanketRef, TotalType, Freight, Misc, SubTotal) 
SELECT BlanketRef, 0, Freight, Misc
	, CASE WHEN BlanketType = 0 THEN h.Subtotal ELSE SubTotal END 
FROM dbo.tblSoSaleBlanket h 
INNER JOIN #tmpBlanketOrder tmp on tmp.BlanketId = h.BlanketId
WHERE --((h.BlanketStatus = @BlanketStatus) OR (@BlanketStatus = -1)) 
	--AND ((h.BlanketType = @BlanketType) OR (@BlanketType = -1)) 
	--AND 
	((h.CurrencyId = @ReportCurrency) OR (@PrintAllInBaseCurrency = 1)) -- single currency or all in base currency
	


-- calculate any 'Pending' values from the existing blanket details (no freight/misc on line items)
--  Scheduled Blankets - pull quantities as of the current workstation date
INSERT INTO #Totals(BlanketRef, TotalType, Freight, Misc, SubTotal) 
SELECT d.BlanketRef, 3, 0, 0, SUM(s.QtyOrdered * d.UnitPrice) 
FROM dbo.tblSoSaleBlanket h 
	INNER JOIN dbo.tblSoSaleBlanketDetail d ON h.BlanketRef = d.BlanketRef 
	INNER JOIN dbo.tblSoSaleBlanketDetailSch s ON d.BlanketDtlRef = s.BlanketDtlRef 
	INNER JOIN #tmpBlanketOrder tmp on tmp.BlanketId = h.BlanketId
WHERE --((h.BlanketStatus = @BlanketStatus) OR (@BlanketStatus = -1)) 
	--AND ((h.BlanketType = @BlanketType) OR (@BlanketType = -1)) 
	--AND 
	((h.CurrencyId = @ReportCurrency) OR (@PrintAllInBaseCurrency = 1)) -- single currency or all in base currency
	AND s.QtyOrdered <> 0 AND s.Status = 0 AND s.ReleaseDate <= @WksDate AND h.BlanketType = 2 -- scheduled only

GROUP BY d.BlanketRef

-- calculate any 'Pending' values from the existing blanket details (no freight/misc on line items)
--  Non-Scheduled Blankets
INSERT INTO #Totals(BlanketRef, TotalType, Freight, Misc, SubTotal) 
SELECT d.BlanketRef, 3, 0, 0, SUM(d.QtyReleased * d.UnitPrice) 
FROM dbo.tblSoSaleBlanket h 
	INNER JOIN dbo.tblSoSaleBlanketDetail d ON h.BlanketRef = d.BlanketRef 
	INNER JOIN #tmpBlanketOrder tmp on tmp.BlanketId = h.BlanketId
WHERE --((h.BlanketStatus = @BlanketStatus) OR (@BlanketStatus = -1)) 
	--AND ((h.BlanketType = @BlanketType) OR (@BlanketType = -1)) 
	--AND 
	((h.CurrencyId = @ReportCurrency) OR (@PrintAllInBaseCurrency = 1)) -- single currency or all in base currency
	AND d.QtyOrdered <> 0 AND h.BlanketType <> 2 -- non-scheduled only

GROUP BY d.BlanketRef

-- capture 'Posted' values for Freight and Misc from tblSoSaleBlanketRelease
INSERT INTO #Totals(BlanketRef, TotalType, Freight, Misc) 
SELECT h.BlanketRef, 1, SUM(SIGN(r.RecType) * h.Freight), SUM(SIGN(r.RecType) * h.Misc) 
FROM dbo.tblSoSaleBlanket h 
	INNER JOIN dbo.tblSoSaleBlanketActivity r ON h.BlanketRef = r.BlanketDtlRef 
	INNER JOIN #tmpBlanketOrder tmp on tmp.BlanketId = h.BlanketId

WHERE --((h.BlanketStatus = @BlanketStatus) OR (@BlanketStatus = -1)) 
	--AND ((h.BlanketType = @BlanketType) OR (@BlanketType = -1)) 
	--AND 
	((h.CurrencyId = @ReportCurrency) OR (@PrintAllInBaseCurrency = 1)) -- single currency or all in base currency
 
GROUP BY h.BlanketRef

-- capture 'Posted' and 'Released' Subtotal for 'Dollar Amount' blankets from tblSoSaleBlanketRelease
--  (non-dollar blankets will not have a 'release' record)
INSERT INTO #Totals(BlanketRef, TotalType, SubTotal) 
SELECT h.BlanketRef , CASE WHEN r.PostRun IS NULL THEN 2 ELSE 1 END , SUM(SIGN(r.RecType) * r.PriceExt) 
FROM dbo.tblSoSaleBlanket h 
	INNER JOIN dbo.tblSoSaleBlanketActivity r ON h.BlanketRef = r.BlanketRef 
	INNER JOIN #tmpBlanketOrder tmp on tmp.BlanketId = h.BlanketId
WHERE --((h.BlanketStatus = @BlanketStatus) OR (@BlanketStatus = -1)) 
	--AND ((h.BlanketType = @BlanketType) OR (@BlanketType = -1)) 
	--AND
	 ((h.CurrencyId = @ReportCurrency) OR (@PrintAllInBaseCurrency = 1)) -- single currency or all in base currency
	AND h.BlanketType = 0 -- amount type only

GROUP BY h.BlanketRef, r.PostRun

-- calculate 'Posted' and 'Released' Subtotal for NON-'Dollar Amount' blankets from tblSoSaleBlanketReleaseDetail
INSERT INTO #Totals(BlanketRef, TotalType, SubTotal) 
SELECT h.BlanketRef , CASE WHEN rd.PostRun is NULL THEN 2 ELSE 1 END, SUM(SIGN(rd.RecType) * rd.PriceExt) 
FROM dbo.tblSoSaleBlanket h 
	INNER JOIN dbo.tblSoSaleBlanketDetail d ON h.BlanketRef = d.BlanketRef 
	INNER JOIN dbo.tblSoSaleBlanketActivity rd ON d.BlanketDtlRef = rd.BlanketDtlRef
	INNER JOIN #tmpBlanketOrder tmp on tmp.BlanketId = h.BlanketId 
WHERE --((h.BlanketStatus = @BlanketStatus) OR (@BlanketStatus = -1)) 
	--AND ((h.BlanketType = @BlanketType) OR (@BlanketType = -1)) 
	--AND 
	((h.CurrencyId = @ReportCurrency) OR (@PrintAllInBaseCurrency = 1)) -- single currency or all in base currency
	AND h.BlanketType <> 0 -- non-amount

GROUP BY h.BlanketRef, rd.PostRun



-- return a resultset of the values (include placeholders for freight & misc)
SELECT CASE WHEN @SortBy = 0 THEN h.SoldToId ELSE h.BlanketId END AS SortBy
	, h.SoldToId, h.BlanketId, h.BlanketRef, h.BlanketType, h.BlanketStatus
	, h.ShipToId, h.CloseDate, h.ExpireDate, h.Rep1Id, h.Rep2Id, h.Rep1Pct, h.Rep2Pct, h.Rep1CommRate, h.Rep2CommRate
	, h.CustPoNum
	, CASE WHEN @PrintAllInBaseCurrency = 1 THEN tot.Subtotal / @ExchRate ELSE tot.Subtotal END AS Subtotal
	, CASE WHEN @PrintAllInBaseCurrency = 1 THEN tot.SubTotalPosted / @ExchRate ELSE tot.SubTotalPosted END AS SubtotalPosted
	, CASE WHEN @PrintAllInBaseCurrency = 1 THEN tot.SubtotalReleased / @ExchRate ELSE tot.SubtotalReleased END  AS SubtotalReleased
	, CASE WHEN @PrintAllInBaseCurrency = 1 THEN tot.SubtotalPending / @ExchRate ELSE tot.SubtotalPending END AS SubtotalPending
	, CASE WHEN @PrintAllInBaseCurrency = 1 
		THEN (tot.Subtotal - CASE WHEN tot.SubTotalReleased > tot.SubTotalPosted THEN tot.SubTotalReleased ELSE tot.SubTotalPosted END) / @ExchRate
		ELSE (tot.Subtotal - CASE WHEN tot.SubTotalReleased > tot.SubTotalPosted THEN tot.SubTotalReleased ELSE tot.SubTotalPosted END) 
		END  AS SubtotalRemaining
	, CASE WHEN @PrintAllInBaseCurrency = 1 THEN tot.Freight / @ExchRate ELSE tot.Freight END AS Freight
	, CASE WHEN @PrintAllInBaseCurrency = 1 THEN tot.FreightPosted / @ExchRate ELSE tot.FreightPosted END AS FreightPosted
	, CASE WHEN @PrintAllInBaseCurrency = 1 THEN tot.FreightReleased / @ExchRate ELSE tot.FreightReleased END AS FreightReleased
	, CASE WHEN @PrintAllInBaseCurrency = 1 THEN tot.FreightPending / @ExchRate ELSE tot.FreightPending END AS FreightPending
	, CASE WHEN @PrintAllInBaseCurrency = 1 
		THEN (tot.Freight - CASE WHEN tot.FreightReleased > tot.FreightPosted THEN tot.FreightReleased ELSE tot.FreightPosted END) / @ExchRate
		ELSE (tot.Freight - CASE WHEN tot.FreightReleased > tot.FreightPosted THEN tot.FreightReleased ELSE tot.FreightPosted END) 
		END  AS FreightRemaining
	, CASE WHEN @PrintAllInBaseCurrency = 1 THEN tot.Misc / @ExchRate ELSE tot.Misc END AS Misc
	, CASE WHEN @PrintAllInBaseCurrency = 1 THEN tot.MiscPosted / @ExchRate ELSE tot.MiscPosted END AS MiscPosted
	, CASE WHEN @PrintAllInBaseCurrency = 1 THEN tot.MiscReleased / @ExchRate ELSE tot.MiscReleased END AS MiscReleased
	, CASE WHEN @PrintAllInBaseCurrency = 1 THEN tot.MiscPending / @ExchRate ELSE tot.MiscPending END AS MiscPending
	, CASE WHEN @PrintAllInBaseCurrency = 1 
		THEN (tot.Misc - CASE WHEN tot.MiscReleased > tot.MiscPosted THEN tot.MiscReleased ELSE tot.MiscPosted END) / @ExchRate
		ELSE (tot.Misc - CASE WHEN tot.MiscReleased > tot.MiscPosted THEN tot.MiscReleased ELSE tot.MiscPosted END)
		END  AS MiscRemaining
	, CASE WHEN @PrintAllInBaseCurrency = 1 THEN tot.Total / @ExchRate ELSE tot.Total END  AS Total
	, CASE WHEN @PrintAllInBaseCurrency = 1 THEN  tot.TotalPosted / @ExchRate ELSE  tot.TotalPosted END  AS TotalPosted
	, CASE WHEN @PrintAllInBaseCurrency = 1 THEN  tot.TotalReleased / @ExchRate ELSE  tot.TotalReleased END  AS TotalReleased
	, CASE WHEN @PrintAllInBaseCurrency = 1 THEN  tot.TotalPending / @ExchRate ELSE  tot.TotalPending END  AS TotalPending
	, CASE WHEN @PrintAllInBaseCurrency = 1 
		THEN (tot.Total - CASE WHEN tot.TotalReleased > tot.TotalPosted THEN tot.TotalReleased ELSE tot.TotalPosted END) / @ExchRate 
		ELSE (tot.Total - CASE WHEN tot.TotalReleased > tot.TotalPosted THEN tot.TotalReleased ELSE tot.TotalPosted END) 
		END AS TotalRemaining 
FROM dbo.tblSoSaleBlanket h 
	INNER JOIN (SELECT BlanketRef
					, SUM(CASE WHEN TotalType = 0 THEN Subtotal ELSE 0 END) AS SubTotal 
					, SUM(CASE WHEN TotalType = 1 THEN SubTotal ELSE 0 END) AS SubTotalPosted
					, SUM(CASE WHEN TotalType = 2 THEN Subtotal ELSE 0 END) AS SubTotalReleased
					, SUM(CASE WHEN TotalType = 3 THEN Subtotal ELSE 0 END) AS SubTotalPending
					, SUM(CASE WHEN TotalType = 0 THEN Freight ELSE 0 END) AS Freight
					, SUM(CASE WHEN TotalType = 1 THEN Freight ELSE 0 END) AS FreightPosted 
					, SUM(CASE WHEN TotalType = 2 THEN Freight ELSE 0 END) AS FreightReleased
					, SUM(CASE WHEN TotalType = 3 THEN Freight ELSE 0 END) AS FreightPending
					, SUM(CASE WHEN TotalType = 0 THEN Misc ELSE 0 END) AS Misc
					, SUM(CASE WHEN TotalType = 1 THEN Misc ELSE 0 END) AS MiscPosted 
					, SUM(CASE WHEN TotalType = 2 THEN Misc ELSE 0 END) AS MiscReleased
					, SUM(CASE WHEN TotalType = 3 THEN Misc ELSE 0 END) AS MiscPending
					, SUM(CASE WHEN TotalType = 0 THEN Subtotal + Freight + Misc ELSE 0 END) AS Total
					, SUM(CASE WHEN TotalType = 1 THEN Subtotal + Freight + Misc ELSE 0 END) AS TotalPosted
					, SUM(CASE WHEN TotalType = 2 THEN Subtotal + Freight + Misc ELSE 0 END) AS TotalReleased
					, SUM(CASE WHEN TotalType = 3 THEN Subtotal + Freight + Misc ELSE 0 END) AS TotalPending 
				FROM #Totals 
				GROUP BY BlanketRef) tot 
		ON h.BlanketRef = tot.BlanketRef 


--detail resultset
-- use a temp table to accumulate the quantities for the given blanket
CREATE TABLE #QtyDtl
(
	BlanketDtlRef int, 
	OriginalQty pDecimal DEFAULT(0), 
	PostedQty pDecimal DEFAULT(0), 
	ReleasedQty pDecimal DEFAULT(0), 
	PendingQty pDecimal DEFAULT(0)
)


-- capture Original, Pending (for non-Scheduled only)
INSERT INTO #QtyDtl (BlanketDtlRef, OriginalQty, PendingQty) 
SELECT d.BlanketDtlRef, d.QtyOrdered OriginalQty, CASE WHEN h.BlanketType = 2 THEN 0 ELSE d.QtyReleased END AS PendingQty 
FROM dbo.tblSoSaleBlanket h 
	INNER JOIN dbo.tblSoSaleBlanketDetail d ON h.BlanketRef = d.BlanketRef 
	INNER JOIN #tmpBlanketOrder tmp on tmp.BlanketId = h.BlanketId
--WHERE h.BlanketRef = @BlanketRef

-- capture Pending for scheduled blankets
INSERT INTO #QtyDtl (BlanketDtlRef, PendingQty) 
SELECT d.BlanketDtlRef, SUM(s.QtyOrdered) PendingQty 
FROM dbo.tblSoSaleBlanket h 
	INNER JOIN dbo.tblSoSaleBlanketDetail d ON h.BlanketRef = d.BlanketRef 
	INNER JOIN dbo.tblSoSaleBlanketDetailSch s ON d.BlanketDtlRef = s.BlanketDtlRef
	INNER JOIN #tmpBlanketOrder tmp on tmp.BlanketId = h.BlanketId
WHERE s.Status = 0 AND s.ReleaseDate <= @WksDate AND h.BlanketType = 2 -- scheduled only
GROUP BY d.BlanketDtlRef

-- capture Prior Released and Prior Posted quantities
INSERT INTO #QtyDtl (BlanketDtlRef, ReleasedQty, PostedQty) 
SELECT d.BlanketDtlRef
	, SUM(CASE WHEN r.PostRun IS NOT NULL THEN 0.0  ELSE (SIGN(r.RecType) * r.Qty) / u.ConvFactor END) ReleasedQty
	, SUM(CASE WHEN r.PostRun IS NULL THEN 0.0 ELSE ( SIGN(r.RecType) * r.Qty) / u.ConvFactor END) PostedQty 
FROM dbo.tblSoSaleBlanketDetail d inner join dbo.tblSoSaleBlanket h  on h.BlanketRef = d.BlanketRef
	INNER JOIN dbo.tblSoSaleBlanketActivity r ON d.BlanketDtlRef = r.BlanketDtlRef
	INNER JOIN #tmpBlanketOrder tmp on tmp.BlanketId = h.BlanketId
	LEFT JOIN dbo.tblInItemUom u ON u.ItemId = d.ItemId AND u.Uom = d.Units 
GROUP BY d.BlanketDtlRef

-- return the resultset
SELECT d.BlanketRef, d.ItemId, d.Descr, d.LocId, ISNULL(i.LottedYn, 0) AS LottedYn, d.LotNum, d.Units
	, q.OriginalQty  AS OriginalQty
	, q.PostedQty  AS PostedQty
	, q.ReleasedQty  AS ReleasedQty
	, q.PendingQty  AS PendingQty
	, CASE WHEN q.PostedQty > q.ReleasedQty 
		THEN q.OriginalQty - q.PostedQty 
		ELSE q.OriginalQty - q.ReleasedQty 
		END  AS RemainingQty
	, CASE WHEN @PrintAllInBaseCurrency = 1 THEN d.UnitPrice / @ExchRate ELSE d.UnitPrice END  AS UnitPrice
	, CASE WHEN @PrintAllInBaseCurrency = 1 THEN d.PriceExt / @ExchRate ELSE d.PriceExt END  AS OriginalPriceExt
	, CASE WHEN @PrintAllInBaseCurrency = 1 THEN (q.PostedQty * d.UnitPrice) / @ExchRate ELSE (q.PostedQty * d.UnitPrice) END  AS PostedPriceExt
	, CASE WHEN @PrintAllInBaseCurrency = 1 THEN (q.ReleasedQty * d.UnitPrice)/ @ExchRate ELSE (q.ReleasedQty * d.UnitPrice) END  AS ReleasedPriceExt
	, CASE WHEN @PrintAllInBaseCurrency = 1 THEN (q.PendingQty * d.UnitPrice) / @ExchRate ELSE (q.PendingQty * d.UnitPrice) END  AS PendingPriceExt 
	, CASE WHEN @PrintAllInBaseCurrency = 1 
		THEN (CASE WHEN q.PostedQty > q.ReleasedQty 
			THEN q.OriginalQty - q.PostedQty 
			ELSE q.OriginalQty - q.ReleasedQty 
			END * d.UnitPrice) / @ExchRate 
		ELSE (CASE WHEN q.PostedQty > q.ReleasedQty 
			THEN q.OriginalQty - q.PostedQty 
			ELSE q.OriginalQty - q.ReleasedQty 
			END * d.UnitPrice)
		END  AS RemainingPriceExt
	, d.Rep1Id, d.Rep2Id, d.Rep1Pct, d.Rep2Pct, d.Rep1CommRate, d.Rep2CommRate, d.TaxClass 
	FROM dbo.tblSoSaleBlanketDetail d
	INNER JOIN (SELECT BlanketDtlRef
		, SUM(OriginalQty) AS OriginalQty 
		, SUM(PostedQty) AS PostedQty
		, SUM(ReleasedQty) AS ReleasedQty
		, SUM(PendingQty) AS PendingQty
		FROM #QtyDtl
		GROUP BY BlanketDtlRef) q
	ON d.BlanketDtlRef = q.BlanketDtlRef
	LEFT JOIN dbo.tblInItem i ON d.ItemId = i.ItemId
	
	
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SoBlanketOrderReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SoBlanketOrderReport_proc';

