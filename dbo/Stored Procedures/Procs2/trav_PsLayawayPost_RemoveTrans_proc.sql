
CREATE PROCEDURE dbo.trav_PsLayawayPost_RemoveTrans_proc
AS
BEGIN TRY
	--TODO
	UPDATE dbo.tblPsPayment SET PostedYN = 1 
	FROM dbo.tblPsPayment INNER JOIN #PsLayawayPaymentList t ON dbo.tblPsPayment.ID = t.ID
		INNER JOIN #PsIncompleteLayawayList l ON dbo.tblPsPayment.HeaderID = l.ID

	DELETE dbo.tblPsTransDetailIN
	FROM dbo.tblPsTransDetailIN INNER JOIN dbo.tblPsTransDetail d ON dbo.tblPsTransDetailIN.DetailID = d.ID 
		INNER JOIN #PsCompletedLayawayList t ON d.HeaderID = t.ID 

	DELETE dbo.tblPsTransDetail
	FROM dbo.tblPsTransDetail INNER JOIN #PsCompletedLayawayList t ON dbo.tblPsTransDetail.HeaderID = t.ID

	DELETE dbo.tblPsTransTax
	FROM dbo.tblPsTransTax INNER JOIN #PsCompletedLayawayList t ON dbo.tblPsTransTax.HeaderID = t.ID

	DELETE dbo.tblPsTransContact
	FROM dbo.tblPsTransContact INNER JOIN #PsCompletedLayawayList t ON dbo.tblPsTransContact.HeaderID = t.ID

	DELETE dbo.tblPsTransHeader
	FROM dbo.tblPsTransHeader INNER JOIN #PsCompletedLayawayList t ON tblPsTransHeader.ID = t.ID

	DELETE dbo.tblPsPayment
	FROM dbo.tblPsPayment INNER JOIN #PsCompletedLayawayList t ON tblPsPayment.HeaderID = t.ID 

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PsLayawayPost_RemoveTrans_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PsLayawayPost_RemoveTrans_proc';

