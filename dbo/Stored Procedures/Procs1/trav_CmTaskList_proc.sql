
CREATE PROCEDURE dbo.trav_CmTaskList_proc
@ViewNotes bit = 1

AS
BEGIN TRY
	SET NOCOUNT ON

	-- Task resultset
	SELECT h.ID AS TaskID, h.[Status], CONVERT(nvarchar(8), h.ActionDate, 112) AS DueDateSort
		, d.Descr AS TaskType, h.Descr AS [Description], h.AssignedToUserId AS AssignedTo
		, h.StartDate, h.ActionDate AS DueDate, h.[Priority], h.EntryDate, h.CompletedDate
		, h.UserId AS EnteredBy, h.CompletedByUserId AS CompletedBy, c.ContactName AS Contact
		, CASE WHEN @ViewNotes <> 0 THEN h.Notes ELSE NULL END AS Notes 
	FROM #TaskList t 
		INNER JOIN dbo.tblCmTask h ON t.TaskID = h.ID 
		LEFT JOIN dbo.tblCmTaskType d ON h.TaskTypeID = d.ID
		LEFT JOIN dbo.tblCmContact c ON h.ContactID = c.ID

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_CmTaskList_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_CmTaskList_proc';

