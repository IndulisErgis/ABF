       CREATE VIEW [dbo].[trav_tblSvTechnician_view] 
       AS 
       SELECT TechID,ScheduleId,LocId,COALESCE(e.FirstName, '') + ' ' + COALESCE(e.MiddleInit, '') + ' ' + COALESCE(e.LastName, '') AS TechName,e.FirstName, e.LastName FROM dbo.tblSvTechnician 
       INNER JOIN dbo.tblSmEmployee e 
       ON TechID = e.EmployeeId
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_tblSvTechnician_view';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_tblSvTechnician_view';

