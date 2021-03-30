

CREATE PROCEDURE [dbo].[trav_SvScheduledTechnicianView_proc]
@Date as DateTime = NULL
AS
SET NOCOUNT ON
BEGIN TRY
-- direct schedules
SELECT  a.TechID,a.ActivityDateTime Scheduled,w.WorkOrderNo,CONVERT(decimal(28,2), CONVERT(decimal(28,2), ISNULL(sub.Duration, 0))/3600) AS Duration,d.DispatchNo,d.Status
                ,w.CustID,w.SiteID,w.PostalCode,w.ID,t.LocID ,e.FirstName,e.LastName, d.[Priority], ats.Description AS ActivityDispatchStatus
				FROM dbo.tblSvWorkOrder w
                INNER JOIN dbo.tblSvWorkOrderDispatch d ON d.WorkOrderID = w.ID
                INNER JOIN dbo.tblSvWorkOrderActivity a ON  a.DispatchID = d.ID
				INNER JOIN  #TechnicianList f ON a.TechID = f.TechID							
                INNER JOIN dbo.tblSvTechnician t ON f.TechID = t.TechID
                LEFT JOIN dbo.tblSmEmployee e ON t.TechID = e.EmployeeId
				LEFT JOIN dbo.tblSvActivityStatus ats ON d.StatusID = ats.ID	
                INNER JOIN (SELECT wd.ID DispatchID,(wd.EstTravel + SUM(ISNULL(wdt.EstimatedTime,0))) Duration
                FROM dbo.tblSvWorkOrderDispatch wd LEFT JOIN dbo.tblSvWorkOrderDispatchWorkToDo wdt ON wd.ID = wdt.DispatchID
                GROUP BY wd.ID,wd.EstTravel) sub ON sub.DispatchID = d.ID  
WHERE d.CancelledYN = 0 -- Dispatch not cancelled
                AND a.ActivityType = 1 -- Activity Type is schedule
                AND (convert(datetime, convert(varchar(10), a.ActivityDateTime, 101))  = @Date or @Date is null)

UNION
-- crew member schedules
SELECT tech.RelationID TechID,a.ActivityDateTime Scheduled,w.WorkOrderNo,CONVERT(decimal(28,2), CONVERT(decimal(28,2), ISNULL(sub.Duration, 0))/3600) AS Duration,d.DispatchNo,d.Status
                ,w.CustID,w.SiteID,w.PostalCode,w.ID,t.LocID ,e.FirstName,e.LastName, d.[Priority], ats.Description AS ActivityDispatchStatus
				FROM dbo.tblSvWorkOrder w
                INNER JOIN dbo.tblSvWorkOrderDispatch d ON d.WorkOrderID = w.ID
                INNER JOIN dbo.tblSvWorkOrderActivity a ON  a.DispatchID = d.ID

				INNER JOIN (Select tr.RelationID, tr.TechID FROM  #TechnicianList f
								INNER JOIN dbo.tblSvTechnicianRelation tr ON f.TechID = tr.RelationID) tech
				ON a.TechID = tech.TechID
                INNER JOIN dbo.tblSvTechnician t ON tech.TechID = t.TechID
                LEFT JOIN dbo.tblSmEmployee e ON tech.TechID = e.EmployeeId
				LEFT JOIN dbo.tblSvActivityStatus ats ON d.StatusID = ats.ID
                INNER JOIN (SELECT wd.ID DispatchID,(wd.EstTravel + SUM(ISNULL(wdt.EstimatedTime,0))) Duration
                FROM dbo.tblSvWorkOrderDispatch wd LEFT JOIN dbo.tblSvWorkOrderDispatchWorkToDo wdt ON wd.ID = wdt.DispatchID
                GROUP BY wd.ID,wd.EstTravel) sub ON sub.DispatchID = d.ID  
WHERE d.CancelledYN = 0 -- Dispatch not cancelled
                AND a.ActivityType = 1 -- Activity Type is schedule
                AND (convert(datetime, convert(varchar(10), a.ActivityDateTime, 101))  = @Date or @Date is null)



END TRY
BEGIN CATCH
EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SvScheduledTechnicianView_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SvScheduledTechnicianView_proc';

