
CREATE PROCEDURE dbo.trav_SvGetUnscheduledWorkOrders_proc
AS
SET NOCOUNT ON
BEGIN TRY

	SELECT 
		wo.ID AS WorkOrderID, wo.WorkOrderNo, dis.ID AS DispatchID, dis.DispatchNo
		, dis.[Description] AS DispatchDescription, wo.CustID, wo.SiteID, eq.EquipmentNo
		, dis.RequestedAMPM, dis.RequestedDate, dis.RequestedTechID
		, wo.Address1, wo.City, wo.Region, wo.PostalCode, dis.[Priority], dis.[Status] AS DispatchStatus
		, a.[Description] AS ActivityStatusDescr
	FROM dbo.tblSvWorkOrder wo 
		LEFT JOIN dbo.tblArCust c ON wo.CustID = c.CustId 
		LEFT JOIN dbo.tblSvWorkOrderDispatch dis ON wo.ID = dis.WorkOrderID 
		LEFT JOIN dbo.tblSvEquipment eq ON dis.EquipmentID = eq.ID 
		LEFT JOIN 
			(SELECT WorkOrderID, DispatchID FROM dbo.tblSvWorkOrderActivity WHERE ActivityType IN (1)) act 
			ON act.WorkOrderID = wo.ID AND act.DispatchID = dis.ID 
		LEFT JOIN dbo.tblSvActivityStatus a ON dis.StatusID = a.ID
	WHERE (wo.CustID IS NULL OR (c.[Status] = 0 AND c.[CreditHold] = 0)) 
		AND dis.[Status] IN (0) AND dis.CancelledYN = 0 AND act.DispatchID IS NULL	
	
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SvGetUnscheduledWorkOrders_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SvGetUnscheduledWorkOrders_proc';

