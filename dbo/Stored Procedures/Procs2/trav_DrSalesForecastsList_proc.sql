
CREATE PROCEDURE [dbo].[trav_DrSalesForecastsList_proc]

AS

BEGIN TRY
SET NOCOUNT ON

SELECT h.Id, h.ItemId, h.LocId, h.UOM, i.Descr, d.FrcstDate, d.Qty, d.Notes 
FROM tblDrFrcst h

INNER JOIN tblDrFrcstDtl d  ON h.Id = d.FrcstId 
LEFT JOIN tblinitem i ON h.itemid = i.itemid
INNER JOIN #tmpDrSalesForecastsList t ON  t.Id=h.Id AND t.FrcstDate = d.FrcstDate    

      
END TRY
BEGIN CATCH
EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DrSalesForecastsList_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DrSalesForecastsList_proc';

