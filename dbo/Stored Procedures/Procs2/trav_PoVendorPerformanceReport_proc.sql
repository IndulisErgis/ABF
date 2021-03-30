
CREATE PROCEDURE dbo.trav_PoVendorPerformanceReport_proc
@QuantityVariance pDecimal = 0,
@CostVariance pDecimal = 0,
@DeliveryDays pDecimal = 0,
@UnitCostPrecision tinyint = 4
AS
SET NOCOUNT ON
BEGIN TRY

	SELECT h.VendorId,v.[Name],h.TransId,d.ItemId,d.Descr,d.LocId,d.QtyOrd,ISNULL(r.QtyRcpt,0) AS QtyRcpt,d.UnitCost,ISNULL(i.InvcUnitCost,0) AS InvcUnitCost,
      ISNULL(d.ReqShipDate, h.ReqShipDate) AS ReqShipDate, r.ReceiptDate,d.ExtCost,ISNULL(i.InvcExtCost,0) AS InvcExtCost,
      CAST(ROUND((CASE WHEN d.QtyOrd = 0 THEN ISNULL(r.QtyRcpt,0) ELSE (ISNULL(r.QtyRcpt,0)-d.QtyOrd)/d.QtyOrd END) * 100,2) AS Decimal(28,10)) AS QtyVar,
      CAST(ROUND((CASE WHEN d.UnitCost = 0 THEN ISNULL(i.InvcUnitCost,0) ELSE (ISNULL(i.InvcUnitCost,0)-d.UnitCost)/d.UnitCost END) * 100,2) AS Decimal(28,10)) AS CostVar,
      r.DeliDays
	FROM #tmpHistoryList t INNER JOIN dbo.tblPoHistDetail d ON t.PostRun = d.PostRun AND t.TransId = d.TransId AND t.EntryNum = d.EntryNum
		INNER JOIN dbo.tblPoHistHeader h ON d.PostRun = h.PostRun AND d.TransId = h.TransId
		LEFT JOIN 
			(SELECT t.PostRun,t.TransID,t.EntryNum,MIN(r.ReceiptDate) ReceiptDate, SUM(QtyFilled) QtyRcpt,
				AVG(DATEDIFF(dd,ISNULL(e.ReqShipDate, h.ReqShipDate),r.ReceiptDate)) AS DeliDays 
			FROM dbo.tblPoHistReceipt r INNER JOIN dbo.tblPoHistLotRcpt t ON r.PostRun = t.PostRun AND r.TransId = t.TransId AND r.ReceiptNum = t.RcptNum
				INNER JOIN dbo.tblPoHistDetail e ON t.PostRun = e.PostRun AND t.TransId = e.TransId AND t.EntryNum = e.EntryNum 
				INNER JOIN dbo.tblPoHistHeader h ON e.PostRun = h.PostRun AND e.TransId = h.TransId
			GROUP BY t.PostRun,t.TransID,t.EntryNum) r ON d.PostRun = r.PostRun AND d.TransId = r.TransId AND d.EntryNum = r.EntryNum 
		LEFT JOIN 
			(SELECT PostRun,TransID,EntryNum, ROUND(SUM(ExtCost)/SUM(Qty),@UnitCostPrecision) AS InvcUnitCost, SUM(ExtCost) AS InvcExtCost 
			FROM tblPoHistInvoice 
			GROUP BY PostRun,TransID,EntryNum) i ON d.PostRun = i.PostRun AND d.TransId = i.TransId AND d.EntryNum = i.EntryNum  
		LEFT JOIN dbo.tblApVendor v ON h.VendorId = v.VendorId 
	WHERE h.TransType<> 0 AND ABS(ROUND((CASE WHEN d.QtyOrd = 0 THEN ISNULL(r.QtyRcpt,0) ELSE (ISNULL(r.QtyRcpt,0)-d.QtyOrd)/d.QtyOrd END) * 100,2)) >= @QuantityVariance  
		AND ABS(ROUND((CASE WHEN d.UnitCost = 0 THEN ISNULL(i.InvcUnitCost,0) ELSE (ISNULL(i.InvcUnitCost,0)-d.UnitCost)/d.UnitCost END) * 100,2)) >= @CostVariance 
		AND ABS(DATEDIFF(dd,ISNULL(d.ReqShipDate, h.ReqShipDate),ISNULL(r.ReceiptDate,ISNULL(d.ReqShipDate, h.ReqShipDate)))) >= @DeliveryDays
	ORDER BY h.VendorId,h.TransId,d.ItemId

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PoVendorPerformanceReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PoVendorPerformanceReport_proc';

