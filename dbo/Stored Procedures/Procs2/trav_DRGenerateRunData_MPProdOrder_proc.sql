
--PET:http://problemtrackingsystem.osas.com/view.php?id=263034

CREATE PROCEDURE dbo.trav_DRGenerateRunData_MPProdOrder_proc
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
	

	--MP Production Orders 
	--	In Process or greater status - i.e. those with real inventory transactions
	Insert into dbo.tblDRRunData (RunId, ItemId, LocId, TransDate, TransType
		, [Source], VirtualYn, Qty, LinkID, LinkIDSub, LinkIDSubLine, CustId, VendorId, AssemblyId)
	Select @RunId, RTRIM(q.ItemId), RTRIM(q.LocId)
		, CASE WHEN s.ComponentType = 0 THEN t.EstCompletionDate ELSE r.EstStartDate END
		, q.TransType
		, CASE WHEN q.TransType = 2 THEN 4 ELSE 8 END --4=ProdOrds / 8=ProdOrdComp 
		, 0, q.Qty, 'MP', o.OrderNo, t.ReleaseNo, t.CustId, Null, o.AssemblyId
		FROM dbo.tblMpMatlSum s 
		INNER JOIN dbo.tblMpRequirements r ON s.TransId = r.TransId
		INNER JOIN dbo.tblMpOrderReleases t ON r.ReleaseId = t.Id
		INNER JOIN dbo.tblMpOrder o ON t.OrderNo = o.OrderNo
		INNER JOIN (Select SeqNum, ItemId, LocId, TransType, LinkId, LinkIdSub, LinkIdSubLine, Qty
				FROM dbo.tblInQty
				WHERE LinkId = 'MP' AND Qty <> 0 
				AND ((TransType = 2 AND ((@OptFlags & 4) = 4))
					OR (TransType = 0 AND ((@OptFlags & 8) = 8))) ) q
			ON s.QtySeqNum = q.SeqNum
		Where (s.[Status] <> 6 and t.[Status] <> 6)-- exclude quantities from requirements marked as 'complete'

		
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DRGenerateRunData_MPProdOrder_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DRGenerateRunData_MPProdOrder_proc';

