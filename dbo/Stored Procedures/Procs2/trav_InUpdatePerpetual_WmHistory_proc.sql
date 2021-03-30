
CREATE PROCEDURE dbo.trav_InUpdatePerpetual_WmHistory_proc
@SeqNum int,
@HistSeqNum int
AS
BEGIN TRY
	DECLARE @UserId pUserId
	DECLARE @HostId pWrkStnId
	DECLARE @WrkStnDate datetime
	DECLARE @PrecQty tinyint
	
	SELECT @PrecQty = Cast([Value] AS tinyint) FROM #GlobalValues WHERE [Key] = 'PrecQty'
	SELECT @UserId = Cast([Value] AS nvarchar(20)) FROM #GlobalValues WHERE [Key] = 'UserId'
	SELECT @HostId = Cast([Value] AS nvarchar(20)) FROM #GlobalValues WHERE [Key] = 'HostId'
	SELECT @WrkStnDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'WrkStnDate'
	
	IF @WrkStnDate IS NULL OR @UserId IS NULL OR @HostId IS NULL OR @PrecQty IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END
	

	INSERT INTO dbo.tblWmHistDetail ([ItemId], [LocId], [LotNum], [SerNum], [TransId]
		, [EntryDate], [TransDate], [Qty], [UID], [HostId], [DeletedYn], [Source]
		, [ExtLocA], [ExtLocAID], [ExtLocB], [ExtLocBID], HistSeqNum)
	SELECT c.ItemId,c.LocId,c.LotNum,NULL,d.DtlSeqNum,@WrkStnDate,p.CountDate,
		ABS(ROUND(d.QtyCounted * u.ConvFactor, @PrecQty) - d.QtyFrozen), 
		@UserId,@HostId,0,CASE WHEN ROUND(d.QtyCounted * u.ConvFactor, @PrecQty) > d.QtyFrozen THEN 15 ELSE 73 END,
		a.Id,d.ExtLocAId,b.Id,d.ExtLocBId, @HistSeqNum
	FROM dbo.tblInPhysCountDetail d INNER JOIN dbo.tblInPhysCount c ON d.SeqNum = c.SeqNum 
		INNER JOIN dbo.tblInPhysCountBatch p ON c.BatchId = p.BatchId
		INNER JOIN dbo.tblInItem i ON c.ItemId = i.ItemId
		INNER JOIN dbo.tblInItemUom u ON c.ItemId = u.ItemId AND d.CountedUom = u.Uom 
		LEFT JOIN dbo.tblWmExtLoc a ON c.LocId = a.LocID AND d.ExtLocAId = a.ExtLocID AND a.[Type] = 0 
		LEFT JOIN dbo.tblWmExtLoc b ON d.ExtLocBId = b.ExtLocID AND b.[Type] = 1
	WHERE d.DtlSeqNum = @SeqNum
	
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InUpdatePerpetual_WmHistory_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InUpdatePerpetual_WmHistory_proc';

