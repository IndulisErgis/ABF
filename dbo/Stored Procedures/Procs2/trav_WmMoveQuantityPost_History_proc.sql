
CREATE PROCEDURE dbo.trav_WmMoveQuantityPost_History_proc
@TransId int
AS
BEGIN TRY
	DECLARE @WrkStnDate datetime
	
	--Retrieve global values
	SELECT @WrkStnDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'WrkStnDate'

	IF @WrkStnDate IS NULL OR @TransId IS NULL 
	BEGIN
		RAISERROR(90025,16,1)
	END

	--create the WM History for the move
	--move out
	INSERT INTO dbo.tblWmHistDetail ([ItemId], [LocId], [LotNum], [SerNum], [TransId]
		, [EntryDate], [TransDate], [Qty], [UID], [HostId], [DeletedYn], [Source]
		, [ExtLocA], [ExtLocAID], [ExtLocB], [ExtLocBID])
	SELECT t.[ItemId], t.[LocId], t.[LotNum], t.[SerNum], CAST(t.[TransId] AS nvarchar)
		, @WrkStnDate, t.[TransDate], t.[Qty], t.[UserId], t.[HostId], 0, 77 --move out
		, t.[ExtLocAFrom], a.[ExtLocID], t.[ExtLocBFrom], b.[ExtLocID]
	FROM #MoveQuantity t
	LEFT JOIN dbo.tblWmExtLoc a ON t.[ExtLocAFrom] = a.[Id]
	LEFT JOIN dbo.tblWmExtLoc b ON t.[ExtLocBFrom] = b.[Id]
	WHERE t.[TransId] = @TransId AND t.[Qty] <> 0.0

	--move in
	INSERT INTO dbo.tblWmHistDetail ([ItemId], [LocId], [LotNum], [SerNum], [TransId]
		, [EntryDate], [TransDate], [Qty], [UID], [HostId], [DeletedYn], [Source]
		, [ExtLocA], [ExtLocAID], [ExtLocB], [ExtLocBID])
	Select t.[ItemId], t.[LocId], t.[LotNum], t.[SerNum], CAST(t.[TransId] AS nvarchar)
		, @WrkStnDate, t.[TransDate], t.[Qty], t.[UserId], t.[HostId], 0, 19 --move in
		, t.[ExtLocATo], a.[ExtLocID], t.[ExtLocBTo], b.[ExtLocID]
	FROM #MoveQuantity t
	LEFT JOIN dbo.tblWmExtLoc a ON t.[ExtLocATo] = a.[Id]
	LEFT JOIN dbo.tblWmExtLoc b ON t.[ExtLocBTo] = b.[Id]
	WHERE t.[TransId] = @TransId AND t.[Qty] <> 0.0

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_WmMoveQuantityPost_History_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_WmMoveQuantityPost_History_proc';

