
CREATE PROCEDURE dbo.trav_PoScheduledDeliveryReport_proc 
@PrintAllInBase bit = 1,
@ReportCurrency pCurrency = 'USD',
@CurrencyPrecision tinyint = 2
AS
SET NOCOUNT ON
BEGIN TRY

	SELECT v.[Name], h.TransId, h.BatchId, h.TransType, h.VendorId, h.ReqShipDate AS ReqShipDateHdr, 
		d.EntryNum, CASE WHEN @PrintAllInBase = 1 THEN d.UnitCost ELSE d.UnitCostFgn END UnitCost, 
		CASE WHEN @PrintAllInBase = 1 THEN d.ExtCost ELSE d.ExtCostFgn END ExtCost, 
		d.ItemId, d.LocId AS LocIdDtl, d.Descr, d.UnitsBase, d.Units, d.AddnlDescr, 
		ISNULL(d.ReqShipDate,h.ReqShipDate) AS ReqShipDateDtl, 
		CASE WHEN s.SumOfQty IS NOT NULL THEN (d.QtyOrd-s.SumOfQty) ELSE d.QtyOrd END ExpectedQty, 
		ROUND(((CASE WHEN s.SumOfQty IS NOT NULL THEN (d.QtyOrd-s.SumOfQty) ELSE d.QtyOrd END) * 
			(CASE WHEN @PrintAllInBase = 1 THEN d.UnitCost ELSE d.UnitCostFgn  END)), @CurrencyPrecision) ExtCostGrp, 
		(ItemId + Descr + d.LocId + Units + CONVERT(nvarchar, UnitCost)) Detail1, ISNULL(d.ExpReceiptDate,h.ExpReceiptDate) AS ExpReceiptDate									
	FROM dbo.tblPoTransHeader h	INNER JOIN dbo.tblApVendor v ON h.VendorId = v.VendorId 
		INNER JOIN dbo.tblPoTransDetail d ON h.TransId = d.TransId 
		INNER JOIN #tmpTransDetailList l ON d.TransId = l.TransId AND d.EntryNum = l.EntryNum
		LEFT JOIN (SELECT TransID, EntryNum, SUM(QtyFilled) AS SumOfQty 
			FROM dbo.tblPoTransLotRcpt 
			GROUP BY TransID, EntryNum) s ON d.TransId = s.TransId AND d.EntryNum = s.EntryNum  
	WHERE (@PrintAllInBase = 1 OR h.CurrencyId = @ReportCurrency) AND h.TransType > 0 
		AND (CASE WHEN [SumOfQty] IS NOT NULL THEN (d.QtyOrd-[SumOfQty]) ELSE d.QtyOrd END) > 0  

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PoScheduledDeliveryReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PoScheduledDeliveryReport_proc';

