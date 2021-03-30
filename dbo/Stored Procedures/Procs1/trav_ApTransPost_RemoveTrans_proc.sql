
CREATE PROCEDURE dbo.trav_ApTransPost_RemoveTrans_proc
AS
BEGIN TRY

DELETE dbo.tblApTransAllocDtl FROM (dbo.tblApTransHeader 
	INNER JOIN dbo.tblApTransAllocDtl ON dbo.tblApTransHeader.TransId = dbo.tblApTransAllocDtl.TransID) 
	INNER JOIN #PostTransList l ON dbo.tblApTransHeader.TransId = l.TransId

DELETE dbo.tblApTransAlloc FROM (dbo.tblApTransHeader 
	INNER JOIN dbo.tblApTransAlloc ON dbo.tblApTransHeader.TransId = dbo.tblApTransAlloc.TransID) 
	INNER JOIN #PostTransList l ON dbo.tblApTransHeader.TransId = l.TransId

DELETE dbo.tblApTransInvoiceTax FROM (dbo.tblApTransHeader 
	INNER JOIN dbo.tblApTransInvoiceTax ON dbo.tblApTransHeader.TransId = dbo.tblApTransInvoiceTax.TransID) 
	INNER JOIN #PostTransList l ON dbo.tblApTransHeader.TransId = l.TransId

DELETE dbo.tblApTransLot FROM (dbo.tblApTransHeader 
	INNER JOIN dbo.tblApTransLot ON dbo.tblApTransHeader.TransId = dbo.tblApTransLot.TransID) 
	INNER JOIN #PostTransList l ON dbo.tblApTransHeader.TransId = l.TransId

DELETE dbo.tblApTransSer FROM (dbo.tblApTransHeader 
	INNER JOIN dbo.tblApTransSer ON dbo.tblApTransHeader.TransId = dbo.tblApTransSer.TransID) 
	INNER JOIN #PostTransList l ON dbo.tblApTransHeader.TransId = l.TransId

DELETE dbo.tblApTransPc FROM (dbo.tblApTransHeader 
	INNER JOIN dbo.tblApTransPc ON dbo.tblApTransHeader.TransId = dbo.tblApTransPc.TransID) 
	INNER JOIN #PostTransList l ON dbo.tblApTransHeader.TransId = l.TransId

DELETE dbo.tblApTransDetail FROM (dbo.tblApTransHeader 
	INNER JOIN dbo.tblApTransDetail ON dbo.tblApTransHeader.TransId = dbo.tblApTransDetail.TransID) 
	INNER JOIN #PostTransList l ON dbo.tblApTransHeader.TransId = l.TransId

DELETE dbo.tblApTransHeader FROM dbo.tblApTransHeader 
	INNER JOIN #PostTransList l ON dbo.tblApTransHeader.TransId = l.TransId
	
	

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApTransPost_RemoveTrans_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApTransPost_RemoveTrans_proc';

