
CREATE PROCEDURE dbo.trav_DRGenerateRunData_JCTrans_proc
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

	DECLARE @RunDate DateTime
	SELECT @RunDate = RunDate FROM dbo.tblDrRunInfo WHERE RunId = @RunId


	--Project transactions
	--capture any committed quantities for project estimates
	INSERT INTO dbo.tblDRRunData (RunId, ItemId, LocId, TransDate, TransType
		, [Source], VirtualYn, Qty, LinkID, LinkIDSub, LinkIDSubLine, CustId, VendorId, AssemblyId)
	SELECT @RunId, RTRIM(q.ItemId), RTRIM(q.LocId), COALESCE(t.TransDate, @RunDate), q.TransType
		, 2048 --2048=Project Committed quantities
		, 0, q.Qty, 'JC', 'PROJECT', Null, p.CustId, Null, Null
		FROM dbo.tblInQty q
		INNER JOIN dbo.tblPcTrans t ON q.SeqNum = t.QtySeqNum_Cmtd
		INNER JOIN dbo.tblPcProjectDetail d ON t.ProjectDetailId = d.Id
		INNER JOIN dbo.tblPcProject p ON d.ProjectId = p.Id
		WHERE q.LinkId = 'JC' AND q.TransType = 0 AND q.Qty <> 0


END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DRGenerateRunData_JCTrans_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DRGenerateRunData_JCTrans_proc';

