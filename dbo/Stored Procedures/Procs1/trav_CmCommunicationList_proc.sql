
CREATE PROCEDURE dbo.trav_CmCommunicationList_proc

AS
BEGIN TRY
	SET NOCOUNT ON

	-- Communication resultset
	SELECT BCType AS [Type], Descr AS [Description], [Subject], [FileName], Body 
	FROM #tmpCommunicationList t 
		INNER JOIN dbo.tblCmBulkComm c ON t.CommunicationID = c.ID 

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_CmCommunicationList_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_CmCommunicationList_proc';

