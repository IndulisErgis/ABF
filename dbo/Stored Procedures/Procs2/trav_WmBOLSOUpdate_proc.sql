
CREATE PROCEDURE [dbo].[trav_WmBOLSOUpdate_proc]
@BOLRef Int
AS
BEGIN TRY

UPDATE dbo.tblSoTransDetail SET BOLNum = h.BOLNum
FROM dbo.tblSoTransDetail 
	INNER JOIN dbo.tblWmBOLDetail t ON dbo.tblSoTransDetail.TransId = t.TransId 
	AND dbo.tblSoTransDetail.EntryNum = t.EntryNum 
	INNER JOIN dbo.tblWmBOLHeader h ON h.BOLRef = t.BOLRef 
WHERE h.BOLRef = @BOLRef

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_WmBOLSOUpdate_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_WmBOLSOUpdate_proc';

