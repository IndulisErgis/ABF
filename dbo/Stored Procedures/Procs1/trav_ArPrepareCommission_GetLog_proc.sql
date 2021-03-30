
CREATE PROCEDURE dbo.trav_ArPrepareCommission_GetLog_proc
AS 

SET NOCOUNT ON
BEGIN TRY

	DECLARE @CutoffDate datetime

	--Retrieve global values
	SELECT @CutoffDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'CutoffDate'

	IF @CutoffDate IS NULL 
	BEGIN
		RAISERROR(90025,16,1)
	END

	--retrieve the resultset
	SELECT s.SalesRepID, s.[Name] SalesRepName
		, Sum(c.AmtPrepared) AS AmountPrepared
		, Cast(Max(Cast(c.HoldYn as tinyint)) as bit) AS HeldInvoices
		FROM dbo.tblArSalesRep s 
		INNER JOIN #SalesRepList l on s.SalesRepId = l.SalesRepId
		INNER JOIN dbo.tblArCommInvc c ON s.SalesRepID = c.SalesRepID
		WHERE c.CompletedDate IS NULL AND c.InvcDate <= @CutoffDate
		GROUP BY s.SalesRepID, s.[Name]


END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArPrepareCommission_GetLog_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArPrepareCommission_GetLog_proc';

