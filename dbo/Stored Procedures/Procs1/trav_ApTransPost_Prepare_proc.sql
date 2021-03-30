
CREATE PROCEDURE dbo.trav_ApTransPost_Prepare_proc
AS
BEGIN TRY
DECLARE @ErrorMessage NVARCHAR(4000), @TransAllocYn bit, @WrkStnDate datetime
DECLARE @TransID pTransID ,@LineNumber int
DECLARE @ErrorMsg nvarchar(4000)

--Retrieve global values
SELECT @TransAllocYn = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'TransAllocYn'
SELECT @WrkStnDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'WrkStnDate'

IF @TransAllocYn IS NULL OR @WrkStnDate IS NULL
BEGIN
	RAISERROR(90025,16,1)
END

-- test for invalid payment values
Create table #InvalidTransList (TransId pTransId)
Insert into #InvalidTransList (TransId)
	Select h.TransId
	FROM dbo.tblApTransHeader h 
	INNER JOIN #PostTransList l ON h.TransId = l.TransId 
	WHERE (PmtAmt1Fgn + PmtAmt2Fgn + PmtAmt3Fgn) <> (TaxableFgn + NonTaxableFgn + SalesTaxFgn + TaxAdjAmtFgn + FreightFgn + MiscFgn - CashDiscFgn - PrepaidAmtFgn)

if (Select Count(*) From #InvalidTransList) > 0
Begin
	Declare @InvalidTransList nvarchar(4000)
	Set @InvalidTransList = ''
	Select @InvalidTransList = @InvalidTransList + ', ' + TransId 
		From #InvalidTransList
	Select @InvalidTransList = SUBSTRING(@InvalidTransList, 3, 4000)
	SET @ErrorMessage = 'The post has been aborted.  Please review and correct the listed transactions before posting again.  Errors were detected in the following transactions: ' + @InvalidTransList + '.'
    RAISERROR(@ErrorMessage,16,1)
End

-- transaction allocation detail - check for unassigned gl accounts (can't use if not interfaced to GL)
IF @TransAllocYn <> 0
BEGIN
	IF ISNULL((SELECT COUNT(1) FROM dbo.tblApTransHeader th 
		INNER JOIN dbo.tblApTransDetail td ON th.TransId = td.TransId 
		INNER JOIN dbo.tblApTransAllocDtl ad ON td.TransId = ad.TransId AND td.EntryNum = ad.EntryNum 
		INNER JOIN #PostTransList l ON th.TransId = l.TransId 
		WHERE ad.AcctId IS NULL), 0) > 0
	BEGIN
		RAISERROR('Invalid GL Accounts exist.',16,1)
	END
END

-- transaction allocation detail -- Check for allocation subtotal matches the line item amount
SELECT TOP 1 @TransID =   td.TransId , @LineNumber = td.EntryNum 
FROM tblApTransDetail td
INNER JOIN #PostTransList l ON l.TransId = td.TransId
INNER JOIN
(
	SELECT TransId, EntryNum, Sum(AmountFgn) AS TotAlloc 
	FROM tblApTransAllocDtl 
	GROUP BY TransId, EntryNum
) al
ON (td.TransID = al.TransId AND td.EntryNum = al.EntryNum)
WHERE td.ExtCostFgn <> al.TotAlloc

SET @ErrorMsg =   N'TransId: '+@TransID + ' ' +  N'LineNumber: '+Convert(varchar(4000),@LineNumber)
IF (COUNT(@TransID) >0) 
BEGIN
	RAISERROR(N'Allocations are out of balance (%s)', 16, 1,@ErrorMsg)
END



-- update null invoice numbers to date & transID combination
UPDATE dbo.tblApTransHeader SET InvoiceNum = RIGHT(CONVERT(nvarchar(8),@WrkStnDate,112),4) + TransID 
WHERE TransId IN 
	(SELECT TransId FROM #PostTransList ) AND (InvoiceNum IS NULL OR InvoiceNum = '')

UPDATE dbo.tblApTransInvoiceTax SET InvcNum = dbo.tblApTransHeader.InvoiceNum 
FROM dbo.tblApTransHeader 
	INNER JOIN dbo.tblApTransInvoiceTax ON dbo.tblApTransHeader.TransID = dbo.tblApTransInvoiceTax.TransID 
	INNER JOIN #PostTransList l ON dbo.tblApTransHeader.TransId = l.TransId 
WHERE dbo.tblApTransInvoiceTax.InvcNum IS NULL

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApTransPost_Prepare_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApTransPost_Prepare_proc';

