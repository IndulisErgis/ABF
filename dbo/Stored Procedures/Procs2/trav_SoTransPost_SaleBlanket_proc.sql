
CREATE PROCEDURE dbo.trav_SoTransPost_SaleBlanket_proc
AS
SET NOCOUNT ON
BEGIN TRY

	DECLARE	@PostRun pPostRun, @WrkStnDate datetime

	--Retrieve global values
	SELECT @PostRun = Cast([Value] AS nvarchar) FROM #GlobalValues WHERE [Key] = 'PostRun'
	SELECT @WrkStnDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'WrkStnDate'
	
	IF @PostRun IS NULL OR @WrkStnDate IS NULL 
	BEGIN
		RAISERROR(90025,16,1)
	END
	
	--Line items
	INSERT INTO dbo.tblSoSaleBlanketActivity (BlanketRef, BlanketDtlRef, EntryDate, TransDate, PostRun, TransId, TransType, RecType, Qty, PriceExt)
	SELECT h.BlanketRef, d.BlanketDtlRef, @WrkStnDate, @WrkStnDate, @PostRun, h.TransId, SIGN(h.TransType), 1, d.QtyShipBase, d.PriceExtFgn
	FROM #PostTransList t INNER JOIN dbo.tblSoTransHeader h ON t.TransId = h.TransId
		INNER JOIN dbo.tblSoTransDetail d ON h.TransId = d.TransId 
		INNER JOIN dbo.tblSoSaleBlanketDetail b ON h.BlanketRef = b.BlanketRef AND d.BlanketDtlRef = b.BlanketDtlRef
	WHERE h.VoidYn = 0 AND (d.PriceExtFgn <> 0 OR d.QtyShipBase <> 0) AND d.[Status] = 0 AND d.GrpId IS NULL --uncompleted / excluding kit components
	
	--Freight
	INSERT INTO dbo.tblSoSaleBlanketActivity (BlanketRef, EntryDate, TransDate, PostRun, TransId, TransType, RecType, Qty, PriceExt)
	SELECT h.BlanketRef, @WrkStnDate, @WrkStnDate, @PostRun, h.TransId, SIGN(h.TransType), 2, 0, h.FreightFgn
	FROM #PostTransList t INNER JOIN dbo.tblSoTransHeader h ON t.TransId = h.TransId 
		INNER JOIN dbo.tblSoSaleBlanket b ON h.BlanketRef = b.BlanketRef
	WHERE h.VoidYn = 0 AND h.FreightFgn <> 0

	--Misd
	INSERT INTO dbo.tblSoSaleBlanketActivity (BlanketRef, EntryDate, TransDate, PostRun, TransId, TransType, RecType, Qty, PriceExt)
	SELECT h.BlanketRef, @WrkStnDate, @WrkStnDate, @PostRun, h.TransId, SIGN(h.TransType), 3, 0, h.MiscFgn
	FROM #PostTransList t INNER JOIN dbo.tblSoTransHeader h ON t.TransId = h.TransId 
		INNER JOIN dbo.tblSoSaleBlanket b ON h.BlanketRef = b.BlanketRef
	WHERE h.VoidYn = 0 AND h.MiscFgn <> 0

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SoTransPost_SaleBlanket_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SoTransPost_SaleBlanket_proc';

