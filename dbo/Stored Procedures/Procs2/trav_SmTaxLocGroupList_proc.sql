
CREATE PROCEDURE [dbo].[trav_SmTaxLocGroupList_proc]

AS
SET NOCOUNT ON
BEGIN TRY

	SELECT g.TaxGrpID, g.[Desc], g.ReportMethod, d.LevelNo,	
			CASE WHEN d.LevelNo = 1 THEN LevelOne WHEN d.LevelNo = 2 THEN LevelTwo 	WHEN d.LevelNo = 3 THEN LevelThree
				WHEN d.LevelNo = 4 THEN LevelFour WHEN d.LevelNo = 5 THEN LevelFive END AS  TaxLocID,	
		   CASE WHEN d .Tax1 = 1 THEN 'X' ELSE '' END AS Tax1, 
           CASE WHEN d.Tax2 = 1 THEN 'X' ELSE '' END AS Tax2, CASE WHEN d.Tax3 = 1 THEN 'X' ELSE '' END AS Tax3, 
           CASE WHEN d.Tax4 = 1 THEN 'X' ELSE '' END AS Tax4
	FROM  dbo.tblSmTaxGroup AS g LEFT JOIN dbo.tblSmTaxGroupDetail AS d ON g.TaxGrpID = d.TaxGrpID
		  INNER JOIN #tmpTaxGroup t ON g.TaxGrpID = t.TaxGrpID

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SmTaxLocGroupList_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SmTaxLocGroupList_proc';

