
CREATE PROCEDURE dbo.trav_PsTransPost_RemoveCount_proc
AS
BEGIN TRY
	DELETE dbo.tblPsCountDetail
	FROM dbo.tblPsCountDetail INNER JOIN dbo.tblPsCountHeader h ON dbo.tblPsCountDetail.CountID = h.ID 
		INNER JOIN #PsHostList t ON h.HostID = t.HostID
	WHERE h.ClosingDate IS NOT NULL AND h.Synched = 1

	DELETE dbo.tblPsCountExchangeRate
	FROM dbo.tblPsCountExchangeRate INNER JOIN dbo.tblPsCountHeader h ON dbo.tblPsCountExchangeRate.CountID = h.ID 
		INNER JOIN #PsHostList t ON h.HostID = t.HostID
	WHERE h.ClosingDate IS NOT NULL AND h.Synched = 1

	DELETE dbo.tblPsCountHeader
	FROM dbo.tblPsCountHeader INNER JOIN #PsHostList t ON tblPsCountHeader.HostID = t.HostID
	WHERE dbo.tblPsCountHeader.ClosingDate IS NOT NULL AND dbo.tblPsCountHeader.Synched = 1

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PsTransPost_RemoveCount_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PsTransPost_RemoveCount_proc';

