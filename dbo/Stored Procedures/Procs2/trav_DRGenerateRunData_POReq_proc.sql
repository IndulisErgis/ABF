
CREATE PROCEDURE dbo.trav_DRGenerateRunData_POReq_proc
AS
BEGIN TRY
	--PET:http://webfront:801/view.php?id=236434
	--PET:http://webfront:801/view.php?id=241463
	--PET:http://webfront:801/view.php?id=242051
	--PET:http://problemtrackingsystem.osas.com/view.php?id=272474
	
	SET NOCOUNT ON

	DECLARE	@RunId pPostRun, @PrecQty tinyint

	--Retrieve global values
	SELECT @RunId = Cast([Value] AS nvarchar) FROM #GlobalValues WHERE [Key] = 'RunId'
	SELECT @PrecQty = Cast([Value] AS tinyint) FROM #GlobalValues WHERE [Key] = 'PrecQty'
	
	IF @RunId IS NULL OR @PrecQty IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END


	--Purchase requisitions
	INSERT INTO dbo.tblDrRunData (RunId, ItemId, LocId, TransDate, TransType
		, [Source], VirtualYn, Qty, LinkID, LinkIDSub, LinkIDSubLine, CustId, VendorId, AssemblyId)
	SELECT @RunId, t.ItemId, t.LocId, ISNULL(t.ExpReceiptDate,t.InitDate), 2
		, 2 --2=PurchReqs
		, 0, ROUND(t.Qty * i.ConvFactor, @PrecQty)
		, 'PO', Null, Null, Null, t.VendorId, Null
		FROM dbo.tblPoPurchaseReq t
		LEFT JOIN dbo.tblInItemUOM i
		ON t.ItemId = i.ItemId AND t.UOM = i.UOM
		WHERE t.Seq = 0 AND  t.Qty <> 0 AND NOT(t.ItemId IS NULL OR t.LocId IS NULL)  

	--Purchase request
	INSERT INTO dbo.tblDrRunData (RunId, ItemId, LocId, TransDate, TransType
		, [Source], VirtualYn, Qty, LinkID, LinkIDSub, LinkIDSubLine, CustId, VendorId, AssemblyId)
	SELECT @RunId, t.ItemId, t.LocId, COALESCE(t.ExpReceiptDate,h.ExpReceiptDate, h.TransDate), 2
		, 2 --2=Purchase request
		, 0, ROUND(t.QtyOrd * i.ConvFactor, @PrecQty)
		, 'PO', Null, Null, Null, h.VendorId, Null
		FROM dbo.tblPoTransHeader h
		INNER JOIN dbo.tblPoTransDetail t ON h.TransId = t.TransID
		LEFT JOIN dbo.tblInItemUOM i
		ON t.ItemId = i.ItemId AND t.Units = i.UOM
		WHERE h.TransType = 0 AND t.QtyOrd <> 0 AND NOT(t.ItemId IS NULL OR t.LocId IS NULL)   
		
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DRGenerateRunData_POReq_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DRGenerateRunData_POReq_proc';

