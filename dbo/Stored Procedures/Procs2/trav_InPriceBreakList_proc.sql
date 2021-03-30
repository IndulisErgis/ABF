
CREATE PROCEDURE [trav_InPriceBreakList_proc]
AS
BEGIN TRY

	 SELECT p.BrkId ,h.Description, BrkQty , BrkAdj , BrkAdjType 
	 FROM dbo.tblInPriceBreakHeader h
	 INNER JOIN dbo.tblInPriceBreaks p ON  h.PriceBrkId = p.BrkId
	 INNER JOIN #tmpPriceBreak t ON p.BrkId = t.BrkId
	 
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InPriceBreakList_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InPriceBreakList_proc';

