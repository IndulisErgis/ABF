
CREATE PROCEDURE dbo.trav_PcBillingPost_Prepare_proc
AS
Set NoCount ON
BEGIN TRY
	DECLARE	@WrkStnDate datetime, @InvoicePrefix nvarchar(4)

	--Retrieve global values
	SELECT @WrkStnDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'WrkStnDate'

	IF @WrkStnDate IS NULL 
	BEGIN
		RAISERROR(90025,16,1)
	END

	--Note: Set the default invoice numbers with Date & TransId combination for use when the transaction value is null
	SELECT @InvoicePrefix = RIGHT(CONVERT(nvarchar(8), @WrkStnDate, 112), 4)	

	--set the default invoice numbers
	UPDATE #PostTransList SET DefaultInvoiceNumber = @InvoicePrefix + TransId

	UPDATE dbo.tblPcInvoiceHeader SET InvcNum = t.DefaultInvoiceNumber
	FROM dbo.tblPcInvoiceHeader INNER JOIN #PostTransList t ON dbo.tblPcInvoiceHeader.TransId = t.TransId 
	WHERE dbo.tblPcInvoiceHeader.InvcNum IS NULL OR dbo.tblPcInvoiceHeader.InvcNum = ''
	
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcBillingPost_Prepare_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcBillingPost_Prepare_proc';

