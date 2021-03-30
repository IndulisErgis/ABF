
CREATE PROCEDURE dbo.trav_DRGenerateRunData_SOBlanket_proc
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE	@RunId pPostRun, @PrecQty tinyint, @SOKittingYN bit

	--Retrieve global values
	SELECT @RunId = Cast([Value] AS nvarchar) FROM #GlobalValues WHERE [Key] = 'RunId'
	SELECT @PrecQty = Cast([Value] AS tinyint) FROM #GlobalValues WHERE [Key] = 'PrecQty'
	SELECT @SOKittingYN = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'SOKittingYN'

	IF @RunId IS NULL OR @PrecQty IS NULL OR @SOKittingYN IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END


	--Sales Order Scheduled Blanket Orders
	--	(non-kitted item)
	INSERT INTO dbo.tblDrRunData (RunId, ItemId, LocId, TransDate, TransType
		, [Source], VirtualYn, Qty, LinkID, LinkIDSub, LinkIDSubLine, CustId, VendorId, AssemblyId)
	SELECT @RunId, d.ItemId, d.LocId, s.ReleaseDate, 0
		, 16 --16=SalesOrds (scheduled blankets mirror sales orders with VirtualYn = 1)
		, 1, ROUND(s.QtyOrdered * du.ConvFactor, CASE WHEN i.ItemType = 2 THEN 0 ELSE @PrecQty END) --round to whole units for serialized
		, NULL, NULL, NULL, h.SoldToId, Null, Null
		FROM dbo.tblSoSaleBlanket h
		INNER JOIN dbo.tblSoSaleBlanketDetail d ON h.BlanketRef = d.BlanketRef
		INNER JOIN dbo.tblInItem i ON d.ItemId = i.ItemId
		INNER JOIN dbo.tblInItemUom du ON d.ItemId = du.ItemId and d.Units = du.Uom
		INNER JOIN dbo.tblSoSaleBlanketDetailSch s ON d.BlanketDtlRef = s.BlanketDtlRef
		WHERE h.BlanketType = 2 AND h.BlanketStatus = 0 --scheduled and open
			AND i.ItemType <> 3 AND i.KittedYn = 0 --inventoried and non-kitted
			AND s.QtyOrdered <> 0 AND s.[Status] = 0 --valid quantity with new status


	--(kit components item)
	IF @SOKittingYN = 1
	BEGIN
		INSERT INTO dbo.tblDrRunData (RunId, ItemId, LocId, TransDate, TransType
			, [Source], VirtualYn, Qty, LinkID, LinkIDSub, LinkIDSubLine, CustId, VendorId, AssemblyId)
		SELECT @RunId, k.ItemId, k.LocId, s.ReleaseDate, 0
			, 16 --16=SalesOrds (scheduled blankets mirror sales orders with VirtualYn = 1)
			, 1, ROUND((k.Quantity * u.ConvFactor) * (s.QtyOrdered * du.ConvFactor), CASE WHEN ic.ItemType = 2 THEN 0 ELSE @PrecQty END) --round to whole units for serialized
			, NULL, NULL, NULL, h.SoldToId, Null, Null --component base qty per kit * base kit qty = total base component qty 
			FROM dbo.tblSoSaleBlanket h
			INNER JOIN dbo.tblSoSaleBlanketDetail d ON h.BlanketRef = d.BlanketRef
			INNER JOIN dbo.tblInItem i ON d.ItemId = i.ItemId
			INNER JOIN dbo.tblInItemUom du ON d.ItemId = du.ItemId and d.Units = du.Uom
			INNER JOIN dbo.tblSoSaleBlanketDetailSch s ON d.BlanketDtlRef = s.BlanketDtlRef
			INNER JOIN dbo.tblBmBom b ON d.ItemId = b.BmItemId AND d.LocId = b.BmLocId
			INNER JOIN dbo.tblBmBomDetail k ON b.BmBomId = k.BmBomId
			INNER JOIN dbo.tblInItem ic ON k.ItemId = ic.ItemId
			INNER JOIN dbo.tblInItemUOM u ON k.ItemId = u.ItemId AND k.UOM = u.UOM
			WHERE h.BlanketType = 2 AND h.BlanketStatus = 0 --scheduled and open
				AND i.ItemType <> 3 AND i.KittedYn <> 0 --inventoried and kitted item
				AND s.QtyOrdered <> 0 AND s.[Status] = 0 --valid quantity with new status
				AND k.Quantity <> 0
	END
		
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DRGenerateRunData_SOBlanket_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DRGenerateRunData_SOBlanket_proc';

