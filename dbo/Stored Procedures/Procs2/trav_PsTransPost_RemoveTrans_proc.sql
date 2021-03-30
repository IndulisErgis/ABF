
CREATE PROCEDURE dbo.trav_PsTransPost_RemoveTrans_proc
AS
BEGIN TRY
	DELETE dbo.tblPsTransDetailIN
	FROM dbo.tblPsTransDetailIN INNER JOIN dbo.tblPsTransDetail d ON dbo.tblPsTransDetailIN.DetailID = d.ID 
		INNER JOIN #PsTransList t ON d.HeaderID = t.ID

	DELETE dbo.tblPsTransDetail
	FROM dbo.tblPsTransDetail INNER JOIN #PsTransList t ON dbo.tblPsTransDetail.HeaderID = t.ID

	DELETE dbo.tblPsTransTax
	FROM dbo.tblPsTransTax INNER JOIN #PsTransList t ON dbo.tblPsTransTax.HeaderID = t.ID

	DELETE dbo.tblPsTransContact
	FROM dbo.tblPsTransContact INNER JOIN #PsTransList t ON dbo.tblPsTransContact.HeaderID = t.ID

	DELETE dbo.tblPsTransHeader
	FROM dbo.tblPsTransHeader INNER JOIN #PsTransList t ON tblPsTransHeader.ID = t.ID

	DELETE dbo.tblPsPayment
	FROM dbo.tblPsPayment INNER JOIN #PsPaymentList t ON tblPsPayment.ID = t.ID

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PsTransPost_RemoveTrans_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PsTransPost_RemoveTrans_proc';

