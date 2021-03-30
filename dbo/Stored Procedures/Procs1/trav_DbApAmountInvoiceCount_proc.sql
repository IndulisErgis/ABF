
CREATE PROCEDURE [dbo].[trav_DbApAmountInvoiceCount_proc]

@Prec tinyint = 2, 
@Foreign bit = 0

AS
BEGIN TRY
	SET NOCOUNT ON

	CREATE TABLE #ApVendors
	(
		VendorCount int
	)

	CREATE TABLE #ApOpenInvoices
	(
		AmtHold pDecimal DEFAULT (0), 
		AmtTmpHold pDecimal DEFAULT (0), 
		AmtReleased pDecimal DEFAULT (0), 
		AmtPrepaid pDecimal DEFAULT (0), 
		InvcHold int, 
		InvcTmpHold int, 
		InvcReleased int, 
		InvcPaid int
	)

	/*  ApVendors  */
	INSERT INTO #ApVendors (VendorCount) 
		SELECT CAST(COUNT(VendorId)AS int) AS VendorCount FROM dbo.tblApVendor

	/*  ApOpenInvoices  */
	INSERT INTO #ApOpenInvoices (AmtHold, AmtTmpHold, AmtReleased, AmtPrepaid
		, InvcHold, InvcTmpHold, InvcReleased, InvcPaid) 
	SELECT ROUND(ISNULL(SUM(CASE WHEN [Status] = 1 THEN (CASE WHEN @Foreign = 0 THEN 
			GrossAmtDue ELSE GrossAmtDueFgn END) ELSE 0 END),0) ,@Prec) AS AmtHold
		, ROUND(ISNULL(SUM(CASE WHEN [Status] = 2 THEN (CASE WHEN @Foreign = 0 THEN 
			GrossAmtDue ELSE GrossAmtDueFgn END) ELSE 0 END),0), @Prec) AS AmtTmpHold
		, ROUND(ISNULL(SUM(CASE WHEN [Status] = 0 THEN (CASE WHEN @Foreign = 0 THEN 
			GrossAmtDue ELSE GrossAmtDueFgn END) ELSE 0 END),0), @Prec) AS AmtReleased
		, ROUND(ISNULL(SUM(CASE WHEN [Status] = 3 THEN (CASE WHEN @Foreign = 0 THEN 
			GrossAmtDue ELSE GrossAmtDueFgn END) ELSE 0 END),0), @Prec) AS AmtPrepaid
		, ISNULL(SUM(CASE WHEN [Status] = 1 THEN 1 ELSE 0 END),0) AS InvcHold
		, ISNULL(SUM(CASE WHEN [Status] = 2 THEN 1 ELSE 0 END),0) AS InvcTmpHold
		, ISNULL(SUM(CASE WHEN [Status] = 0 THEN 1 ELSE 0 END),0) AS InvcReleased
		, ISNULL(SUM(CASE WHEN [Status] = 4 THEN 1 ELSE 0 END),0) AS InvcPaid 
	FROM dbo.tblApOpenInvoice

	-- return resultset
	SELECT * FROM #ApVendors, #ApOpenInvoices
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DbApAmountInvoiceCount_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DbApAmountInvoiceCount_proc';

