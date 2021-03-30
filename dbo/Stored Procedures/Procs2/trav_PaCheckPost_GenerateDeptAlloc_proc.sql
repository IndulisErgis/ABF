
CREATE PROCEDURE dbo.trav_PaCheckPost_GenerateDeptAlloc_proc 
AS
BEGIN TRY

DECLARE @UseHomeDepartment bit, @PrecCurr tinyint, @PaYear smallint

SELECT @PrecCurr = Cast([Value] AS tinyint) FROM #GlobalValues WHERE [Key] = 'PrecCurr'
SELECT @UseHomeDepartment = case when Cast([Value] AS nvarchar(1))='H' then 1 else 0 end FROM #GlobalValues WHERE [Key] = 'PaPostEplrTaxDedDpt'
SELECT @PaYear = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'PaYear'

CREATE TABLE #CheckList([CheckId] [int] NOT NULL PRIMARY KEY ([CheckId]))

INSERT INTO #CheckList([CheckId])
SELECT [TransID] FROM #PostTransList

exec [dbo].[trav_PaCalculateDepartmentAllocations_proc] @UseHomeDepartment, @PrecCurr, @PaYear

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaCheckPost_GenerateDeptAlloc_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaCheckPost_GenerateDeptAlloc_proc';

