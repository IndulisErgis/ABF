
CREATE PROCEDURE dbo.trav_InBackOrderAllocationReport_proc
AS
SET NOCOUNT ON
--In Use quantity is included in the calculation of Availabe quantity , 
--but Traverse does not update In Use quantity.
BEGIN TRY

	CREATE TABLE #tmpInQtyInOnHand
	(
		ItemId pItemId NOT NULL,
		LocId pLocId NOT NULL,
		QtyOnHand pDecimal NOT NULL
	)

	CREATE TABLE #tmpInQty
	(
		ItemId pItemId NOT NULL,
		LocId pLocId NOT NULL,
		QtyCmtd pDecimal NOT NULL,
		QtyInUse pDecimal NOT NULL
	)
	
	--Serial OnHand
	INSERT INTO #tmpInQtyInOnHand(ItemId, LocId, QtyOnHand)
	SELECT q.ItemId, q.LocId, q.QtyOnHand
	FROM (SELECT d.ItemId,d.LocId 
			FROM #tmpMatReqDetailList t INNER JOIN dbo.tblInMatReqDetail d ON t.TransId = d.TransId AND t.LineNum = d.LineNum 
			GROUP BY d.ItemId,d.LocId) r
		INNER JOIN dbo.trav_InItemOnHandSer_view q ON r.ItemId = q.ItemId AND r.LocId = q.LocId 

	-- Regular OnHand
	INSERT INTO #tmpInQtyInOnHand(ItemId, LocId, QtyOnHand)
	SELECT q.ItemId, q.LocId, q.QtyOnHand
	FROM (SELECT d.ItemId,d.LocId 
			FROM #tmpMatReqDetailList t INNER JOIN dbo.tblInMatReqDetail d ON t.TransId = d.TransId AND t.LineNum = d.LineNum 
			GROUP BY d.ItemId,d.LocId) r
		INNER JOIN dbo.trav_InItemOnHand_view q ON r.ItemId = q.ItemId AND r.LocId = q.LocId 

	-- Cmtd, InUse
	INSERT INTO #tmpInQty(ItemId, LocId, QtyCmtd,QtyInUse)
	SELECT r.ItemId, r.LocId, ISNULL(q.QtyCmtd,0),ISNULL(q.QtyInUse,0)
	FROM (SELECT d.ItemId,d.LocId 
			FROM #tmpMatReqDetailList t INNER JOIN dbo.tblInMatReqDetail d ON t.TransId = d.TransId AND t.LineNum = d.LineNum 
			GROUP BY d.ItemId,d.LocId) r
		LEFT JOIN dbo.trav_InItemQtys_view q ON r.ItemId = q.ItemId AND r.LocId = q.LocId 
		LEFT JOIN dbo.trav_InItemOnHandSer_view s ON r.ItemId = s.ItemId AND s.LocId = q.LocId 

	SELECT d.ItemId,d.Descr,d.Status,d.CustId,d.ProjId,d.ProjName,d.PhaseId,d.PhaseName, 
		d.TaskId,d.TaskName,i.UomBase,h.DateNeeded,d.LocId,l.Descr AS LDescr,h.ReqNum, 
		d.QtyBkord*d.ConvFactor AS QtyBkordtot, h.ShipToId ,d.TransId,c.DfltBinNum,
		d.LineNum,h.DateShipped,ISNULL(q.QtyOnHand,0) - ISNULL(m.QtyCmtd,0) - ISNULL(m.QtyInUse,0) AS Available
	FROM #tmpMatReqDetailList t INNER JOIN dbo.tblInMatReqDetail d ON t.TransId = d.TransId AND t.LineNum = d.LineNum
		INNER JOIN dbo.tblInMatReqHeader h (NOLOCK) ON d.TransId = h.TransId
		INNER JOIN dbo.tblInLoc l (NOLOCK) ON d.LocId = l.LocId 
		INNER JOIN dbo.tblInItem i (NOLOCK) ON d.ItemId = i.ItemId 
		INNER JOIN dbo.tblInItemLoc c ON d.LocId = c.LocId AND d.ItemId = c.ItemId
		LEFT JOIN #tmpInQtyInOnHand q ON d.ItemId = q.ItemId AND d.LocId = q.LocId
		LEFT JOIN #tmpInQty m ON d.ItemId = m.ItemId AND d.LocId = m.LocId
	WHERE d.QtyBkord * d.ConvFactor > 0

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InBackOrderAllocationReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InBackOrderAllocationReport_proc';

