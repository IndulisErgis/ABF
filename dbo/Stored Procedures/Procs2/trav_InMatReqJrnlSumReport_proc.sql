
CREATE PROCEDURE [dbo].[trav_InMatReqJrnlSumReport_proc]

@Print  Smallint,
@gInGlYn  Bit,
@CurrencyPrecision tinyint 

AS
SET NOCOUNT ON
BEGIN TRY

	IF @Print = 2
	BEGIN
		IF @gInGlYn = 1
			SELECT '' AS ReqNum, ' ' AS ShipToID, '1' AS ReqType, 0 AS transid,' ' AS DatePlaced, ' ' AS DateNeeded, h.SumYear, h.GLPeriod,
				SUM(ROUND((QtyFilled * CostUnitStd * reqtype),@CurrencyPrecision)) AS ReqTotals, 0 AS CostExtPos, 0 AS CostExtNeg, g.AcctId AS GLAcctNum,
				'' AS ItemId, '' AS Descr, '' AS SumOfQtyFilled, 0 AS CostUnitStd, 0 AS UomSelling, 0 AS ConvFactor
			FROM tblInMatReqHeader h (NOLOCK) INNER JOIN tblInMatReqDetail d (NOLOCK) ON h.TransId = d.TransId
				INNER JOIN tblGlAcctHdr g (NOLOCK) ON d.GLAcctNum = g.AcctId
				INNER JOIN #tmpMatReqList t ON h.TransId = t.TransId
			GROUP BY h.SumYear, h.GLPeriod, g.AcctId
		ELSE
			SELECT '' AS ReqNum, ' ' AS ShipToID, '1' AS ReqType, 0 AS transid, ' ' AS DatePlaced, ' ' AS DateNeeded, h.SumYear, h.GLPeriod,
				 SUM(ROUND((QtyFilled * CostUnitStd * reqtype),@CurrencyPrecision)) AS ReqTotals, 0 AS CostExtPos, 0 AS CostExtNeg, d.GLAcctNum,
				'' AS ItemId, '' AS Descr, '' AS SumOfQtyFilled, 0 AS CostUnitStd, 0 AS UomSelling, 0 AS ConvFactor
			FROM tblInMatReqHeader h (NOLOCK) INNER JOIN tblInMatReqDetail d (NOLOCK) ON h.TransId = d.TransId
				INNER JOIN #tmpMatReqList t ON h.TransId = t.TransId
			GROUP BY h.SumYear, h.GLPeriod, d.GLAcctNum
	END
	
	ELSE IF(@Print = 3)
	BEGIN
		SELECT h.ReqNum, h.ReqType,	SUM(ROUND((QtyFilled * CostUnitStd * reqtype),@CurrencyPrecision)) AS ReqTotals,  d.ItemId, 
			d.Descr, SUM(d.QtyFilled) AS SumOfQtyFilled, d.UomSelling	
		FROM dbo.tblInMatReqHeader h INNER JOIN dbo.tblInMatReqDetail d ON h.TransId = d.TransId
			INNER JOIN #tmpMatReqList t ON h.TransId = t.TransId
		GROUP BY h.ReqNum, d.ItemId, d.Descr, d.CostUnitStd, h.ReqType, d.UomSelling
		ORDER BY d.ItemId
	END
	
	ELSE
		SELECT ReqNum, ShipToId, ReqType, h.TransId, DatePlaced, DateNeeded, SumYear, GLPeriod,
			   ROUND(ReqTotal * ReqType,@CurrencyPrecision) AS ReqTotals,
			   CASE WHEN ReqType > 0 THEN ROUND(ReqTotal,@CurrencyPrecision) ELSE 0 END AS CostExtPos,
			   CASE WHEN ReqType < 0 THEN ROUND(ReqTotal * reqtype,@CurrencyPrecision) ELSE 0 END AS CostExtNeg, ' ' AS GLAcctNum,
			   '' AS ItemId, '' AS Descr, '' AS SumOfQtyFilled, 0 AS CostUnitStd, 0 AS UomSelling, 0 AS ConvFactor
		FROM tblInMatReqHeader h (NOLOCK) INNER JOIN #tmpMatReqList t ON h.TransId = t.TransId	
		
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InMatReqJrnlSumReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InMatReqJrnlSumReport_proc';

