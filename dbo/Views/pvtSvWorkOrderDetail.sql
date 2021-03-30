
CREATE VIEW dbo.pvtSvWorkOrderDetail
AS

SELECT o.CustID AS [Customer ID], c.CustName AS [Customer Name], o.WorkOrderNo AS [Order No]
	, d.DispatchNo AS [Dispatch No]
	, CASE d.[Status] 
		WHEN 0 THEN 'Open' 
		WHEN 1 THEN 'Completed' 
		WHEN 2 THEN 'Billed' 
		WHEN 3 THEN 'Posted' 
		ELSE 'NA' END AS [Dispatch Status]
	, d.CancelledYN AS [Cancelled], d.HoldYN AS [Hold], todo.[Description] AS [Work To Do]
	, CONVERT(decimal(20, 2), todo.EstTime) / 3600 AS [Estimated Time (Hrs)]
	, ISNULL(d.RequestedTechID, 'NA') AS [Requested Tech]
	, ISNULL(r.TechID, 'NA') AS [Scheduled Tech]
	, r.ActivityDateTime AS [Scheduled Date]
	, CASE WHEN d.SchedApproved = 0 THEN 'Approved' ELSE 'Not Approved' END AS [Schedule Approved] 
FROM dbo.tblSvWorkOrder o 
	INNER JOIN dbo.tblSvWorkOrderDispatch d ON o.ID = d.WorkOrderID 
	INNER JOIN dbo.tblArCust c ON o.CustID = c.CustID 
	LEFT JOIN 
	( 
		SELECT WorkOrderID, DispatchID, [Description], EstimatedTime AS EstTime 
		FROM dbo.tblSvWorkOrderDispatchWorkToDo 
	) todo 
		ON todo.DispatchID = d.ID 
	LEFT JOIN 
	(
		SELECT DispatchID, ActivityDateTime, TechID FROM tblSvWorkOrderActivity WHERE ID IN
		(
			SELECT MAX(ID) AS ID 
			FROM dbo.tblSvWorkOrderActivity WHERE ActivityType = 1 
			GROUP BY DispatchID
		)
	) r 
		ON d.ID = r.DispatchID
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtSvWorkOrderDetail';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtSvWorkOrderDetail';

