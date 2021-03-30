
CREATE PROCEDURE dbo.trav_DbCmMyTasks_proc
@UserId pUserID = '', 
@View tinyint -- 0 = Assigned to me, 1 = Entered by me, 2 = Assigned To/Entered By Me

AS
BEGIN TRY
	SET NOCOUNT ON
	--DECLARE @HighestPermission tinyint
	
	--SET @UserId = LOWER(@UserId)

	--SELECT TOP 1 @HighestPermission = MIN(TaskPermission)
	--FROM dbo.tblCmUserPermission
	--WHERE LOWER(UserId) = @UserId
	--GROUP BY UserId

	--IF @View = 3 AND @HighestPermission > 0
	--	SET @View = 2
	--TODO:Uncoment for CRM Enhacements

	SELECT d.Descr AS TaskType, h.Descr AS [Description], h.ActionDate AS DueDate, h.[Status]
		, CASE h.[Priority] WHEN 2 THEN 0 WHEN 0 THEN 1 ELSE 2 END AS [Priority]
		, h.UserId, h.AssignedToUserID, h.ID AS TaskId 
	FROM dbo.tblCmTask h 
		LEFT JOIN dbo.tblCmTaskType d ON h.TaskTypeID = d.ID
	WHERE [Status] <> 5 AND [Status] <> 2 
		AND ((h.AssignedToUserID = @UserId AND (@View = 0 OR @View = 2)) 
			OR (h.UserID = @UserId AND (@View = 1 OR @View = 2)) 
			OR (@UserId = ''))

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DbCmMyTasks_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DbCmMyTasks_proc';

