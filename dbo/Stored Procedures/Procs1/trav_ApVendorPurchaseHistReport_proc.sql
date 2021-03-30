
CREATE PROCEDURE dbo.[trav_ApVendorPurchaseHistReport_proc]
@FiscalYear smallint,
@FiscalPeriod smallint

AS
BEGIN TRY
	DECLARE @TotPurch decimal(28,10), @TotCogs decimal(28,10)

	SELECT @TotPurch = SUM(SIGN(h.TransType) * d.ExtCost), @TotCogs = SUM(SIGN(h.TransType) * CASE WHEN d.EntryNum > 0 THEN d.ExtCost ELSE 0 END)
	FROM #tmpVendorList t INNER JOIN dbo.tblApHistHeader h ON t.VendorId = h.VendorId
		INNER JOIN dbo.tblApHistDetail d ON h.PostRun = d.PostRun AND h.TransId = d.TransId AND h.InvoiceNum = d.InvoiceNum 
	WHERE h.FiscalYear = @FiscalYear AND h.GlPeriod = @FiscalPeriod

	SELECT h.VendorId, CASE WHEN h.VendorID = '++++++++++' THEN 'Temp Vendors' ELSE MIN(v.Name) END AS [Name], 
		v.VendorClass, d.PartId, CASE WHEN d.EntryNum < 0 THEN -1 ELSE 1 END EntryNum, MIN(d.UnitsBase) AS BaseUnit, 
		SUM(SIGN(h.TransType) * d.ExtCost) AS Purchase, SUM(SIGN(h.TransType) * CASE WHEN d.EntryNum > 0 THEN d.ExtCost ELSE 0 END) AS CostOfGoods,
		@TotPurch AS CompTotalPurchases, @TotCogs AS CompTotalCogs,SUM(SIGN(h.TransType) * CASE WHEN d.EntryNum > 0 THEN d.QtyBase ELSE 0 END ) AS Qty
	FROM #tmpVendorList t INNER JOIN dbo.tblApHistHeader h ON t.VendorId = h.VendorId
		INNER JOIN dbo.tblApHistDetail d ON h.PostRun = d.PostRun AND h.TransId = d.TransId AND h.InvoiceNum = d.InvoiceNum 
		LEFT JOIN dbo.tblApVendor v ON h.VendorId = v.VendorId
	WHERE h.FiscalYear = @FiscalYear AND h.GlPeriod = @FiscalPeriod
	GROUP BY h.VendorId, v.VendorClass, d.PartId, CASE WHEN d.EntryNum < 0 THEN -1 ELSE 1 END
	
	END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApVendorPurchaseHistReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApVendorPurchaseHistReport_proc';

