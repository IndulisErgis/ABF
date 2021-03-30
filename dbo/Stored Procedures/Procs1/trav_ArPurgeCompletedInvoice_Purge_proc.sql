
CREATE PROCEDURE dbo.trav_ArPurgeCompletedInvoice_Purge_proc
AS

SET NOCOUNT ON
BEGIN TRY
	DECLARE @PurgeDate datetime, @ZeroPurgeDate datetime, @PrecCurr smallint

	--Retrieve global values
	SELECT @PurgeDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'PurgeDate'
	SELECT @ZeroPurgeDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'ZeroPurgeDate'
	SELECT @PrecCurr = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'PrecCurr'

	IF @PurgeDate IS NULL OR @ZeroPurgeDate IS NULL OR @PrecCurr IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END

	--purge completed invoices prior to the purge date
	DELETE dbo.tblArCommInvc  
		FROM dbo.tblArCommInvc c 
		INNER JOIN #SalesRepList l ON c.SalesRepId = l.SalesRepId
	WHERE c.HoldYn = 0 
		AND c.CompletedDate < @PurgeDate 

	--purge zero commission invoices prior to the zero commission purge date
	DELETE dbo.tblArCommInvc  
		FROM dbo.tblArCommInvc c 
		INNER JOIN #SalesRepList l ON c.SalesRepId = l.SalesRepId
	WHERE c.HoldYn = 0 
		AND c.InvcDate < @ZeroPurgeDate
		AND ((c.PayLines = 1 AND ROUND(c.AmtLines, @PrecCurr) = 0) OR (c.PayLines = 0)OR (c.CommRateDtl = 0) OR (c.PctInvc = 0))
		AND ((c.PayTax = 1 AND ROUND(c.AmtTax, @PrecCurr) = 0) OR (c.PayTax = 0)OR (c.CommRateDtl = 0) OR (c.PctInvc = 0)) 
		AND ((c.PayFreight = 1 AND ROUND(c.AmtFreight, @PrecCurr) = 0) OR (c.PayFreight = 0)OR (c.CommRateDtl = 0) OR (c.PctInvc = 0))
		AND ((c.PayMisc = 1 AND ROUND(c.AmtMisc, @PrecCurr) = 0) OR (c.PayMisc = 0)OR (c.CommRateDtl = 0) OR (c.PctInvc = 0))


END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArPurgeCompletedInvoice_Purge_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArPurgeCompletedInvoice_Purge_proc';

