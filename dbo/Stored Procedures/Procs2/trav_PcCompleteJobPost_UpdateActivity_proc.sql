
CREATE PROCEDURE dbo.trav_PcCompleteJobPost_UpdateActivity_proc
AS
BEGIN TRY

	UPDATE dbo.tblPcActivity SET [Status] = 5 --Completed
	FROM #PostTransList t INNER JOIN dbo.tblPcActivity ON t.TransId = dbo.tblPcActivity.ProjectDetailId 
	WHERE (dbo.tblPcActivity.[Type] BETWEEN 0 AND 3 AND dbo.tblPcActivity.[Status] = 4) OR  --Activity type is Time, Material, Expense, Other; Activity status is billed.
		(dbo.tblPcActivity.[Type] = 6 AND dbo.tblPcActivity.[Status] = 2) --Posted Fixed Fee billing
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcCompleteJobPost_UpdateActivity_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcCompleteJobPost_UpdateActivity_proc';

