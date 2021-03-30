
CREATE PROCEDURE [dbo].[trav_WmInqItemQty_proc] 
@Filter nvarchar(max) = null --sql filter string to apply to the results
AS
BEGIN TRY

	SET NOCOUNT ON

	Declare @nsql nvarchar(max)

	--temporary table for processing results
	CREATE TABLE #ItemList
	(
		[ItemId] [pItemId],
		[LocId] [pLocId], 
		Primary Key ([ItemId], [LocId])
	)

	CREATE NONCLUSTERED INDEX IX_ItemList_ItemIdLocId on #ItemList([ItemId], [LocId])

	CREATE TABLE #QuantityTrans
	(
		[Id] [Int] Not Null Identity(1, 1),
		[ItemId] [pItemId],
		[LocId] [pLocId], 
		[LotNum] [pLotNum] Null, 
		[SerNum] [pSerNum] Null, 
		[ExtLocA] [Int] Null,
		[ExtLocB] [Int] Null,
		[QtyOnHand] [pDecimal],
		[QtyCmtd] [pDecimal],
		[QtyPicked] [pDecimal],
		Primary Key ([Id])
	)

	CREATE NONCLUSTERED INDEX IX_QuantityTrans_ItemIdLocId on #QuantityTrans([ItemId], [LocId])

	CREATE TABLE #QuantityDetail
	(
		[Id] [Int] Not Null Identity(1, 1),
		[ItemId] [pItemId],
		[LocId] [pLocId], 
		[LotNum] [pLotNum] Null, 
		[SerNum] [pSerNum] Null, 
		[ExtLocA] [Int] Null,
		[ExtLocAId] [nvarchar](10), 
		[ExtLocB] [Int] Null,
		[ExtLocBId] [nvarchar](10), 
		[QtyOnHand] [pDecimal],
		[QtyCmtd] [pDecimal],
		[QtyPicked] [pDecimal],
		[UOM] [pUOM] NULL, 
		[InitialDate] [datetime], 
		[ExpDate] [datetime], 
		[Cmnt] [nvarchar](35),
		Primary Key ([Id])
	)

	CREATE NONCLUSTERED INDEX IX_QuantityDetail_ItemIdLocId on #QuantityDetail([ItemId], [LocId])

	--use dynamic sql to apply filter criteria to build a pre-filtered list of item/locations
	--	**cannot support filtering for LotNum, Bin or Container as values are derived from detail data.
	Select @nsql = 'INSERT INTO #ItemList([ItemId], [LocId]) 
		SELECT t.[ItemId], t.[LocId] 
		FROM (
			SELECT i.[ItemId], i.[Descr] AS ItemDescr, i.[ItemType], i.[ItemStatus], i.[LottedYN], i.[Descr], i.[KittedYN]
				, i.[ProductLine], i.[SalesCat], i.[PriceId], i.[TaxClass]
				, l.[LocId], l.[ABCClass], l.[ItemLocStatus]
			FROM dbo.tblInItem i 
			INNER JOIN dbo.tblInItemLoc l ON i.[ItemId] = l.[ItemId]
		) t'
	
	--conditionally apply filter criteria to the dataset
	Select @Filter = NULLIF(LTRIM(RTRIM(@Filter)), '')
	If @Filter is not null
	Begin
		Select @nsql = @nsql + ' Where (' + @Filter + ')'
	End

	--build the list of items
	--	use a try/catch to capture all the items in case the filter includes LotNum, Bin or Container
	BEGIN TRY
		exec sp_executesql @nsql
	END TRY
	BEGIN CATCH
		--include all items
		INSERT INTO #ItemList([ItemId], [LocId])
			SELECT l.[ItemId], l.[LocId] FROM dbo.tblInItemLoc l
	END CATCH


	--capture the transactional quantity info (On Hand - total)
	Insert into #QuantityTrans (ItemId, LocId, LotNum, SerNum, ExtLocA, ExtLocB
		, QtyOnHand, QtyCmtd, QtyPicked)
	SELECT d.ItemId, d.LocId, d.LotNum, Null, Null, Null 
		, (d.Qty - d.InvoicedQty - d.RemoveQty), 0, 0
	FROM #ItemList l
	INNER JOIN dbo.tblInQtyOnHand d ON l.[ItemId] = d.[ItemId] AND l.[LocId] = d.[LocId]

	--capture the transactional quantity info (On Hand - reduce the Null ExtLoc Qtys by the total from tblInQtyOnHand_Ext)
	Insert into #QuantityTrans (ItemId, LocId, LotNum, SerNum, ExtLocA, ExtLocB
		, QtyOnHand, QtyCmtd, QtyPicked)
	SELECT d.ItemId, d.LocId, d.LotNum, Null, Null, Null 
		, -d.Qty, 0, 0
	FROM #ItemList l
	INNER JOIN dbo.tblInQtyOnHand_Ext d ON l.[ItemId] = d.[ItemId] AND l.[LocId] = d.[LocId]

	--capture the transactional quantity info (On Hand - Add in the detail for ExtLoc from tblInQtyOnHand_Ext)
	Insert into #QuantityTrans (ItemId, LocId, LotNum, SerNum, ExtLocA, ExtLocB
		, QtyOnHand, QtyCmtd, QtyPicked)
	SELECT d.ItemId, d.LocId, d.LotNum, Null, d.ExtLocA, d.ExtLocB
		, d.Qty, 0, 0
	FROM #ItemList l
	INNER JOIN dbo.tblInQtyOnHand_Ext d ON l.[ItemId] = d.[ItemId] AND l.[LocId] = d.[LocId]


	--capture the transactional quantity info (committed - total)
	Insert into #QuantityTrans (ItemId, LocId, LotNum, SerNum, ExtLocA, ExtLocB
		, QtyOnHand, QtyCmtd, QtyPicked)
	SELECT d.ItemId, d.LocId, d.LotNum, Null, Null, Null
		, 0, d.Qty, 0
	FROM #ItemList l
	INNER JOIN dbo.tblInQty d ON l.[ItemId] = d.[ItemId] AND l.[LocId] = d.[LocId]
	WHERE d.TransType = 0--cmtd

	--capture the transactional quantity info (committed - reduce the Null extLoc qtys by the total from tblInQty_Ext)
	Insert into #QuantityTrans (ItemId, LocId, LotNum, SerNum, ExtLocA, ExtLocB
		, QtyOnHand, QtyCmtd, QtyPicked)
	SELECT d.ItemId, d.LocId, Null, Null, Null, Null 
		, 0, -d.Qty, 0
	FROM #ItemList l
	INNER JOIN dbo.tblInQty_Ext d ON l.[ItemId] = d.[ItemId] AND l.[LocId] = d.[LocId]
	WHERE d.TransType = 0 --cmtd

	--capture the transactional quantity info (committed - Add in the detail for extloc from tblInQty_Ext)
	Insert into #QuantityTrans (ItemId, LocId, LotNum, SerNum, ExtLocA, ExtLocB
		, QtyOnHand, QtyCmtd, QtyPicked)
	SELECT d.ItemId, d.LocId, d.LotNum, Null, d.ExtLocA, d.ExtLocB
		, 0, d.Qty, 0
	FROM #ItemList l
	INNER JOIN dbo.tblInQty_Ext d ON l.[ItemId] = d.[ItemId] AND l.[LocId] = d.[LocId]
	WHERE d.TransType = 0 --cmtd



	--capture the transactional quantity info (serialized)
	Insert into #QuantityTrans (ItemId, LocId, LotNum, SerNum, ExtLocA, ExtLocB
		, QtyOnHand, QtyCmtd, QtyPicked)
	SELECT q.ItemId, q.LocId, q.LotNum, q.SerNum, q.ExtLocA, q.ExtLocB
		, CASE SerNumStatus WHEN 5 THEN 0 ELSE 1 END QtyOnHand
		, 0.0 QtyCmtd, 0.0 QtyPicked
	FROM #ItemList l
	INNER JOIN dbo.tblInItemSer q ON l.[ItemId] = q.[ItemId] AND l.[LocId] = q.[LocId]
	WHERE ((q.SerNumStatus = 1) OR (q.SerNumStatus = 2) OR (q.SerNumStatus = 5))


	--capture the transactional quantity info (Picked - Reqular item)
	Insert into #QuantityTrans (ItemId, LocId, LotNum, SerNum, ExtLocA, ExtLocB
		, QtyOnHand, QtyCmtd, QtyPicked)
	SELECT d.ItemId, d.LocId, e.LotNum, Null, e.ExtLocA, e.ExtLocB
		, 0 QtyOnHand, 0 QtyCmtd, (e.QtyFilled * u.ConvFactor) QtyPicked
	FROM dbo.tblSoTransHeader h 
	INNER JOIN dbo.tblSoTransDetail d ON h.TransId = d.TransID
	INNER JOIN dbo.tblSoTransDetailExt e ON d.TransId = e.TransId AND d.EntryNum = e.EntryNum 
	INNER JOIN dbo.tblInItemUom u ON d.ItemId = u.ItemId AND d.UnitsSell = u.Uom
	INNER JOIN #ItemList l ON d.[ItemId] = l.[ItemId] AND d.[LocId] = l.[LocId]
	WHERE h.TransType = 5 AND h.VoidYn = 0 AND e.QtyFilled <> 0

	--capture the transactional quantity info (Picked - serialized item)
	Insert into #QuantityTrans (ItemId, LocId, LotNum, SerNum, ExtLocA, ExtLocB
		, QtyOnHand, QtyCmtd, QtyPicked)
	SELECT d.ItemId, d.LocId, e.LotNum, e.SerNum, e.ExtLocA, e.ExtLocB
		, 0.0 QtyOnHand, 0.0 QtyCmtd, 1.0 QtyPicked
	FROM dbo.tblSoTransHeader h 
	INNER JOIN dbo.tblSoTransDetail d ON h.TransId = d.TransID
	INNER JOIN dbo.tblSoTransSer e ON d.TransId = e.TransId AND d.EntryNum = e.EntryNum 
	INNER JOIN #ItemList l ON d.[ItemId] = l.[ItemId] AND d.[LocId] = l.[LocId]
	WHERE h.TransType = 5 AND h.VoidYn = 0



	--summarize the base UOM quantity detail
	INSERT INTO #QuantityDetail (ItemId, LocId, LotNum, SerNum, ExtLocA, ExtLocAId, ExtLocB, ExtLocBId
		, UOM, InitialDate, ExpDate, Cmnt, QtyOnHand, QtyCmtd, QtyPicked)
	SELECT l.ItemId, l.LocId, qt.LotNum, qt.SerNum, qt.ExtLocA, a.ExtLocId, qt.ExtLocB, b.ExtLocId
		, i.UomBase, t.InitialDate, t.ExpDate, t.Cmnt
		, isnull(SUM(qt.QtyOnHand), 0), isnull(SUM(qt.QtyCmtd), 0), isnull(SUM(qt.QtyPicked), 0)
	FROM #ItemList s
	INNER JOIN dbo.tblInItemLoc l ON s.[ItemId] = l.[ItemId] AND s.[LocId] = l.[LocId]
	INNER JOIN dbo.tblInItem i ON l.ItemId = i.ItemId
	LEFT JOIN #QuantityTrans qt ON l.itemid = qt.itemid and l.locid = qt.LocId
	LEFT JOIN dbo.tblWmExtLoc a	ON qt.ExtLocA = a.Id
	LEFT JOIN dbo.tblWmExtLoc b	ON qt.ExtLocB = b.Id
	LEFT JOIN dbo.tblInItemLocLot t ON qt.ItemId = t.ItemId AND qt.LocId = t.LocId AND qt.LotNum = t.LotNum
	GROUP BY l.ItemId, l.LocId, qt.LotNum, qt.SerNum, qt.ExtLocA, a.ExtLocId, qt.ExtLocB, b.ExtLocId
		, i.UomBase, t.InitialDate, t.ExpDate, t.Cmnt


	--update the Uom to the default instead of base
	--	and convert the base quantity values to the Default UOM
	UPDATE #QuantityDetail Set QtyOnHand = #QuantityDetail.QtyOnHand / isnull(u.ConvFactor, 1.0)
		, QtyCmtd = #QuantityDetail.QtyCmtd / isnull(u.ConvFactor, 1.0)
		, QtyPicked = #QuantityDetail.QtyPicked / isnull(u.ConvFactor, 1.0)
		, Uom = u.Uom	
		FROM #QuantityDetail
		INNER JOIN dbo.tblInItem i 
			ON #QuantityDetail.ItemId = i.ItemId
		LEFT JOIN dbo.tblInItemUomDflt ud ON ud.ItemId = i.itemId AND ud.DfltType = 1
		LEFT JOIN dbo.tblInitemUom u 
			ON i.ItemId = u.ItemId AND ISNULL(ud.Uom, i.UomDflt) = u.UOM		
	WHERE u.Uom <> i.UomBase

	--construct the sql command to return the dataset
	Select @nsql = 'Select i.[ItemId], i.Descr AS ItemDescr, i.[ItemType], i.[ItemStatus], i.[LottedYN], i.[Descr], i.[KittedYN]
		, i.[ProductLine], i.[SalesCat], i.[PriceId], i.[TaxClass]
		, l.[ABCClass], l.[ItemLocStatus]
		, q.[LocId], q.[LotNum], q.[SerNum], q.[ExtLocAId], q.[ExtLocBId]
		, q.[QtyOnHand], q.[QtyCmtd], q.[UOM]
		, q.[InitialDate], q.[ExpDate], q.[Cmnt], q.[QtyPicked] 
	From #QuantityDetail q 
	Inner Join dbo.tblInItem i On q.[ItemId] = i.[ItemId]	
	Inner Join dbo.tblInItemLoc l On q.[ItemId] = l.[ItemId] And q.[LocId] = l.[Locid]'
	
	--conditionally apply filter criteria to the dataset
	Select @Filter = NULLIF(LTRIM(RTRIM(@Filter)), '')
	If @Filter is not null
	Begin
		Select @nsql = 'Select * From (' + @nsql + ') t Where (' + @Filter + ')'
	End

	--return the results
	exec sp_executesql @nsql
		
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_WmInqItemQty_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_WmInqItemQty_proc';

