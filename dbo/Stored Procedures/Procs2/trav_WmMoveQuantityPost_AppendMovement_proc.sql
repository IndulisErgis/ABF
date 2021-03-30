
CREATE PROCEDURE dbo.trav_WmMoveQuantityPost_AppendMovement_proc
@TransId int
AS
BEGIN TRY
	DECLARE @PrecQty tinyint
		
	
	--Retrieve global values
	SELECT @PrecQty = Cast([Value] AS tinyint) FROM #GlobalValues WHERE [Key] = 'PrecQty'

	IF @PrecQty IS NULL OR @TransId IS NULL 
	BEGIN
		RAISERROR(90025,16,1)
	END

	--Tracks the processed transactions in #TransList
	--CREATE TABLE #TransList
	--(
	--	[TransId] [int], 
	--	PRIMARY KEY ([TransId])
	--)

	--Appends entries into the following work table 
	--CREATE TABLE #MoveQuantity
	--(
	--	[Id] [int] NOT NULL IDENTITY(1, 1),
	--	[TransId] [int], 
	--	[ItemType] [tinyint], 
	--	[ItemId] [pItemId], 
	--	[LocId] [pLocId], 
	--	[LotNum] [pLotNum] Null, 
	--	[SerNum] [pSerNum] Null,
	--	[ExtLocAFrom] [int] Null, 
	--	[ExtLocATo] [int] Null, 
	--	[ExtLocBFrom] [int] Null, 
	--	[ExtLocBTo] [int] Null, 
	--	[Qty] [pDecimal],
	--	[TransDate] [datetime] not null,
	--	[UserId] [pUserId] not null,
	--	[HostId] [pWrkStnId] not null,
	--	PRIMARY KEY ([TransId], [Id])
	--)

	DECLARE @MoveBy tinyint
	DECLARE @MoveById pItemId
	DECLARE @LocId pLocId
	DECLARE @ExtLocAFrom int
	DECLARE @ExtLocATo int
	DECLARE @UserId pUserId
	DECLARE @HostId pWrkStnId
	DECLARE @TransDate datetime
	

	--lookup transaciton values 
	SELECT @MoveBy = m.[MoveBy]
		, @MoveById = m.[MoveById]
		, @LocId = m.[LocId]
		, @ExtLocAFrom = m.[ExtLocAFrom]
		, @ExtLocATo = m.[ExtLocATo]
		, @UserId = m.[UID]
		, @HostId = m.[HostId]
		, @TransDate = m.[TransDate]
		FROM dbo.tblWmMoveQuantity m 
		WHERE m.[Id] = @TransId
			AND m.[ParentId] IS NULL --must be a parent record
	
			
	--capture the processed transaction id
	Insert into #TransList ([TransId]) Values (@TransId)
	

	--if move by ItemId
	IF @MoveBy = 0
	BEGIN
		--capture the detail for regular items
		Insert into #MoveQuantity([TransId], [ItemType], [ItemId], [LocId], [LotNum], [SerNum]
			, [ExtLocAFrom], [ExtLocATo], [ExtLocBFrom], [ExtLocBTo], [Qty]
			, [TransDate], [UserId], [HostId])
		Select d.[Id], i.[ItemType], d.[MoveById], d.[LocId], d.[LotNum], NULL
			, d.[ExtLocAFrom], d.[ExtLocATo], d.[ExtLocBFrom], d.[ExtLocBTo]
			, ROUND(d.[Qty] * u.[ConvFactor], @PrecQty)
			, @TransDate, @UserId, @HostId
		FROM dbo.tblWmMoveQuantity d
		INNER JOIN dbo.tblInItem i ON d.[MoveById] = i.[ItemId]
		INNER JOIN dbo.tblInItemUom u ON d.[MoveById] = u.[ItemId] AND d.[Uom] = u.[Uom]
		WHERE d.[Id] = @TransId AND d.[ParentId] IS NULL --parent records only
			AND i.[ItemType] = 1 AND i.[KittedYN] = 0 --regular/non-kitted


		--capture the detail for serialized items (1 base unit each)
		Insert into #MoveQuantity([TransId], [ItemType], [ItemId], [LocId], [LotNum], [SerNum]
			, [ExtLocAFrom], [ExtLocATo], [ExtLocBFrom], [ExtLocBTo], [Qty]
			, [TransDate], [UserId], [HostId])
		Select d.[ParentId], i.[ItemType], d.[MoveById], d.[LocId], s.[LotNum], d.[SerNum]
			, d.[ExtLocAFrom], d.[ExtLocATo], d.[ExtLocBFrom], d.[ExtLocBTo], 1.0
			, @TransDate, @UserId, @HostId
		FROM dbo.tblWmMoveQuantity d
		INNER JOIN dbo.tblInItem i ON d.[MoveById] = i.[ItemId]
		INNER JOIN dbo.tblInItemSer s ON d.[MoveById] = s.[ItemId] and d.[SerNum] = s.[SerNum]
		WHERE d.[ParentId] = @TransId 
			AND i.[ItemType] = 2 --serialized
			AND ISNULL(s.[ExtLocA], -1) = ISNULL(d.[ExtLocAFrom], -1)
			AND ISNULL(s.[ExtLocB], -1) = ISNULL(d.[ExtLocBFrom], -1)
	END
	ELSE --if moving by ext loc b
	BEGIN
		--capture the MoveBy ExtLocB Id value
		DECLARE @MoveByKey int
		SELECT @MoveByKey = [Id] FROM dbo.tblWmExtLoc WHERE [Type] = 1 AND [ExtLocID] = @MoveById

		--capture the quantity to move for each item in the given extlocb container
		INSERT INTO #MoveQuantity([TransId], [ItemType], [ItemId], [LocId], [LotNum], [SerNum]
			, [ExtLocAFrom], [ExtLocATo], [ExtLocBFrom], [ExtLocBTo], [Qty]
			, [TransDate], [UserId], [HostId])
		SELECT @TransId, i.[ItemType], RTRIM(qt.[ItemId]), qt.[LocId], qt.[LotNum], qt.[SerNum]
			, @ExtLocAFrom, @ExtLocATo, @MoveByKey, @MoveByKey, SUM(qt.[QtyOnHand])
			, @TransDate, @UserId, @HostId
			FROM (
				SELECT q.[ItemId], q.[LocId], q.[LotNum], Null AS [SerNum], SUM([QtyOnHand]) AS [QtyOnHand]
					FROM (SELECT d.[ItemId], d.[LocId], d.[LotNum]
						, (d.[Qty] - d.[InvoicedQty] - d.[RemoveQty]) AS [QtyOnHand]
							FROM dbo.tblInQtyOnHand d 
							WHERE @MoveByKey IS NULL 
								AND @ExtLocAFrom IS NULL 
								AND d.[LocId] = @LocId
						UNION ALL --reduce the Null ExtLoc Qtys by the total from tblInQtyOnHand_Ext
						SELECT d.[ItemId], d.[LocId], d.[LotNum], -d.[Qty]
							FROM dbo.tblInQtyOnHand_Ext d
							WHERE @MoveByKey IS NULL 
								AND @ExtLocAFrom IS NULL 
								AND d.[LocId] = @LocId
						UNION ALL --Add in the detail for ExtLoc from tblInQtyOnHand_Ext
						SELECT d.[ItemId], d.[LocId], d.[LotNum], d.[Qty]
							FROM dbo.tblInQtyOnHand_Ext d
							WHERE ISNULL(d.[ExtLocB], -1) = ISNULL(@MoveByKey, -1)
								AND ISNULL(d.[ExtLocA], -1) = ISNULL(@ExtLocAFrom, -1) 
								AND d.[LocId] = @LocId
						) q
					GROUP BY q.[ItemId], q.[LocId], q.[LotNum]
				UNION ALL
				SELECT q.[ItemId], q.[LocId], q.[LotNum], q.[SerNum], 1.0  AS [QtyOnHand]
					FROM dbo.tblInItemSer q
					WHERE ISNULL(q.[ExtLocB], -1) = ISNULL(@MoveByKey, -1)
						AND ISNULL(q.[ExtLocA], -1) = ISNULL(@ExtLocAFrom, -1)
						AND q.[LocId] = @LocId
				) qt
			INNER JOIN dbo.tblInItem i 
				ON qt.[ItemId] = i.[ItemId]
			WHERE (i.[ItemType] = 1 OR i.[ItemType] = 2) AND i.[KittedYn] = 0
			GROUP BY qt.[ItemId], qt.[LocId], qt.[LotNum], qt.[SerNum], i.[ItemType]
	END

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_WmMoveQuantityPost_AppendMovement_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_WmMoveQuantityPost_AppendMovement_proc';

