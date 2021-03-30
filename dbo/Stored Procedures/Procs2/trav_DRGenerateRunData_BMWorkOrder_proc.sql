
CREATE PROCEDURE dbo.trav_DRGenerateRunData_BMWorkOrder_proc
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE	@RunId pPostRun, @PrecQty tinyint

	--Retrieve global values
	SELECT @RunId = Cast([Value] AS nvarchar) FROM #GlobalValues WHERE [Key] = 'RunId'
	
	IF @RunId IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END

	DECLARE @OptFlags int
	SELECT @OptFlags = Flags FROM dbo.tblDrRunInfo WHERE RunId = @RunId
	

	--BM - Issued Work Orders
	INSERT INTO dbo.tblDrRunData (RunId, ItemId, LocId, TransDate, TransType
		, [Source], VirtualYn, Qty, LinkID, LinkIDSub, LinkIDSubLine, CustId, VendorId, AssemblyId, AssemblyLocId)
	SELECT @RunId, q.ItemId, q.LocId, t.TransDate, q.TransType
		, CASE WHEN q.TransType = 2 THEN 256 ELSE 512 END --256=WorkOrder / 512=WorkOrdComp 
		, 0, q.Qty, q.LinkId, q.LinkIdSub, q.LinkIdSubLine, Null, Null, a.BmItemId, a.BmLocId
		FROM (
			SELECT RTRIM(q2.ItemId) AS [ItemId], RTRIM(q2.LocId) AS [LocId]
				, q2.TransType, q2.LinkId, q2.LinkIdSubLine, RTRIM(q2.LinkIdSub) AS [LinkIdSub]
				, q2.Qty, q2.SeqNum
			FROM dbo.tblInQty q2
			WHERE q2.LinkId = 'BM' AND q2.Qty <> 0 
			AND ((q2.TransType = 2 AND ((@OptFlags & 256) = 256))
				OR (q2.TransType = 0 AND ((@OptFlags & 512) = 512))) 
			) q
		INNER JOIN ( --capture qtys for assemblies 
			SELECT h.BmBomID, h.TransDate, h.QtySeqNum
				FROM dbo.tblBmWorkOrder h
			UNION ALL --capture qtys for components of assemblies 
			SELECT h.BmBomID, h.TransDate, d.QtySeqNum
				FROM dbo.tblBmWorkOrder h 
				INNER JOIN dbo.tblBmWorkOrderDetail d ON h.TransId = d.TransId
			) t
		ON q.SeqNum = t.QtySeqNum
		LEFT JOIN dbo.tblBmBom a ON t.BmBomId = a.BmBomId

		
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DRGenerateRunData_BMWorkOrder_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DRGenerateRunData_BMWorkOrder_proc';

