
CREATE PROCEDURE dbo.trav_WMPickReleaseOrders_ProcessOrderList_proc
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @PickId nvarchar(20)
	
	--Retrieve global values
	SELECT @PickId = Cast([Value] AS nvarchar) FROM #GlobalValues WHERE [Key] = 'PickId'

	IF @PickId IS NULL 
	BEGIN
		RAISERROR(90025,16,1)
	END


	--create a temp table to identify entries with activity
	CREATE TABLE #Activity
	(
		[PickGenKey] int not null,
		PRIMARY KEY CLUSTERED ([PickGenKey])
	)
	
	
	--remove any source entries that are allocated to another pickid 
	DELETE #OrderSummary 
		FROM dbo.tblWmPick_Gen g 
	WHERE #OrderSummary.SourceId = g.SourceId 
		AND #OrderSummary.TransId = g.TransId
		AND #OrderSummary.EntryNum = g.EntryNum
		AND #OrderSummary.SeqNum = g.SeqNum
		AND g.PickID <> @PickId


	--identify any existing entries for the current pickid 
	--	that have activity
	--	and are not already in the list
	INSERT INTO #Activity ([PickGenKey])
	SELECT g.PickGenKey
    FROM dbo.tblWmPick_Gen g 
	INNER JOIN dbo.tblWmPick p
		ON g.SourceId = p.SourceId 
		AND g.TransId = p.TransId 
		AND g.EntryNum = p.EntryNum 
		AND g.SeqNum = p.SeqNum
	LEFT JOIN #OrderSummary s
		ON s.SourceId = g.SourceId 
		AND s.TransId = g.TransId
		AND s.EntryNum = g.EntryNum
		AND s.SeqNum = g.SeqNum
	WHERE g.PickID = @PickId -- for current pick
		AND s.SourceId IS NULL -- not in current list
	GROUP BY g.PickGenKey --get a distinct list


	--remove all "release" entries for the current pickid 
	--	that do not have activity
	DELETE dbo.tblWmPick_Gen 
	WHERE [PickID] = @PickId
		AND [PickGenKey] NOT IN (SELECT [PickGenKey] FROM #Activity)
		
	
	--add the new releases to the table
	INSERT INTO dbo.tblWmPick_Gen ([SourceId], [TransId], [EntryNum], [SeqNum]
		, [PickNum], [ItemId], [LocId], [LotNum], [ExtLocA], [ExtLocB]
		, [UOM], [QtyReq], [ReqDate], [Ref1], [Ref2], [Ref3], [GrpId], [OriCompQty], [PickID])
	SELECT l.[SourceId], l.[TransId], l.[EntryNum], l.[SeqNum]
		, l.[PickNum], l.[ItemId], l.[LocId], l.[LotNum]
		, ISNULL(l.[ExtLocA], (SELECT TOP 1 b.Id FROM dbo.tblInItemLoc d 
							  INNER JOIN tblWmExtLoc b 
								ON d.LocId = b.LocID
								AND d.DfltBinNum = b.ExtLocID 
								AND  b.[Type] = 0  
							  WHERE d.ItemId = l.ItemId AND d.LocId = l.LocId))
		, l.[ExtLocB], l.[UOM], l.[QtyReq], l.[ReqDate], l.[Ref1], l.[Ref2], l.[Ref3], l.[GrpId], l.[OriCompQty], @PickId
	FROM #OrderSummary s
	INNER JOIN #OrderList l ON s.[Id] = l.[Id]
	
		
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_WMPickReleaseOrders_ProcessOrderList_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_WMPickReleaseOrders_ProcessOrderList_proc';

