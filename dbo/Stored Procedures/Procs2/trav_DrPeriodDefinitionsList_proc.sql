
CREATE PROCEDURE [dbo].[trav_DrPeriodDefinitionsList_proc]

AS

BEGIN TRY

SET NOCOUNT ON

	SELECT h.PdDefId, h.Descr, h.TimeFencePds, d.Period, d.IncUnit, d.Increment	FROM dbo.tblDrPeriodDef h 
	INNER JOIN dbo.tblDrPeriodDefDtl d ON h.PdDefId = d.PdDefId
	INNER JOIN #tmpDrPeriodDefinitionsList t ON  t.PdDefId=h.PdDefId 
	
END TRY
BEGIN CATCH
EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DrPeriodDefinitionsList_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DrPeriodDefinitionsList_proc';

