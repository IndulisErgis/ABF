
CREATE PROCEDURE dbo.trav_ArCheckDuplicatePONumber_proc 
@CustomerId pCustId, 
@PONum nvarchar(25)

AS

	DECLARE @Ret tinyint 
	SET @Ret = 0

	IF EXISTS (SELECT * FROM dbo.tblArHistHeader WHERE SoldToId = @CustomerId AND CustPONum = @PONum) 
		SET @Ret = 1 
	ELSE IF EXISTS (SELECT * FROM dbo.tblArRecurHeader WHERE CustId = @CustomerId AND CustPONum = @PONum) 
		SET @Ret = 1 
	ELSE IF EXISTS (SELECT * FROM dbo.tblArTransHeader WHERE CustId = @CustomerId AND CustPONum = @PONum) 
		SET @Ret = 1 
	ELSE IF EXISTS (SELECT * FROM dbo.tblPcInvoiceHeader WHERE CustId = @CustomerId AND CustPONum = @PONum) 
		SET @Ret = 1 
	ELSE IF EXISTS (SELECT * FROM dbo.tblPcProjectDetail d INNER JOIN dbo.tblPcProject p ON p.Id = d.ProjectId 
						WHERE p.CustId = @CustomerId AND d.CustPONum = @PONum) 
		SET @Ret = 1 
	ELSE IF EXISTS (SELECT * FROM dbo.tblPsHistHeader WHERE SoldToID = @CustomerId AND PONumber = @PONum) 
		SET @Ret = 1 
	ELSE IF EXISTS (SELECT * FROM dbo.tblPsTransHeader WHERE SoldToID = @CustomerId AND PONumber = @PONum) 
		SET @Ret = 1 
	ELSE IF EXISTS (SELECT * FROM dbo.tblSoSaleBlanket WHERE CustId = @CustomerId AND CustPONum = @PONum) 
		SET @Ret = 1 
	ELSE IF EXISTS (SELECT * FROM dbo.tblSoTransHeader WHERE CustId = @CustomerId AND CustPONum = @PONum) 
		SET @Ret = 1 
	ELSE IF EXISTS (SELECT * FROM dbo.tblSvHistoryWorkOrder WHERE CustId = @CustomerId AND CustomerPoNumber = @PONum) 
		SET @Ret = 1 
	ELSE IF EXISTS (SELECT * FROM dbo.tblSvInvoiceHeader WHERE CustId = @CustomerId AND CustomerPoNumber = @PONum) 
		SET @Ret = 1 
	ELSE IF EXISTS (SELECT * FROM dbo.tblSvWorkOrder WHERE CustId = @CustomerId AND CustomerPoNumber = @PONum) 
		SET @Ret = 1 

	SELECT @Ret AS ReturnValue
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArCheckDuplicatePONumber_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArCheckDuplicatePONumber_proc';

