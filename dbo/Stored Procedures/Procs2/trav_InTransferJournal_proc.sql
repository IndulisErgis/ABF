
CREATE PROCEDURE dbo.trav_InTransferJournal_proc
AS
SET NOCOUNT ON
BEGIN TRY

	SELECT  x.LocIdFrom, x.ItemIdFrom, x.LocIdTo, x.ItemIdTo, i.Descr, x.TransId, x.Cmnt, x.XferDate, 
        x.GLPeriod, x.SumYear, x.Qty, x.Uom, x.CostUnitXfer AS CostExtXfer, x.CostUnit AS CostUnit, 
        x.CostUnit* x.Qty AS CostExt, x.CostUnit+(x.CostUnitXfer/x.Qty) AS ToUnitCost, 
        x.CostUnitXfer+x.CostUnit* x.Qty AS ToUnitCostExt, 
		l.LotNumFrom + l.LotNumTo + CAST(l.SeqNum AS nvarchar(15)) AS LotGroup, 
        s.SerNum, i.ItemType, i.LottedYN, l.CostUnit AS CostUnitLot, s.CostUnit AS CostUnitSer, 
        s.PriceUnit AS PriceUnitSer, x.HistSeqNumFrom, x.HistSeqNumTo, l.QtyFilled AS LotQty, 1 AS SerQty, 
        s.CostXfer AS SerCostXfer, l.CostXfer AS LotCostXfer, x.CostUnitXfer/x.Qty AS CostUnitXfer1,
        l.LotNumFrom AS LLotNumFrom, l.LotNumTo AS LLotNumTo, S.LotNumFrom AS SLotNumFrom, x.BatchId
	FROM #tmpTransferList t INNER JOIN dbo.tblInXfers x ON t.TransId = x.TransId 
		INNER JOIN dbo.tblInItem i ON i.ItemId = x.ItemIdFrom
		LEFT JOIN dbo.tblInXferLot l  ON x.TransId = l.TransId 
		LEFT JOIN dbo.tblInXferSer s  ON x.TransId = s.TransId

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InTransferJournal_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InTransferJournal_proc';

