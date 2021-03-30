
CREATE PROCEDURE [dbo].[trav_InCopyItems_proc]
AS
BEGIN TRY

--MOD: Refactored for processing multiple CopyTo locations
--MOD: Updated the log to include CopyTo Location Id and GL Account Code
--PET: http://webfront:801/view.php?id=242024

	DECLARE @chkLocInfo Bit, @chkPriceInfo Bit, @chkCostInfo Bit, @chkVendInfo Bit, @chkBinInfo Bit
    DECLARE @LocFrom pLocID
	
	--Retrieve global values
	SELECT @chkLocInfo = CAST([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'LocInfo'
	SELECT @chkPriceInfo = CAST([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'PriceInfo'
	SELECT @chkCostInfo = CAST([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'CostInfo'
	SELECT @chkVendInfo = CAST([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'VendorInfo'	
	SELECT @chkBinInfo = CAST([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'BinInfo'
	SELECT @LocFrom = [Value] FROM #GlobalValues WHERE [Key] = 'LocFrom'
	
	--build a list of items/locations to be created
	CREATE TABLE #ItemLocationList 
	(
		[ItemId] [pItemId], 
		[LocIdFrom] [pLocId] NULL, --allow null when no source is identified
		[LocIdTo] [pLocId], 
		[GLAcctCode] [pGLAcctCode]
		PRIMARY KEY ([ItemId], [LocIdTo])
	)
	
	IF ISNULL(@LocFrom, '') = ''
	BEGIN
		--populate the item/location list with all items that do not have the identified locations
		INSERT INTO #ItemLocationList ([ItemId], [LocIdFrom], [LocIdTo], [GLAcctCode])
		SELECT temp.ItemId, @LocFrom, temp.LocIdTo, temp.GLAcctCode
		FROM (
			SELECT t.ItemId, c.LocIDTo, c.GLAcctCode 
			FROM #ItemList t, #CopyItemsLocationList c --cross join items and destination locations
		) temp 
		LEFT JOIN dbo.tblInItemLoc loc ON temp.ItemId = loc.ItemId AND temp.LocIdTo = loc.LocId
		WHERE loc.LocId IS NULL --filter to exclude existing location

		--Create a new item location record for any selected items that 
		--	do not already have the identified locations
		--	using the Item default uom as the default order quantity uom
		INSERT INTO dbo.tblInItemLoc (ItemId, LocId, GLAcctCode, OrderQtyUom)
		SELECT l.ItemId, l.LocIdTo, l.GLAcctCode, i.UomDflt
		FROM #ItemLocationList l
		INNER JOIN dbo.tblInItem i ON l.ItemId = i.ItemId 
	END
	ELSE
	BEGIN
		IF @chkLocInfo IS NULL
		BEGIN
			RAISERROR(90025,16,1)
		END

		--populate the item/location list with all items that do not have the identified locations
		INSERT INTO #ItemLocationList ([ItemId], [LocIdFrom], [LocIdTo], [GLAcctCode])
		SELECT temp.ItemId, temp.LocIdFrom, temp.LocIdTo, temp.GLAcctCode
		FROM (
			SELECT t.ItemId, @LocFrom AS LocIdFrom, c.LocIDTo, c.GLAcctCode 
			FROM #ItemList t, #CopyItemsLocationList c --cross join items and destination locations
		) temp 
		INNER JOIN dbo.tblInItemLoc locFrom ON temp.ItemId = locFrom.ItemId AND temp.LocIdFrom = locFrom.LocId --source must exist
		LEFT JOIN dbo.tblInItemLoc loc ON temp.ItemId = loc.ItemId AND temp.LocIdTo = loc.LocId --destination cannot exist
		WHERE @LocFrom <> temp.LocIdTo
			AND loc.LocId IS NULL --filter to exclude existing location

		--Copy Location Information
		IF @chkLocInfo = 1
		BEGIN							

				INSERT INTO dbo.tblInItemLoc (ItemId, LocId, GLAcctCode, CostLandedLast, CarrCostPct,
					OrderCostAmt,QtySafetyStock, QtyOrderPoint, QtyOnHandMax, QtyOrderMin, Eoq, EoqType, ForecastId,
					SafetyStockType, OrderPointType, DfltLeadTime, DfltBinNum, DfltVendId, DfltPriceId, PriceAdjtype,
					PriceAdjBase, PriceAdjAmt,OrderQtyUom, ABCClass)
				SELECT l.ItemId, l.LocIdTo, l.GLAcctCode, loc.CostLandedLast, loc.CarrCostPct,
					OrderCostAmt,QtySafetyStock, loc.QtyOrderPoint, loc.QtyOnHandMax, loc.QtyOrderMin, loc.Eoq, loc.EoqType, loc.ForecastId,
					SafetyStockType, loc.OrderPointType, loc.DfltLeadTime, loc.DfltBinNum, loc.DfltVendId, loc.DfltPriceId, loc.PriceAdjtype,
					PriceAdjBase, loc.PriceAdjAmt,OrderQtyUom, loc.ABCClass
				FROM #ItemLocationList l
				INNER JOIN dbo.tblInItemLoc loc on l.ItemId = loc.ItemId AND l.LocIdFrom = loc.LocId
		END

		--Copy Price Information
		IF @chkPriceInfo = 1
		BEGIN				
				INSERT into dbo.tblInItemLocUomPrice (ItemId, LocId, Uom, BrkId, PriceAvg, PriceMin, PriceList, PriceBase)
				SELECT l.ItemId, l.LocIdTo, p.Uom, p.BrkId, p.PriceAvg, p.PriceMin, p.PriceList, p.PriceBase
				FROM #ItemLocationList l
				INNER JOIN dbo.tblInItemLocUomPrice p on l.ItemId = p.ItemId AND l.LocIdFrom = p.LocId
		END

		--Copy Cost Information
		IF @chkCostInfo = 1
		BEGIN
			UPDATE dbo.tblInItemLoc SET CostStd = c.CostStd, CostAvg = c.CostAvg, CostBase = c.CostBase, CostLast = c.CostLast
			FROM (SELECT l.ItemId, l.LocIdTo, loc.CostStd, loc.CostAvg, loc.CostBase, loc.CostLast
				FROM #ItemLocationList l
				INNER JOIN dbo.tblInItemLoc loc ON l.ItemId = loc.ItemId AND l.LocIdFrom = loc.LocId
			) c
			WHERE dbo.tblInItemLoc.ItemId = c.ItemId AND dbo.tblInItemLoc.LocId = c.LocIdTo
		END

		--Copy Vendor Information
		IF @chkVendInfo = 1   
		BEGIN				
			INSERT INTO dbo.tblInItemLocVend (ItemId, LocId, VendId, VendName, LeadTime)
			SELECT l.ItemId, l.LocIDTo, vend.VendId, vend.VendName, vend.LeadTime
			FROM #ItemLocationList l
			INNER JOIN dbo.tblInItemLocVend vend ON l.ItemId = vend.ItemId AND l.LocIdFrom = vend.LocId
		END

		--Copy Bin Information
		IF @chkBinInfo = 1  
		BEGIN				
			INSERT INTO dbo.tblInItemLocBin (ItemId, LocId, BinNum)
			SELECT l.ItemId, l.LocIDTo, bin.BinNum
			FROM #ItemLocationList l 
			INNER JOIN dbo.tblInItemLocBin bin ON l.ItemId = bin.ItemId AND l.LocIdFrom = bin.LocId
		END						
	END

	--clear and rebuild the log of items processed
	DELETE FROM #CopyItemsToLocationLog
	
	INSERT INTO #CopyItemsToLocationLog (ItemId, Descr, ProductLine, LocationId, AccountCode)
	SELECT DISTINCT t.ItemId, i.Descr, i.ProductLine, t.LocIdTo, t.GLAcctCode
	FROM #ItemLocationList t 
	INNER JOIN dbo.tblInItem i ON t.ItemId = i.ItemId 

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InCopyItems_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InCopyItems_proc';

