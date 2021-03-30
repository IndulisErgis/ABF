
CREATE PROCEDURE [dbo].[trav_MbECOPick_Proc]
	
AS
SET NOCOUNT ON

BEGIN TRY

	SELECT ECONum, e.Descr, Engineer, AssemblyId, CurrRevisionNo, NewRevisionNo, ECODate
		, EffectiveDate, t.Descr AS TypeDescr, s.Descr AS StatusDescr, Other, OtherDate, Notes 
	FROM dbo.tblMbECONum e 
		LEFT JOIN dbo.tblMbECOType t ON e.TypeRef = t.TypeRef 
		LEFT JOIN dbo.tblMbECOStatus s ON e.StatusRef = s.StatusRef 
		INNER JOIN #tmpECOPick tmp ON tmp.ECORef = e.ECORef
		
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_MbECOPick_Proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_MbECOPick_Proc';

