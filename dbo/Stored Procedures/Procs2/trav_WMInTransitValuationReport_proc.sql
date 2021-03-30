
--PET:http://webfront:801/view.php?id=244652

CREATE PROCEDURE dbo.trav_WMInTransitValuationReport_proc
@SortBy int, 
@QuantityPrecision tinyint, 
@CurrencyPrecision tinyint, 
@UnitCostPrecision tinyint

AS
BEGIN TRY
	SET NOCOUNT ON

	SELECT xfer.TranKey, CASE @SortBy WHEN 0 THEN xfer.ItemId WHEN 1 THEN xfer.LocId END AS GrpID1
		, CASE @SortBy WHEN 0 THEN xfer.LocId WHEN 1 THEN xfer.ItemId END AS GrpID2
		, xfer.ItemID, item.Descr, xfer.LocId, xfer.LocIdTo
		, xfer.UOM AS TransferUOM, xfer.CostTransfer AS TransferCost
		, ISNULL(pqty.TtlAmt, 0) AS TotalExtCostFrom
		, ISNULL(rqty.TtlAmt, 0) AS TotalExtCostTo
		, ROUND(ISNULL(xfer.Qty, 0), @QuantityPrecision) AS TransferQty 
	FROM dbo.tblWmTransfer xfer 
		INNER JOIN #Filter fltr ON (fltr.TranKey = xfer.TranKey) 
		LEFT JOIN dbo.tblInItemUom unit ON (xfer.ItemId = unit.ItemId) AND (xfer.UOM = unit.Uom) 
		LEFT JOIN dbo.tblInItem item ON item.ItemId = xfer.ItemId 
		INNER JOIN 
		(
			SELECT pick.TranKey, SUM(ROUND((pick.Qty * ISNULL(unit.ConvFactor, 1)), @QuantityPrecision)) AS TtlQty
				, SUM (ROUND((pick.Qty * pick.UnitCost), @CurrencyPrecision)) AS TtlAmt 
			FROM dbo.tblWmTransferPick pick 
				INNER JOIN #Filter fltr ON pick.TranKey = fltr.TranKey 
				LEFT JOIN dbo.tblInItemUom unit ON (unit.ItemId = pick.ItemId) AND (unit.Uom = pick.UOM) 
			GROUP BY pick.TranKey
		) pqty
			ON (pqty.TranKey = xfer.TranKey) 
		LEFT JOIN 
		(
			SELECT pick.TranKey, SUM(ROUND((rcpt.Qty * ISNULL(unit.ConvFactor, 1)), @QuantityPrecision)) AS TtlQty
				, SUM (ROUND((rcpt.Qty * rcpt.UnitCost), @CurrencyPrecision)) AS TtlAmt 
			FROM dbo.tblWmTransferRcpt rcpt 
				INNER JOIN dbo.tblWmTransferPick pick ON (pick.TranPickKey = rcpt.TranPickKey) 
				INNER JOIN #Filter fltr ON pick.TranKey = fltr.TranKey 
				LEFT JOIN dbo.tblInItemUom unit ON (unit.ItemId = rcpt.ItemId) AND (unit.Uom = rcpt.UOM) 
			GROUP BY pick.TranKey
		) rqty
			ON (rqty.TranKey = xfer.TranKey) 
		WHERE ISNULL(pqty.TtlQty, 0) - ISNULL(rqty.TtlQty, 0) > 0
			
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_WMInTransitValuationReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_WMInTransitValuationReport_proc';

