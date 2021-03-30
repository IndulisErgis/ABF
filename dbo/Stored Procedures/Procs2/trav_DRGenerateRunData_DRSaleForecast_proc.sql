
CREATE PROCEDURE dbo.trav_DRGenerateRunData_DRSaleForecast_proc
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


	DECLARE @RunDate DateTime
	SELECT @RunDate = RunDate FROM dbo.tblDrRunInfo WHERE RunId = @RunId
	

	--capture any non-kitted sales forecasts as of the rundate
	INSERT INTO dbo.tblDrRunData (RunId, ItemId, LocId, TransDate, TransType
		, [Source], VirtualYn, Qty, LinkID, LinkIDSub, LinkIDSubLine, CustId, VendorId, AssemblyId)
	SELECT @RunId, h.ItemId, h.LocId, FrcstDate, 0, 32 --32=FrcstSales
		, 1, ROUND(d.Qty * CASE WHEN ISNULL(u.ConvFactor, 0) = 0 THEN 1 ELSE u.ConvFactor END, @PrecQty)
		, 'DR', Null, Null, Null, Null, Null
	FROM dbo.tblDrFrcst h 
	INNER JOIN dbo.tblDrFrcstDtl d ON h.Id = d.FrcstId
	INNER JOIN dbo.tblInItem i ON h.ItemId = i.ItemId
	LEFT JOIN dbo.tblInItemUOM u ON h.ItemId = u.ItemId AND h.UOM = u.UOM
	WHERE Qty <> 0 AND i.KittedYn = 0 AND FrcstDate >= @RunDate

	
	--capture sales forecasts as of the run date for the components of kitted sales forecasts
	IF @SOKittingYN = 1
	BEGIN
		INSERT INTO dbo.tblDrRunData (RunId, ItemId, LocId, TransDate, TransType
			, [Source], VirtualYn, LinkID, LinkIDSub, LinkIDSubLine, CustId, VendorId, AssemblyId, Qty)
		SELECT @RunId, d.ItemId, d.LocId, fd.FrcstDate, 0, 32 --32=FrcstSales
			, 1, 'DR', Null, Null, Null, Null, Null
			, ROUND((((fd.Qty * CASE WHEN ISNULL(u3.ConvFactor, 0) = 0 THEN 1 ELSE u3.ConvFactor END) --use the base quantity of the forecast detail
		 		/ (CASE WHEN ISNULL(u1.ConvFactor, 0) = 0 THEN 1 ELSE u1.ConvFactor END))  --convert forecast base qty into kit definition units
				* (d.Quantity * CASE WHEN ISNULL(u2.ConvFactor, 0) = 0 THEN 1 ELSE u2.ConvFactor END)), @PrecQty) --expand the component qty in base units
		FROM dbo.tblBmBom h 
		INNER JOIN dbo.tblBmBomDetail d ON h.BmBomId = d.BmBomId
		INNER JOIN dbo.tblInItem i ON h.BmItemId = i.ItemId
		INNER JOIN dbo.tblDrFrcst f ON h.BmItemId = f.ItemId AND h.BmLocId = f.LocId
		INNER JOIN dbo.tblDrFrcstDtl fd ON f.Id = fd.FrcstId
		LEFT JOIN dbo.tblInItemUom u1 ON h.BmItemId = u1.ItemId AND h.Uom = u1.Uom
		LEFT JOIN dbo.tblInItemUom u2 ON d.ItemId = u2.ItemId AND d.Uom = u2.Uom
		LEFT JOIN dbo.tblInItemUom u3 ON f.ItemId = u3.ItemId AND f.Uom = u3.Uom
		WHERE i.KittedYn <> 0 AND d.Quantity <> 0 AND fd.FrcstDate >= @RunDate
	END
		
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DRGenerateRunData_DRSaleForecast_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DRGenerateRunData_DRSaleForecast_proc';

