
CREATE PROCEDURE [dbo].[trav_WmBuildBOL_proc]
@BOLRef Int
AS
BEGIN TRY
	-- Clear the BOL details that builded from SO for specified BOL number
	DELETE dbo.tblWmBOLDetail 
	FROM dbo.tblWmBOLHeader h
		INNER JOIN dbo.tblWmBOLDetail ON h.BolRef = dbo.tblWmBOLDetail.BolRef
	WHERE h.BOLRef = @BOLRef AND dbo.tblWmBOLDetail.[Source] = 1

	DELETE dbo.tblWmBOLDetailCustomerOrder 
	FROM dbo.tblWmBOLHeader h
		INNER JOIN dbo.tblWmBOLDetailCustomerOrder d ON h.BolRef = d.BolRef
	WHERE h.BOLRef = @BOLRef AND d.[Source] = 1

	-- Create BOL Details from SO trans details
	INSERT INTO dbo.tblWMBOLDetail (BOLRef, [Source], TransId, EntryNum, Descr, Qty
		, QtyUOM, ExtWeight, HazMatYn, HandleQty, HandleUOM)
	SELECT @BOLRef, 1, d.TransId, d.EntryNum, d.Descr, d.QtyShipSell, d.UnitsSell, d.QtyShipSell * ISNULL(u.[Weight], 0)
		, CASE WHEN i.HMRef IS NULL THEN 0 ELSE 1 END , d.QtyShipSell, d.UnitsSell
	FROM #WMBuildBOL t
		INNER JOIN dbo.tblSoTransDetail d ON t.TransId = d.TransId AND t.EntryNum = d.EntryNum 
		LEFT JOIN dbo.tblInItem i ON d.ItemId = i.ItemId
		LEFT JOIN dbo.tblInItemUom u ON d.ItemId = u.ItemID AND d.UnitsSell = u.Uom

	-- Create BOL Hazardous Material details
	INSERT INTO dbo.tblWMBOLDetailHM (BOLDtlRef, HMCode, Descr) 
	SELECT b.BOLDtlRef,h.HMCode,h.Descr
	FROM dbo.tblWMBOLDetail b
		INNER JOIN dbo.tblSoTransDetail d ON b.TransId = d.TransId AND b.EntryNum = d.EntryNum 
		INNER JOIN dbo.tblInItem i ON d.ItemId = i.ItemId
		INNER JOIN dbo.tblInHazMat h ON i.HMRef = h.HMRef
	WHERE b.BOLRef = @BOLRef AND b.HazMatYn = 1

	-- Create Customer Order Information
	INSERT INTO dbo.tblWmBOLDetailCustomerOrder (BOLRef, CustomerPoNo, PackQty, ExtWeight, [Source])
	SELECT @BOLRef, CustPONum, SUM(d.QtyShipSell), SUM(d.QtyShipSell * ISNULL(u.[Weight], 0)), 1
	FROM #WMBuildBOL t
		INNER JOIN dbo.tblSoTransDetail d ON t.TransId = d.TransId AND t.EntryNum = d.EntryNum 
		INNER JOIN dbo.tblSoTransHeader h ON t.TransId = h.Transid
		LEFT JOIN dbo.tblInItem i ON d.ItemId = i.ItemId
		LEFT JOIN dbo.tblInItemUom u ON d.ItemId = u.ItemID AND d.UnitsSell = u.Uom
	GROUP BY h.CustPONum
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_WmBuildBOL_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_WmBuildBOL_proc';

