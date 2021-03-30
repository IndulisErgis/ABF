
CREATE PROCEDURE [dbo].[trav_SoScheduledBlanketOrderReport_proc]
-- the following should come from the pick screen or be retrieved in report sp (not needed anywhere else on the report except to retrieve the data)
@ExchRate pDecimal = 1,
@ReportCurrency pCurrency = 'USD',
@PrintAllInBaseCurrency bit = 1

AS
SET NOCOUNT ON
BEGIN TRY


-- return the resultset
SELECT distinct s.BlanketDtlSchRef, s.ReleaseDate, h.BlanketId, h.SoldToId, d.ItemId, d.Descr, d.LocId, d.Units, s.QtyOrdered,d.CatId
	, CASE WHEN @PrintAllInBaseCurrency = 1 THEN d.UnitPrice / ISNULL(@ExchRate, 1) ELSE d.UnitPrice END AS UnitPrice
	, CASE WHEN @PrintAllInBaseCurrency = 1 THEN (s.QtyOrdered * d.UnitPrice) / ISNULL(@ExchRate, 1)  ELSE s.QtyOrdered * d.UnitPrice  END AS PriceExt 
FROM dbo.tblSoSaleBlanket h 
	INNER JOIN dbo.tblSoSaleBlanketDetail d ON h.BlanketRef = d.BlanketRef 
	INNER JOIN dbo.tblSoSaleBlanketDetailSch s ON d.BlanketDtlRef = s.BlanketDtlRef
	INNER JOIN #tmpBlanketOrder tmp on tmp.BlanketId = h.BlanketId 
WHERE h.BlanketStatus = 0 AND h.BlanketType = 2 -- open status and scheduled blankets
	AND s.Status = 0 -- new scheduled quantities
	AND ((h.CurrencyId = @ReportCurrency) OR (@PrintAllInBaseCurrency = 1)) -- single currency or all in base currency
    AND tmp.ReleaseDate = s.ReleaseDate

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SoScheduledBlanketOrderReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SoScheduledBlanketOrderReport_proc';

