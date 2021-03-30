
--PET:http://webfront:801/view.php?id=243302
--PET:http://problemtrackingsystem.osas.com/view.php?id=272474
CREATE PROCEDURE dbo.trav_DRGenerateRunData_POTrans_proc 
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE	@RunId pPostRun

	--Retrieve global values
	SELECT @RunId = Cast([Value] AS nvarchar) FROM #GlobalValues WHERE [Key] = 'RunId'
	
	IF @RunId IS NULL 
	BEGIN
		RAISERROR(90025,16,1)
	END


	--Live Purchase orders
	INSERT INTO dbo.tblDrRunData (RunId, ItemId, LocId, TransDate, TransType
		, [Source], VirtualYn, Qty, LinkID, LinkIDSub, LinkIDSubLine, CustId, VendorId, AssemblyId)
	SELECT @RunId, RTRIM(q.ItemId), RTRIM(q.LocId), COALESCE(d.ExpReceiptDate,t.ExpReceiptDate, t.TransDate), q.TransType
		, 1 --1=PurchOrds
		, 0, q.Qty, q.LinkId, RTRIM(q.LinkIdSub), q.LinkIdSubLine, Null, t.VendorId, Null
	FROM dbo.tblInQty q
	INNER JOIN dbo.tblPoTransDetail d ON q.SeqNum = d.QtySeqNum
	INNER JOIN dbo.tblPoTransHeader t
	ON d.TransId = t.TransId 
	WHERE q.LinkId = 'PO' AND q.TransType = 2 AND q.Qty <> 0
		
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DRGenerateRunData_POTrans_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DRGenerateRunData_POTrans_proc';

