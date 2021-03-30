
CREATE PROCEDURE dbo.trav_DRGenerateRunData_SOTrans_proc
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


	--Sales Order Transactions
	INSERT INTO dbo.tblDrRunData (RunId, ItemId, LocId, TransDate, TransType
		, [Source], VirtualYn, Qty, LinkID, LinkIDSub, LinkIDSubLine, CustId, VendorId, AssemblyId)
	SELECT @RunId, RTRIM(q.ItemId), RTRIM(q.LocId), COALESCE(d.ReqShipDate, t.ReqShipDate, t.TransDate), q.TransType
		, 16 --16=SalesOrds
		, 0, q.Qty, q.LinkId, RTRIM(q.LinkIdSub), q.LinkIdSubLine, t.SoldToId, Null, Null
		FROM dbo.tblInQty q
		INNER JOIN dbo.tblSoTransDetail d ON q.SeqNum = d.QtySeqNum_Cmtd
		INNER JOIN dbo.tblSoTransHeader t On d.TransId = t.TransId 
		WHERE t.[VoidYn] = 0 --not voided
			AND q.LinkId = 'SO' AND q.TransType = 0 AND q.Qty <> 0 
			AND d.[Status] = 0 --not completed

		
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DRGenerateRunData_SOTrans_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DRGenerateRunData_SOTrans_proc';

