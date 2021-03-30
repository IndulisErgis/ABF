
CREATE PROCEDURE [dbo].[trav_InMatReqJrnlReport_proc]
@CurrencyPrecision tinyint 
AS
SET NOCOUNT ON
BEGIN TRY

	CREATE TABLE #tmp 
	(
		TransId int,
		LineNum smallint,
		LotNum pLotNum,
		SerNum pSerNum,
		CostUnit pDecimal,
		LotCount int
	)

	SELECT h.*, d.LineNum, d.ItemId,  d.Status, d.LocId AS DLocId, d.Descr, d.UomBase, d.UomSelling, d.ConvFactor, d.ItemType, 
		i.LottedYN, d.GLAcctNum, d.GLDescr, d.QtyReqstd,d.QtyFilled,d.QtyBkord,
	   CAST(ROUND(h.reqtype * d.QtyFilled * d.CostUnitStd,@CurrencyPrecision) AS float) AS CostExts, d.JOJobId, d.JOPhaseId, d.JOCostCode, d.HistSeqNum, 
	   CAST(CASE WHEN h.ReqType > 0 THEN ROUND(d.QtyFilled * d.CostUnitStd,@CurrencyPrecision) ELSE 0 END AS float) AS CostExtPos,  
	   CAST(CASE WHEN h.ReqType < 0 THEN -ROUND(d.QtyFilled * d.CostUnitStd,@CurrencyPrecision) ELSE 0 END AS float) AS CostExtNeg, h.DateShipped
	FROM dbo.tblInMatReqHeader h INNER JOIN dbo.tblInMatReqDetail d ON h.TransId = d.TransId
		INNER JOIN #tmpMatReqList t ON h.TransId = t.TransId			
		LEFT JOIN dbo.tblInItem AS i ON i.ItemId = d.ItemId

	--Getting LotNumInfo
	SELECT l.TransId, l.LineNum, l.LotNum, l.QtyFilled , h.ReqType * l.CostUnit AS CostUnit 
	FROM dbo.tblInMatReqHeader h INNER JOIN dbo.tblInMatReqDetail d ON h.TransId = d.TransId 
		 INNER JOIN dbo.tblInMatReqLot l ON d.LineNum = l.LineNum AND d.TransId = l.TransId 
		 INNER JOIN #tmpMatReqList t ON h.TransId = t.TransId

	--Getting SerialNumInfo
	INSERT INTO #tmp 
		SELECT s.TransId, s.LineNum, s.LotNum, s.SerNum, h.ReqType * s.CostUnit AS CostUnit, NULL
		FROM dbo.tblInMatReqHeader h INNER JOIN dbo.tblInMatReqDetail d ON h.TransId = d.TransId 
			 INNER JOIN dbo.tblInMatReqSer s ON d.LineNum = s.LineNum AND d.TransId = s.TransId 
			 INNER JOIN #tmpMatReqList t ON h.TransId = t.TransId
		 
	 UPDATE #tmp SET LotCount = (SELECT COUNT(s.LotNum) FROM #tmp s WHERE s.LotNum IS NOT NULL)	 
	 SELECT * FROM #tmp 

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InMatReqJrnlReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InMatReqJrnlReport_proc';

