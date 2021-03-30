
CREATE PROCEDURE [trav_InForecastTypesList_proc]
AS
BEGIN TRY

	SELECT f.ForecastType, f.Descr, f.AdjFactor, d.Period, d.WeightFactor
	FROM   dbo.tblPoForecastType f INNER JOIN dbo.tblPoForecastTypeDetail d ON f.ForecastType = d.ForecastType
		   INNER JOIN #tmpForecastType t ON  f.ForecastType = t.ForecastType

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InForecastTypesList_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InForecastTypesList_proc';

