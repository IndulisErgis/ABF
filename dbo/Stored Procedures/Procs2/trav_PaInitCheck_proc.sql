
CREATE PROCEDURE [dbo].[trav_PaInitCheck_proc]
@paYear SMALLINT
AS
BEGIN TRY
	SET NOCOUNT ON
	DELETE Earn FROM [dbo].[tblPaCheckEarn] Earn INNER JOIN [dbo].[tblPaCheck] Chk ON Earn.[CheckId] = Chk.[Id] WHERE Chk.[PaYear] = @paYear
	DELETE Ded FROM [dbo].[tblPaCheckDeduct] Ded INNER JOIN [dbo].[tblPaCheck] Chk ON Ded.[CheckId] = Chk.[Id] WHERE Chk.[PaYear] = @paYear
	DELETE WH FROM [dbo].[tblPaCheckWithhold] WH INNER JOIN [dbo].[tblPaCheck] Chk ON WH.[CheckId] = Chk.[Id] WHERE Chk.[PaYear] = @paYear
	DELETE Cost FROM [dbo].[tblPaCheckEmplrCost] Cost INNER JOIN [dbo].[tblPaCheck] Chk ON Cost.[CheckId] = Chk.[Id] WHERE Chk.[PaYear] = @paYear
	DELETE Tax FROM [dbo].[tblPaCheckEmplrTax] Tax INNER JOIN [dbo].[tblPaCheck] Chk ON Tax.[CheckId] = Chk.[Id] WHERE Chk.[PaYear] = @paYear
	DELETE Lv FROM [dbo].[tblPaCheckLeave] Lv INNER JOIN [dbo].[tblPaCheck] Chk ON Lv.[CheckId] = Chk.[Id] WHERE Chk.[PaYear] = @paYear
	DELETE Dist FROM [dbo].[tblPaCheckDistribution] Dist INNER JOIN [dbo].[tblPaCheck] Chk ON Dist.[CheckId] = Chk.[Id] WHERE Chk.[PaYear] = @paYear
	DELETE Trans FROM [dbo].[tblPaCheckTrans] Trans INNER JOIN [dbo].[tblPaCheck] Chk ON Trans.[CheckId] = Chk.[Id] WHERE Chk.[PaYear] = @paYear
	DELETE FROM [dbo].[tblPaCheck] WHERE [PaYear] = @paYear
END TRY
BEGIN CATCH
	EXEC [dbo].[trav_RaiseError_proc]
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaInitCheck_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaInitCheck_proc';

