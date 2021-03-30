
CREATE PROCEDURE [dbo].[trav_DbApAgingAnalysis_proc]

@Prec tinyint = 2, 
@Foreign bit = 0, 
@Wksdate datetime =   null

AS
BEGIN TRY
	SET NOCOUNT ON



	CREATE TABLE #ApAgedTrialBal
	(
		VendorId pVendorID, 
		InvoiceNum pInvoiceNum, 
		[Status] tinyint, 
		InvcDate datetime, 
		GrossAmtDue pDecimal, 
		AmtFuture pDecimal, 
		AmtCurrent pDecimal, 
		AmtDue1 pDecimal, 
		AmtDue2 pDecimal, 
		AmtDue3 pDecimal, 
		AmtDue4 pDecimal
	)

	DECLARE @Age1 datetime, @Age2 datetime, @Age3 datetime, @Age4 datetime

	SELECT @Age1 = DATEADD(day, -30, @WksDate)
	SELECT @Age2 = DATEADD(day, -60, @WksDate)
	SELECT @Age3 = DATEADD(day, -90, @WksDate)
	SELECT @Age4 = DATEADD(day, -120, @WksDate)

	-- Open Invoices
	INSERT INTO #ApAgedTrialBal (VendorId, InvoiceNum, [Status], InvcDate, GrossAmtDue, AmtFuture, AmtCurrent
		, AmtDue1, AmtDue2, AmtDue3, AmtDue4) 
	SELECT v.VendorId, InvoiceNum, i.Status, InvoiceDate
		, CASE WHEN @Foreign = 0 THEN GrossAmtDue ELSE GrossAmtDueFgn END AS GrossAmtDue
		, CASE WHEN InvoiceDate > @WksDate THEN 
			(CASE WHEN @Foreign = 0 THEN GrossAmtDue ELSE GrossAmtDueFgn END) ELSE 0 END AS AmtFuture
		, CASE WHEN (InvoiceDate >= @Age1 AND InvoiceDate <= @WksDate) THEN 
			(CASE WHEN @Foreign = 0 THEN GrossAmtDue ELSE GrossAmtDueFgn END) ELSE 0 END AS AmtCurrent
		, CASE WHEN (InvoiceDate >= @Age2 AND InvoiceDate < @Age1) THEN 
			(CASE WHEN @Foreign = 0 THEN GrossAmtDue ELSE GrossAmtDueFgn END) ELSE 0 END AS AmtDue1
		, CASE WHEN (InvoiceDate >= @Age3 AND InvoiceDate < @Age2) THEN 
			(CASE WHEN @Foreign = 0 THEN GrossAmtDue ELSE GrossAmtDueFgn END) ELSE 0 END AS AmtDue2
		, CASE WHEN (InvoiceDate >= @Age4 AND InvoiceDate < @Age3) THEN 
			(CASE WHEN @Foreign = 0 THEN GrossAmtDue ELSE GrossAmtDueFgn END) ELSE 0 END AS AmtDue3
		, CASE WHEN InvoiceDate < @Age4 THEN 
			(CASE WHEN @Foreign = 0 THEN GrossAmtDue ELSE GrossAmtDueFgn END) ELSE 0 END AS AmtDue4 
	FROM dbo.tblApVendor v INNER JOIN dbo.tblApOpenInvoice i ON v.VendorId = i.VendorId 
	WHERE i.Status < 3 
		AND ((VoidCreatedDate IS NOT NULL AND VoidCreatedDate < = @WksDate) 
		OR (VoidCreatedDate IS NULL AND InvoiceDate < = @WksDate))

	-- Check record for paid invoice with invoice date before transaction cutoff date
	-- and check date between payment cutoff date and transaction cutoff date
	INSERT INTO #ApAgedTrialBal (VendorId, InvoiceNum, [Status], InvcDate, GrossAmtDue, AmtFuture, AmtCurrent
		, AmtDue1, AmtDue2, AmtDue3, AmtDue4) 
	SELECT v.VendorId, InvoiceNum, i.Status, CheckDate
		, -1 * (CASE WHEN @Foreign = 0 THEN GrossAmtDue ELSE GrossAmtDueFgn END) AS GrossAmtDue
		, 0 AS AmtFuture, 0 AS AmtCurrent, 0 AS AmtDue1, 0 AS AmtDue2, 0 AS AmtDue3, 0 AS AmtDue4 
	FROM dbo.tblApVendor v INNER JOIN dbo.tblApOpenInvoice i ON v.VendorId = i.VendorId 
	WHERE i.Status = 4 
		AND ((VoidCreatedDate IS NOT NULL AND VoidCreatedDate < = @WksDate) 
		OR (VoidCreatedDate IS NULL AND InvoiceDate < = @WksDate)) 
		AND CheckDate <= @WksDate

	-- Invoice record for paid invoice with invoice date before transaction cutoff date
	--  and check date between payment cutoff date and transaction cutoff date
	INSERT INTO #ApAgedTrialBal (VendorId, InvoiceNum, [Status], InvcDate, GrossAmtDue, AmtFuture, AmtCurrent
		, AmtDue1, AmtDue2, AmtDue3, AmtDue4) 
	SELECT v.VendorId, InvoiceNum, i.Status, InvoiceDate
		, CASE WHEN @Foreign = 0 THEN GrossAmtDue ELSE GrossAmtDueFgn END AS GrossAmtDue
		, 0 AS AmtFuture, 0 AS AmtCurrent, 0 AS AmtDue1, 0 AS AmtDue2, 0 AS AmtDue3, 0 AS AmtDue4 
	FROM dbo.tblApVendor v INNER JOIN dbo.tblApOpenInvoice i ON v.VendorId = i.VendorId 
	WHERE i.Status = 4 
		AND ((VoidCreatedDate IS NOT NULL AND VoidCreatedDate < = @WksDate) 
		OR (VoidCreatedDate IS NULL AND InvoiceDate < = @WksDate)) 
		AND CheckDate <=@WksDate

	-- Invoice record for paid invoice with invoice date before transaction cutoff date
	--  and check date after transaction cutoff date
	INSERT INTO #ApAgedTrialBal (VendorId, InvoiceNum, [Status], InvcDate, GrossAmtDue, AmtFuture, AmtCurrent
		, AmtDue1, AmtDue2, AmtDue3, AmtDue4) 
	SELECT v.VendorId, InvoiceNum, 0, InvoiceDate
		, CASE WHEN @Foreign = 0 THEN GrossAmtDue ELSE GrossAmtDueFgn END AS GrossAmtDue
		, CASE WHEN InvoiceDate > @WksDate THEN 
			(CASE WHEN @Foreign = 0 THEN GrossAmtDue ELSE GrossAmtDueFgn END) ELSE 0 END AS AmtFuture
		, CASE WHEN (InvoiceDate >= @Age1) AND (InvoiceDate <= @WksDate) THEN 
			(CASE WHEN @Foreign = 0 THEN GrossAmtDue ELSE GrossAmtDueFgn END) ELSE 0 END AS AmtCurrent
		, CASE WHEN (InvoiceDate >= @Age2) AND (InvoiceDate < @Age1) THEN 
			(CASE WHEN @Foreign = 0 THEN GrossAmtDue ELSE GrossAmtDueFgn END) ELSE 0 END AS AmtDue1
		, CASE WHEN (InvoiceDate >= @Age3) AND (InvoiceDate < @Age2) THEN 
			(CASE WHEN @Foreign = 0 THEN GrossAmtDue ELSE GrossAmtDueFgn END) ELSE 0 END AS AmtDue2
		, CASE WHEN (InvoiceDate >= @Age4) AND (InvoiceDate < @Age3) THEN 
			(CASE WHEN @Foreign = 0 THEN GrossAmtDue ELSE GrossAmtDueFgn END) ELSE 0 END AS AmtDue3
		, CASE WHEN InvoiceDate < @Age4 THEN 
			(CASE WHEN @Foreign = 0 THEN GrossAmtDue ELSE GrossAmtDueFgn END) ELSE 0 END AS AmtDue4 
	FROM dbo.tblApVendor v INNER JOIN dbo.tblApOpenInvoice i ON v.VendorId = i.VendorId 
	WHERE i.Status = 4 
		AND ((VoidCreatedDate IS NOT NULL AND VoidCreatedDate < = @WksDate) 
		OR (VoidCreatedDate IS NULL AND InvoiceDate < = @WksDate)) 
		AND CheckDate > @WksDate

	-- Check record for paid invoice with invoice date after transaction cutoff date
	--  and check date between payment cutoff date AND transaction cutoff date
	INSERT INTO #ApAgedTrialBal (VendorId, InvoiceNum, [Status], InvcDate, GrossAmtDue, AmtFuture, AmtCurrent
		, AmtDue1, AmtDue2, AmtDue3, AmtDue4) 
	SELECT v.VendorId, InvoiceNum, i.Status, CheckDate
		, -1 * (CASE WHEN @Foreign = 0 THEN GrossAmtDue ELSE GrossAmtDueFgn END) AS GrossAmtDue
		, CASE WHEN CheckDate > @WksDate THEN 
			-1 * (CASE WHEN @Foreign = 0 THEN GrossAmtDue ELSE GrossAmtDueFgn END) ELSE 0 END AS AmtFuture
		, CASE WHEN CheckDate >= @Age1 AND CheckDate <= @WksDate THEN 
			-1 * (CASE WHEN @Foreign = 0 THEN GrossAmtDue ELSE GrossAmtDueFgn END) ELSE 0 END AS AmtCurrent
		, CASE WHEN CheckDate >= @Age2 AND CheckDate < @Age1 THEN 
			-1 * (CASE WHEN @Foreign = 0 THEN GrossAmtDue ELSE GrossAmtDueFgn END) ELSE 0 END AS AmtDue1
		, CASE WHEN CheckDate >= @Age3 AND CheckDate < @Age2 THEN 
			-1 * (CASE WHEN @Foreign = 0 THEN GrossAmtDue ELSE GrossAmtDueFgn END) ELSE 0 END AS AmtDue2
		, CASE WHEN CheckDate >= @Age4 AND CheckDate < @Age3 THEN 
			-1 * (CASE WHEN @Foreign = 0 THEN GrossAmtDue ELSE GrossAmtDueFgn END) ELSE 0 END AS AmtDue3
		, CASE WHEN CheckDate < @Age4 THEN 
			-1 * (CASE WHEN @Foreign = 0 THEN GrossAmtDue ELSE GrossAmtDueFgn END) ELSE 0 END AS AmtDue4 
	FROM dbo.tblApVendor v INNER JOIN dbo.tblApOpenInvoice i ON v.VendorId = i.VendorId 
	WHERE i.Status = 4 
		AND ((VoidCreatedDate IS NOT NULL AND VoidCreatedDate > @WksDate) 
		OR (VoidCreatedDate IS NULL AND InvoiceDate > @WksDate)) 
		AND CheckDate <=@WksDate

	-- return resultset
	SELECT ROUND(ISNULL(SUM(AmtCurrent),0), @Prec)AS CurrentBal
		, ROUND(ISNULL(SUM(AmtDue1),0), @Prec) AS Bal3160
		, ROUND(ISNULL(SUM(AmtDue2),0), @Prec) AS Bal6190
		, ROUND(ISNULL(SUM(AmtDue3),0), @Prec) AS Bal91120
		, ROUND(ISNULL(SUM(AmtDue4),0), @Prec) AS BalOver120
		, ROUND(ISNULL(SUM(GrossAmtDue),0), @Prec) AS TotDue 
	FROM #ApAgedTrialBal
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DbApAgingAnalysis_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DbApAgingAnalysis_proc';

