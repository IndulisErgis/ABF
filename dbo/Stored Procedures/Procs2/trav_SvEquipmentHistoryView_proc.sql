
CREATE PROCEDURE [dbo].[trav_SvEquipmentHistoryView_proc]
AS
SET NOCOUNT ON
BEGIN TRY

select * from
		( SELECT e.EquipmentNo,e.Description,e.ItemID,e.[Status] as EquipmentStatus,e.SerialNumber,e.TagNumber,e.Manufacturer,e.Model,e.CategoryID
		,d.[Status],e.Usage,e.ServiceContractCharge,e.[Ownership],e.AssetID,e.GLAcctExpense ,w.ID AS WorkOrderId,w.WorkOrderNo,e.CustID ,e.SiteID
		,w.Attention,w.Address1,w.Address2,w.City,w.Region,w.PostalCode,w.Country,w.Phone1,w.Phone2,w.Phone3,w.Email,w.Internet,w.Rep1Id,w.Rep1Pct,w.Rep1CommRate,w.Rep2Id
		,w.Rep2Pct,w.Rep2CommRate,w.FixedPrice,w.BillByWorkOrder,w.BillingType OrderBillingType,w.TerrId,w.OriginalWorkOrder,w.CustomerPoNumber,w.PODate ,proj.ProjectName
		,proj.PhaseId,proj.TaskId,d.DispatchNo,d.Description AS DispatchDescription,e.EquipmentNo EquipmentID,d.EquipmentDescription,d.BillingType DispatchBillingType
		,d.BillToID,CONVERT(decimal(20,2),d.EstTravel)/3600 EstTravel ,CONVERT(decimal(20,2),d.EstTravel + ISNULL(todo.EstTime, 0))/3600 TotalEst ,d.Counter,d.LocID,d.EntryDate
		,d.STATUS AS DispatchStatus,d.HoldYN AS Hold ,d.RequestedDate ,d.RequestedAMPM,d.RequestedTechID,d.CancelledYN AS Cancelled,a.ActivityDate AS CompletedDate
		,NULL AS OrderPostRun,d.PostRun AS DispatchPostRun 
		FROM dbo.tblSvWorkOrder w  INNER JOIN dbo.tblSvWorkOrderDispatch d ON w.ID = d.WorkOrderID INNER JOIN #EquipmentList e1 ON e1.ID = d.EquipmentID
		INNER JOIN dbo.tblSvEquipment e ON e.ID = e1.ID
		LEFT JOIN ( SELECT WorkOrderID ,DispatchId,MAX(ActivityDateTime) ActivityDate FROM dbo.tblSvWorkOrderActivity WHERE ActivityType = 4 GROUP BY WorkOrderID ,DispatchID ) a ON a.WorkOrderID = w.ID AND a.DispatchID = d.ID
		LEFT JOIN ( SELECT WorkOrderID,DispatchID,SUM(EstimatedTime) EstTime FROM dbo.tblSvWorkOrderDispatchWorkToDo GROUP BY WorkOrderID,DispatchID) todo ON todo.WorkOrderID = w.ID AND todo.DispatchID = d.ID
		LEFT JOIN ( SELECT pd.Id, pd.ProjectId,pc.CustId,pc.ProjectName,pd.PhaseId,pd.TaskId FROM dbo.tblPcProject pc LEFT JOIN dbo.tblPcProjectDetail pd on pc.Id = pd.ProjectId ) proj on proj.Id= w.ProjectDetailID and proj.CustId = w.CustID
		UNION ALL
		Select e.EquipmentNo,e.Description,e.ItemID,e.[Status] as EquipmentStatus,e.SerialNumber,e.TagNumber,e.Manufacturer,e.Model,e.CategoryID
		,e.[Status],e.Usage,e.ServiceContractCharge,e.[Ownership],e.AssetID,e.GLAcctExpense , hw.ID as WorkOrderId,hw.WorkOrderNo,e.CustID,e.SiteID
		,hw.Attention,hw.Address1,hw.Address2,hw.City,hw.Region,hw.PostalCode, hw.Country,hw.Phone1,hw.Phone2,hw.Phone3,hw.Email,hw.Internet,hw.Rep1Id,hw.Rep1Pct,hw.Rep1CommRate,hw.Rep2Id
		,hw.Rep2Pct, hw.Rep2CommRate,hw.FixedPrice ,hw.BillByWorkOrder,hw.BillingType,hw.TerrId,hw.OriginalWorkOrder,hw.CustomerPoNumber,hw.PODate,hw.ProjectID
		, hw.PhaseId, hw.TaskId,hd.DispatchNo,hd.Description as DispatchDescription,e.EquipmentNo,hd.EquipmentDescription,hd.BillingType
		,hd.BillToID,CONVERT(decimal(20,2),hd.EstTravel)/3600 EstTravel,CONVERT(decimal(20,2),hd.EstTravel + ISNULL(todo.EstTime, 0))/3600 TotalEst,hd.Counter,hd.LocID,hd.EntryDate,3 as Status,CAST(0 as bit) as Hold,hd.RequestedDate,hd.RequestedAMPM,hd.RequestedTechID,hd.CancelledYN as Cancelled,a.ActivityDate as CompletedDate
		,hw.PostRun as OrderPostRun,hd.PostRun as DispatchPostRun 
		FROM dbo.tblSvHistoryWorkOrder hw INNER JOIN dbo.tblSvHistoryWorkOrderDispatch hd ON hw.ID = hd.WorkOrderID INNER JOIN #EquipmentList e1 ON e1.ID = hd.EquipmentID
		INNER JOIN dbo.tblSvEquipment e ON e.ID = e1.ID
		LEFT JOIN ( SELECT WorkOrderID,DispatchId, MAX(ActivityDateTime) ActivityDate from dbo.tblSvHistoryWorkOrderActivity where ActivityType = 4 group by WorkOrderID,DispatchID) a on a.WorkOrderID = hw.ID and a.DispatchID = hd.ID
		left join (select WorkOrderID ,SUM(EstimatedTime) EstTime FROM dbo.tblSvHistoryWorkOrderDispatchWorkToDo Group by WorkOrderID ) todo on todo.WorkOrderID = hw.ID
		left join (select pc.Id, pc.CustId,pc.ProjectName from dbo.tblPcProject pc LEFT JOIN dbo.tblPcProjectDetail pd on pc.Id = pd.ProjectId) proj on proj.ProjectName = hw.ProjectID and proj.CustId = hw.CustID ) ds
END TRY
BEGIN CATCH
EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SvEquipmentHistoryView_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SvEquipmentHistoryView_proc';

