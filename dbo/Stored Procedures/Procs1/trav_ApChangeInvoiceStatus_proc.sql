
CREATE PROCEDURE dbo.trav_ApChangeInvoiceStatus_proc 
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @VendorIdFrom pVendorID, @VendorIdThru pVendorID, @PriorityCodeFrom nvarchar(1), @PriorityCodeThru nvarchar(1),
		@InvoiceDueDate Datetime, @StatusFrom tinyint, @StatusTo tinyint

	--Retrieve global values
	SELECT @InvoiceDueDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'InvoiceDueDate'
	SELECT @VendorIdFrom = NULLIF(Cast([Value] AS nvarchar(10)),'') FROM #GlobalValues WHERE [Key] = 'VendorIdFrom'
	SELECT @VendorIdThru = NULLIF(Cast([Value] AS nvarchar(10)),'') FROM #GlobalValues WHERE [Key] = 'VendorIdThru'
	SELECT @PriorityCodeFrom = NULLIF(Cast([Value] AS nvarchar(1)),'') FROM #GlobalValues WHERE [Key] = 'PriorityCodeFrom'
	SELECT @PriorityCodeThru = NULLIF(Cast([Value] AS nvarchar(1)),'') FROM #GlobalValues WHERE [Key] = 'PriorityCodeThru'
	SELECT @StatusFrom = Cast([Value] AS tinyint) FROM #GlobalValues WHERE [Key] = 'StatusFrom'
	SELECT @StatusTo = Cast([Value] AS tinyint) FROM #GlobalValues WHERE [Key] = 'StatusTo'

	IF @InvoiceDueDate IS NULL OR @StatusFrom IS NULL OR @StatusTo IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END
	
	IF @StatusFrom = 3
		BEGIN
			SELECT v.VendorId, SUM(GrossAmtDue) AS TotalDue, SUM(GrossAmtDuefgn) AS TotalDuefgn,
			ISNULL(SUM(BaseGrossAmtDue),0) AS TotBaseGrossAmtDue
			INTO #tblApOpenInvoice
			FROM dbo.tblApOpenInvoice i INNER JOIN dbo.tblApVendor v ON i.VendorID = v.VendorID
			WHERE i.[Counter] NOT IN (SELECT [Counter] FROM dbo.tblApPrepChkInvc) AND 
			((i.[Counter] NOT IN( SELECT [InvoiceCounter] FROM dbo.tblPoTransDeposit d WHERE d.InvoiceCounter IS NOT NULL)) OR (i.GroupID NOT IN(SELECT [InvoiceCounter] FROM dbo.tblPoTransDeposit d WHERE d.InvoiceCounter IS NOT NULL))) AND
				(@VendorIdFrom IS NULL OR v.VendorID >= @VendorIdFrom) AND 
				(@VendorIdThru IS NULL OR v.VendorID <= @VendorIdThru) AND
				(@PriorityCodeFrom IS NULL OR ISNULL(v.PriorityCode,'') >= @PriorityCodeFrom) AND 
				(@PriorityCodeThru IS NULL OR ISNULL(v.PriorityCode,'') <= @PriorityCodeThru) AND
				i.[Status] = 3 AND i.NetDueDate <= @InvoiceDueDate
			GROUP BY v.VendorId

			UPDATE dbo.tblApVendor SET GrossDue = GrossDue + TotBaseGrossAmtDue,  GrossDuefgn = GrossDuefgn + TotalDuefgn,
				Prepaid = Prepaid - TotalDue, Prepaidfgn = Prepaidfgn - TotalDuefgn
			FROM #tblApOpenInvoice a INNER JOIN tblApVendor ON a.VendorID = tblApVendor.VendorID

			UPDATE dbo.tblApOpenInvoice SET [Status] = @StatusTo, CheckNum = NULL, CheckDate = NULL, BankID = NULL, 
				PmtCurrencyId = NULL, PmtExchRate = 1, CalcGainLoss = 0, GLAccGainLoss = NULL, CheckPeriod = 0,
				CheckYear = 0, GrossAmtDue = BaseGrossAmtDue
			FROM dbo.tblApOpenInvoice INNER JOIN dbo.tblApVendor v ON dbo.tblApOpenInvoice.VendorID = v.VendorID
			WHERE [Counter] NOT IN (SELECT [Counter] FROM dbo.tblApPrepChkInvc) AND 
				(@VendorIdFrom IS NULL OR v.VendorID >= @VendorIdFrom) AND 
				(@VendorIdThru IS NULL OR v.VendorID <= @VendorIdThru) AND
				(@PriorityCodeFrom IS NULL OR ISNULL(v.PriorityCode,'') >= @PriorityCodeFrom) AND 
				(@PriorityCodeThru IS NULL OR ISNULL(v.PriorityCode,'') <= @PriorityCodeThru) AND
				dbo.tblApOpenInvoice.[Status] = 3 AND dbo.tblApOpenInvoice.NetDueDate <= @InvoiceDueDate

		END
	ELSE
		UPDATE dbo.tblApOpenInvoice SET [Status] = @StatusTo
		FROM dbo.tblApOpenInvoice INNER JOIN dbo.tblApVendor v ON dbo.tblApOpenInvoice.VendorID = v.VendorID
		WHERE [Counter] NOT IN (SELECT [Counter] FROM dbo.tblApPrepChkInvc) AND 
		(([Counter] NOT IN( SELECT [InvoiceCounter] FROM dbo.tblPoTransDeposit d WHERE d.InvoiceCounter IS NOT NULL )) OR (GroupID NOT IN(SELECT [InvoiceCounter] FROM dbo.tblPoTransDeposit d WHERE d.InvoiceCounter IS NOT NULL))) AND
				(@VendorIdFrom IS NULL OR v.VendorID >= @VendorIdFrom) AND 
				(@VendorIdThru IS NULL OR v.VendorID <= @VendorIdThru) AND
				(@PriorityCodeFrom IS NULL OR ISNULL(v.PriorityCode,'') >= @PriorityCodeFrom) AND 
				(@PriorityCodeThru IS NULL OR ISNULL(v.PriorityCode,'') <= @PriorityCodeThru) AND	
				dbo.tblApOpenInvoice.[Status] = @StatusFrom AND dbo.tblApOpenInvoice.NetDueDate <= @InvoiceDueDate
		
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApChangeInvoiceStatus_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApChangeInvoiceStatus_proc';

