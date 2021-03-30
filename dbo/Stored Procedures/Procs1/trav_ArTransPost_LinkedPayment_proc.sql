
CREATE PROCEDURE dbo.trav_ArTransPost_LinkedPayment_proc
AS
BEGIN TRY

	--update linked payments from AR
	UPDATE dbo.tblArCashRcptDetail SET InvcNum = tmp.InvcNum
	FROM (
		SELECT p.LinkId
		, CASE WHEN h.TransType < 0 
			THEN ISNULL(h.OrgInvcNum, ISNULL(h.InvcNum, l.DefaultInvoiceNumber)) 
			ELSE ISNULL(h.InvcNum, l.DefaultInvoiceNumber)
		END AS InvcNum 
		FROM #PostTransList l
		INNER JOIN dbo.tblArTransHeader h on l.TransId = h.TransId
		INNER JOIN dbo.tblArTransPmt p on h.TransId = p.TransId
		WHERE p.PostedYn = 0 --unposted only
	) tmp 
	WHERE RcptHeaderID = tmp.LinkId

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArTransPost_LinkedPayment_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArTransPost_LinkedPayment_proc';

