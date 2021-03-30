
CREATE PROCEDURE dbo.trav_PaVoidCheck_CheckHistory_proc
AS
--PET:http://webfront:801/view.php?id=227706
--PET:http://webfront:801/view.php?id=251453

BEGIN TRY
	DECLARE @VoidDate datetime
       
	SELECT @VoidDate = Cast([Value] AS DateTime) FROM #GlobalValues WHERE [Key] = 'VoidDate'
       
	IF @VoidDate IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END

	--mark check history as voided
	UPDATE dbo.tblPaCheckHist SET [Voided] = 1
		, [VoidDate] = @VoidDate, VoidBankId = i.[BankId]
	FROM dbo.tblPaCheckHist 
	INNER JOIN #VoidCheckLog l ON dbo.tblPaCheckHist.[PostRun] = l.[PostRun] AND dbo.tblPaCheckHist.[Id] = l.[Id]
	INNER JOIN #VoidCheckList i ON l.[PostRun] = i.[PostRun] AND l.[Id] = i.[Id]
	WHERE l.[Status] = 0 
	

	--mark transaction history as voided
	UPDATE dbo.tblPaTransDeductHist SET [Voided] = 1 
	FROM dbo.tblPaTransDeductHist 
	INNER JOIN #VoidCheckLog l ON dbo.tblPaTransDeductHist.CheckId =  l.[Id]
	WHERE l.[Status] = 0 

	--Earnings
	UPDATE dbo.tblPaTransEarnHist SET [Voided] = 1 
	FROM dbo.tblPaTransEarnHist 
	INNER JOIN #VoidCheckLog l ON dbo.tblPaTransEarnHist.CheckId =  l.[Id]
	WHERE l.[Status] = 0 

	UPDATE dbo.tblPaTransEmplrCostHist SET [Voided] = 1 
	FROM dbo.tblPaTransEmplrCostHist 
	INNER JOIN #VoidCheckLog l ON dbo.tblPaTransEmplrCostHist.CheckId =  l.[Id]
	WHERE l.[Status] = 0 

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaVoidCheck_CheckHistory_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaVoidCheck_CheckHistory_proc';

