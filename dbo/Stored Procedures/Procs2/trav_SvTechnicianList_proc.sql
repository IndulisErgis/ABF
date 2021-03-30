
CREATE PROCEDURE dbo.trav_SvTechnicianList_proc
@IncludeTechnicianRelations bit = 1

AS
BEGIN TRY
	SET NOCOUNT ON
-- creating temp table for testing (will remove once testing is completed)
--DROP TABLE #tmpTechnicianList
--CREATE TABLE #tmpTechnicianList([TechID] nvarchar(11) NOT NULL PRIMARY KEY CLUSTERED ([TechID]))
--INSERT INTO #tmpTechnicianList (TechID) 
--SELECT TechID FROM 
--(
-- SELECT t.TechID, t.ScheduleID, t.LocID
--  , COALESCE(e.FirstName, '') + ' ' + COALESCE(e.MiddleInit, '') + ' ' + COALESCE(e.LastName, '') AS TechName 
-- FROM dbo.tblSvTechnician t 
--  LEFT JOIN dbo.tblSmEmployee e ON t.TechID = e.EmployeeId 
--) tmp --{0}

	-- Technician resultset
	SELECT t.TechID
		, COALESCE(s.FirstName, '') + ' ' + COALESCE(s.MiddleInit, '') + ' ' + COALESCE(s.LastName, '') AS TechName
		, t.ScheduleID, t.LocID 
	FROM #tmpTechnicianList tmp 
		INNER JOIN dbo.tblSvTechnician t ON t.TechID = tmp.TechID 
		LEFT JOIN dbo.tblSmEmployee s ON t.TechID = s.EmployeeId

	-- Labor Code resultset
	SELECT tmp.TechID, l.LaborCode, c.[Description] AS LaborCodeDescription
		, l.SkillLevel, s.[Description] AS SkillLevelDescription 
	FROM #tmpTechnicianList tmp 
		INNER JOIN dbo.tblSvTechnicianLaborCode l ON tmp.TechID = l.TechID 
		LEFT JOIN dbo.tblSvLaborCode c ON l.LaborCode = c.LaborCode 
		LEFT JOIN dbo.tblSvSkill s ON l.SkillLevel = s.SkillLevel

	-- Members resultset
	SELECT r.TechID, r.RelationID AS MemberID
		, COALESCE(s.FirstName, '') + ' ' + COALESCE(s.MiddleInit, '') + ' ' + COALESCE(s.LastName, '') AS MemberName 
	FROM #tmpTechnicianList tmp 
		INNER JOIN dbo.tblSvTechnicianRelation r ON tmp.TechID = r.TechID 
		LEFT JOIN dbo.tblSmEmployee s ON r.RelationID = s.EmployeeId 
	WHERE @IncludeTechnicianRelations <> 0

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SvTechnicianList_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SvTechnicianList_proc';

