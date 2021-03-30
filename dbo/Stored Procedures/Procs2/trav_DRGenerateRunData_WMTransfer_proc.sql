
CREATE PROCEDURE dbo.trav_DRGenerateRunData_WMTransfer_proc
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


	--capture any on order quantities for WM Transfers
	INSERT INTO dbo.tblDrRunData (RunId, ItemId, LocId, TransDate, TransType
		, [Source], VirtualYn, Qty, LinkID, LinkIDSub, LinkIDSubLine, CustId, VendorId, AssemblyId)
	SELECT @RunId, RTRIM(q.ItemId), RTRIM(q.LocId), (p.EntryDate), q.TransType
		, 1024 --1024=WM Transfer on order
		, 0, q.Qty, q.LinkId, RTRIM(q.LinkIdSub), q.LinkIdSubLine, Null, Null, Null
		FROM dbo.tblInQty q
		INNER JOIN dbo.tblWmTransferPick p ON q.SeqNum = p.QOOSeqNum
		INNER JOIN dbo.tblWmTransfer t ON p.TranKey = t.TranKey
		WHERE q.LinkId = 'WM' AND q.TransType = 2 AND q.Qty <> 0

		
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DRGenerateRunData_WMTransfer_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DRGenerateRunData_WMTransfer_proc';

