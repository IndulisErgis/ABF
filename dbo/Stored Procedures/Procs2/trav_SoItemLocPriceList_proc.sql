
CREATE PROCEDURE [dbo].[trav_SoItemLocPriceList_proc]

AS
SET NOCOUNT ON
BEGIN TRY

	SELECT  p.ItemId, p.LocId, p.CustLevel, cl.Descr, p.PriceAdjBase, p.PriceAdjType, p.PriceAdjAmt, p.PriceAdjPromoYn, 
			i.Descr AS ItemIdDescr, p.ItemId + p.LocId AS ItemIdLocID
	FROM  dbo.tblSoItemLocPrice AS p INNER JOIN dbo.tblInItem AS i ON p.ItemId = i.ItemId	
			INNER JOIN tblSoCustLevel cl ON cl.CustLevel = p.CustLevel	-- PET:- 0238857	
			INNER JOIN #tmpItemLoc AS t ON p.ItemId = t.ItemId AND p.LocId = t.LocId	
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SoItemLocPriceList_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SoItemLocPriceList_proc';

