
CREATE PROCEDURE trav_PoLandedCostDetail_proc
@PostRun pPostRun, 
@TransId pTransID, 
@EntryNum int, 
@ReceiptId uniqueidentifier = NULL

AS
BEGIN TRY
	SET NOCOUNT ON

	IF (@PostRun = '')
	BEGIN
		SELECT LandedCostID, [Description], [Level], CostType, Amount, CalcAmount 
		FROM
		(
			SELECT d.LandedCostID, l.[Description], l.[Level], l.CostType, l.Amount
				, ISNULL(v.Amount, l.CalcAmount) AS CalcAmount, l.LCTransSeqNum 
			FROM dbo.tblPoTransDetail d 
				INNER JOIN dbo.tblPoTransDetailLandedCost l ON d.TransId = l.TransId AND d.EntryNum = l.EntryNum 
				LEFT JOIN dbo.tblPoTransReceiptLandedCost v ON l.LCTransSeqNum = v.LCTransSeqNum 
			WHERE l.TransID = @TransId AND l.EntryNum = @EntryNum AND (@ReceiptID IS NULL OR v.ReceiptID = @ReceiptId)
		) tmp ORDER BY LCTransSeqNum
	END
	ELSE
	BEGIN
		SELECT LandedCostID, [Description], [Level], CostType, Amount, CalcAmount 
		FROM
		(
			SELECT d.LandedCostID, l.[Description], l.[Level], l.CostType, l.Amount
				, ISNULL(v.Amount, l.CalcAmount) AS CalcAmount, l.LCTransSeqNum 
			FROM dbo.tblPoHistDetail d 
				INNER JOIN dbo.tblPoHistDetailLandedCost l ON d.TransId = l.TransId AND d.EntryNum = l.EntryNum 
				LEFT JOIN dbo.tblPoHistReceiptLandedCost v ON l.LCTransSeqNum = v.LCTransSeqNum 
			WHERE l.PostRun = @PostRun AND l.TransID = @TransId AND l.EntryNum = @EntryNum 
				AND (@ReceiptID IS NULL OR v.ReceiptID = @ReceiptId)
		) tmp ORDER BY LCTransSeqNum
	END

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PoLandedCostDetail_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PoLandedCostDetail_proc';

