
CREATE PROCEDURE dbo.trav_ArTransPost_Prepare_proc
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

	--remove any voided transactions from the list of transactions to process
	DELETE #PostTransList 
	WHERE TransId IN (SELECT b.TransId FROM #PostTransList b INNER JOIN dbo.tblArTransHeader h on b.TransId = h.TransId Where h.VoidYn = 1)
	
	--set the default invoice numbers
	UPDATE #PostTransList SET DefaultInvoiceNumber = @InvoicePrefix + TransId
	
	UPDATE dbo.tblArTransHeader SET InvcNum = t.DefaultInvoiceNumber
	FROM dbo.tblArTransHeader INNER JOIN #PostTransList t ON dbo.tblArTransHeader.TransId = t.TransId 
	WHERE dbo.tblArTransHeader.InvcNum IS NULL OR dbo.tblArTransHeader.InvcNum = ''
	
	--remove any active transactions from the list of voided transactions to process
	DELETE #VoidTransList
	WHERE TransId IN (SELECT b.TransId FROM #PostTransList b INNER JOIN dbo.tblArTransHeader h on b.TransId = h.TransId Where h.VoidYn = 0)

	--set the default invoice numbers
	UPDATE #VoidTransList SET DefaultInvoiceNumber = @InvoicePrefix + TransId

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArTransPost_Prepare_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArTransPost_Prepare_proc';

