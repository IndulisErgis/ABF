
CREATE PROCEDURE dbo.trav_SvWorkToDoDescriptionsList_proc

AS
BEGIN TRY
	SET NOCOUNT ON

-- creating temp table for testing (will remove once testing is completed)
--DROP TABLE #tmpWorkToDoList
--CREATE TABLE #tmpWorkToDoList(WorkToDoID nvarchar(11) NOT NULL PRIMARY KEY CLUSTERED (WorkToDoID))
--INSERT INTO #tmpWorkToDoList (WorkToDoID) SELECT WorkToDoID FROM dbo.tblSvWorkToDo --{0}

	-- Work To Do resultset
	SELECT w.WorkToDoID, [Description], LaborCode, EstimatedTime / 3600.00 AS EstimatedTime, RequiredSkillLevel 
	FROM #tmpWorkToDoList tmp 
		INNER JOIN dbo.tblSvWorkToDo w ON w.WorkToDoID = tmp.WorkToDoID

	-- Members resultset
	SELECT r.WorkToDoID, r.RelationID AS MemberID, wr.[Description] AS MemberName
		, wr.LaborCode AS LaborCodeMember, wr.EstimatedTime / 3600.00 AS EstimatedTimeMember
		, wr.RequiredSkillLevel AS RequiredSkillLevelMember 
	FROM #tmpWorkToDoList tmp 
		INNER JOIN dbo.tblSvWorkToDo w ON w.WorkToDoID = tmp.WorkToDoID 
		INNER JOIN dbo.tblSvWorkToDoRelation r ON w.WorkToDoID = r.WorkToDoID 
		LEFT JOIN dbo.tblSvWorkToDo wr ON wr.WorkToDoID = r.RelationID

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SvWorkToDoDescriptionsList_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SvWorkToDoDescriptionsList_proc';

